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

class _HomePageState extends State<HomePage> {
  int _currentTabIndex = 1;
  int _currentCarouselIndex = 0;

  final HimxApi _himxApi = HimxApi();

  bool _isLoading = true;
  String? _errorMessage;

  List<HimxUserRole> _myRoles = [];
  List<HimxRole> _recommendedRoles = [];

  @override
  void initState() {
    super.initState();
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

      // If user already has roles, default to "My Dates"
      if (_myRoles.isNotEmpty) {
        setState(() {
          _currentTabIndex = 0;
        });
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.pageBackground,
              AppTheme.pageBackground.withValues(alpha: 0.95),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top title
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('Date Him', style: AppTheme.titleTextStyle),
              ),

              // Content area
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.selectedBackground))
                    : (_errorMessage != null)
                        ? _buildErrorState()
                        : _currentTabIndex == 0
                            ? _buildMyDatingsTab()
                            : _buildDiscoverTab(),
              ),
            ],
          ),
        ),
      ),
      // Bottom navigation bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.unselectedBackground.withValues(alpha: 0.9),
          border: const Border(
            top: BorderSide(
              color: Color(0xFF7B4EFF),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentTabIndex,
          onTap: (index) {
            setState(() {
              _currentTabIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppTheme.selectedBackground,
          unselectedItemColor: AppTheme.bodyText.withValues(alpha: 0.5),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.favorite),
              label: 'My Dates',
              tooltip: 'My Dates (${_myRoles.length})',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.explore),
              label: 'Discover',
              tooltip: 'Discover',
            ),
          ],
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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.unselectedBackground.withValues(alpha: 0.5),
                    AppTheme.unselectedBackground.withValues(alpha: 0.2),
                  ],
                ),
              ),
              child: const Icon(Icons.wifi_off, color: AppTheme.shadowOverlay, size: 64),
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to Load',
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
              child: const Text('Retry', style: AppTheme.buttonTextStyle),
            ),
          ],
        ),
      ),
    );
  }

  // My Dates Tab
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

  // Empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.unselectedBackground,
                  AppTheme.unselectedBackground.withValues(alpha: 0.6),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowOverlay.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(Icons.favorite_border, size: 80, color: AppTheme.shadowOverlay),
          ),
          const SizedBox(height: 30),
          const Text(
            'No Dates Yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.titleText),
          ),
          const SizedBox(height: 12),
          const Text('Discover someone special', style: TextStyle(fontSize: 16, color: AppTheme.bodyText)),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _currentTabIndex = 1; // Switch to "Discover" Tab
              });
            },
            icon: const Icon(Icons.explore),
            label: const Text('Discover'),
            style: AppTheme.primaryButtonStyle(),
          ),
        ],
      ),
    );
  }

  // Dating card
  Widget _buildDatingCard(HimxUserRole dating) {
    final lastMessage = 'Continue your date~';
    final unreadCount = 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.unselectedBackground.withValues(alpha: 0.6),
            AppTheme.unselectedBackground.withValues(alpha: 0.3),
          ],
        ),
        border: Border.all(
          color: AppTheme.selectedBackground.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowOverlay.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            _openDating(dating);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar with 3:4 aspect ratio
                Container(
                  width: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.selectedBackground.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        dating.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade800,
                            child: const Icon(Icons.person, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Message content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Role name (show nickname if set)
                      Text(
                        dating.nickname.isNotEmpty ? dating.nickname : dating.name,
                        style: const TextStyle(color: AppTheme.titleText, fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Last message
                      Text(
                        lastMessage,
                        style: const TextStyle(color: AppTheme.bodyText, fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Unread badge
                if (unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.shadowOverlay,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.shadowOverlay.withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
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

  // Discover Tab
  Widget _buildDiscoverTab() {
    if (_recommendedRoles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, color: AppTheme.shadowOverlay, size: 64),
            const SizedBox(height: 12),
            const Text(
              'No Recommendations',
              style: TextStyle(color: AppTheme.titleText, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadHomeData,
              style: AppTheme.primaryButtonStyle(),
              child: const Text('Refresh', style: AppTheme.buttonTextStyle),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppTheme.selectedBackground : AppTheme.titleText,
                  width: 8,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.shadowOverlay.withValues(alpha: 0.6),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                        BoxShadow(
                          color: AppTheme.selectedBackground.withValues(alpha: 0.4),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: AppTheme.bodyText.withValues(alpha: 0.15),
                          blurRadius: 12,
                          spreadRadius: 0,
                        )
                      ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  children: [
                    Image.network(
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
                    if (isSelected)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                AppTheme.shadowOverlay.withValues(alpha: 0.2),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CharacterSettingsPage(role: boyfriend)));
              },
              style: AppTheme.primaryButtonStyle(
                borderRadius: 25,
              ),
              child: const Text('Date with him', style: AppTheme.buttonTextStyle),
            ),
          ],
        ),
      ),
    );
  }
}
