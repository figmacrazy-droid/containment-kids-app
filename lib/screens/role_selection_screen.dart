import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_theme.dart';
import 'child/child_home_screen.dart';
import 'admin/admin_login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  List<Widget> _buildCartoonBackground(Size size) {
    return List.generate(15, (index) {
      return Positioned(
        top: (index * 40) % size.height,
        left: (index * 50) % size.width,
        child: Opacity(
          opacity: 0.1,
          child: Icon(
            CartoonIcons.list[index % CartoonIcons.list.length],
            size: size.width * (0.1 + index * 0.01),
            color: Colors.white,
          ),
        ),
      );
    });
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final size = MediaQuery.of(context).size;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: size.height * 0.02, horizontal: size.width * 0.05),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 6)),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: size.width * 0.07,
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, size: size.width * 0.07, color: color),
            ),
            SizedBox(width: size.width * 0.03),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: size.width * 0.05,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: size.width * 0.05, color: color.withOpacity(0.7)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // خلفية الشعار
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'image/icon.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(),
              ),
            ),
          ),
          // الخلفية المتدرجة
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFB74D), Color(0xFF4FC3F7)],
              ),
            ),
          ),
          // عناصر كرتونية
          ..._buildCartoonBackground(size),
          // المحتوى
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(size.width * 0.05),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipOval(
                    child: Image.asset(
                      'image/icon.png',
                      width: size.width * 0.25,
                      height: size.width * 0.25,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.recycling_outlined,
                        size: size.width * 0.12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
                  Text('أهلاً وسهلاً', style: AppTextStyles.title),
                  SizedBox(height: size.height * 0.05),
                  _buildRoleCard(
                    context: context,
                    icon: Icons.emoji_emotions,
                    label: 'عالم الأطفال',
                    color: AppColors.childButton,
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const ChildHomeScreen()),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  _buildRoleCard(
                    context: context,
                    icon: Icons.admin_panel_settings,
                    label: 'دخول الأدمن',
                    color: AppColors.adminButton,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}