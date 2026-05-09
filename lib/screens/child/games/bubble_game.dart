import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'dart:async';

class BubbleGame extends StatefulWidget {
  const BubbleGame({super.key});

  @override
  State<BubbleGame> createState() => _BubbleGameState();
}

class _BubbleGameState extends State<BubbleGame> {
  List<Balloon> _balloons = [];
  int _score = 0;
  int _timeLeft = 30; // 30 ثانية
  Timer? _timer;
  bool _gameActive = false;
  final Random _random = Random();
  Timer? _balloonGenerator;
  Timer? _updateTimer; // ✅ مؤقت لتحديث حركة البالونات
  static const double _balloonSize = 60.0; // حجم البالون

  @override
  void dispose() {
    _timer?.cancel();
    _balloonGenerator?.cancel();
    _updateTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    _balloons.clear();
    _score = 0;
    _timeLeft = 30;
    _gameActive = true;

    // مؤقت العد التنازلي
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft <= 1) {
        _gameActive = false;
        timer.cancel();
        _balloonGenerator?.cancel();
        _updateTimer?.cancel();
      }
      setState(() {
        _timeLeft--;
      });
    });

    // توليد بالونات كل 700 مللي ثانية
    _balloonGenerator = Timer.periodic(const Duration(milliseconds: 700), (timer) {
      if (!_gameActive) {
        timer.cancel();
        return;
      }
      setState(() {
        _balloons.add(Balloon(
          id: DateTime.now().millisecondsSinceEpoch + _random.nextInt(1000),
          x: _random.nextDouble() * 0.8 + 0.1, // بين 0.1 و 0.9
          y: -0.05, // ✅ تبدأ من أعلى الشاشة
          color: Colors.primaries[_random.nextInt(Colors.primaries.length)],
        ));
      });
    });

    // ✅ تحديث حركة البالونات كل 30 مللي ثانية
    _updateTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!_gameActive) {
        timer.cancel();
        return;
      }
      setState(() {
        for (var balloon in _balloons) {
          balloon.y += 0.006; // سرعة الهبوط (تعبر الشاشة في ~5 ثوان)
        }
        // إزالة البالونات التي وصلت إلى أسفل الشاشة
        _balloons.removeWhere((b) => b.y > 1.0);
      });
    });
  }

  void _popBalloon(Balloon balloon) {
    if (!_gameActive) return;
    setState(() {
      _balloons.removeWhere((b) => b.id == balloon.id);
      _score++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('لعبة الوجه الضاحك', style: GoogleFonts.cairo()),
        backgroundColor: Colors.pink,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'النقاط: $_score',
              style: GoogleFonts.cairo(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // خلفية اللعبة
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.lightBlue.shade100, Colors.lightBlue.shade300],
              ),
            ),
          ),
          // البالونات
          ..._balloons.map((balloon) {
            return Positioned(
              left: balloon.x * size.width - _balloonSize / 2,
              top: balloon.y * size.height,
              child: GestureDetector(
                onTap: () => _popBalloon(balloon),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 50),
                  width: _balloonSize,
                  height: _balloonSize,
                  decoration: BoxDecoration(
                    color: balloon.color,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
                    ],
                  ),
                  child: const Icon(Icons.tag_faces, color: Colors.white, size: 30),
                ),
              ),
            );
          }).toList(),
          // عرض الوقت
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '⏱️ $_timeLeft',
                style: GoogleFonts.cairo(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          // شاشة البداية أو النهاية
          if (!_gameActive)
            Center(
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _timeLeft == 0 ? 'انتهى الوقت!' : 'لعبة الوجه الضاحك',
                      style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    if (_timeLeft == 0) Text('نقاطك: $_score', style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _startGame();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      ),
                      child: Text(_timeLeft == 0 ? 'حاول مرة أخرى' : 'ابدأ اللعبة'),
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

class Balloon {
  final int id;
  double x;
  double y;
  final Color color;

  Balloon({required this.id, required this.x, required this.y, required this.color});
}