import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../models/himx_role.dart';
import '../models/himx_user_role.dart';
import 'character_settings_page.dart';
import 'dating_page.dart';
import '../theme/app_theme.dart';
import '../services/himx_api.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentCarouselIndex = 0;

  final HimxApi _himxApi = HimxApi();

  bool _isLoading = true;
  String? _errorMessage;

  List<HimxUserRole> _myRoles = [];
  List<HimxRole> _recommendedRoles = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([_himxApi.getMyRoles(), _himxApi.getRecommendedRoles()]);

      final myRoles = results[0] as List<HimxUserRole>;
      final recommended = results[1] as List<HimxRole>;

      if (!mounted) return;
      setState(() {
        _myRoles = myRoles;
        _recommendedRoles = recommended;
        _isLoading = false;
      });

      // If user already has roles, default to "我的约会"
      if (_myRoles.isNotEmpty) {
        _tabController.animateTo(0);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = '$e';
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      body: Container(
        decoration: const BoxDecoration(color: AppTheme.pageBackground),
        child: SafeArea(
          child: Column(
            children: [
              // 顶部标题
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('Date Him', style: AppTheme.titleTextStyle),
              ),

              // Tab 栏
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                  color: AppTheme.unselectedBackground,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: AppTheme.selectedBackground,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.shadowOverlay.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: AppTheme.titleText,
                  unselectedLabelColor: AppTheme.bodyText.withValues(alpha: 0.6),
                  labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('我的约会'),
                          if (_myRoles.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(left: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.shadowOverlay,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${_myRoles.length}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.buttonText,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Tab(text: '发现更多'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Tab 内容
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : (_errorMessage != null)
                    ? _buildErrorState()
                    : TabBarView(controller: _tabController, children: [_buildMyDatingsTab(), _buildDiscoverTab()]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, color: AppTheme.shadowOverlay, size: 64),
            const SizedBox(height: 16),
            const Text(
              '加载失败',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.titleText),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? '',
              style: TextStyle(color: AppTheme.bodyText.withValues(alpha: 0.7)),
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadHomeData,
              style: AppTheme.primaryButtonStyle(),
              child: const Text('重试', style: AppTheme.buttonTextStyle),
            ),
          ],
        ),
      ),
    );
  }

  // 我的约会 Tab
  Widget _buildMyDatingsTab() {
    if (_myRoles.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _myRoles.length,
      itemBuilder: (context, index) {
        final item = _myRoles[index];
        return _buildDatingCard(item);
      },
    );
  }

  // 空状态页面
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(color: AppTheme.unselectedBackground, shape: BoxShape.circle),
            child: Icon(Icons.favorite_border, size: 80, color: AppTheme.shadowOverlay),
          ),
          const SizedBox(height: 30),
          const Text(
            '还没有开始约会哦',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.titleText),
          ),
          const SizedBox(height: 12),
          const Text('去发现心仪的他吧', style: TextStyle(fontSize: 16, color: AppTheme.bodyText)),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              _tabController.animateTo(1); // 切换到"发现更多" Tab
            },
            icon: const Icon(Icons.explore),
            label: const Text('去发现'),
            style: AppTheme.primaryButtonStyle(),
          ),
        ],
      ),
    );
  }

  // 正在约会的卡片
  Widget _buildDatingCard(HimxUserRole dating) {
    final lastMessage = '继续你们的约会吧～';
    final unreadCount = 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppTheme.unselectedBoxDecoration(borderRadius: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            _openDating(dating);
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // 角色头像
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    dating.imageUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey.shade800,
                        child: const Icon(Icons.person, color: Colors.grey),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // 消息内容
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 角色名称（如果用户设置了nickname则显示nickname）
                      Text(
                        dating.nickname.isNotEmpty ? dating.nickname : dating.name,
                        style: const TextStyle(color: AppTheme.titleText, fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // 最后一条消息
                      Text(
                        lastMessage,
                        style: const TextStyle(color: AppTheme.bodyText, fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // 未读消息徽章
                if (unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppTheme.shadowOverlay, borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      unreadCount > 99 ? '99+' : '$unreadCount',
                      style: const TextStyle(color: AppTheme.buttonText, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openDating(HimxUserRole userRole) {
    final role = HimxRole(
      id: userRole.id,
      roleId: userRole.roleId,
      name: userRole.name,
      imageUrl: userRole.imageUrl,
      videoUrl: userRole.videoUrl,
      description: userRole.description,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DatingPage(
          role: role,
          nickname: userRole.nickname,
          personality: userRole.personality,
          userNickname: userRole.userNickname,
        ),
      ),
    );
  }

  // 发现更多 Tab
  Widget _buildDiscoverTab() {
    if (_recommendedRoles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, color: AppTheme.shadowOverlay, size: 64),
            const SizedBox(height: 12),
            const Text(
              '暂时没有推荐角色',
              style: TextStyle(color: AppTheme.titleText, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadHomeData,
              style: AppTheme.primaryButtonStyle(),
              child: const Text('刷新', style: AppTheme.buttonTextStyle),
            ),
          ],
        ),
      );
    }

    return Center(
      child: CarouselSlider.builder(
        itemCount: _recommendedRoles.length,
        itemBuilder: (context, index, realIndex) {
          final boyfriend = _recommendedRoles[index];
          final isSelected = index == _currentCarouselIndex;
          return _buildBoyfriendCard(boyfriend, isSelected);
        },
        options: CarouselOptions(
          height: 500,
          enlargeCenterPage: true,
          enableInfiniteScroll: true,
          autoPlay: false,
          viewportFraction: 0.7,
          onPageChanged: (index, reason) {
            setState(() {
              _currentCarouselIndex = index;
            });
          },
        ),
      ),
    );
  }

  Widget _buildBoyfriendCard(HimxRole boyfriend, bool isSelected) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.titleText, width: 8),
              boxShadow: isSelected
                  ? [
                      BoxShadow(color: AppTheme.shadowOverlay.withValues(alpha: 0.6), blurRadius: 20, spreadRadius: 4),
                      BoxShadow(
                        color: AppTheme.selectedBackground.withValues(alpha: 0.5),
                        blurRadius: 30,
                        spreadRadius: 6,
                      ),
                    ]
                  : [BoxShadow(color: AppTheme.bodyText.withValues(alpha: 0.3), blurRadius: 12, spreadRadius: 2)],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                boyfriend.imageUrl,
                height: 360,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 360,
                    color: Colors.grey.shade800,
                    child: const Icon(Icons.person, size: 100, color: Colors.grey),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CharacterSettingsPage(role: boyfriend)));
            },
            style: AppTheme.primaryButtonStyle(),
            child: const Text('Date with him', style: AppTheme.buttonTextStyle),
          ),
        ],
      ),
    );
  }
}
