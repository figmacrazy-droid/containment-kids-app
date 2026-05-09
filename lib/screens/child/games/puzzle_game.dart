import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'dart:ui' as ui;

class PuzzleGame extends StatefulWidget {
  const PuzzleGame({super.key});

  @override
  State<PuzzleGame> createState() => _PuzzleGameState();
}

class _PuzzleGameState extends State<PuzzleGame> {
  late List<PuzzlePiece> _pieces;
  int _moves = 0;
  bool _gameCompleted = false;
  ui.Image? _loadedImage;
  String? _currentImageAsset;

  final List<String> _imageAssets = [
    'image/puzzle/animal1.jpg',
    'image/puzzle/animal2.jpg',
    'image/puzzle/animal3.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  Future<void> _initGame() async {
    setState(() {
      _loadedImage = null;
      _pieces = [];
    });

    _currentImageAsset = _imageAssets[Random().nextInt(_imageAssets.length)];

    // تحميل الصورة
    final ImageStream stream = Image.asset(_currentImageAsset!).image
        .resolve(ImageConfiguration.empty);
    stream.addListener(
      ImageStreamListener((info, _) {
        if (mounted) {
          setState(() {
            _loadedImage = info.image;
            _createPieces();
          });
        }
      }),
    );
  }

  void _createPieces() {
    if (_loadedImage == null) return;

    int pieceWidth = _loadedImage!.width ~/ 3;
    int pieceHeight = _loadedImage!.height ~/ 3;

    _pieces = [];
    for (int i = 0; i < 9; i++) {
      int row = i ~/ 3;
      int col = i % 3;
      _pieces.add(PuzzlePiece(
        id: i,
        correctIndex: i,
        srcRect: Rect.fromLTWH(
          (col * pieceWidth).toDouble(),
          (row * pieceHeight).toDouble(),
          pieceWidth.toDouble(),
          pieceHeight.toDouble(),
        ),
      ));
    }

    // خلط القطع (مع الاحتفاظ بالقطعة الفارغة في مكانها)
    _pieces.shuffle();
    // تأكد من أن القطعة الفارغة (id=8) هي التي ستبقى فارغة
    for (int i = 0; i < _pieces.length; i++) {
      _pieces[i] = _pieces[i].copyWith(currentIndex: i);
    }

    setState(() {});
  }

  void _onPieceTap(int index) {
    if (_gameCompleted) return;

    // إيجاد القطعة الفارغة (id == 8)
    int emptyIndex = _pieces.indexWhere((piece) => piece.id == 8);
    if (emptyIndex == -1) return;

    // التحقق من التجاور
    int row1 = index ~/ 3;
    int col1 = index % 3;
    int row2 = emptyIndex ~/ 3;
    int col2 = emptyIndex % 3;

    bool areAdjacent = (row1 == row2 && (col1 - col2).abs() == 1) ||
        (col1 == col2 && (row1 - row2).abs() == 1);

    if (areAdjacent) {
      setState(() {
        // تبديل القطع
        var temp = _pieces[index];
        _pieces[index] = _pieces[emptyIndex];
        _pieces[emptyIndex] = temp;
        _moves++;
        _checkCompletion();
      });
    }
  }

  void _checkCompletion() {
    bool completed = true;
    for (int i = 0; i < _pieces.length; i++) {
      if (_pieces[i].id != _pieces[i].correctIndex) {
        completed = false;
        break;
      }
    }
    if (completed) {
      _gameCompleted = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'لعبة التركيب',
          style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'حركات: $_moves',
              style: GoogleFonts.cairo(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // خلفية الشعار (خفيفة)
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
          // خلفية متدرجة
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF81D4FA), Color(0xFF4FC3F7)],
              ),
            ),
          ),
          // المحتوى الرئيسي
          Column(
            children: [
              if (_gameCompleted)
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    '🎉 أحسنت! أكملت اللعبة في $_moves حركة 🎉',
                    style: GoogleFonts.cairo(fontSize: 20, color: Colors.white),
                  ),
                ),
              Expanded(
                child: _loadedImage == null
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    final piece = _pieces.firstWhere(
                          (p) => p.currentIndex == index,
                      orElse: () => _pieces.first,
                    );
                    if (piece.id == 8) {
                      // القطعة الفارغة
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      );
                    }
                    return GestureDetector(
                      onTap: () => _onPieceTap(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CustomPaint(
                            painter: PiecePainter(
                              image: _loadedImage!,
                              srcRect: piece.srcRect,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                  onPressed: _initGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(
                    'لعبة جديدة',
                    style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// كلاس يمثل قطعة البازل
class PuzzlePiece {
  final int id; // الرقم الفريد للقطعة (0-7 قطع قابلة للحركة، 8 فارغة)
  final int correctIndex; // المكان الصحيح لهذه القطعة (يساوي id)
  final int currentIndex; // المكان الحالي في الشبكة
  final Rect srcRect; // المستطيل من الصورة الأصلية

  PuzzlePiece({
    required this.id,
    required this.correctIndex,
    required this.srcRect,
    this.currentIndex = -1,
  });

  PuzzlePiece copyWith({int? currentIndex}) {
    return PuzzlePiece(
      id: id,
      correctIndex: correctIndex,
      srcRect: srcRect,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

// كلاس لرسم جزء من الصورة
class PiecePainter extends CustomPainter {
  final ui.Image image;
  final Rect srcRect;

  PiecePainter({required this.image, required this.srcRect});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImageRect(
      image,
      srcRect,
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint(),
    );
  }

  @override
  bool shouldRepaint(covariant PiecePainter oldDelegate) {
    return oldDelegate.image != image || oldDelegate.srcRect != srcRect;
  }
}