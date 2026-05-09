import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:google_fonts/google_fonts.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;
  const VideoPlayerScreen({super.key, required this.videoUrl, required this.title});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _videoController = VideoPlayerController.network(widget.videoUrl);
      await _videoController.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoController.value.aspectRatio,
        allowFullScreen: true,
        allowMuting: true,
        allowPlaybackSpeedChanging: true,

        // ✅ إظهار التحكمات بشكل دائم
        showControls: true,
        // ✅ إظهار التحكمات فور بدء التشغيل
        showControlsOnInitialize: true,

        // ✅ تخصيص ألوان شريط التقدم
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.red,
          handleColor: Colors.red,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.lightGreen,
        ),

        // ✅ معالج الأخطاء
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage,
              style: GoogleFonts.cairo(color: Colors.white),
            ),
          );
        },

        // ✅ اتجاهات الشاشة عند ملء الشاشة
        deviceOrientationsOnEnterFullScreen: [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.portraitUp,
        ],
      );

      setState(() => _isLoading = false);
    } catch (e) {
      print('❌ خطأ في تحميل الفيديو: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'تعذر تحميل الفيديو. تحقق من الاتصال.';
      });
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title, style: GoogleFonts.cairo()),
        backgroundColor: Colors.black87,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 60),
            const SizedBox(height: 16),
            Text(_errorMessage!, style: GoogleFonts.cairo(fontSize: 18, color: Colors.white)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _initializePlayer,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      )
          : Center(
        child: _chewieController != null
            ? Chewie(controller: _chewieController!)
            : const SizedBox(),
      ),
    );
  }
}