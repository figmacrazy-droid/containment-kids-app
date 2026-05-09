import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_upload_screen.dart';
import 'admin_videos_list_screen.dart';

class VideoManagementScreen extends StatelessWidget {
  const VideoManagementScreen({super.key});

  // 🎨 الألوان الجديدة وفق الهوية البصرية
  static const Color primaryOrange = Color(0xFFF28C28);      // برتقالي دافئ
  static const Color primaryTeal = Color(0xFF1F7A7A);        // أزرق مخضر
  static const Color uploadColor = primaryOrange;            // لون رفع الفيديو
  static const Color deleteColor = Color(0xFFEF4444);        // أحمر للحذف
  static const Color cardBg = Colors.white;
  static const Color textDark = Color(0xFF1F2937);
  static const Color textLight = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'إدارة الفيديوهات',
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
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(size.width * 0.06),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 500),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: primaryOrange.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.video_library_outlined,
                              size: 60,
                              color: primaryOrange,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'مكتبة الفيديوهات',
                            style: GoogleFonts.cairo(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: textDark,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'قم بإدارة الفيديوهات بكل سهولة',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: size.height * 0.06),

              _buildManagementCard(
                context: context,
                icon: Icons.cloud_upload_outlined,
                label: 'رفع فيديو جديد',
                color: uploadColor,
                gradientColors: [uploadColor, primaryTeal],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminUploadScreen()),
                  );
                },
              ),
              SizedBox(height: size.height * 0.02),

              _buildManagementCard(
                context: context,
                icon: Icons.delete_outline,
                label: 'حذف فيديو',
                color: deleteColor,
                gradientColors: [deleteColor, deleteColor.withOpacity(0.8)],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminVideosListScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManagementCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    final size = MediaQuery.of(context).size;

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: size.height * 0.035),
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
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: color.withOpacity(0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(size.width * 0.025),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: gradientColors,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      size: size.width * 0.1,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: size.height * 0.015),
                  Text(
                    label,
                    style: GoogleFonts.cairo(
                      fontSize: size.width * 0.042,
                      fontWeight: FontWeight.w700,
                      color: textDark,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: size.height * 0.008),
                  Container(
                    width: size.width * 0.1,
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.3)],
                      ),
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
}