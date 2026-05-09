import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import '../../services/api_service.dart';

class AdminUploadScreen extends StatefulWidget {
  const AdminUploadScreen({super.key});

  @override
  State<AdminUploadScreen> createState() => _AdminUploadScreenState();
}

class _AdminUploadScreenState extends State<AdminUploadScreen> {
  File? _selectedVideo;
  File? _selectedThumbnail;
  String? _videoName;
  String? _thumbnailName;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _uploadMessage;
  VideoPlayerController? _videoController;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'animation';
  String _selectedAgeGroup = '4-6';

  // الألوان
  static const Color primaryOrange = Color(0xFFF28C28);
  static const Color primaryTeal = Color(0xFF1F7A7A);
  static const Color successColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color cardBg = Colors.white;
  static const Color textDark = Color(0xFF1F2937);
  static const Color textLight = Color(0xFF6B7280);
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color inputBg = Color(0xFFF9FAFB);

  @override
  void dispose() {
    _videoController?.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );
      if (result != null) {
        final file = File(result.files.single.path!);
        setState(() {
          _selectedVideo = file;
          _videoName = result.files.single.name;
          _uploadMessage = null;
          _videoController?.dispose();
          _videoController = VideoPlayerController.file(file)
            ..initialize().then((_) {
              setState(() {});
              _videoController?.play();
            });
        });
      }
    } catch (e) {
      setState(() => _uploadMessage = 'خطأ في اختيار الفيديو: $e');
    }
  }

  Future<void> _pickThumbnail() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (result != null) {
        setState(() {
          _selectedThumbnail = File(result.files.single.path!);
          _thumbnailName = result.files.single.name;
        });
      }
    } catch (e) {
      setState(() => _uploadMessage = 'خطأ في اختيار الصورة: $e');
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedVideo == null) {
      setState(() => _uploadMessage = 'الرجاء اختيار فيديو أولاً');
      return;
    }
    if (_titleController.text.isEmpty) {
      setState(() => _uploadMessage = 'الرجاء إدخال عنوان الفيديو');
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _uploadMessage = null;
    });

    try {
      int videoDuration = 0;
      try {
        final tempController = VideoPlayerController.file(_selectedVideo!);
        await tempController.initialize();
        videoDuration = tempController.value.duration.inSeconds;
        tempController.dispose();
      } catch (_) {}

      // استخدام onProgress لتحديث شريط التقدم
      String videoFilePath = await ApiService.uploadVideoFile(
        _selectedVideo!.path,
        onProgress: (sent, total) {
          if (total > 0) {
            setState(() {
              _uploadProgress = sent / total;
            });
          }
        },
      );

      String? thumbnailUrl;
      if (_selectedThumbnail == null) {
        final thumbnailPath = await VideoThumbnail.thumbnailFile(
          video: _selectedVideo!.path,
          thumbnailPath: (await getTemporaryDirectory()).path,
          imageFormat: ImageFormat.JPEG,
          quality: 75,
        );
        if (thumbnailPath != null) {
          thumbnailUrl = await ApiService.uploadVideoFile(thumbnailPath);
        }
      } else {
        thumbnailUrl = await ApiService.uploadVideoFile(_selectedThumbnail!.path);
      }

      await ApiService.addVideo(
        title: _titleController.text,
        description: _descriptionController.text,
        videoPath: videoFilePath,
        thumbnailPath: thumbnailUrl,
        duration: videoDuration,
        category: _selectedCategory,
        ageGroup: _selectedAgeGroup,
      );

      setState(() {
        _uploadMessage = '✅ تم رفع الفيديو بنجاح';
        _selectedVideo = null;
        _selectedThumbnail = null;
        _videoName = null;
        _thumbnailName = null;
        _titleController.clear();
        _descriptionController.clear();
        _videoController?.dispose();
        _videoController = null;
        _uploadProgress = 1.0;
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });
    } catch (e) {
      setState(() => _uploadMessage = '❌ فشل الرفع: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('رفع فيديو جديد', style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [primaryOrange, primaryTeal]),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
          ),
        ),
        actions: [
          if (_selectedVideo != null)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.white),
              onPressed: () => setState(() {
                _selectedVideo = null;
                _videoName = null;
                _videoController?.dispose();
                _videoController = null;
              }),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(size.width * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بطاقة المعلومات
            Container(
              decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20)]),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildTextField('عنوان الفيديو', _titleController),
                  const SizedBox(height: 20),
                  _buildTextField('وصف الفيديو', _descriptionController, maxLines: 3),
                  const SizedBox(height: 20),
                  _buildDropdown('التصنيف', _selectedCategory, ['animation', 'recycling'], ['🎬 أنميشن', '♻️ تدوير'], (v) => setState(() => _selectedCategory = v!)),
                  const SizedBox(height: 20),
                  _buildDropdown('الفئة العمرية', _selectedAgeGroup, ['1-3', '4-6', '7-12'], ['1-3 سنوات', '4-6 سنوات', '7-12 سنوات'], (v) => setState(() => _selectedAgeGroup = v!)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // اختيار الفيديو
            _buildFilePicker('ملف الفيديو', _videoName, _pickVideo, successColor),
            if (_selectedVideo != null && _videoController?.value.isInitialized == true) ...[
              const SizedBox(height: 16),
              ClipRRect(borderRadius: BorderRadius.circular(16), child: AspectRatio(aspectRatio: _videoController!.value.aspectRatio, child: VideoPlayer(_videoController!))),
            ],
            const SizedBox(height: 20),
            // الصورة المصغرة
            _buildFilePicker('الصورة المصغرة (اختياري)', _thumbnailName, _pickThumbnail, primaryOrange),
            const SizedBox(height: 24),
            // زر الرفع
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: _selectedVideo != null && !_isUploading ? [primaryOrange, primaryTeal] : [borderColor, borderColor]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: _selectedVideo != null && !_isUploading ? [BoxShadow(color: primaryOrange.withOpacity(0.3), blurRadius: 12)] : null,
              ),
              child: ElevatedButton(
                onPressed: (_isUploading || _selectedVideo == null) ? null : _uploadFile,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: Text('رفع الفيديو', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
            if (_isUploading) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(value: _uploadProgress, backgroundColor: borderColor, valueColor: AlwaysStoppedAnimation<Color>(primaryOrange)),
            ],
            if (_uploadMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: _uploadMessage!.contains('✅') ? successColor.withOpacity(0.1) : errorColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Text(_uploadMessage!, style: GoogleFonts.cairo(color: _uploadMessage!.contains('✅') ? successColor : errorColor)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600, color: textDark)),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: 'أدخل $label',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: borderColor)),
          filled: true,
          fillColor: inputBg,
        ),
      ),
    ]);
  }

  Widget _buildDropdown(String label, String value, List<String> items, List<String> labels, void Function(String?) onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600, color: textDark)),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        value: value,
        items: List.generate(items.length, (i) => DropdownMenuItem(value: items[i], child: Text(labels[i]))),
        onChanged: onChanged,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          filled: true,
          fillColor: inputBg,
        ),
      ),
    ]);
  }

  Widget _buildFilePicker(String label, String? name, VoidCallback onTap, Color color) {
    return Container(
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20)]),
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600, color: textDark)),
        const SizedBox(height: 16),
        InkWell(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(border: Border.all(color: name != null ? successColor : borderColor, width: 2), borderRadius: BorderRadius.circular(20), color: inputBg),
            child: Column(children: [
              Icon(name != null ? Icons.check_circle : Icons.cloud_upload_outlined, size: 48, color: name != null ? successColor : primaryOrange),
              const SizedBox(height: 12),
              Text(name ?? 'اضغط للاختيار', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w500, color: name != null ? successColor : primaryOrange)),
            ]),
          ),
        ),
      ]),
    );
  }
}