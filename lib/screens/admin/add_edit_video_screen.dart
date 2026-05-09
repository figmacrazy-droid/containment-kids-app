import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

final supabase = Supabase.instance.client;

class AddEditVideoScreen extends StatefulWidget {
  final String category;
  final Map<String, dynamic>? video;

  const AddEditVideoScreen({
    super.key,
    required this.category,
    this.video,
  });

  @override
  State<AddEditVideoScreen> createState() => _AddEditVideoScreenState();
}

class _AddEditVideoScreenState extends State<AddEditVideoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _videoFile;
  String? _existingVideoUrl;
  bool _isLoading = false;

  // 🎨 الألوان الجديدة وفق الهوية البصرية
  static const Color primaryOrange = Color(0xFFF28C28);      // برتقالي دافئ
  static const Color primaryTeal = Color(0xFF1F7A7A);        // أزرق مخضر
  static const Color lightBg = Color(0xFFF8FAFC);            // خلفية بيضاء ناعمة
  static const Color cardBg = Colors.white;
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color labelColor = Color(0xFF4B5563);
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color successColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    if (widget.video != null) {
      _titleController.text = widget.video!['title'];
      _descriptionController.text = widget.video!['description'];
      _existingVideoUrl = widget.video!['video_url'];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );
    if (result != null) {
      setState(() {
        _videoFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      String? videoUrl = _existingVideoUrl;

      if (_videoFile != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.mp4';
        final path = 'videos/${widget.category}/$fileName';
        await supabase.storage.from('videos').upload(path, _videoFile!);
        videoUrl = supabase.storage.from('videos').getPublicUrl(path);
      }

      if (videoUrl == null || videoUrl.isEmpty) {
        throw Exception('لم يتم الحصول على رابط الفيديو');
      }

      final data = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'video_url': videoUrl,
        'category': widget.category,
      };

      if (widget.video == null) {
        await supabase.from('videos').insert(data);
      } else {
        await supabase.from('videos').update(data).eq('id', widget.video!['id']);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ تم الحفظ بنجاح', style: GoogleFonts.cairo(color: Colors.white)),
            backgroundColor: successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ خطأ: $e', style: GoogleFonts.cairo(color: Colors.white)),
          backgroundColor: errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        title: Text(
          widget.video == null ? 'إضافة فيديو جديد' : 'تعديل الفيديو',
          style: GoogleFonts.cairo(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryOrange, primaryTeal],
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(primaryOrange),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // بطاقة العنوان والوصف
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        style: GoogleFonts.cairo(color: textPrimary),
                        decoration: InputDecoration(
                          labelText: 'عنوان الفيديو',
                          labelStyle: GoogleFonts.cairo(color: labelColor),
                          floatingLabelStyle: GoogleFonts.cairo(
                            color: primaryOrange,
                            fontWeight: FontWeight.w600,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: primaryOrange, width: 2),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                        ),
                        validator: (value) => value!.isEmpty ? 'الرجاء إدخال العنوان' : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        style: GoogleFonts.cairo(color: textPrimary),
                        decoration: InputDecoration(
                          labelText: 'وصف الفيديو',
                          labelStyle: GoogleFonts.cairo(color: labelColor),
                          floatingLabelStyle: GoogleFonts.cairo(color: primaryOrange),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: primaryOrange, width: 2),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // قسم رفع الفيديو
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ملف الفيديو',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: labelColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: _pickVideo,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: borderColor, width: 2),
                            borderRadius: BorderRadius.circular(20),
                            color: const Color(0xFFF9FAFB),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.cloud_upload_outlined,
                                  size: 48,
                                  color: primaryOrange.withOpacity(0.7),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'اضغط لاختيار فيديو',
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: primaryOrange,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (_videoFile != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: successColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check_circle, size: 16, color: successColor),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _videoFile!.path.split('/').last,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.cairo(fontSize: 13, color: successColor),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else if (_existingVideoUrl != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: primaryOrange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.video_library, size: 16, color: primaryOrange),
                                        const SizedBox(width: 8),
                                        Text(
                                          'فيديو موجود',
                                          style: GoogleFonts.cairo(fontSize: 13, color: primaryOrange),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // زر الحفظ (برتقالي)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [primaryOrange, primaryTeal],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryOrange.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Text(
                    widget.video == null ? '✨ إضافة الفيديو' : '🔄 تحديث الفيديو',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}