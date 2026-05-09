import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_theme.dart';
import 'child/child_home_screen.dart';
import 'admin/admin_login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // الخلفية المتدرجة
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.backgroundStart, AppColors.backgroundEnd],
              ),
            ),
          ),
          // عناصر كرتونية في الخلفية
          ..._buildCartoonBackground(),
          // المحتوى
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // شعار مصغر
                  Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 15,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.recycling_outlined,
                          size: 60,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('أهلاً وسهلاً', style: AppTextStyles.title),
                  const SizedBox(height: 40),
                  // زر الطفل
                  _buildRoleCard(
                    context,
                    icon: Icons.emoji_emotions,
                    label: 'عالم الأطفال',
                    color: AppColors.childButton,
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const ChildHomeScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  // زر الأدمن
                  _buildRoleCard(
                    context,
                    icon: Icons.admin_panel_settings,
                    label: 'دخول الأدمن',
                    color: AppColors.adminButton,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 30),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(width: 20),
            Text(label, style: AppTextStyles.buttonLabel),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 30, color: color.withOpacity(0.7)),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCartoonBackground() {
    return List.generate(15, (index) {
      return Positioned(
        top: (index * 40) % 800,
        right: (index * 50) % 400,
        child: Opacity(
          opacity: 0.1,
          child: Icon(
            cartoonIcons[index % cartoonIcons.length],
            size: 70 + (index * 5) % 70,
            color: Colors.white,
          ),
        ),
      );
    });
  }
}