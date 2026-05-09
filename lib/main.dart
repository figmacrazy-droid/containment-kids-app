import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/child/age_selection_screen.dart';
import 'screens/child/child_home_screen.dart';

void main() {
  runApp(const IhtwaApp());
}

class IhtwaApp extends StatelessWidget {
  const IhtwaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'احتواء',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: GoogleFonts.cairo().fontFamily,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAge();
  }

  Future<void> _checkAge() async {
    final prefs = await SharedPreferences.getInstance();
    final age = prefs.getString('child_age');
    // انتظر 3 ثوانٍ ثم انتقل للشاشة المناسبة
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    if (age != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ChildHomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AgeSelectionScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final logoSize = size.width * 0.4;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipOval(
              child: Image.asset(
                'image/شعار احتواء.png',
                width: logoSize,
                height: logoSize,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFF28C28),
                  child: const Icon(Icons.error, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: size.height * 0.03),
            Text(
              'احتواء',
              style: GoogleFonts.cairo(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFF28C28),
              ),
            ),
            SizedBox(height: size.height * 0.01),
            Text(
              'لأطفالنا أجمل',
              style: GoogleFonts.cairo(
                fontSize: 16,
                color: const Color(0xFF1F7A7A),
              ),
            ),
            SizedBox(height: size.height * 0.05),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF28C28)),
            ),
          ],
        ),
      ),
    );
  }
}