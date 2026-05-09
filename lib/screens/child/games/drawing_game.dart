import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DrawingGame extends StatefulWidget {
  const DrawingGame({super.key});

  @override
  State<DrawingGame> createState() => _DrawingGameState();
}

class _DrawingGameState extends State<DrawingGame> {
  Color _selectedColor = Colors.red;
  double _strokeWidth = 5.0;
  List<DrawingPoint> _points = [];
  final List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.brown,
    Colors.black,
  ];

  void _clearCanvas() {
    setState(() {
      _points.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الرسم والتلوين', style: GoogleFonts.cairo()),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: _clearCanvas,
          ),
        ],
      ),
      body: Column(
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
          // شريط تحكم سمك الفرشاة
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.brush, color: Colors.purple),
                Expanded(
                  child: Slider(
                    value: _strokeWidth,
                    min: 2,
                    max: 20,
                    onChanged: (value) {
                      setState(() {
                        _strokeWidth = value;
                      });
                    },
                  ),
                ),
                Text('${_strokeWidth.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          // منطقة الرسم
          Expanded(
            child: GestureDetector(
              onPanStart: (details) {
                final RenderBox box = context.findRenderObject() as RenderBox;
                final point = box.globalToLocal(details.globalPosition);
                setState(() {
                  _points.add(DrawingPoint(
                    offset: point,
                    color: _selectedColor,
                    strokeWidth: _strokeWidth,
                  ));
                });
              },
              onPanUpdate: (details) {
                final RenderBox box = context.findRenderObject() as RenderBox;
                final point = box.globalToLocal(details.globalPosition);
                setState(() {
                  _points.add(DrawingPoint(
                    offset: point,
                    color: _selectedColor,
                    strokeWidth: _strokeWidth,
                  ));
                });
              },
              child: Container(
                color: Colors.white,
                child: CustomPaint(
                  painter: DrawingPainter(points: _points),
                  size: Size.infinite,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DrawingPoint {
  final Offset offset;
  final Color color;
  final double strokeWidth;

  DrawingPoint({
    required this.offset,
    required this.color,
    required this.strokeWidth,
  });
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint> points;

  DrawingPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length; i++) {
      if (i == 0) {
        _drawPoint(canvas, points[i]);
      } else {
        final p1 = points[i - 1];
        final p2 = points[i];
        _drawLine(canvas, p1, p2);
      }
    }
  }

  void _drawPoint(Canvas canvas, DrawingPoint point) {
    final paint = Paint()
      ..color = point.color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(point.offset, point.strokeWidth / 2, paint);
  }

  void _drawLine(Canvas canvas, DrawingPoint p1, DrawingPoint p2) {
    final paint = Paint()
      ..color = p1.color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = p1.strokeWidth;
    canvas.drawLine(p1.offset, p2.offset, paint);
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}