import 'package:flutter/material.dart';
import '../models/himx_role.dart';
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
      // For now, we mainly need standard roles for the feed.
      // We might ignore "My Dates" for this specific UI request or merge them later.
      final results = await Future.wait([_himxApi.getRecommendedRoles()]);

      final recommended = results[0];

      if (!mounted) return;
      setState(() {
        _recommendedRoles = recommended;
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
                  : _recommendedRoles.isEmpty
                  ? _buildEmptyState()
                  : PageView.builder(
                      scrollDirection: Axis.vertical,
                      controller: PageController(viewportFraction: 0.9), // Reveal next card slightly or just spacing
                      itemCount: _recommendedRoles.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: _buildCharacterPage(_recommendedRoles[index]),
                        );
                      },
                    ),
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
            BottomNavigationBarItem(icon: Icon(Icons.explore, size: 28), label: 'Discover'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble, size: 28), label: 'Chat'),
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
