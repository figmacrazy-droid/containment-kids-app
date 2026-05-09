import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'games_list_screen.dart';
import 'videos_list_screen.dart';
import 'images_list_screen.dart';
import '../admin/admin_login_screen.dart';
import 'age_selection_screen.dart';
import 'about_screen.dart'; // صفحة من نحن

class ChildHomeScreen extends StatefulWidget {
  const ChildHomeScreen({super.key});

  @override
  State<ChildHomeScreen> createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends State<ChildHomeScreen> {
  int _tapCount = 0;
  DateTime? _lastTapTime;
  String _currentAge = '4-6';

  @override
  void initState() {
    super.initState();
    _loadAge();
  }

  Future<void> _loadAge() async {
    final prefs = await SharedPreferences.getInstance();
    final age = prefs.getString('child_age') ?? '4-6';
    setState(() => _currentAge = age);
  }

  void _handleSecretTap() {
    if (_lastTapTime != null &&
        DateTime.now().difference(_lastTapTime!) > const Duration(seconds: 2)) {
      _tapCount = 0;
    }
    _lastTapTime = DateTime.now();
    _tapCount++;
    if (_tapCount >= 5) {
      _tapCount = 0;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
      );
    }
  }

  Widget _buildGameCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 400),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF28C28),
                    Color(0xFF1F7A7A),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 60, color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipOval(
              child: Image.asset(
                'image/شعار احتواء.png',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 40,
                  height: 40,
                  color: const Color(0xFFF28C28),
                  child: const Icon(Icons.recycling, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'عالم الأطفال',
              style: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F7A7A),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        actions: [
          // أيقونة "من نحن" (تظهر على اليسار)
          IconButton(
            icon: const Icon(Icons.info_outline, color: Color(0xFFF28C28)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
          ),
          // أيقونة تغيير العمر (تظهر على اليمين)
          IconButton(
            icon: const Icon(Icons.person, color: Color(0xFF1F7A7A)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AgeSelectionScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _BackgroundPainter()),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF28C28).withOpacity(0.3),
                        blurRadius: 25,
                        spreadRadius: 5,
                      ),
                    ],
                    image: const DecorationImage(
                      image: AssetImage('image/شعار احتواء.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'اختر نشاطك المفضل',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F7A7A),
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    childAspectRatio: 1.1,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: [
                      _buildGameCard(
                        icon: Icons.animation,
                        label: 'أنميشن',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VideosListScreen(
                              category: 'animation',
                              title: 'أنميشن',
                              ageGroup: _currentAge,
                            ),
                          ),
                        ),
                      ),
                      _buildGameCard(
                        icon: Icons.sports_esports,
                        label: 'ألعاب',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => GamesListScreen()),
                        ),
                      ),
                      _buildGameCard(
                        icon: Icons.recycling,
                        label: 'تدوير',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VideosListScreen(
                              category: 'recycling',
                              title: 'إعادة التدوير',
                              ageGroup: _currentAge,
                            ),
                          ),
                        ),
                      ),
                      _buildGameCard(
                        icon: Icons.photo_library,
                        label: 'صور',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ImagesListScreen(
                              category: 'general',
                              title: 'صور',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: GestureDetector(
              onTap: _handleSecretTap,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'image/شعار احتواء.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFF28C28),
                      child: const Icon(Icons.recycling, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);

    const Color orange = Color(0xFFF28C28);
    const Color teal = Color(0xFF1F7A7A);

    paint.color = orange.withOpacity(0.1);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.1), 80, paint);

    paint.color = teal.withOpacity(0.08);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.8), 100, paint);

    paint.color = orange.withOpacity(0.05);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.5), 120, paint);

    paint.color = teal.withOpacity(0.06);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.7), 70, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}