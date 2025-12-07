import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/boyfriend.dart';
import '../models/character_settings.dart';
import '../models/chat_message.dart';
import '../models/date_scene.dart';
import '../models/song.dart';

class DatingPage extends StatefulWidget {
  final Boyfriend boyfriend;
  final CharacterSettings settings;

  const DatingPage({super.key, required this.boyfriend, required this.settings});

  @override
  State<DatingPage> createState() => _DatingPageState();
}

class _DatingPageState extends State<DatingPage> {
  VideoPlayerController? _videoController;
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  // 场景相关
  DateScene? _currentScene;
  final List<DateScene> _availableScenes = DateScenes.getPresetScenes();
  final Map<String, DateScene> _initializedScenes = {}; // 已初始化的场景
  String _currentMediaUrl = ''; // 当前显示的媒体 URL

  // 音乐相关
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<Song> _songs = Songs.getPresetSongs();
  Song? _currentSong;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _currentMediaUrl = widget.boyfriend.videoUrl ?? widget.boyfriend.imageUrl;
    if (widget.boyfriend.videoUrl != null) {
      _initializeVideo(widget.boyfriend.videoUrl!);
    }
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    // 监听播放状态
    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });

    // 监听播放位置
    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _currentPosition = position;
      });
    });

    // 监听总时长
    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _totalDuration = duration;
      });
    });

    // 监听播放完成
    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        _isPlaying = false;
        _currentPosition = Duration.zero;
      });
    });
  }

  void _initializeVideo(String videoUrl) {
    _videoController?.dispose();
    _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
      ..initialize().then((_) {
        setState(() {});
        _videoController?.setLooping(true);
        _videoController?.play();
      });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: _messageController.text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    Future.delayed(const Duration(seconds: 1), () {
      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: '这是AI回复的示例消息，请在此处对接您的AI接口',
        isUser: false,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(aiMessage);
        _isLoading = false;
      });

      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0, // reverse: true 时，0 是最底部
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  // 显示场景选择底部弹窗
  void _showSceneSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '选择约会场景',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _availableScenes.length,
                itemBuilder: (context, index) {
                  final scene = _availableScenes[index];
                  return _buildSceneCard(scene);
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 构建场景卡片
  Widget _buildSceneCard(DateScene scene) {
    final isSelected = _currentScene?.id == scene.id;

    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _selectScene(scene);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.pink.shade400
                : Colors.white.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          image: DecorationImage(
            image: NetworkImage(scene.imageUrl),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.3),
              BlendMode.darken,
            ),
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    scene.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    scene.description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade400,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 选择场景
  Future<void> _selectScene(DateScene scene) async {
    // 添加系统消息提示切换场景
    final systemMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: '场景已切换到：${scene.name}',
      isUser: false,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(systemMessage);
      _currentScene = scene;
    });

    _scrollToBottom();

    // 检查场景是否已初始化
    if (_initializedScenes.containsKey(scene.id)) {
      // 已初始化，直接使用缓存的场景数据
      final initializedScene = _initializedScenes[scene.id]!;
      _changeSceneMedia(initializedScene);
    } else {
      // 未初始化，调用初始化接口
      await _initializeScene(scene);
    }
  }

  // 初始化场景（调用后端接口）
  Future<void> _initializeScene(DateScene scene) async {
    // TODO: 调用后端接口初始化场景
    // 示例接口调用：
    // final response = await ApiService.initializeScene(
    //   boyfriendId: widget.boyfriend.id,
    //   sceneId: scene.id,
    // );
    //
    // final initializedScene = scene.copyWith(
    //   imageUrl: response.imageUrl,
    //   videoUrl: response.videoUrl,
    //   isInitialized: true,
    // );

    // 模拟接口调用
    await Future.delayed(const Duration(seconds: 1));

    // 暂时使用预设的图片，实际应该从接口返回
    final initializedScene = scene.copyWith(isInitialized: true);

    setState(() {
      _initializedScenes[scene.id] = initializedScene;
    });

    _changeSceneMedia(initializedScene);
  }

  // 切换场景媒体
  void _changeSceneMedia(DateScene scene) {
    setState(() {
      _currentMediaUrl = scene.videoUrl ?? scene.imageUrl;

      // 如果有视频，初始化视频播放器
      if (scene.videoUrl != null) {
        _initializeVideo(scene.videoUrl!);
      } else {
        // 只有图片，释放视频播放器
        _videoController?.dispose();
        _videoController = null;
      }
    });
  }

  // 显示歌曲列表
  void _showSongList() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '${widget.settings.nickname} 的歌单',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _songs.length,
                  itemBuilder: (context, index) {
                    final song = _songs[index];
                    return _buildSongItem(song);
                  },
                ),
              ),
              if (_currentSong != null) _buildMiniPlayer(),
            ],
          ),
        ),
      ),
    );
  }

  // 构建歌曲列表项
  Widget _buildSongItem(Song song) {
    final isPlaying = _currentSong?.id == song.id && _isPlaying;
    final isCurrent = _currentSong?.id == song.id;

    return Opacity(
      opacity: song.isUnlocked ? 1.0 : 0.5,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isCurrent
              ? Colors.pink.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCurrent
                ? Colors.pink.shade400
                : Colors.white.withValues(alpha: 0.1),
            width: isCurrent ? 2 : 1,
          ),
        ),
        child: ListTile(
          onTap: song.isUnlocked
              ? () {
                  Navigator.pop(context);
                  _playSong(song);
                }
              : null,
          leading: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  song.coverUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey.shade800,
                      child: const Icon(Icons.music_note, color: Colors.white54),
                    );
                  },
                ),
              ),
              if (!song.isUnlocked)
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.lock, color: Colors.white, size: 24),
                ),
            ],
          ),
          title: Text(
            song.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            song.artist,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatDuration(song.duration),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              if (isPlaying)
                const Icon(Icons.equalizer, color: Colors.pink, size: 24)
              else if (song.isUnlocked)
                Icon(Icons.play_circle_outline,
                    color: Colors.white.withValues(alpha: 0.6), size: 24),
            ],
          ),
        ),
      ),
    );
  }

  // 构建迷你播放器
  Widget _buildMiniPlayer() {
    if (_currentSong == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  _currentSong!.coverUrl,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentSong!.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _currentSong!.artist,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _togglePlayPause,
                icon: Icon(
                  _isPlaying ? Icons.pause_circle : Icons.play_circle,
                  color: Colors.pink,
                  size: 36,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                _formatDuration(_currentPosition),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
              ),
              Expanded(
                child: Slider(
                  value: _currentPosition.inSeconds.toDouble(),
                  max: _totalDuration.inSeconds.toDouble(),
                  activeColor: Colors.pink,
                  inactiveColor: Colors.white.withValues(alpha: 0.2),
                  onChanged: (value) {
                    _audioPlayer.seek(Duration(seconds: value.toInt()));
                  },
                ),
              ),
              Text(
                _formatDuration(_totalDuration),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 播放歌曲
  Future<void> _playSong(Song song) async {
    final systemMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: '${widget.settings.nickname} 为你唱起了《${song.title}》',
      isUser: false,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(systemMessage);
      _currentSong = song;
    });

    _scrollToBottom();

    // TODO: 替换为实际的音频URL
    // await _audioPlayer.play(UrlSource(song.audioUrl));

    // 模拟播放（实际项目中需要替换为真实音频）
    await _audioPlayer.play(AssetSource('audio/demo.mp3')); // 如果有本地音频
  }

  // 切换播放/暂停
  void _togglePlayPause() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.resume();
    }
  }

  // 格式化时长
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 背景角色图片/视频覆盖整个页面
          _buildMediaDisplay(),

          // 聊天区域 - 黑色渐变背景
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: MediaQuery.of(context).size.height * 0.4,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.5),
                    Colors.black.withValues(alpha: 0.8),
                    Colors.black.withValues(alpha: 0.95),
                  ],
                  stops: const [0.0, 0.3, 0.7, 1.0],
                ),
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 60, 16, 100),
                reverse: true,
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  // 如果正在加载，第一项显示加载提示
                  if (index == 0 && _isLoading) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${widget.settings.nickname} 正在输入...',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // 正常消息
                  final messageIndex = _isLoading ? index - 1 : index;
                  final reversedIndex = _messages.length - 1 - messageIndex;
                  return _buildMessageBubble(_messages[reversedIndex]);
                },
              ),
            ),
          ),

          // 输入框悬浮在底部，无背景
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: _buildMessageInput(),
          ),

          // 返回按钮
          Positioned(
            top: 50,
            left: 20,
            child: Material(
              color: Colors.black.withValues(alpha: 0.5),
              shape: const CircleBorder(),
              child: InkWell(
                onTap: () => Navigator.pop(context),
                customBorder: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.arrow_back, color: Colors.white, size: 24),
                ),
              ),
            ),
          ),

          // 功能按钮
          Positioned(top: 120, right: 20, child: _buildFunctionButtons()),
        ],
      ),
    );
  }

  Widget _buildMediaDisplay() {
    // 如果有视频控制器且已初始化，显示视频
    if (_videoController != null && _videoController!.value.isInitialized) {
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _videoController!.value.size.width,
            height: _videoController!.value.size.height,
            child: VideoPlayer(_videoController!),
          ),
        ),
      );
    }

    // 如果正在加载视频
    if (_videoController != null && !_videoController!.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    // 显示图片（使用当前场景的图片或默认图片）
    final imageUrl = _currentScene?.imageUrl ?? widget.boyfriend.imageUrl;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Image.network(
        imageUrl,
        key: ValueKey(imageUrl), // 用于触发 AnimatedSwitcher
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.black,
            child: const Center(
              child: Icon(Icons.person, size: 100, color: Colors.white54),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFunctionButtons() {
    final buttons = [
      {'icon': Icons.favorite, 'label': 'Date', 'color': Colors.pink},
      {'icon': Icons.music_note, 'label': 'Sing', 'color': Colors.purple},
      {'icon': Icons.book, 'label': 'Diary', 'color': Colors.blue},
      {'icon': Icons.card_giftcard, 'label': 'Gift', 'color': Colors.orange},
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: buttons.map((button) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildFunctionButton(
            icon: button['icon'] as IconData,
            label: button['label'] as String,
            color: button['color'] as Color,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFunctionButton({required IconData icon, required String label, required Color color}) {
    return Material(
      color: Colors.white.withValues(alpha: 0.8),
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        onTap: () {
          if (label == 'Date') {
            _showSceneSelector();
          } else if (label == 'Sing') {
            _showSongList();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$label 功能开发中...')),
            );
          }
        },
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Icon(icon, color: color, size: 28),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
        child: Center(
          child: Text(
            message.content,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: message.isUser
                  ? Colors.pink.shade200
                  : Colors.white,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: '输入消息...',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                ),
                filled: true,
                fillColor: Colors.black.withValues(alpha: 0.3),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 16),
          Material(
            color: Colors.pink.shade400,
            shape: const CircleBorder(),
            elevation: 4,
            child: InkWell(
              onTap: _sendMessage,
              customBorder: const CircleBorder(),
              child: const Padding(
                padding: EdgeInsets.all(14),
                child: Icon(Icons.send, color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
