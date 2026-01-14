import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:image_picker/image_picker.dart';
import '../models/himx_role.dart';
import '../models/chat_message.dart';
import '../models/song.dart';
import '../theme/app_theme.dart';
import '../services/himx_api.dart' as service;
import '../services/api_client.dart';
import 'diary_page.dart';
import 'package:flutter/cupertino.dart';
import '../widgets/glass_container.dart';

class DatingPage extends StatefulWidget {
  final HimxRole role;
  final String nickname;
  final String personality;
  final String userNickname;

  DatingPage({
    super.key,
    required this.role,
    required this.nickname,
    required this.personality,
    required this.userNickname,
  });

  @override
  State<DatingPage> createState() => _DatingPageState();
}

class _DatingPageState extends State<DatingPage> {
  VideoPlayerController? _videoController;
  final service.HimxApi _himxApi = service.HimxApi();
  final ApiClient _apiClient = ApiClient();
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  String? _currentOutfitUrl; // 当前穿搭图片 URL
  final TextEditingController _wardrobePromptController = TextEditingController(); // 换装提示词控制器
  final TextEditingController _datingLocationController = TextEditingController(); // 约会地点控制器
  String? _userPhotoUrl; // 用户照片 URL (可选)
  String? _datingPreviewUrl; // 生成的约会照片预览 URL
  final TextEditingController _songInputController = TextEditingController(); // 歌曲输入控制器
  bool _isLearningSong = false; // 是否正在学习歌曲

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
    // if (widget.role.videoUrl != null) {
    //   _initializeVideo(widget.role.videoUrl!);
    // }
    _setupAudioPlayer();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final history = await _himxApi.getChatList(roleId: widget.role.id);
      if (!mounted) return;

