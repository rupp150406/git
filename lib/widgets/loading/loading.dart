import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

// A global class to preload and manage the video player
class VideoLoader {
  static final VideoLoader _instance = VideoLoader._internal();
  factory VideoLoader() => _instance;
  VideoLoader._internal();

  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isInitializing = false;

  Future<VideoPlayerController?> getController() async {
    if (_isInitialized && _controller != null) {
      return _controller;
    }

    if (_isInitializing) {
      // Wait until initialization is complete
      while (_isInitializing && !_isInitialized) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return _controller;
    }

    _isInitializing = true;
    try {
      _controller = VideoPlayerController.asset('assets/videos/loading.mp4');
      await _controller!.initialize();
      await _controller!.setLooping(true);
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing video player: $e');
      _controller = null;
    } finally {
      _isInitializing = false;
    }
    return _controller;
  }

  void disposeController() {
    if (_controller != null) {
      _controller!.dispose();
      _controller = null;
      _isInitialized = false;
    }
  }
}

class LoadingVideo extends StatefulWidget {
  const LoadingVideo({Key? key}) : super(key: key);

  @override
  State<LoadingVideo> createState() => _LoadingVideoState();
}

class _LoadingVideoState extends State<LoadingVideo> {
  VideoPlayerController? _controller;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _setupVideo();
  }

  Future<void> _setupVideo() async {
    _controller = await VideoLoader().getController();

    if (_controller != null) {
      if (!_controller!.value.isPlaying) {
        await _controller!.play();
      }

      if (mounted) {
        setState(() {
          _isReady = true;
        });
      }
    }
  }

  @override
  void dispose() {
    // Don't dispose the controller here since it's shared
    // The controller will be disposed when the app exits
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show a transparent widget while waiting to avoid flickering
    if (!_isReady || _controller == null) {
      return Container(color: Colors.transparent);
    }

    return Center(
      child: AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: VideoPlayer(_controller!),
      ),
    );
  }
}
