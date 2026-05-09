import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class ApiService {
  static String get baseUploadUrl => baseUrl.replaceFirst('/api', '');
  static const String baseUrl = 'https://containmentapp.alwaysdata.net/api';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // ========== جلب الفيديوهات (يمكن فلترتها حسب التصنيف والعمر) ==========
  static Future<List<dynamic>> getVideos({
    String? category,
    String? ageGroup,
  }) async {
    try {
      String url = '$baseUrl/videos.php';
      Map<String, String> params = {};
      if (category != null) params['category'] = category;
      if (ageGroup != null) params['age_group'] = ageGroup;
      if (params.isNotEmpty) {
        url += '?${Uri(queryParameters: params).query}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('فشل تحميل الفيديوهات (رمز: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // ========== إضافة فيديو جديد (يدعم العمر والحالة) ==========
  static Future<Map<String, dynamic>> addVideo({
    required String title,
    required String description,
    required String videoPath,
    String? thumbnailPath,
    int duration = 0,
    required String category,
    String ageGroup = '', // ← المعامل الجديد للفئة العمرية
    int status = 1,       // ← حالة الفيديو (ظاهر تلقائياً)
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('لا يوجد توكن، يرجى تسجيل الدخول');

      final url = Uri.parse('$baseUrl/videos.php?token=$token');
      final body = json.encode({
        'title': title,
        'description': description,
        'video_path': videoPath,
        'thumbnail_path': thumbnailPath,
        'duration': duration,
        'category': category,
        'age_group': ageGroup,  // ← أضفناه هنا
        'status': status,
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('انتهت الجلسة، يرجى تسجيل الدخول مجدداً');
      } else {
        throw Exception('فشل إضافة الفيديو (رمز: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('خطأ في إضافة الفيديو: $e');
    }
  }

  // ========== رفع ملف فيديو ==========
  static Future<String> uploadVideoFile(String filePath, {void Function(int, int)? onProgress}) async {
    final token = await _getToken();
    if (token == null) throw Exception('لا يوجد توكن');

    var dio = Dio();
    var formData = FormData.fromMap({
      'video': await MultipartFile.fromFile(filePath),
    });

    try {
      var response = await dio.post(
        '$baseUrl/upload.php?token=$token',
        data: formData,
        onSendProgress: onProgress,
        options: Options(
          receiveTimeout: const Duration(minutes: 60),
          sendTimeout: const Duration(minutes: 60),
        ),
      );

      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        if (jsonResponse is String) {
          jsonResponse = json.decode(jsonResponse);
        }
        if (jsonResponse['success'] == true) {
          return jsonResponse['file_path'];
        }
        throw Exception(jsonResponse['message'] ?? 'فشل غير معروف');
      }
      throw Exception('فشل رفع الفيديو');
    } catch (e) {
      throw Exception('خطأ في الرفع: $e');
    }
  }

  // ========== رفع صورة (اختياري إذا أردت فصله) ==========
  static Future<String> uploadImageFile(String filePath) async {
    final token = await _getToken();
    if (token == null) throw Exception('لا يوجد توكن');

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/upload_image.php?token=$token'),
    );
    request.files.add(await http.MultipartFile.fromPath('image', filePath));

    var response = await request.send().timeout(const Duration(seconds: 300));
    var responseData = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(responseData.body);
      if (jsonResponse['success'] == true) {
        return jsonResponse['file_path'];
      }
      throw Exception(jsonResponse['message']);
    }
    throw Exception('فشل رفع الصورة');
  }

  // ========== حذف فيديو ==========
  static Future<void> deleteVideo(int id) async {
    final token = await _getToken();
    if (token == null) throw Exception('لا يوجد توكن');

    final response = await http.delete(
      Uri.parse('$baseUrl/videos.php?id=$id&token=$token'),
    );
    if (response.statusCode != 200) {
      throw Exception('فشل حذف الفيديو');
    }
  }

  // ========== تحديث فيديو (PUT) ==========
  static Future<void> updateVideo(int id, Map<String, dynamic> data) async {
    final token = await _getToken();
    if (token == null) throw Exception('لا يوجد توكن');

    final response = await http.put(
      Uri.parse('$baseUrl/videos.php?id=$id&token=$token'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('فشل تحديث الفيديو');
    }
  }

  // ========== جلب جميع الصور ==========
  static Future<List<dynamic>> getImages({String? category}) async {
    try {
      String url = '$baseUrl/images.php';
      if (category != null) url += '?category=$category';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('فشل تحميل الصور');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // ========== إضافة صورة ==========
  static Future<Map<String, dynamic>> addImage({
    required String title,
    required String description,
    required String imagePath,
    String category = 'general',
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('لا يوجد توكن');

    final response = await http.post(
      Uri.parse('$baseUrl/images.php?token=$token'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'title': title,
        'description': description,
        'image_path': imagePath,
        'category': category,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('فشل إضافة الصورة');
    }
  }

  // ========== تحديث صورة ==========
  static Future<void> updateImage(int id, Map<String, dynamic> data) async {
    final token = await _getToken();
    if (token == null) throw Exception('لا يوجد توكن');

    final response = await http.put(
      Uri.parse('$baseUrl/images.php?id=$id&token=$token'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('فشل تحديث الصورة');
    }
  }

  // ========== حذف صورة ==========
  static Future<void> deleteImage(int id) async {
    final token = await _getToken();
    if (token == null) throw Exception('لا يوجد توكن');

    final response = await http.delete(
      Uri.parse('$baseUrl/images.php?id=$id&token=$token'),
    );
    if (response.statusCode != 200) {
      throw Exception('فشل حذف الصورة');
    }
  }
}