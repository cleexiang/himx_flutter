import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../models/boyfriend.dart';
import 'character_settings_page.dart';
import 'dating_page.dart';
import '../models/character_settings.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentCarouselIndex = 0;

  // 所有可选角色
  final List<Boyfriend> allBoyfriends = [
    Boyfriend(
      id: '1',
      name: '温柔绅士',
      imageUrl:
          'https://uonxglfnzhafyypynuug.supabase.co/storage/v1/object/public/datehim/cbwbs34p0hrme0ctqxatvfnsx0.jpg',
      description: '温柔体贴的绅士型男友',
    ),
    Boyfriend(
      id: '2',
      name: '霸道总裁',
      imageUrl:
          'https://uonxglfnzhafyypynuug.supabase.co/storage/v1/object/public/datehim/qw01rrvd5rm80ctr3gak2pbf0.jpg',
      description: '强势霸道的总裁型男友',
    ),
    Boyfriend(
      id: '3',
      name: '阳光男孩',
      imageUrl:
          'https://uonxglfnzhafyypynuug.supabase.co/storage/v1/object/public/datehim/8bch7xhqhnrme0ctr3h9egzmvr.jpg',
      description: '活力四射的阳光大男孩',
    ),
    Boyfriend(
      id: '4',
      name: '阳光男孩',
      imageUrl:
          'https://uonxglfnzhafyypynuug.supabase.co/storage/v1/object/public/datehim/89emyqj2hnrmc0ctr3ftkpkat0.jpg',
      description: '活力四射的阳光大男孩',
    ),
  ];

  // 正在约会的角色列表（模拟数据，实际应该从本地存储或服务器获取）
  final List<Map<String, dynamic>> activeDatings = [
    // 示例：已经开始约会的角色
    // {
    //   'boyfriend': Boyfriend(...),
    //   'settings': CharacterSettings(...),
    //   'lastMessage': '你好呀~',
    //   'unreadCount': 2,
    // }
  ];

  @override
  void initState() {
    super.initState();
    // 如果有正在约会的角色，默认显示"我的约会"，否则显示"发现更多"
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: activeDatings.isEmpty ? 1 : 0,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg_home2.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 顶部标题
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Date Him',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black45,
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),

              // Tab 栏
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFD4AF37),
                        Color(0xFFCD7F32),
                      ],
                    ),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
                  labelStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('我的约会'),
                          if (activeDatings.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(left: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.pink,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${activeDatings.length}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
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
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMyDatingsTab(),
                    _buildDiscoverTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 我的约会 Tab
  Widget _buildMyDatingsTab() {
    if (activeDatings.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: activeDatings.length,
      itemBuilder: (context, index) {
        final dating = activeDatings[index];
        return _buildDatingCard(dating);
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
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_border,
              size: 80,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            '还没有开始约会哦',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '去发现心仪的他吧',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              _tabController.animateTo(1); // 切换到"发现更多" Tab
            },
            icon: const Icon(Icons.explore),
            label: const Text('去发现'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCD7F32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 正在约会的卡片
  Widget _buildDatingCard(Map<String, dynamic> dating) {
    final boyfriend = dating['boyfriend'] as Boyfriend;
    final settings = dating['settings'] as CharacterSettings;
    final lastMessage = dating['lastMessage'] as String;
    final unreadCount = dating['unreadCount'] as int;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DatingPage(
                  boyfriend: boyfriend,
                  settings: settings,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // 角色头像
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    boyfriend.imageUrl,
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
                      // 角色名称
                      Text(
                        settings.nickname.isEmpty ? boyfriend.name : settings.nickname,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // 最后一条消息
                      Text(
                        lastMessage,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // 未读消息徽章
                if (unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.pink,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      unreadCount > 99 ? '99+' : '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 发现更多 Tab
  Widget _buildDiscoverTab() {
    return Center(
      child: CarouselSlider.builder(
        itemCount: allBoyfriends.length,
        itemBuilder: (context, index, realIndex) {
          final boyfriend = allBoyfriends[index];
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

  Widget _buildBoyfriendCard(Boyfriend boyfriend, bool isSelected) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.black,
                width: 8, // 更粗的边框
              ),
              boxShadow: isSelected
                  ? [
                      // 外阴影
                      BoxShadow(
                        color: const Color(0xFFCD7F32).withValues(alpha: 0.6),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                        blurRadius: 30,
                        spreadRadius: 6,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
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
          Container(
            decoration: BoxDecoration(
              // 从两边往中间的径向渐变
              gradient: const RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  Color(0xFFF4E4C1), // 中心浅金色
                  Color(0xFFD4AF37), // 金色
                  Color(0xFFCD7F32), // 古铜色
                  Color(0xFFB87333), // 深古铜色
                ],
                stops: [0.0, 0.3, 0.7, 1.0],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                // 外阴影 - 增强立体感
                BoxShadow(
                  color: const Color(0xFFCD7F32).withValues(alpha: 0.6),
                  blurRadius: 12,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
                // 外发光效果
                BoxShadow(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                // 内阴影效果通过叠加层实现
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: -2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // 高光层
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 20,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.4),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // 按钮本体
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CharacterSettingsPage(boyfriend: boyfriend)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Date with him',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          // 文字阴影增强可读性
                          Shadow(
                            color: Colors.black45,
                            offset: Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
