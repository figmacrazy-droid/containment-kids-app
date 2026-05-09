import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ImageViewerScreen extends StatelessWidget {
  final String imageUrl;
  final String title;
  const ImageViewerScreen({super.key, required this.imageUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: GoogleFonts.cairo()),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(imageUrl, fit: BoxFit.contain),
        ),
      ),
    );
  }
}