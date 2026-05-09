import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class MazeGame extends StatefulWidget {
  const MazeGame({super.key});

  @override
  State<MazeGame> createState() => _MazeGameState();
}

class _MazeGameState extends State<MazeGame> {
  final List<List<int>> _maze = [
    [1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 0, 0, 0, 1, 0, 0, 0, 1],
    [1, 0, 1, 0, 1, 0, 1, 0, 1],
    [1, 0, 1, 0, 0, 0, 1, 0, 1],
    [1, 0, 1, 1, 1, 0, 1, 0, 1],
    [1, 0, 0, 0, 0, 0, 1, 0, 1],
    [1, 0, 1, 1, 1, 1, 1, 0, 1],
    [1, 0, 0, 0, 0, 0, 0, 0, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1],
  ];

  late int _playerRow, _playerCol;
  late int _targetRow, _targetCol;
  int _targetsReached = 0;
  int _moves = 0;
  bool _showMessage = false;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      _playerRow = 1;
      _playerCol = 1;
      _moves = 0;
      _targetsReached = 0;
      _setRandomTarget();
      _showMessage = false;
    });
  }

  void _setRandomTarget() {
    List<Map<String, int>> availablePositions = [];
    for (int r = 0; r < _maze.length; r++) {
      for (int c = 0; c < _maze[r].length; c++) {
        if (_maze[r][c] == 0 && !(r == 1 && c == 1)) {
          availablePositions.add({'row': r, 'col': c});
        }
      }
    }
    if (availablePositions.isNotEmpty) {
      final random = Random();
      final pos = availablePositions[random.nextInt(availablePositions.length)];
      _targetRow = pos['row']!;
      _targetCol = pos['col']!;
    } else {
      _targetRow = 7;
      _targetCol = 7;
    }
  }

  void _movePlayer(int dRow, int dCol) {
    int newRow = _playerRow + dRow;
    int newCol = _playerCol + dCol;

    if (newRow >= 0 &&
        newRow < _maze.length &&
        newCol >= 0 &&
        newCol < _maze[0].length &&
        _maze[newRow][newCol] == 0) {
      setState(() {
        _playerRow = newRow;
        _playerCol = newCol;
        _moves++;

        if (_playerRow == _targetRow && _playerCol == _targetCol) {
          _targetsReached++;
          _showMessage = true;
          _message = '🎉 أحسنت! وصلت للهدف رقم $_targetsReached';
          Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              _playerRow = 1;
              _playerCol = 1;
              _moves = 0;
              _setRandomTarget();
              _showMessage = false;
            });
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cellSize = size.width / 9;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'لعبة المتاهة',
          style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'الهدف رقم: $_targetsReached',
              style: GoogleFonts.cairo(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
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
          // الخلفية
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF81D4FA), Color(0xFF4FC3F7)],
              ),
            ),
          ),
          // المحتوى
          Column(
            children: [
              if (_showMessage)
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    _message,
                    style: GoogleFonts.cairo(fontSize: 20, color: Colors.white),
                  ),
                ),
              Expanded(
                child: Center(
                  child: Container(
                    width: cellSize * 9,
                    height: cellSize * 9,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5)),
                      ],
                    ),
                    child: Stack(
                      children: [
                        for (int row = 0; row < _maze.length; row++)
                          for (int col = 0; col < _maze[row].length; col++)
                            if (_maze[row][col] == 1)
                              Positioned(
                                top: row * cellSize,
                                left: col * cellSize,
                                child: Container(
                                  width: cellSize,
                                  height: cellSize,
                                  decoration: BoxDecoration(
                                    color: Colors.brown.shade400,
                                    border: Border.all(color: Colors.brown.shade600),
                                  ),
                                ),
                              ),
                        Positioned(
                          top: _targetRow * cellSize,
                          left: _targetCol * cellSize,
                          child: Container(
                            width: cellSize,
                            height: cellSize,
                            decoration: BoxDecoration(
                              color: Colors.yellow.shade700,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.orange, width: 2),
                            ),
                            child: const Icon(Icons.flag, color: Colors.white, size: 20),
                          ),
                        ),
                        Positioned(
                          top: _playerRow * cellSize,
                          left: _playerCol * cellSize,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: cellSize,
                            height: cellSize,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: const [
                                BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                              ],
                            ),
                            child: const Icon(Icons.person, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildControlButton(Icons.arrow_upward, () => _movePlayer(-1, 0)),
                    _buildControlButton(Icons.arrow_downward, () => _movePlayer(1, 0)),
                    _buildControlButton(Icons.arrow_back, () => _movePlayer(0, -1)),
                    _buildControlButton(Icons.arrow_forward, () => _movePlayer(0, 1)),
                    _buildControlButton(Icons.refresh, _resetGame, color: Colors.amber),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onPressed, {Color color = Colors.teal}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(16),
      ),
      child: Icon(icon, size: 30),
    );
  }
}