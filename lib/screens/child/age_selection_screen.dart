import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'child_home_screen.dart';

class AgeSelectionScreen extends StatelessWidget {
  const AgeSelectionScreen({super.key});

  Future<void> _saveAge(String ageGroup, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('child_age', ageGroup);
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ChildHomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'اختر عمرك',
              style: GoogleFonts.cairo(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFF28C28),
              ),
            ),
            const SizedBox(height: 30),
            _buildAgeButton(context, '1-3', '1-3 سنوات', const Color(0xFF1F7A7A)),
            const SizedBox(height: 15),
            _buildAgeButton(context, '4-6', '4-6 سنوات', const Color(0xFFF28C28)),
            const SizedBox(height: 15),
            _buildAgeButton(context, '7-12', '7-12 سنوات', Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildAgeButton(BuildContext context, String age, String text, Color color) {
    return SizedBox(
      width: 200,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        onPressed: () => _saveAge(age, context),
        child: Text(text, style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold)),
      ),
    );
  }
}