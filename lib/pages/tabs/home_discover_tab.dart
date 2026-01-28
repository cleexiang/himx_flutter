import 'package:flutter/material.dart';
import 'package:himx/services/auth_service.dart';
import 'package:video_player/video_player.dart';
import '../../models/himx_role.dart';
import '../../theme/starry_theme.dart';
import '../../services/himx_api.dart';
import '../dating_page.dart';
import '../coins_purchase_page.dart';
import '../pro_subscription_page.dart';

/// 推荐角色 Tab
class HomeDiscoverTab extends StatefulWidget {
  const HomeDiscoverTab({super.key});

  @override
  State<HomeDiscoverTab> createState() => _HomeDiscoverTabState();
}

class _HomeDiscoverTabState extends State<HomeDiscoverTab> {
  final HimxApi _himxApi = HimxApi();

  bool _isLoading = true;
  String? _errorMessage;
  List<HimxRole> _recommendedRoles = [];

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
      final roles = await _himxApi.getRecommendedRoles();
      if (!mounted) return;
      setState(() {
        _recommendedRoles = roles;
        _isLoading = false;
      });
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
            'Discover',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              // PRO 按钮
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProSubscriptionPage()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
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
              ),
              const SizedBox(width: 12),
              // 积分
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CoinsPurchasePage()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.diamond, color: Colors.cyanAccent, size: 16),
                      SizedBox(width: 4),
                      Text(
                        AuthService().currentUser?.credits.toString() ?? "0",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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

    if (_recommendedRoles.isEmpty) {
      return const Center(
        child: Text('No characters found.', style: TextStyle(color: Colors.white)),
      );
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

  Widget _buildCharacterPage(HimxRole role) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 背景
          _CharacterBackground(imageUrl: role.imageUrl, videoUrl: role.videoUrl),

          // 渐变遮罩
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.6),
                  Colors.black.withValues(alpha: 0.9),
                ],
                stops: const [0.0, 0.4, 0.8, 1.0],
              ),
            ),
          ),

          // 信息
          Positioned(
            left: 20,
            right: 20,
            bottom: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DatingPage(role: role, nickname: '', personality: '', userNickname: ''),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9747FF),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// 角色背景组件
class _CharacterBackground extends StatefulWidget {
  final String imageUrl;
  final String? videoUrl;

  const _CharacterBackground({required this.imageUrl, this.videoUrl});

  @override
  State<_CharacterBackground> createState() => _CharacterBackgroundState();
}

class _CharacterBackgroundState extends State<_CharacterBackground> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
