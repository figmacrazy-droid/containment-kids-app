import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'dart:async';

class RacingGame extends StatefulWidget {
  const RacingGame({super.key});

  @override
  State<RacingGame> createState() => _RacingGameState();
}

class _RacingGameState extends State<RacingGame> {
  static const int laneCount = 3; // 3 ممرات
  static const double laneWidth = 100.0; // عرض كل ممر
  static const double carSize = 60.0; // حجم السيارة
  static const int winScore = 10; // النقاط المطلوبة للفوز

  late int _playerLane; // ممر اللاعب (0, 1, 2)
  late List<Obstacle> _obstacles;
  late List<Coin> _coins; // عملات
  late Timer _gameTimer;
  late Timer _obstacleTimer;
  late Timer _coinTimer;
  int _score = 0;
  bool _gameOver = false;
  bool _gameWon = false;
  bool _gameStarted = false;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      _playerLane = 1; // الممر الأوسط
      _obstacles = [];
      _coins = [];
      _score = 0;
      _gameOver = false;
      _gameWon = false;
      _gameStarted = false;
    });
  }

  void _startGame() {
    if (_gameStarted) return;
    setState(() {
      _gameStarted = true;
      _gameOver = false;
      _gameWon = false;
    });

    // إنشاء عوائق كل 1.2 ثانية
    _obstacleTimer = Timer.periodic(const Duration(milliseconds: 1200), (timer) {
      if (_gameOver || _gameWon) {
        timer.cancel();
        return;
      }
      _addObstacle();
    });

    // إنشاء عملات كل 0.8 ثانية (لجعل اللعبة أكثر متعة)
    _coinTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (_gameOver || _gameWon) {
        timer.cancel();
        return;
      }
      _addCoin();
    });

    // تحديث حركة العناصر كل 50ms
    _gameTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_gameOver || _gameWon) {
        timer.cancel();
        return;
      }
      _updateElements();
    });
  }

  void _addObstacle() {
    int lane = _random.nextInt(laneCount);
    // التأكد من عدم تكدس العوائق في نفس الممر بشكل كبير
    bool tooManyInLane = _obstacles.where((o) => o.lane == lane).length >= 2;
    if (!tooManyInLane) {
      _obstacles.add(Obstacle(
        lane: lane,
        y: -carSize, // يبدأ من أعلى الشاشة
      ));
    }
  }

  void _addCoin() {
    int lane = _random.nextInt(laneCount);
    _coins.add(Coin(
      lane: lane,
      y: -carSize,
    ));
  }

  void _updateElements() {
    setState(() {
      // تحريك العوائق للأسفل
      for (int i = _obstacles.length - 1; i >= 0; i--) {
        _obstacles[i].y += 8; // سرعة العوائق

        // إزالة العوائق التي خرجت من الشاشة
        if (_obstacles[i].y > 600) {
          _obstacles.removeAt(i);
        }
      }

      // تحريك العملات للأسفل
      for (int i = _coins.length - 1; i >= 0; i--) {
        _coins[i].y += 8;

        // إزالة العملات التي خرجت من الشاشة
        if (_coins[i].y > 600) {
          _coins.removeAt(i);
        }
      }

      // التحقق من التصادم مع العوائق
      _checkCollision();
    });
  }

  void _checkCollision() {
    // موقع السيارة الثابت في الأسفل (حوالي y = 450)
    const double carY = 450;

    // التحقق من التصادم مع العوائق
    for (var obstacle in _obstacles) {
      if (obstacle.lane == _playerLane &&
          obstacle.y + carSize > carY &&
          obstacle.y < carY + carSize) {
        _gameOver = true;
        _stopTimers();
        break;
      }
    }

    // التحقق من جمع العملات
    for (int i = _coins.length - 1; i >= 0; i--) {
      var coin = _coins[i];
      if (coin.lane == _playerLane &&
          coin.y + carSize > carY &&
          coin.y < carY + carSize) {
        // تم جمع العملة
        _coins.removeAt(i);
        setState(() {
          _score++;
          if (_score >= winScore) {
            _gameWon = true;
            _stopTimers();
          }
        });
      }
    }
  }

  void _stopTimers() {
    _obstacleTimer.cancel();
    _coinTimer.cancel();
    _gameTimer.cancel();
  }

  void _moveLeft() {
    if (_gameOver || !_gameStarted || _gameWon) return;
    setState(() {
      _playerLane = max(0, _playerLane - 1);
    });
  }

  void _moveRight() {
    if (_gameOver || !_gameStarted || _gameWon) return;
    setState(() {
      _playerLane = min(laneCount - 1, _playerLane + 1);
    });
  }

  @override
  void dispose() {
    _stopTimers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('لعبة السباق', style: GoogleFonts.cairo()),
        backgroundColor: Colors.deepOrange,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'النقاط: $_score/$winScore',
              style: GoogleFonts.cairo(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // خلفية الطريق
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.grey.shade800, Colors.grey.shade600],
              ),
            ),
          ),
          // خطوط المسارات
          ...List.generate(laneCount + 1, (index) {
            return Positioned(
              left: index * laneWidth,
              top: 0,
              bottom: 0,
              child: Container(
                width: 2,
                color: Colors.white.withOpacity(0.3),
              ),
            );
          }),
          // العوائق (حمراء)
          ..._obstacles.map((obstacle) {
            return Positioned(
              left: obstacle.lane * laneWidth + (laneWidth - carSize) / 2,
              top: obstacle.y,
              child: Container(
                width: carSize,
                height: carSize,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning, color: Colors.white),
              ),
            );
          }).toList(),
          // العملات (صفراء)
          ..._coins.map((coin) {
            return Positioned(
              left: coin.lane * laneWidth + (laneWidth - carSize) / 2,
              top: coin.y,
              child: Container(
                width: carSize * 0.7,
                height: carSize * 0.7,
                decoration: const BoxDecoration(
                  color: Colors.yellow,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.star, color: Colors.amber, size: 30),
              ),
            );
          }).toList(),
          // سيارة اللاعب (في الأسفل)
          Positioned(
            left: _playerLane * laneWidth + (laneWidth - carSize) / 2,
            bottom: 20,
            child: Container(
              width: carSize,
              height: carSize,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(color: Colors.white, blurRadius: 10),
                ],
              ),
              child: const Icon(Icons.directions_car, color: Colors.white),
            ),
          ),
          // شاشة البداية / الفوز / الخسارة
          if (!_gameStarted || _gameOver || _gameWon)
            Center(
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _gameWon
                          ? '🎉البطل فاز 🎉'
                          : (_gameOver
                          ? '😵 خسرت!'
                          : 'لعبة السباق'),
                      style: GoogleFonts.cairo(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    if (_gameWon)
                      Text(
                        'لقد جمعت $_score نقطة!',
                        style: GoogleFonts.cairo(fontSize: 20, color: Colors.white),
                      ),
                    if (_gameOver)
                      Text(
                        'نقاطك: $_score',
                        style: GoogleFonts.cairo(fontSize: 20, color: Colors.white),
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _resetGame();
                        _startGame();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _gameWon ? Colors.green : Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      ),
                      child: Text(_gameWon || _gameOver ? 'حاول مرة أخرى' : 'ابدأ اللعبة'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.deepOrange,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, size: 40, color: Colors.white),
              onPressed: _moveLeft,
            ),
            Text('تحرك', style: GoogleFonts.cairo(color: Colors.white)),
            IconButton(
              icon: const Icon(Icons.arrow_forward, size: 40, color: Colors.white),
              onPressed: _moveRight,
            ),
          ],
        ),
      ),
    );
  }
}

class Obstacle {
  int lane; // الممر
  double y; // الموقع الرأسي

  Obstacle({required this.lane, required this.y});
}

class Coin {
  int lane; // الممر
  double y; // الموقع الرأسي

  Coin({required this.lane, required this.y});
}