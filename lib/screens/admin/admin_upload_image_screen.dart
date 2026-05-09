import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_service.dart';

class AdminUploadImageScreen extends StatefulWidget {
  const AdminUploadImageScreen({super.key});

  @override
  State<AdminUploadImageScreen> createState() => _AdminUploadImageScreenState();
}

class _AdminUploadImageScreenState extends State<AdminUploadImageScreen> {
  File? _selectedImage;
  String? _imageName;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _uploadMessage;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'general';

  // 🎨 الألوان الجديدة وفق الهوية البصرية
  static const Color primaryOrange = Color(0xFFF28C28);      // برتقالي دافئ
  static const Color primaryTeal = Color(0xFF1F7A7A);        // أزرق مخضر
  static const Color successColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color cardBg = Colors.white;
  static const Color textDark = Color(0xFF1F2937);
  static const Color textLight = Color(0xFF6B7280);
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color inputBg = Color(0xFFF9FAFB);

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          _selectedImage = File(result.files.single.path!);
          _imageName = result.files.single.name;
          _uploadMessage = null;
        });
      }
    } catch (e) {
      setState(() => _uploadMessage = 'خطأ في اختيار الصورة: $e');
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedImage == null) {
      setState(() => _uploadMessage = 'الرجاء اختيار صورة أولاً');
      return;
    }

    if (_titleController.text.isEmpty) {
      setState(() => _uploadMessage = 'الرجاء إدخال عنوان الصورة');
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _uploadMessage = null;
    });

    try {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) setState(() => _uploadProgress = 0.2);
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _uploadProgress = 0.5);
      });
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _uploadProgress = 0.8);
      });

      print('🔍 بدء رفع الصورة...');
      String imagePath = await ApiService.uploadVideoFile(_selectedImage!.path);
      print('✅ تم رفع الصورة: $imagePath');

      print('🔍 إدخال بيانات الصورة...');
      await ApiService.addImage(
        title: _titleController.text,
        description: _descriptionController.text,
        imagePath: imagePath,
        category: _selectedCategory,
      );
      print('✅ تم إدخال بيانات الصورة بنجاح');

      setState(() {
        _uploadMessage = '✅ تم رفع الصورة بنجاح';
        _selectedImage = null;
        _imageName = null;
        _titleController.clear();
        _descriptionController.clear();
        _uploadProgress = 1.0;
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });
    } catch (e) {
      print('❌ فشل الرفع: $e');
      setState(() {
        _uploadMessage = '❌ فشل الرفع: $e';
        _isUploading = false;
      });
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
        title: Text(
          'رفع صورة جديدة',
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
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
          ),
        ),
        actions: [
          if (_selectedImage != null)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: const Icon(Icons.clear, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _selectedImage = null;
                    _imageName = null;
                  });
                },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(size.width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // بطاقة المعلومات الأساسية
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
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // حقل العنوان
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'عنوان الصورة',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _titleController,
                            style: GoogleFonts.cairo(fontSize: 16, color: textDark),
                            decoration: InputDecoration(
                              hintText: 'أدخل عنوان الصورة',
                              hintStyle: GoogleFonts.cairo(
                                color: textLight.withOpacity(0.5),
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(Icons.title, color: primaryOrange),
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
                                borderSide: BorderSide(
                                  color: primaryOrange,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: inputBg,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // حقل الوصف
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'وصف الصورة',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 3,
                            style: GoogleFonts.cairo(fontSize: 16, color: textDark),
                            decoration: InputDecoration(
                              hintText: 'أدخل وصفاً للصورة (اختياري)',
                              hintStyle: GoogleFonts.cairo(
                                color: textLight.withOpacity(0.5),
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(Icons.description, color: primaryOrange),
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
                                borderSide: BorderSide(
                                  color: primaryOrange,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: inputBg,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // قائمة التصنيف
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'التصنيف',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: inputBg,
                            ),
                            child: DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              items: const [
                                DropdownMenuItem(value: 'general', child: Text('📁 عام')),
                                DropdownMenuItem(value: 'recycling', child: Text('♻️ تدوير')),
                              ],
                              onChanged: (value) => setState(() => _selectedCategory = value!),
                              decoration: InputDecoration(
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
                                  borderSide: BorderSide(
                                    color: primaryOrange,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                              ),
                              style: GoogleFonts.cairo(fontSize: 16, color: textDark),
                              dropdownColor: cardBg,
                              icon: Icon(Icons.arrow_drop_down, color: primaryOrange),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // قسم اختيار الصورة
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
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ملف الصورة',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // منطقة رفع الصورة
                      InkWell(
                        onTap: _isUploading ? null : _pickImage,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _selectedImage != null ? successColor : borderColor,
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            color: inputBg,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Icon(
                                  _selectedImage != null ? Icons.check_circle : Icons.cloud_upload_outlined,
                                  size: 48,
                                  color: _selectedImage != null ? successColor : primaryOrange,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _selectedImage != null ? 'تم اختيار الصورة' : 'اضغط لاختيار صورة',
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: _selectedImage != null ? successColor : primaryOrange,
                                  ),
                                ),
                                if (_imageName != null) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: successColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.image, size: 16, color: successColor),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _imageName!,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.cairo(
                                              fontSize: 13,
                                              color: successColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),

                      // معاينة الصورة
                      if (_selectedImage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              _selectedImage!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // شريط التقدم
              if (_isUploading) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'جاري الرفع...',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: primaryOrange,
                            ),
                          ),
                          Text(
                            '${(_uploadProgress * 100).toInt()}%',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: primaryOrange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _uploadProgress,
                        backgroundColor: borderColor,
                        valueColor: AlwaysStoppedAnimation<Color>(primaryOrange),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // رسالة النتيجة
              if (_uploadMessage != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _uploadMessage!.contains('✅')
                        ? successColor.withOpacity(0.08)
                        : errorColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _uploadMessage!.contains('✅') ? successColor.withOpacity(0.2) : errorColor.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _uploadMessage!.contains('✅') ? Icons.check_circle : Icons.error_outline,
                        color: _uploadMessage!.contains('✅') ? successColor : errorColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _uploadMessage!,
                          style: GoogleFonts.cairo(
                            color: _uploadMessage!.contains('✅') ? successColor : errorColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // زر الرفع المتدرج
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: _selectedImage != null && !_isUploading
                      ? LinearGradient(
                    colors: [primaryOrange, primaryTeal],
                  )
                      : LinearGradient(
                    colors: [borderColor, borderColor],
                  ),
                  boxShadow: _selectedImage != null && !_isUploading
                      ? [
                    BoxShadow(
                      color: primaryOrange.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                      : null,
                ),
                child: ElevatedButton(
                  onPressed: (_isUploading || _selectedImage == null) ? null : _uploadFile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_isUploading ? Icons.hourglass_empty : Icons.cloud_upload),
                      const SizedBox(width: 8),
                      Text(
                        _isUploading ? 'جاري الرفع...' : 'رفع الصورة',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
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