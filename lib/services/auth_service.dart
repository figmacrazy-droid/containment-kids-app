import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // ⚠️ استبدلي 192.168.1.100 بعنوان IP الصحيح لجهاز الكمبيوتر الخاص بك
  static const String baseUrl = 'http://containmentapp.alwaysdata.net/api';

  // ========== تسجيل الدخول ==========
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      // طباعة الاستجابة للتشخيص (يمكنك إزالتها بعد التأكد)
      print('🔍 استجابة تسجيل الدخول: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'فشل تسجيل الدخول (رمز: ${response.statusCode})'
        };
      }
    } catch (e) {
      print('❌ خطأ في الاتصال: $e');
      return {'success': false, 'message': 'خطأ في الاتصال: $e'};
    }
  }

  // ========== حفظ التوكن بعد تسجيل الدخول الناجح ==========
  static Future<void> saveToken(String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('user', json.encode(user));
    await prefs.setBool('isLoggedIn', true);
  }

  // ========== جلب التوكن المخزن ==========
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // ========== جلب معلومات المستخدم المخزنة ==========
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? userString = prefs.getString('user');
    if (userString != null) {
      return json.decode(userString);
    }
    return null;
  }

  // ========== التحقق من حالة تسجيل الدخول ==========
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  // ========== تسجيل الخروج ==========
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    await prefs.remove('isLoggedIn');
  }
}