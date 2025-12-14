import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class UniversalMediaWidget extends StatefulWidget {
  final String mediaPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? errorWidget;
  final bool enableCache;
  final bool autoPlay;
  final void Function(String cachedPath)? onCacheCompleted; // 新增回调

  const UniversalMediaWidget({
    Key? key,
    required this.mediaPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorWidget,
    this.enableCache = true,
    this.autoPlay = false,
    this.onCacheCompleted, // 新增回调
  }) : super(key: key);

  @override
  State<UniversalMediaWidget> createState() => _UniversalMediaWidgetState();
}

class _UniversalMediaWidgetState extends State<UniversalMediaWidget> {
  VideoPlayerController? _videoController;
  String? _cachedPath;
  bool _isLoading = false;
  HttpClientRequest? _currentRequest;
  IOSink? _currentSink;
  bool _disposed = false;

  bool get _isVideo {
    final ext = path.extension(widget.mediaPath).toLowerCase();
    return ['.mp4', '.mov', '.avi', '.wmv', '.webm', '.mkv'].contains(ext);
  }

  bool get _isNetworkPath {
    return widget.mediaPath.startsWith('http://') || widget.mediaPath.startsWith('https://');
  }

  bool get _isAssetPath {
    return !_isNetworkPath && !widget.mediaPath.startsWith('/');
  }

  @override
  void initState() {
    super.initState();
    _initializeMedia();
  }

  @override
  void dispose() {
    _disposed = true;
    _disposeVideoController();
    _currentRequest?.close();
    _currentSink?.close();
    super.dispose();
  }

  @override
  void didUpdateWidget(UniversalMediaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mediaPath != widget.mediaPath) {
      _disposeVideoController();
      _initializeMedia();
    }
  }

  void _disposeVideoController() {
    _videoController?.dispose();
    _videoController = null;
    _cachedPath = null;
  }

  Future<void> _initializeMedia() async {
    if (_isVideo) {
      await _initializeVideo();
    } else if (_isNetworkPath && widget.enableCache) {
      await _cacheNetworkFile();
    }
  }

  Future<void> _initializeVideo() async {
    if (widget.mediaPath.isEmpty) {
      return;
    }

    String? videoPath = widget.mediaPath;

    if (_isNetworkPath && widget.enableCache) {
      videoPath = await _cacheNetworkFile();
    }

    if (videoPath == null) return;

    setState(() => _isLoading = true);

    try {
      _videoController = _isNetworkPath && !widget.enableCache
          ? VideoPlayerController.networkUrl(Uri.parse(videoPath))
          : _isAssetPath
          ? VideoPlayerController.asset(videoPath)
          : VideoPlayerController.file(File(videoPath));

      await _videoController?.initialize();
      await _videoController?.setLooping(true);
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Video initialization error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<String?> _cacheNetworkFile() async {
    if (_cachedPath != null) {
      debugPrint('Using existing cached file: $_cachedPath');
      // 新增：已缓存也回调
      widget.onCacheCompleted?.call(_cachedPath!);
      return _cachedPath;
    }

    if (_disposed) return null;
    setState(() => _isLoading = true);

    try {
      final cacheDir = await getApplicationCacheDirectory();
      final fileName = path.basename(widget.mediaPath).replaceAll("?", "");
      final cachedFile = File('${cacheDir.path}/$fileName');

      if (await cachedFile.exists()) {
        debugPrint('File already exists in cache');
        _cachedPath = cachedFile.path;
        // 新增：已缓存也回调
        widget.onCacheCompleted?.call(_cachedPath!);
        return _cachedPath;
      }

      debugPrint('Downloading file from network...');
      _currentRequest = await HttpClient().getUrl(Uri.parse(widget.mediaPath));
      final httpResponse = await _currentRequest!.close();

      if (_disposed) {
        await cachedFile.delete();
        return null;
      }

      if (httpResponse.statusCode != 200) {
        debugPrint('Download failed with status: ${httpResponse.statusCode}');
        return null;
      }

      final contentLength = httpResponse.contentLength;
      var receivedBytes = 0;
      _currentSink = cachedFile.openWrite();

      await for (final chunk in httpResponse) {
        if (_disposed) {
          await _currentSink?.close();
          await cachedFile.delete();
          return null;
        }
        _currentSink?.add(chunk);
        receivedBytes += chunk.length;
      }
      await _currentSink?.close();

      if (_disposed) {
        await cachedFile.delete();
        return null;
      }

      if (contentLength != null && receivedBytes != contentLength) {
        debugPrint('Download incomplete: received $receivedBytes of $contentLength bytes');
        await cachedFile.delete();
        return null;
      }

      debugPrint('File successfully cached: $receivedBytes bytes');
      _cachedPath = cachedFile.path;
      // 新增：下载完成后回调
      widget.onCacheCompleted?.call(_cachedPath!);
      return _cachedPath;
    } catch (e) {
      debugPrint('Cache error: $e');
      return null;
    } finally {
      if (!_disposed) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget contentWidget;

    if (_isLoading) {
      contentWidget = const Center(child: CircularProgressIndicator());
    } else if (_isVideo && _videoController != null) {
      if (_videoController!.value.isInitialized) {
        contentWidget = Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              // 使用Positioned.fill确保填满父容器
              child: FittedBox(
                // 使用FittedBox控制缩放
                fit: BoxFit.cover, // 保持比例，填满并裁剪
                child: SizedBox(
                  width: _videoController!.value.size.width,
                  height: _videoController!.value.size.height,
                  child: VideoPlayer(_videoController!),
                ),
              ),
            ),
            if (!widget.autoPlay) Image.asset('resources/images/icon_play.png', width: 48, height: 48),
          ],
        );

        if (widget.autoPlay && !_videoController!.value.isPlaying) {
          _videoController!.play();
        }
      } else {
        contentWidget = const Center(child: CircularProgressIndicator());
      }
    } else if (_isNetworkPath) {
      if (widget.enableCache && _cachedPath != null) {
        contentWidget = Image.file(
          File(_cachedPath!),
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Image.file error: $error');
            debugPrint('Stack trace: $stackTrace');
            return widget.errorWidget ?? const Center(child: Icon(Icons.error));
          },
        );
      } else {
        contentWidget = CachedNetworkImage(
          imageUrl: widget.mediaPath,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) {
            debugPrint('CachedNetworkImage error: $error');
            debugPrint('Failed URL: $url');
            return widget.errorWidget ?? const Center(child: Icon(Icons.error));
          },
        );
      }
    } else {
      contentWidget = _isAssetPath
          ? Image.asset(widget.mediaPath, width: widget.width, height: widget.height, fit: widget.fit)
          : Image.file(File(widget.mediaPath), width: widget.width, height: widget.height, fit: widget.fit);
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF2B2B2B), Color(0xFF111111)],
                ),
              ),
            ),
          ),
          Positioned.fill(child: contentWidget),
        ],
      ),
    );
  }
}
