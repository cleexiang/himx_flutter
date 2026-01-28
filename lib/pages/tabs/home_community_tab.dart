import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../models/himx_user_role.dart';
import '../../models/community_post.dart';
import '../../theme/starry_theme.dart';
import '../../services/himx_api.dart';

/// 社区 Tab
class HomeCommunityTab extends StatefulWidget {
  const HomeCommunityTab({super.key});

  @override
  State<HomeCommunityTab> createState() => _HomeCommunityTabState();
}

class _HomeCommunityTabState extends State<HomeCommunityTab> {
  final HimxApi _himxApi = HimxApi();

  int _currentTabIndex = 0;
  bool _isLoading = true;
  bool _isSharing = false;
  int? _sharingPostId;
  List<HimxUserRole> _myRoles = [];
  List<CommunityPost> _myPosts = [];
  List<CommunityPost> _communityFeed = [];
  String? _selectedRoleFilter;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final roles = await _himxApi.getMyRoles();
      if (!mounted) return;

      setState(() {
        _myRoles = roles;
      });

      // 同时加载"我的"帖子和社区内容
      await Future.wait([_loadMyPosts(roles), _loadCommunityFeed()]);
    } catch (e) {
      debugPrint('Error loading community data: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMyPosts(List<HimxUserRole> roles) async {
    if (roles.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final allPosts = <CommunityPost>[];

      for (final role in roles) {
        final results = await Future.wait([
          _himxApi.getPhotoList(roleId: role.roleId, type: 'dating'),
          _himxApi.getPhotoList(roleId: role.roleId, type: 'outfit'),
        ]);

        final datingPhotos = results[0];
        final outfitPhotos = results[1];

        allPosts.addAll(
          datingPhotos.map(
            (p) => CommunityPost.fromPhoto(
              p,
              role,
              'dating',
              userId: 'current_user',
              userName: role.userNickname ?? 'User',
              userAvatarUrl: role.imageUrl,
            ),
          ),
        );
        allPosts.addAll(
          outfitPhotos.map(
            (p) => CommunityPost.fromPhoto(
              p,
              role,
              'outfit',
              userId: 'current_user',
              userName: role.userNickname ?? 'User',
              userAvatarUrl: role.imageUrl,
            ),
          ),
        );
      }

      allPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (!mounted) return;
      setState(() {
        _myPosts = allPosts;
      });
    } catch (e) {
      debugPrint('Error loading my posts: $e');
    }
  }

  Future<void> _loadCommunityFeed() async {
    try {
      final feed = await _himxApi.getCommunityFeed();
      if (!mounted) return;
      setState(() {
        _communityFeed = feed;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading community feed: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleLike(CommunityPost post) async {
    try {
      if (post.isLiked) {
        await _himxApi.unlikeCommunityPost(postId: post.id);
      } else {
        await _himxApi.likeCommunityPost(postId: post.id);
      }
      // 刷新数据
      if (!mounted) return;
      _loadData();
    } catch (e) {
      debugPrint('Error toggling like: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('操作失败，请重试'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(child: _currentTabIndex == 0 ? _buildMyTab() : _buildCommunityTab()),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: CupertinoSegmentedControl<int>(
        onValueChanged: (int value) {
          setState(() {
            _currentTabIndex = value;
            _selectedRoleFilter = null;
          });
        },
        groupValue: _currentTabIndex,
        selectedColor: StarryTheme.accentPink,
        borderColor: Colors.transparent,
        children: const {
          0: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            child: Text('我的', style: TextStyle(fontSize: 14)),
          ),
          1: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            child: Text('社区', style: TextStyle(fontSize: 14)),
          ),
        },
      ),
    );
  }

  Widget _buildMyTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: StarryTheme.accentPink));
    }

    if (_myPosts.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        _buildRoleFilter(),
        Expanded(child: _buildMyGrid()),
      ],
    );
  }

  Widget _buildRoleFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildRoleFilterButton(label: '全部', roleId: null, isSelected: _selectedRoleFilter == null),
          ...List.generate(_myRoles.length, (index) {
            final role = _myRoles[index];
            return _buildRoleFilterButton(
              label: role.name,
              roleId: role.roleId,
              isSelected: _selectedRoleFilter == role.roleId,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRoleFilterButton({required String label, required String? roleId, required bool isSelected}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedRoleFilter = roleId;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? StarryTheme.accentPink : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMyGrid() {
    final filtered = _selectedRoleFilter == null
        ? _myPosts
        : _myPosts.where((p) => p.roleId == _selectedRoleFilter).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text('该角色暂无内容', style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: StarryTheme.accentPink,
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: filtered.length,
        itemBuilder: (context, index) => _buildMyPostCard(filtered[index]),
      ),
    );
  }

  Widget _buildMyPostCard(CommunityPost post) {
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
              // Content type tag - left bottom
              Positioned(
                left: 8,
                bottom: 8,
                child: _buildContentTypeTag(post.contentType),
              ),
              // Share button - right bottom
              Positioned(
                bottom: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    if (!_isCurrentPostSharing(post)) {
                      _showShareConfirmDialog(post);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: _isCurrentPostSharing(post)
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.share_outlined, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommunityTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: StarryTheme.accentPink));
    }

    if (_communityFeed.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.explore_outlined, size: 60, color: StarryTheme.accentPink.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text(
              '社区为空',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('暂无公开分享的内容', style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: StarryTheme.accentPink,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: _communityFeed.length,
        itemBuilder: (context, index) => _buildCommunityFeedCard(_communityFeed[index]),
      ),
    );
  }

  Widget _buildCommunityFeedCard(CommunityPost post) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Avatar + User info
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(post.userAvatarUrl),
                    onBackgroundImageError: (exception, stackTrace) {},
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.userName,
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Text(
                              post.roleName,
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11),
                            ),
                            const SizedBox(width: 6),
                            _buildContentTypeTag(post.contentType),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Content: Large image (2x size, 220x294)
              Padding(
                padding: const EdgeInsets.only(left: 60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 220,
                        height: 294,
                        child: Image.network(
                          post.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade900,
                              child: const Icon(Icons.image, color: Colors.white24, size: 60),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Location info below image
                    if (post.location != null && post.location!.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: Colors.white54),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              post.location!,
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Like button
              Padding(
                padding: const EdgeInsets.only(left: 60),
                child: GestureDetector(
                  onTap: () => _toggleLike(post),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        post.isLiked ? Icons.favorite : Icons.favorite_outline,
                        color: post.isLiked ? StarryTheme.accentPink : Colors.white54,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${post.likeCount}',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Divider
        Divider(
          height: 1,
          color: Colors.white.withValues(alpha: 0.1),
          indent: 8,
          endIndent: 8,
        ),
      ],
    );
  }

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

  Widget _buildEmptyState() {
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
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: AspectRatio(
                  aspectRatio: post.displayAspectRatio,
                  child: Image.network(post.imageUrl, fit: BoxFit.cover),
                ),
              ),
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
                    if (post.location != null && post.location!.isNotEmpty) ...const [SizedBox(height: 12)],
                    if (post.location != null && post.location!.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: StarryTheme.accentPink),
                          const SizedBox(width: 4),
                          Text(post.location!, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${dateTime.month}-${dateTime.day}';
    }
  }

  bool _isCurrentPostSharing(CommunityPost post) {
    return _isSharing && _sharingPostId == post.id;
  }

  void _showShareConfirmDialog(CommunityPost post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '确认分享',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '确定要将这张照片分享到社区吗？',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '取消',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performShare(post);
            },
            child: const Text(
              '确认',
              style: TextStyle(color: StarryTheme.accentPink, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performShare(CommunityPost post) async {
    setState(() {
      _isSharing = true;
      _sharingPostId = post.id;
    });

    try {
      await _himxApi.shareToCommunity(
        photoId: post.id,
        roleId: post.roleId,
        contentType: post.contentType,
        location: post.location,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('分享成功！'),
          backgroundColor: Colors.green.shade700,
        ),
      );

      // 刷新数据
      await _loadData();
    } catch (e) {
      debugPrint('Error sharing to community: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('分享失败，请重试'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
          _sharingPostId = null;
        });
      }
    }
  }
}
