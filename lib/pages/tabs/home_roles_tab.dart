import 'package:flutter/material.dart';
import '../../models/himx_role.dart';
import '../../models/himx_user_role.dart';
import '../../models/chat_message.dart';
import '../../theme/starry_theme.dart';
import '../../services/himx_api.dart';
import '../dating_page.dart';

/// 我的角色 Tab
class HomeRolesTab extends StatefulWidget {
  const HomeRolesTab({super.key});

  @override
  State<HomeRolesTab> createState() => _HomeRolesTabState();
}

class _HomeRolesTabState extends State<HomeRolesTab> {
  final HimxApi _himxApi = HimxApi();

  bool _isLoading = true;
  String? _errorMessage;
  List<HimxUserRole> _myRoles = [];
  Map<int, ChatMessage?> _lastMessages = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final roles = await _himxApi.getMyRoles();
      if (!mounted) return;
      setState(() {
        _myRoles = roles;
        _isLoading = false;
      });
      _loadLastMessagesForRoles(roles);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = '$e';
      });
    }
  }

  Future<void> _loadLastMessagesForRoles(List<HimxUserRole> roles) async {
    for (final role in roles) {
      try {
        final messages = await _himxApi.getChatList(roleId: role.id);
        if (!mounted) return;

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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'My Dates',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: StarryTheme.accentPink));
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_myRoles.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: StarryTheme.accentPink,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _myRoles.length,
        itemBuilder: (context, index) {
          return _buildRoleItem(_myRoles[index]);
        },
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
            const Icon(Icons.error_outline, color: StarryTheme.accentPink, size: 60),
            const SizedBox(height: 16),
            const Text(
              'Failed to Load',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? '',
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
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

  Widget _buildRoleItem(HimxUserRole role) {
    final lastMessage = _lastMessages[role.id];
    const itemHeight = 120.0;
    const imageWidth = itemHeight * 3 / 4;

    return GestureDetector(
      onTap: () {
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
        return const Color(0xFFFFD700);
      case 'friend':
      default:
        return Colors.cyan;
    }
  }
}
