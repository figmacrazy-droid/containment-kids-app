import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_theme.dart';
import 'video_management_screen.dart';
import 'image_management_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  // 🎨 الألوان الجديدة وفق الهوية البصرية
  static const Color primaryOrange = Color(0xFFF28C28);      // برتقالي دافئ
  static const Color primaryTeal = Color(0xFF1F7A7A);        // أزرق مخضر
  static const Color cardBg = Colors.white;
  static const Color cardShadow = Color(0xFF1E293B);
  static const Color accentPurple = Color(0xFF8B5CF6);       // قد نستخدمه للفيديو
  static const Color accentOrange = Color(0xFFF59E0B);       // للصور
  static const Color textDark = Color(0xFF1E293B);
  static const Color textLight = Color(0xFF64748B);

  List<Widget> _buildElegantBackground(Size size) {
    final icons = [
      Icons.admin_panel_settings,
      Icons.video_library,
      Icons.image,
      Icons.dashboard,
      Icons.settings,
      Icons.security,
    ];
    return List.generate(8, (index) {
      return Positioned(
        top: (index * 80) % size.height,
        right: (index * 90) % size.width,
        child: Opacity(
          opacity: 0.03,
          child: Icon(
            icons[index % icons.length],
            size: size.width * (0.12 + index * 0.01),
            color: primaryOrange,
          ),
        ),
      );
    });
  }

  Widget _buildAdminCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final size = MediaQuery.of(context).size;
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (label.hashCode % 200)),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cardBg,
                    cardBg.withOpacity(0.95),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: cardShadow.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: color.withOpacity(0.08),
                    blurRadius: 30,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(size.width * 0.025),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: size.width * 0.09,
                      color: color,
                    ),
                  ),
                  SizedBox(height: size.height * 0.015),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
                    child: Text(
                      label,
                      style: GoogleFonts.cairo(
                        fontSize: size.width * 0.038,
                        fontWeight: FontWeight.w700,
                        color: textDark,
                        letterSpacing: -0.3,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ),
                  SizedBox(height: size.height * 0.008),
                  Container(
                    width: size.width * 0.08,
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [color, color.withOpacity(0.3)]),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'ميزة "$feature" قيد التطوير',
          style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: primaryOrange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'image/شعار احتواء.png',
                  width: 42,
                  height: 42,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryOrange, primaryTeal],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'لوحة التحكم',
              style: GoogleFonts.cairo(
                fontSize: size.width * 0.055,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
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
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
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
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: Image.asset(
                'image/شعار احتواء.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(),
              ),
            ),
          ),
          ..._buildElegantBackground(size),
          Padding(
            padding: EdgeInsets.all(size.width * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.02),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.04,
                    vertical: size.height * 0.01,
                  ),
                  decoration: BoxDecoration(
                    color: primaryOrange.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.admin_panel_settings, size: 20, color: primaryOrange),
                      const SizedBox(width: 8),
                      Text(
                        'مرحباً أيها الأدمن',
                        style: GoogleFonts.cairo(
                          fontSize: size.width * 0.045,
                          fontWeight: FontWeight.w700,
                          color: textDark,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.012),
                Text(
                  'يمكنك إدارة المحتوى من هنا',
                  style: GoogleFonts.cairo(
                    fontSize: size.width * 0.032,
                    color: textLight,
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: size.height * 0.04),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: size.width * 0.04,
                    mainAxisSpacing: size.width * 0.04,
                    childAspectRatio: 0.9,
                    children: [
                      _buildAdminCard(
                        context: context,
                        icon: Icons.video_library_rounded,
                        label: 'إدارة الفيديوهات',
                        color: accentPurple,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const VideoManagementScreen()),
                          );
                        },
                      ),
                      _buildAdminCard(
                        context: context,
                        icon: Icons.image_rounded,
                        label: 'إدارة الصور',
                        color: accentOrange,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ImageManagementScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}