      setState(() {
        _messages.insertAll(0, history);
      });
      // Scroll to bottom after loading history
      Future.delayed(const Duration(milliseconds: 300), _scrollToBottom);
    } catch (e) {
      debugPrint('Failed to load history: $e');
    }
  }

  void _setupAudioPlayer() {
    // Listen to play state
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });

    // Listen to position changes
    _audioPlayer.onPositionChanged.listen((position) {
      if (!mounted) return;
      setState(() {
        _currentPosition = position;
      });
    });

    // Listen to duration changes
    _audioPlayer.onDurationChanged.listen((duration) {
      if (!mounted) return;
      setState(() {
        _totalDuration = duration;
      });
    });

    // Listen to play complete
    _audioPlayer.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        _isPlaying = false;
        _currentPosition = Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _messageController.dispose();
    _wardrobePromptController.dispose();
    _datingLocationController.dispose();
    _songInputController.dispose();
    _scrollController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      final aiMessage = await _himxApi.chat(roleId: widget.role.id, q: content, lang: 'zh');

      if (!mounted) return;

      setState(() {
        _messages.add(aiMessage);
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('发送失败: $e')));
    }
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

  // 显示约会地点选择底部弹窗
  void _showDatingSelector() {
    String? tempSelectedCharacterImage = _currentOutfitUrl ?? widget.role.imageUrl;
    String? tempUserPhotoUrl = _userPhotoUrl;
    bool isGenerating = false;
    final ScrollController modalScrollController = ScrollController(); // 添加滚动控制器
    List<String> characterImages = [widget.role.imageUrl]; // 从 API 获取的照片列表
    bool isLoadingOutfits = true;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          // 加载 outfit 照片列表（仅在第一次时加载）
          if (isLoadingOutfits && characterImages.length == 1) {
            _himxApi
                .getPhotoList(roleId: widget.role.roleId, type: 'outfit')
                .then((photos) {
                  if (!mounted) return;
                  setModalState(() {
                    characterImages = [widget.role.imageUrl, ...photos.map((p) => p.imageUrl)];
                    isLoadingOutfits = false;
                  });
                })
                .catchError((e) {
                  debugPrint('加载 outfit 照片失败: $e');
                  if (!mounted) return;
                  setModalState(() {
                    isLoadingOutfits = false;
                  });
                });
          }

          return Container(
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                // 顶部标题栏（固定）
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '定制约会',
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () {
                          debugPrint('🚪 点击关闭按钮');
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 可滚动内容
                Expanded(
                  child: SingleChildScrollView(
                    controller: modalScrollController, // 使用滚动控制器
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Dating Location Input
                        const Text(
                          '约会地点',
                          style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _datingLocationController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: '输入你想去的地方...',
                            hintStyle: const TextStyle(color: Colors.white30),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 2. Character Image Selection
                        const Text(
                          '选择角色的穿搭',
                          style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 100,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: characterImages.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final url = characterImages[index];
                              final isSelected = tempSelectedCharacterImage == url;
                              return GestureDetector(
                                onTap: () => setModalState(() => tempSelectedCharacterImage = url),
                                child: Container(
                                  width: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected ? Colors.purpleAccent : Colors.white10,
                                      width: 2,
                                    ),
                                    image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 3. User Photo (Optional)
                        const Text(
                          '我的照片 (可选)',
                          style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              debugPrint('📸 点击选择照片');
                              try {
                                // 从相册选择照片
                                debugPrint('📸 开始打开相册选择器');
                                final XFile? image = await _imagePicker.pickImage(
                                  source: ImageSource.gallery,
                                  maxWidth: 1280,
                                  maxHeight: 1280,
                                  imageQuality: 85,
                                );

                                debugPrint('📸 选择结果: ${image?.path ?? "未选择"}');
                                if (image == null) {
                                  debugPrint('📸 用户取消选择');
                                  return;
                                }

                                // 显示上传中状态
                                debugPrint('📸 开始上传照片');
                                setModalState(() => tempUserPhotoUrl = 'uploading');

                                // 上传照片到服务器
                                final imageUrl = await _apiClient.uploadImage(File(image.path));
                                debugPrint('📸 上传成功: $imageUrl');

                                // 更新照片 URL
                                if (!mounted) return;
                                setModalState(() => tempUserPhotoUrl = imageUrl);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('照片上传成功'),
                                    backgroundColor: Colors.green,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              } catch (e, stackTrace) {
                                debugPrint('📸 错误: $e');
                                debugPrint('📸 堆栈: $stackTrace');
                                if (!mounted) return;
                                setModalState(() => tempUserPhotoUrl = null);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('上传照片失败: $e'),
                                    backgroundColor: Colors.red,
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: tempUserPhotoUrl == 'uploading'
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.purpleAccent,
                                            ),
                                          )
                                        : tempUserPhotoUrl != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(16),
                                            child: Image.network(
                                              tempUserPhotoUrl!,
                                              fit: BoxFit.cover,
                                              width: 80,
                                              height: 80,
                                            ),
                                          )
                                        : const Icon(Icons.add_a_photo, color: Colors.white54),
                                  ),
                                  // 删除按钮
                                  if (tempUserPhotoUrl != null && tempUserPhotoUrl != 'uploading')
                                    Positioned(
                                      top: 2,
                                      right: 2,
                                      child: GestureDetector(
                                        onTap: () {
                                          debugPrint('📸 点击删除照片');
                                          setModalState(() => tempUserPhotoUrl = null);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.close, color: Colors.white, size: 16),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 4. Generation & Preview
                        if (_datingPreviewUrl != null || isGenerating)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 图片预览
                              Container(
                                height: 400,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: Colors.white10),
                                ),
                                child: isGenerating
                                    ? const Center(child: CircularProgressIndicator(color: Colors.purpleAccent))
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(24),
                                        child: Image.network(_datingPreviewUrl!, fit: BoxFit.cover),
                                      ),
                              ),

                              // 按钮区域（不再覆盖在图片上）
                              if (!isGenerating && _datingPreviewUrl != null) ...[
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            _currentOutfitUrl = _datingPreviewUrl;
                                            _userPhotoUrl = tempUserPhotoUrl;
                                          });
                                          Navigator.pop(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.purpleAccent,
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        child: const Text(
                                          '应用修改',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () async {
                                          if (tempSelectedCharacterImage == null) return;
                                          setModalState(() => isGenerating = true);
                                          try {
                                            final photo = await _himxApi.generateDatingPhoto(
                                              roleId: widget.role.roleId,
                                              location: _datingLocationController.text.trim(),
                                              characterImageUrl: tempSelectedCharacterImage!,
                                              userImageUrl: tempUserPhotoUrl,
                                              aspectRatio: '3:4',
                                            );
                                            if (!mounted) return;
                                            setModalState(() {
                                              isGenerating = false;
                                              _datingPreviewUrl = photo.imageUrl;
                                            });
                                            // 滚动到底部，露出图片和按钮
                                            Future.delayed(const Duration(milliseconds: 300), () {
                                              if (modalScrollController.hasClients) {
                                                modalScrollController.animateTo(
                                                  modalScrollController.position.maxScrollExtent,
                                                  duration: const Duration(milliseconds: 500),
                                                  curve: Curves.easeOut,
                                                );
                                              }
                                            });
                                          } catch (e) {
                                            if (!mounted) return;
                                            setModalState(() => isGenerating = false);
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(SnackBar(content: Text('生成失败: $e')));
                                          }
                                        },
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          side: const BorderSide(color: Colors.white30),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        child: const Text(
                                          '重新生成',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),

                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),

                // 底部按钮（固定）
                if (!isGenerating && _datingPreviewUrl == null)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _datingLocationController.text.isEmpty || tempSelectedCharacterImage == null
                            ? null
                            : () async {
                                debugPrint('🎨 点击生成约会照片按钮');
                                setModalState(() => isGenerating = true);
                                try {
                                  final photo = await _himxApi.generateDatingPhoto(
                                    roleId: widget.role.roleId,
                                    location: _datingLocationController.text.trim(),
                                    characterImageUrl: tempSelectedCharacterImage!,
                                    userImageUrl: tempUserPhotoUrl,
                                  );
                                  if (!mounted) return;
                                  setModalState(() {
                                    isGenerating = false;
                                    _datingPreviewUrl = photo.imageUrl;
                                  });
                                  // 滚动到底部，露出图片和按钮
                                  Future.delayed(const Duration(milliseconds: 300), () {
                                    if (modalScrollController.hasClients) {
                                      modalScrollController.animateTo(
                                        modalScrollController.position.maxScrollExtent,
                                        duration: const Duration(milliseconds: 500),
                                        curve: Curves.easeOut,
                                      );
                                    }
                                  });
                                } catch (e) {
                                  debugPrint('🎨 生成失败: $e');
                                  if (!mounted) return;
                                  setModalState(() => isGenerating = false);
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('生成失败: $e')));
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purpleAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          disabledBackgroundColor: Colors.white10,
                        ),
                        child: const Text(
                          '生成约会照片',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 显示歌曲列表和合成功能
  void _showSongList() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) => Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '${widget.nickname} 的歌单',
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  // 歌曲搜索/合成输入
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _songInputController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: '输入你想听的歌名...',
                              hintStyle: const TextStyle(color: Colors.white30),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.05),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _isLearningSong || _songInputController.text.trim().isEmpty
                              ? null
                              : () async {
                                  final songTitle = _songInputController.text.trim();
                                  setModalState(() => _isLearningSong = true);

                                  // TODO: 接口待实现，目前模拟合成过程
                                  await Future.delayed(const Duration(seconds: 3));

                                  if (!mounted) return;

                                  final newSong = Song(
                                    id: 'learned_${DateTime.now().millisecondsSinceEpoch}',
                                    title: songTitle,
                                    artist: widget.nickname,
                                    coverUrl: 'https://images.unsplash.com/photo-1514320291840-2e0a9bf2a9ae?w=400',
                                    audioUrl: 'audio/demo.mp3', // 模拟音频
                                    duration: const Duration(minutes: 3, seconds: 0),
                                    isUnlocked: true,
                                  );

                                  setState(() {
                                    _songs.insert(0, newSong);
                                    _isLearningSong = false;
                                  });
                                  setModalState(() {});
                                  _songInputController.clear();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purpleAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          child: const Text(
                            '点歌',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (_isLearningSong)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.purpleAccent),
                          ),
                          const SizedBox(width: 12),
                          Text('${widget.nickname} 正在学习中...', style: const TextStyle(color: Colors.purpleAccent)),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '历史已点歌曲',
                        style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

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
          );
        },
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
          color: isCurrent ? AppTheme.selectedBackground.withValues(alpha: 0.3) : AppTheme.pageBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCurrent ? AppTheme.selectedBackground : AppTheme.shadowOverlay.withValues(alpha: 0.3),
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
            style: const TextStyle(color: AppTheme.titleText, fontSize: 16, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(song.artist, style: const TextStyle(color: AppTheme.bodyText, fontSize: 13)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_formatDuration(song.duration), style: const TextStyle(color: AppTheme.bodyText, fontSize: 13)),
              const SizedBox(width: 8),
              if (isPlaying)
                const Icon(Icons.equalizer, color: AppTheme.shadowOverlay, size: 24)
              else if (song.isUnlocked)
                const Icon(Icons.play_circle_outline, color: AppTheme.bodyText, size: 24),
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
        color: AppTheme.unselectedBackground,
        border: Border(top: BorderSide(color: AppTheme.shadowOverlay.withValues(alpha: 0.3))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(_currentSong!.coverUrl, width: 40, height: 40, fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentSong!.title,
                      style: const TextStyle(color: AppTheme.titleText, fontSize: 14, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(_currentSong!.artist, style: const TextStyle(color: AppTheme.bodyText, fontSize: 12)),
                  ],
                ),
              ),
              IconButton(
                onPressed: _togglePlayPause,
                icon: Icon(
                  _isPlaying ? Icons.pause_circle : Icons.play_circle,
                  color: AppTheme.shadowOverlay,
                  size: 36,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(_formatDuration(_currentPosition), style: const TextStyle(color: AppTheme.bodyText, fontSize: 11)),
              Expanded(
                child: Slider(
                  value: _currentPosition.inSeconds.toDouble(),
                  max: _totalDuration.inSeconds.toDouble(),
                  activeColor: AppTheme.shadowOverlay,
                  inactiveColor: AppTheme.bodyText.withValues(alpha: 0.3),
                  onChanged: (value) {
                    _audioPlayer.seek(Duration(seconds: value.toInt()));
                  },
                ),
              ),
              Text(_formatDuration(_totalDuration), style: const TextStyle(color: AppTheme.bodyText, fontSize: 11)),
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
      content: '${widget.nickname} 为你唱起了《${song.title}》',
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

  // Open diary page
  void _openDiary() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => DiaryPage(role: widget.role)));
  }

  // Outfit photos will be loaded from API

  void _showOutfitModal() {
    String? tempPreviewUrl;
    bool isGenerating = false;
    String mode = 'prompt'; // 'prompt' or 'reference'
    String? selectedReferenceImage;
    List<String> outfitImages = []; // 从 API 获取的 outfit 照片列表
    bool isLoadingOutfits = true;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          // 加载 outfit 照片列表（仅在第一次时加载）
          if (isLoadingOutfits && outfitImages.isEmpty) {
            _himxApi
                .getPhotoList(roleId: widget.role.roleId, type: 'outfit')
                .then((photos) {
                  if (!mounted) return;
                  setModalState(() {
                    outfitImages = photos.map((p) => p.imageUrl).toList();
                    isLoadingOutfits = false;
                  });
                })
                .catchError((e) {
                  debugPrint('加载 outfit 照片失败: $e');
                  if (!mounted) return;
                  setModalState(() {
                    isLoadingOutfits = false;
                  });
                });
          }

          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border.all(color: Colors.white10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Outfit',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 1. Outfit Photos from API
                const Text(
                  '我的衣柜',
                  style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: isLoadingOutfits
                      ? const Center(child: CircularProgressIndicator(color: Colors.purpleAccent, strokeWidth: 2))
                      : outfitImages.isEmpty
                      ? const Center(
                          child: Text('暂无照片', style: TextStyle(color: Colors.white30, fontSize: 14)),
                        )
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: outfitImages.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final url = outfitImages[index];
                            final isSelected = _currentOutfitUrl == url;
                            return GestureDetector(
                              onTap: () {
                                setState(() => _currentOutfitUrl = url);
                                setModalState(() {});
                              },
                              child: Container(
                                width: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected ? Colors.purpleAccent : Colors.white10,
                                    width: 2,
                                  ),
                                  image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 32),

                // 2. AI Custom Generation
                const Text(
                  'Custom Expression',
                  style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setModalState(() => mode = 'prompt'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: mode == 'prompt' ? Colors.purpleAccent.withValues(alpha: 0.2) : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                'Prompt',
                                style: TextStyle(
                                  color: mode == 'prompt' ? Colors.purpleAccent : Colors.white60,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setModalState(() => mode = 'reference'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: mode == 'reference'
                                  ? Colors.purpleAccent.withValues(alpha: 0.2)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                'Reference',
                                style: TextStyle(
                                  color: mode == 'reference' ? Colors.purpleAccent : Colors.white60,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (mode == 'prompt')
                  TextField(
                    controller: _wardrobePromptController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Describe the outfit or style...',
                      hintStyle: const TextStyle(color: Colors.white30),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  )
                else
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        debugPrint('📸 点击选择参考图片');
                        try {
                          final XFile? image = await _imagePicker.pickImage(
                            source: ImageSource.gallery,
                            maxWidth: 1280,
                            maxHeight: 1280,
                            imageQuality: 85,
                          );

                          if (image == null) {
                            debugPrint('📸 用户取消选择');
                            return;
                          }

                          debugPrint('📸 开始上传参考图片');
                          setModalState(() => selectedReferenceImage = 'uploading');

                          final imageUrl = await _apiClient.uploadImage(File(image.path));
                          debugPrint('📸 参考图片上传成功: $imageUrl');

                          if (!mounted) return;
                          setModalState(() => selectedReferenceImage = imageUrl);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('参考图片上传成功'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } catch (e) {
                          debugPrint('📸 上传参考图片失败: $e');
                          if (!mounted) return;
                          setModalState(() => selectedReferenceImage = null);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('上传参考图片失败: $e'),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white12, style: BorderStyle.solid),
                        ),
                        child: selectedReferenceImage == 'uploading'
                            ? const Center(child: CircularProgressIndicator(color: Colors.purpleAccent, strokeWidth: 2))
                            : selectedReferenceImage != null
                            ? Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      selectedReferenceImage!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => setModalState(() => selectedReferenceImage = null),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate, color: Colors.white54, size: 32),
                                  SizedBox(height: 8),
                                  Text('选择参考图片', style: TextStyle(color: Colors.white30)),
                                ],
                              ),
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // Generation Preview Area
                if (tempPreviewUrl != null || isGenerating)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 图片预览区域 - 按9:16比例显示
                      AspectRatio(
                        aspectRatio: 9 / 16,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: isGenerating
                              ? const Center(child: CircularProgressIndicator(color: Colors.purpleAccent))
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Image.network(tempPreviewUrl!, fit: BoxFit.cover, width: double.infinity),
                                ),
                        ),
                      ),
                      // 按钮区域 - 在图片下方
                      if (!isGenerating && tempPreviewUrl != null) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() => _currentOutfitUrl = tempPreviewUrl);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('装扮已应用'),
                                      backgroundColor: Colors.green,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purpleAccent,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text(
                                  '应用',
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () async {
                                  debugPrint('🎨 点击重新生成按钮');
                                  setModalState(() {
                                    isGenerating = true;
                                    tempPreviewUrl = null;
                                  });
                                  try {
                                    final photo = await _himxApi.generateOutfitPhoto(
                                      roleId: widget.role.roleId,
                                      characterImageUrl: widget.role.imageUrl,
                                      outfitDescription: mode == 'prompt'
                                          ? _wardrobePromptController.text.trim()
                                          : null,
                                      referenceImageUrl: mode == 'reference' ? selectedReferenceImage : null,
                                    );
                                    if (!mounted) return;
                                    setModalState(() {
                                      isGenerating = false;
                                      tempPreviewUrl = photo.imageUrl;
                                    });
                                  } catch (e) {
                                    debugPrint('🎨 重新生成失败: $e');
                                    if (!mounted) return;
                                    setModalState(() => isGenerating = false);
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('重新生成失败: $e')));
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  side: const BorderSide(color: Colors.white30),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text(
                                  '重新生成',
                                  style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  )
                else
                  const Spacer(),

                if (!isGenerating && tempPreviewUrl == null)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed:
                          (mode == 'prompt' && _wardrobePromptController.text.isEmpty) ||
                              (mode == 'reference' && selectedReferenceImage == null) ||
                              selectedReferenceImage == 'uploading'
                          ? null
                          : () async {
                              debugPrint('🎨 点击生成装扮照片按钮');
                              setModalState(() => isGenerating = true);
                              try {
                                final photo = await _himxApi.generateOutfitPhoto(
                                  roleId: widget.role.roleId,
                                  characterImageUrl: widget.role.imageUrl,
                                  outfitDescription: mode == 'prompt' ? _wardrobePromptController.text.trim() : null,
                                  referenceImageUrl: mode == 'reference' ? selectedReferenceImage : null,
                                  aspectRatio: '9:16',
                                );
                                if (!mounted) return;
                                setModalState(() {
                                  isGenerating = false;
                                  tempPreviewUrl = photo.imageUrl;
                                });
                                debugPrint('🎨 生成成功: ${photo.imageUrl}');
                              } catch (e) {
                                debugPrint('🎨 生成失败: $e');
                                if (!mounted) return;
                                setModalState(() => isGenerating = false);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('生成失败: $e')));
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purpleAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        disabledBackgroundColor: Colors.white10,
                      ),
                      child: const Text(
                        '生成装扮照片',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Media Display (Background Layer)
          _buildMediaDisplay(),

          // 2. Chat Area (Bottom Gradient & List) - Behind menus? Or below?
          // Let's keep it full width at bottom, but maybe adjust padding so it doesn't conflict with menus if they overlap
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
                // Adjust padding to avoid covering the input area
                padding: const EdgeInsets.fromLTRB(16, 60, 16, 100),
                reverse: true,
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == 0 && _isLoading) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${widget.nickname} 正在输入...',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }
                  final messageIndex = _isLoading ? index - 1 : index;
                  final reversedIndex = _messages.length - 1 - messageIndex;
                  return _buildMessageBubble(_messages[reversedIndex]);
                },
              ),
            ),
          ),

          // 3. UI Overlay (Top Bar, Menus)
          SafeArea(
            child: Stack(
              children: [
                // Top Bar
                Positioned(top: 0, left: 0, right: 0, child: _buildTopBar()),
                // Right Menu (Functional Buttons with Glass Style)
                Positioned(right: 16, top: 120, bottom: 120, width: 72, child: _buildRightMenu()),
              ],
            ),
          ),

          // 4. Chat Input (Bottom)
          Positioned(left: 16, right: 16, bottom: 20, child: _buildMessageInput()),

          // Back Button (retained if needed, or rely on Top Bar back?)
          // _buildTopBar has no back button in Wardrobe, but DatingPage needs one.
          // I will add a back button to _buildTopBar or keep it separate.
          // Wardrobe TopBar replaced the visual space. Let's add a small back button
          // to top-left or assume user swipes back.
          // For safety, let's keep the explicit back button but style it better or
          // integrate into TopBar. I'll integrate it into TopBar logic.
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.3),
                border: Border.all(color: Colors.white.withValues(alpha: 0.7), width: 1.5),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),

          // Menu Button
          GestureDetector(
            onTap: () {
              // TODO: Add menu logic
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.3),
                border: Border.all(color: Colors.white.withValues(alpha: 0.7), width: 1.5),
              ),
              child: const Icon(Icons.menu, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightMenu() {
    final menuItems = [
      (icon: Icons.favorite, color: Colors.pink, onTap: _showDatingSelector),
      (icon: Icons.music_note, color: Colors.purple, onTap: _showSongList),
      (icon: Icons.book, color: Colors.blue, onTap: _openDiary),
      (icon: Icons.checkroom, color: Colors.purpleAccent, onTap: _showOutfitModal),
    ];

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: menuItems.length,
            separatorBuilder: (c, i) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = menuItems[index];
              return GestureDetector(
                onTap: item.onTap,
                child: GlassContainer(
                  height: 64,
                  borderRadius: BorderRadius.circular(16),
                  padding: EdgeInsets.zero,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 2.0),
                  child: Center(child: Icon(item.icon, color: item.color, size: 28)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMediaDisplay() {
    // 优先显示 _currentOutfitUrl (包含生成的约会照片或通过预览应用的图片)
    final imageUrl = _currentOutfitUrl ?? widget.role.imageUrl;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Image.network(
        imageUrl,
        key: ValueKey(imageUrl),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.black,
            child: const Center(child: Icon(Icons.person, size: 100, color: Colors.white54)),
          );
        },
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
          child: Transform.translate(offset: Offset(0, 10 * (1 - value)), child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
        child: Center(
          child: Text(
            message.content,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: message.isUser ? AppTheme.shadowOverlay : AppTheme.pageBackground,
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
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
                ),
                filled: true,
                fillColor: Colors.black.withValues(alpha: 0.3),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 16),
          Material(
            color: AppTheme.buttonBackground,
            shape: const CircleBorder(),
            elevation: 4,
            child: InkWell(
              onTap: _sendMessage,
              customBorder: const CircleBorder(),
              child: const Padding(
                padding: EdgeInsets.all(14),
                child: Icon(Icons.send, color: AppTheme.buttonText, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
