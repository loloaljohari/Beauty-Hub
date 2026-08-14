import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoThumbnailWidget extends StatefulWidget {
  final String videoPath;
  final String baseUrl;

  const VideoThumbnailWidget({
    super.key,
    required this.videoPath,
    this.baseUrl = "http://10.0.2.2:8000/storage/",
  });

  @override
  State<VideoThumbnailWidget> createState() => _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState extends State<VideoThumbnailWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initThumbnail();
  }

  void _initThumbnail() {
    final path = widget.videoPath;

    // 1. تحديد مصدر الفيديو (محلي أو سيرفر)
    if (path.startsWith('http://') || path.startsWith('https://')) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(path));
    } else if (path.startsWith('/') || path.startsWith('file://')) {
      _controller = VideoPlayerController.file(File(path));
    } else {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse('${widget.baseUrl}$path'),
      );
    }

    // 2. تهيئة المشغل للحصول على الإطار الأول فقط دون تشغيله
    _controller.initialize().then((_) {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // تفريغ الذاكرة
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        color: Colors.grey.shade300,
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        // عرض الإطار الأول من الفيديو ليملأ الحاوية كصورة
        SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: VideoPlayer(_controller),
            ),
          ),
        ),

        // أيقونة الفيديو فوق الصورة للتمييز
        Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: Colors.black54,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.play_arrow,
            color: Colors.white,
            size: 24,
          ),
        ),
      ],
    );
  }
}