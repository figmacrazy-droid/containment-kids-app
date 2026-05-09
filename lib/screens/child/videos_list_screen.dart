import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';
import 'custom_video_player.dart';

class VideosListScreen extends StatefulWidget {
  final String category;
  final String title;
  final String ageGroup; // ✅ جديد
  const VideosListScreen({
    super.key,
    required this.category,
    required this.title,
    this.ageGroup = '4-6', // افتراضي
  });

  @override
  State<VideosListScreen> createState() => _VideosListScreenState();
}

class _VideosListScreenState extends State<VideosListScreen> {
  late Future<List<dynamic>> _videosFuture;

  @override
  void initState() {
    super.initState();
    _videosFuture = ApiService.getVideos(
      category: widget.category,
      ageGroup: widget.ageGroup, // ✅ ترسل العمر للخادم
    );
  }

  String _formatDuration(int seconds) {
    if (seconds <= 0) return '0:00';
    final int minutes = seconds ~/ 60;
    final int secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: widget.category == 'animation' ? Colors.blue : Colors.green,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _videosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error}', style: GoogleFonts.cairo()));
          }
          final videos = snapshot.data!;
          if (videos.isEmpty) {
            return Center(child: Text('لا توجد فيديوهات', style: GoogleFonts.cairo(fontSize: 18)));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              final thumbnailUrl = video['thumbnail_path'] != null
                  ? '${ApiService.baseUploadUrl}/uploads/${video['thumbnail_path']}'
                  : null;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: InkWell(
                  onTap: () {
                    String videoUrl = '${ApiService.baseUploadUrl}/uploads/${video['video_path']}';
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CustomVideoPlayer(
                          videoUrl: videoUrl,
                          title: video['title'],
                        ),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: 200,
                            width: double.infinity,
                            child: thumbnailUrl != null
                                ? Image.network(
                              thumbnailUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image, size: 50, color: Colors.white),
                              ),
                            )
                                : Container(
                              color: Colors.grey[400],
                              child: const Icon(Icons.video_library, size: 60, color: Colors.white70),
                            ),
                          ),
                          Positioned.fill(
                            child: Center(
                              child: CircleAvatar(
                                radius: 35,
                                backgroundColor: Colors.white.withOpacity(0.9),
                                child: Icon(
                                  Icons.play_arrow,
                                  size: 45,
                                  color: widget.category == 'animation' ? Colors.blue : Colors.green,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.access_time, size: 14, color: Colors.white70),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatDuration(int.parse(video['duration']?.toString() ?? '0')),
                                    style: GoogleFonts.cairo(fontSize: 12, color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              video['title'] ?? 'بدون عنوان',
                              style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              video['description'] != null && video['description'].isNotEmpty
                                  ? video['description']
                                  : 'لا يوجد وصف',
                              style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey[600]),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}