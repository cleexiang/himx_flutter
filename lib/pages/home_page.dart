import 'package:flutter/material.dart';
import '../models/himx_role.dart';
import '../models/himx_user_role.dart';
import '../models/chat_message.dart';
import '../models/community_post.dart';
import 'dating_page.dart';
import '../theme/starry_theme.dart';
import '../services/himx_api.dart';
import 'package:video_player/video_player.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentTabIndex = 0; // Default to Home
  final HimxApi _himxApi = HimxApi();

  bool _isLoading = true;
  String? _errorMessage;

  List<HimxRole> _recommendedRoles = [];
  List<HimxUserRole> _myRoles = [];
  Map<int, ChatMessage?> _lastMessages = {}; // Store last message for each role

  // Community tab state
  List<CommunityPost> _communityPosts = [];
  String? _selectedRoleFilter; // null = 全部
  bool _isLoadingCommunity = false;

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
      // Load recommended roles and my roles in parallel
      final results = await Future.wait([_himxApi.getRecommendedRoles(), _himxApi.getMyRoles()]);

      final recommended = results[0] as List<HimxRole>;
      final myRoles = results[1] as List<HimxUserRole>;

      if (!mounted) return;
      setState(() {
        _recommendedRoles = recommended;
        _myRoles = myRoles;
        _isLoading = false;
      });

      // Load last message for each role asynchronously
      _loadLastMessagesForMyRoles(myRoles);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = '$e';
      });
    }
  }

  Future<void> _loadLastMessagesForMyRoles(List<HimxUserRole> roles) async {
    for (final role in roles) {
      try {
        final messages = await _himxApi.getChatList(roleId: role.id);
        if (!mounted) return;

        // Get the last non-empty message from the list
        ChatMessage? lastMessage;
        for (var i = messages.length - 1; i >= 0; i--) {
          if (messages[i].content.isNotEmpty) {
            lastMessage = messages[i];
            break;
          }
        }

        if (lastMessage != null) {
          setState(() {
            _lastMessages[role.id] = lastMessage;
          });
        }
      } catch (e) {
        debugPrint('Error loading messages for role ${role.id}: $e');
      }
    }
  }

  /// 加载社区数据
  Future<void> _loadCommunityData() async {
    if (_myRoles.isEmpty) return;

    setState(() => _isLoadingCommunity = true);

    try {
      final allPosts = <CommunityPost>[];

      for (final role in _myRoles) {
        // 并行获取约会和换装照片
        final results = await Future.wait([
          _himxApi.getPhotoList(roleId: role.roleId, type: 'dating'),
          _himxApi.getPhotoList(roleId: role.roleId, type: 'outfit'),
        ]);

        final datingPhotos = results[0];
        final outfitPhotos = results[1];

        // 转换为 CommunityPost
        allPosts.addAll(datingPhotos.map((p) => CommunityPost.fromPhoto(p, role, 'dating')));
        allPosts.addAll(outfitPhotos.map((p) => CommunityPost.fromPhoto(p, role, 'outfit')));
      }

      // 按时间倒序排列
      allPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (!mounted) return;
      setState(() {
        _communityPosts = allPosts;
        _isLoadingCommunity = false;
      });
    } catch (e) {
      debugPrint('Error loading community data: $e');
      if (!mounted) return;
      setState(() => _isLoadingCommunity = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background for StarryTheme
      body: SafeArea(
        child: Column(
          children: [
            // Top Header
            _buildTopHeader(),

            // Main Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: StarryTheme.accentPink))
                  : (_errorMessage != null)
                  ? _buildErrorState()
                  : _currentTabIndex == 0
                  ? _buildRecommendedRolesTab()
                  : _currentTabIndex == 1
                  ? _buildMyRolesTab()
                  : _currentTabIndex == 2
                  ? _buildCommunityTab()
                  : const SizedBox(), // Tab 3 placeholder
            ),
          ],
        ),
      ),
      // Bottom navigation bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentTabIndex,
          onTap: (index) {
            setState(() {
              _currentTabIndex = index;
            });
            // 切换到社区 Tab 时加载数据
            if (index == 2 && _communityPosts.isEmpty && !_isLoadingCommunity) {
              _loadCommunityData();
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: StarryTheme.accentPink,
          unselectedItemColor: Colors.white54,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled, size: 28), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble, size: 28), label: 'Discover'),
            BottomNavigationBarItem(icon: Icon(Icons.explore, size: 28), label: 'Chat'),
            BottomNavigationBarItem(icon: Icon(Icons.person, size: 28), label: 'Profile'),
          ],
        ),
      ),
      extendBody: true,
    );
  }

  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // App Name
          const Text(
            'Him X',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'IBMPlexSans', // Assuming this font is available per pubspec
            ),
          ),

          // Right Side: Sub & Points
          Row(
            children: [
              // Subscription Button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)], // Gold gradient
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.star, color: Colors.black, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'PRO',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Points Display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.diamond, color: Colors.cyanAccent, size: 16),
                    SizedBox(width: 4),
                    Text(
                      '1,250', // Mock data
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterPage(HimxRole role) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Image or Video
          CharacterBackground(imageUrl: role.imageUrl, videoUrl: role.videoUrl),

          // 2. Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3), // Light dim at top
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.6), // Darker at bottom
                  Colors.black.withValues(alpha: 0.9), // Almost black at very bottom
                ],
                stops: const [0.0, 0.4, 0.8, 1.0],
              ),
            ),
          ),

          // 3. User Info & Actions
          Positioned(
            left: 20,
            right: 20,
            bottom: 40, // Closer to bottom as requested
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name and Icons
                Row(
                  children: [
                    Text(
                      role.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(blurRadius: 10.0, color: Colors.black, offset: Offset(2.0, 2.0))],
                      ),
                    ),
                  ],
                ),

                // Location (if available)
                if (role.location != null && role.location!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        role.location!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          shadows: [Shadow(blurRadius: 4.0, color: Colors.black, offset: Offset(1.0, 1.0))],
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 12),

                // Tags
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (role.tags?.split(',') ?? []).asMap().entries.map((entry) {
                    final index = entry.key;
                    final tag = entry.value.trim();
                    if (tag.isEmpty) return const SizedBox.shrink();
                    final colors = [Colors.blue, Colors.teal, Colors.red, Colors.green, Colors.purple, Colors.orange];
                    return _buildTag(tag, colors[index % colors.length]);
                  }).toList(),
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  role.description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.4,
                    shadows: [Shadow(blurRadius: 4.0, color: Colors.black, offset: Offset(1.0, 1.0))],
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 24),

                // Chat Button
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      // Direct navigation to DatingPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DatingPage(
                            role: role,
                            nickname: '', // No nickname yet
                            personality: '', // Default
                            userNickname: '', // Default
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9747FF), // Purple accent
                      foregroundColor: Colors.white,
                      elevation: 4,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.chat_bubble_outline, size: 16),
                        SizedBox(width: 6),
                        Text('Say Hi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.8), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedRolesTab() {
    if (_recommendedRoles.isEmpty) {
      return _buildEmptyState();
    }
    return PageView.builder(
      scrollDirection: Axis.vertical,
      controller: PageController(viewportFraction: 0.9),
      itemCount: _recommendedRoles.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: _buildCharacterPage(_recommendedRoles[index]),
        );
      },
    );
  }

  Widget _buildMyRolesTab() {
    if (_myRoles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_outline, color: StarryTheme.accentPink, size: 60),
            const SizedBox(height: 16),
            const Text(
              'No Dating History',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start dating with someone from Discover tab',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _myRoles.length,
      itemBuilder: (context, index) {
        return _buildMyRoleItem(_myRoles[index]);
      },
    );
  }

  Widget _buildMyRoleItem(HimxUserRole role) {
    final lastMessage = _lastMessages[role.id];
    const itemHeight = 120.0;
    const imageWidth = itemHeight * 3 / 4; // 3:4 ratio

    return GestureDetector(
      onTap: () {
        // Convert HimxUserRole to HimxRole for DatingPage
        final himxRole = HimxRole(
          id: role.id,
          roleId: role.roleId,
          name: role.name,
          imageUrl: role.imageUrl,
          videoUrl: role.videoUrl,
          description: role.description,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DatingPage(
              role: himxRole,
              nickname: role.nickname,
              personality: role.personality,
              userNickname: role.userNickname,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: itemHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10, width: 1),
          color: Colors.black.withValues(alpha: 0.3),
        ),
        child: Row(
          children: [
            // Avatar on the left
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
              child: Image.network(
                role.imageUrl,
                width: imageWidth,
                height: itemHeight,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: imageWidth,
                    height: itemHeight,
                    color: Colors.grey.shade800,
                    child: const Icon(Icons.person, color: Colors.white54, size: 40),
                  );
                },
              ),
            ),

            // Content on the right
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Name and relationship level
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            role.name,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getRelationshipColor(role.relationshipLevel),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            role.relationshipLevel,
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),

                    // Last message
                    if (lastMessage != null)
                      Text(
                        lastMessage.content,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      Text(
                        'No messages yet',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRelationshipColor(String level) {
    switch (level) {
      case 'lover':
        return StarryTheme.accentPink;
      case 'married':
        return const Color(0xFFFFD700); // Gold
      case 'friend':
      default:
        return Colors.cyan;
    }
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: StarryTheme.accentPink, size: 60),
            const SizedBox(height: 16),
            Text(
              'Failed to Load',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? '',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadHomeData, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text('No characters found.', style: const TextStyle(color: Colors.white)),
    );
  }

  // ==================== 社区 Tab ====================

  Widget _buildCommunityTab() {
    return Column(
      children: [
        // 角色筛选器
        _buildRoleFilter(),

        // 内容区域
        Expanded(
          child: _isLoadingCommunity
              ? const Center(child: CircularProgressIndicator(color: StarryTheme.accentPink))
              : _communityPosts.isEmpty
              ? _buildCommunityEmptyState()
              : _buildCommunityGrid(),
        ),
      ],
    );
  }

  /// 角色筛选器
  Widget _buildRoleFilter() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _myRoles.length + 1, // +1 for "全部"
        itemBuilder: (context, index) {
          if (index == 0) {
            // "全部" 选项
            return _buildFilterChip(roleId: null, label: '全部', imageUrl: null, isSelected: _selectedRoleFilter == null);
          }
          final role = _myRoles[index - 1];
          return _buildFilterChip(
            roleId: role.roleId,
            label: role.name,
            imageUrl: role.imageUrl,
            isSelected: _selectedRoleFilter == role.roleId,
          );
        },
      ),
    );
  }

  Widget _buildFilterChip({
    required String? roleId,
    required String label,
    required String? imageUrl,
    required bool isSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedRoleFilter = roleId;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: isSelected ? const LinearGradient(colors: [StarryTheme.accentPink, Color(0xFF9747FF)]) : null,
            color: isSelected ? null : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? Colors.transparent : Colors.white24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (imageUrl != null) ...[
                CircleAvatar(radius: 12, backgroundImage: NetworkImage(imageUrl)),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 社区空状态
  Widget _buildCommunityEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library_outlined, size: 60, color: StarryTheme.accentPink.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          const Text(
            '暂无内容',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '去和角色约会或换装，生成你的第一张照片吧！',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 社区内容网格
  Widget _buildCommunityGrid() {
    // 根据筛选条件过滤
    final filtered = _selectedRoleFilter == null
        ? _communityPosts
        : _communityPosts.where((p) => p.roleId == _selectedRoleFilter).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text('该角色暂无内容', style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCommunityData,
      color: StarryTheme.accentPink,
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65, // 适合 3:4 和 9:16 混合
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: filtered.length,
        itemBuilder: (context, index) => _buildCommunityCard(filtered[index]),
      ),
    );
  }

  /// 社区内容卡片
  Widget _buildCommunityCard(CommunityPost post) {
    return GestureDetector(
      onTap: () => _showPostDetail(post),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 图片
              Image.network(
                post.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade900,
                    child: const Icon(Icons.image, color: Colors.white24, size: 40),
                  );
                },
              ),

              // 底部渐变 + 信息
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 角色信息
                      Row(
                        children: [
                          CircleAvatar(radius: 10, backgroundImage: NetworkImage(post.roleImageUrl)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              post.roleName,
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildContentTypeTag(post.contentType),
                        ],
                      ),

                      // 地点 (如果有)
                      if (post.location != null && post.location!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 10, color: Colors.white54),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                post.location!,
                                style: const TextStyle(color: Colors.white54, fontSize: 10),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 内容类型标签
  Widget _buildContentTypeTag(String type) {
    final isOutfit = type == 'outfit';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isOutfit ? StarryTheme.accentGold.withValues(alpha: 0.8) : StarryTheme.accentPink.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isOutfit ? '换装' : '约会',
        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// 查看帖子详情
  void _showPostDetail(CommunityPost post) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 图片
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: AspectRatio(
                  aspectRatio: post.displayAspectRatio,
                  child: Image.network(post.imageUrl, fit: BoxFit.cover),
                ),
              ),

              // 信息
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(radius: 16, backgroundImage: NetworkImage(post.roleImageUrl)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.roleName,
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                post.contentTypeDisplay,
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white54),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    if (post.location != null && post.location!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: StarryTheme.accentPink),
                          const SizedBox(width: 4),
                          Text(post.location!, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CharacterBackground extends StatefulWidget {
  final String imageUrl;
  final String? videoUrl;

  const CharacterBackground({super.key, required this.imageUrl, this.videoUrl});

  @override
  State<CharacterBackground> createState() => _CharacterBackgroundState();
}

class _CharacterBackgroundState extends State<CharacterBackground> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // _initializeVideo();
  }

  @override
  void didUpdateWidget(CharacterBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    // if (widget.videoUrl != oldWidget.videoUrl) {
    //   _disposeVideo();
    //   _initializeVideo();
    // }
  }

  void _initializeVideo() {
    if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!))
        ..initialize()
            .then((_) {
              if (mounted) {
                setState(() {
                  _isInitialized = true;
                });
                _controller!.setLooping(true);
                _controller!.play();
              }
            })
            .catchError((error) {
              debugPrint("Video init error: $error");
              // Fallback to image is automatic if _isInitialized remains false
            });
    }
  }

  void _disposeVideo() {
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
  }

  @override
  void dispose() {
    _disposeVideo();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If video is ready, show video
    if (_controller != null && _isInitialized) {
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller!.value.size.width,
            height: _controller!.value.size.height,
            child: VideoPlayer(_controller!),
          ),
        ),
      );
    }

    // Fallback or loading state is the image
    return Image.network(
      widget.imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: StarryTheme.darkBackground,
          child: const Center(child: Icon(Icons.person, size: 100, color: Colors.white24)),
        );
      },
    );
  }
}
