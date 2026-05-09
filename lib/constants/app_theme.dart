import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primaryOrange = Color(0xFFF28C28);
  static const Color primaryTeal = Color(0xFF1F7A7A);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF8FAFC);
}

class AppTextStyles {
  static TextStyle title = GoogleFonts.cairo(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryOrange,
  );

  static TextStyle subtitle = GoogleFonts.cairo(
    fontSize: 18,
    color: AppColors.primaryTeal,
  );

  static TextStyle buttonLabel = GoogleFonts.cairo(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle smallLabel = GoogleFonts.cairo(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryTeal,
  );
}

// تم إزالة CartoonIcons بالكامل