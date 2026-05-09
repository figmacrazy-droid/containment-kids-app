// import 'package:flutter/material.dart';
// import 'package:fijkplayer/fijkplayer.dart';
//
// class FijkVideoPlayer extends StatefulWidget {
//   final String videoUrl;
//   final String title;
//   const FijkVideoPlayer({super.key, required this.videoUrl, required this.title});
//
//   @override
//   State<FijkVideoPlayer> createState() => _FijkVideoPlayerState();
// }
//
// class _FijkVideoPlayerState extends State<FijkVideoPlayer> {
//   late FijkPlayer player;
//
//   @override
//   void initState() {
//     super.initState();
//     player = FijkPlayer();
//     player.setDataSource(widget.videoUrl, autoPlay: true).catchError((error) {
//       print('❌ خطأ في تحميل الفيديو: $error');
//     });
//   }
//
//   @override
//   void dispose() {
//     player.release(); // تحرير الموارد
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//         backgroundColor: Colors.blue,
//       ),
//       body: FijkView(
//         player: player,
//         // سيتم عرض واجهة التحكم الافتراضية عند لمس الفيديو
//       ),
//     );
//   }
// }