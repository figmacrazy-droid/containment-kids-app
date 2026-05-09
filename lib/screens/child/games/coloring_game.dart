import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ColoringGame extends StatefulWidget {
  const ColoringGame({super.key});

  @override
  State<ColoringGame> createState() => _ColoringGameState();
}

class _ColoringGameState extends State<ColoringGame> {
  // الألوان المتاحة
  final List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.brown,
  ];

  Color _selectedColor = Colors.red;

  // خريطة لتخزين ألوان كل جزء
  final Map<String, Color> _coloredParts = {
    'house_body': Colors.white,
    'roof': Colors.white,
    'door': Colors.white,
    'window': Colors.white,
    'sun': Colors.white,
    'tree': Colors.white,
  };

  // دالة لتلوين الجزء المحدد
  void _colorPart(String part) {
    setState(() {
      _coloredParts[part] = _selectedColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'لعبة التلوين',
          style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                _coloredParts.updateAll((key, value) => Colors.white);
              });
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE1BEE7), Color(0xFFBA68C8)],
          ),
        ),
        child: Column(
          children: [
            // شريط الألوان
            Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _colors.length,
                itemBuilder: (context, index) {
                  final color = _colors[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 60,
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: _selectedColor == color
                            ? Border.all(color: Colors.white, width: 4)
                            : null,
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // منطقة الرسم
            Expanded(
              child: Center(
                child: Container(
                  width: size.width * 0.9,
                  height: size.width * 0.9,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5)),
                    ],
                  ),
                  child: CustomPaint(
                    painter: ColoringPainter(coloredParts: _coloredParts),
                    size: Size(size.width * 0.9, size.width * 0.9),
                  ),
                ),
              ),
            ),
            // أزرار اختيار الأجزاء
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  _buildPartButton('جسم المنزل', 'house_body', Colors.brown),
                  _buildPartButton('السقف', 'roof', Colors.red),
                  _buildPartButton('الباب', 'door', Colors.orange),
                  _buildPartButton('النافذة', 'window', Colors.blue),
                  _buildPartButton('الشمس', 'sun', Colors.yellow),
                  _buildPartButton('الشجرة', 'tree', Colors.green),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة لبناء زر جزء الرسم
  Widget _buildPartButton(String label, String part, Color defaultColor) {
    return ElevatedButton(
      onPressed: () => _colorPart(part),
      style: ElevatedButton.styleFrom(
        backgroundColor: _coloredParts[part] == Colors.white ? defaultColor : _coloredParts[part],
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(
        label,
        style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// كلاس الرسم المخصص
class ColoringPainter extends CustomPainter {
  final Map<String, Color> coloredParts;

  ColoringPainter({required this.coloredParts});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..style = PaintingStyle.fill;

    // رسم جسم المنزل
    paint.color = coloredParts['house_body'] ?? Colors.white;
    Rect houseBodyRect = Rect.fromLTWH(size.width * 0.2, size.height * 0.4, size.width * 0.4, size.height * 0.4);
    canvas.drawRect(houseBodyRect, paint);

    // حدود جسم المنزل
    paint.style = PaintingStyle.stroke;
    paint.color = Colors.black;
    paint.strokeWidth = 2;
    canvas.drawRect(houseBodyRect, paint);

    // رسم السقف
    paint.style = PaintingStyle.fill;
    paint.color = coloredParts['roof'] ?? Colors.white;
    Path roofPath = Path()
      ..moveTo(size.width * 0.2, size.height * 0.4)
      ..lineTo(size.width * 0.4, size.height * 0.2)
      ..lineTo(size.width * 0.6, size.height * 0.4)
      ..close();
    canvas.drawPath(roofPath, paint);

    // حدود السقف
    paint.style = PaintingStyle.stroke;
    paint.color = Colors.black;
    canvas.drawPath(roofPath, paint);

    // رسم الباب
    paint.style = PaintingStyle.fill;
    paint.color = coloredParts['door'] ?? Colors.white;
    Rect doorRect = Rect.fromLTWH(size.width * 0.35, size.height * 0.6, size.width * 0.1, size.height * 0.2);
    canvas.drawRect(doorRect, paint);
    paint.style = PaintingStyle.stroke;
    canvas.drawRect(doorRect, paint);

    // رسم النافذة
    paint.style = PaintingStyle.fill;
    paint.color = coloredParts['window'] ?? Colors.white;
    Rect windowRect = Rect.fromLTWH(size.width * 0.25, size.height * 0.5, size.width * 0.08, size.height * 0.08);
    canvas.drawRect(windowRect, paint);
    paint.style = PaintingStyle.stroke;
    canvas.drawRect(windowRect, paint);

    // رسم الشمس
    paint.style = PaintingStyle.fill;
    paint.color = coloredParts['sun'] ?? Colors.white;
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.2), size.width * 0.1, paint);
    paint.style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.2), size.width * 0.1, paint);

    // رسم الشجرة
    paint.style = PaintingStyle.fill;
    paint.color = coloredParts['tree'] ?? Colors.white;
    Rect treeRect = Rect.fromLTWH(size.width * 0.7, size.height * 0.5, size.width * 0.15, size.height * 0.3);
    canvas.drawRect(treeRect, paint);
    paint.style = PaintingStyle.stroke;
    canvas.drawRect(treeRect, paint);
  }

  @override
  bool shouldRepaint(covariant ColoringPainter oldDelegate) {
    return oldDelegate.coloredParts != coloredParts;
  }
}