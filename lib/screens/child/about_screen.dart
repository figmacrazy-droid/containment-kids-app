import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  final String email = 'ahtiwaapp@gmail.com';

  Future<void> _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'استفسار حول تطبيق أبطال احتواء..',
      },
    );
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        throw 'لا يمكن فتح تطبيق البريد';
      }
    } catch (e) {
      print('خطأ: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('من نحن', style: GoogleFonts.cairo()),
        backgroundColor: const Color(0xFFF28C28),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          children: [
            // الشعار مع ظل
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: const DecorationImage(
                  image: AssetImage('image/شعار احتواء.png'),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF28C28).withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 6,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // اسم التطبيق
            Text(
              'أبطال احتواء',
              style: GoogleFonts.cairo(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFF28C28),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'لأطفالنا أجمل',
              style: GoogleFonts.cairo(
                fontSize: 16,
                color: const Color(0xFF1F7A7A),
              ),
            ),
            const SizedBox(height: 30),

            // قصة التطبيق
            _buildSection(
              icon: Icons.star_rounded,
              title: 'قصة التطبيق',
              content:
              'أبطال احتواء بدأ من فكرة بسيطة: نصنع مكان آمن وممتع للأطفال يتعلمون فيه حب البيئة وإعادة التدوير من غير تعقيد. '
                  'التطبيق يجمع بين الترفيه والتعليم في واجهة سهلة تناسب الصغار والكبار.',
            ),
            const SizedBox(height: 20),

            // الهدف
            _buildSection(
              icon: Icons.emoji_objects_rounded,
              title: 'هدفنا',
              content:
              'هدفنا نساعد الطفل يكتشف متعة التعلم من خلال فيديوهات أنميشن، ألعاب، وصور ملهمة. كل محتوى يتم اختياره بعناية عشان ينمي مهارات الطفل وقيمه الإيجابية.',
            ),
            const SizedBox(height: 20),

            // المميزات
            _buildSection(
              icon: Icons.check_circle_outline_rounded,
              title: 'ماذا تجد في التطبيق؟',
              content:
              '🎬 فيديوهات تعليمية هادفة\n'
                  '🧩 ألعاب ذاكرة وتركيب ومتاهات\n'
                  '♻️ قسم خاص عن إعادة التدوير\n'
                  '📸 مكتبة صور ملونة وجميلة\n'
                  '👶 واجهات مرتبة لكل الأعمار\n'
                  '🔒 محتوى آمن بإشراف الأهل والأدمن',
            ),
            const SizedBox(height: 30),

            Divider(thickness: 1, color: Colors.grey[300]),
            const SizedBox(height: 20),

            // قسم التواصل
            _buildSection(
              icon: Icons.email_outlined,
              title: 'تواصل معنا',
              content: 'إذا عندك سؤال أو اقتراح، تواصل معانا على:',
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: _sendEmail,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF28C28).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF28C28).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.mark_as_unread, color: Color(0xFFF28C28)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        email,
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          color: const Color(0xFF1F7A7A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFFF28C28)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'يسعدنا تواصلكم معنا 💚',
              style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  // ويدجت مساعد لكل قسم (مع أيقونة و عنوان و محتوى)
  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF28C28).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: const Color(0xFFF28C28), size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F7A7A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                content,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}