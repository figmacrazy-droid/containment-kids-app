import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MemoryGame extends StatefulWidget {
  const MemoryGame({super.key});

  @override
  State<MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  final List<Map<String, dynamic>> _cards = [
    {'id': 1, 'content': '🐶', 'isMatched': false, 'isFlipped': false},
    {'id': 2, 'content': '🐱', 'isMatched': false, 'isFlipped': false},
    {'id': 3, 'content': '🐭', 'isMatched': false, 'isFlipped': false},
    {'id': 4, 'content': '🐹', 'isMatched': false, 'isFlipped': false},
    {'id': 5, 'content': '🐰', 'isMatched': false, 'isFlipped': false},
    {'id': 6, 'content': '🦊', 'isMatched': false, 'isFlipped': false},
    {'id': 7, 'content': '🐻', 'isMatched': false, 'isFlipped': false},
    {'id': 8, 'content': '🐼', 'isMatched': false, 'isFlipped': false},
  ];

  late List<Map<String, dynamic>> _gameCards;
  int? _firstSelectedIndex;
  int? _secondSelectedIndex;
  bool _isWaiting = false;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    List<Map<String, dynamic>> duplicatedCards = [];
    for (var card in _cards) {
      duplicatedCards.add({...card, 'id': card['id'] * 2});
      duplicatedCards.add({...card, 'id': card['id'] * 2 + 1});
    }
    duplicatedCards.shuffle();
    setState(() {
      _gameCards = duplicatedCards;
      _firstSelectedIndex = null;
      _secondSelectedIndex = null;
      _score = 0;
    });
  }

  void _onCardTap(int index) {
    if (_isWaiting ||
        _gameCards[index]['isFlipped'] ||
        _gameCards[index]['isMatched']) {
      return;
    }

    if (_firstSelectedIndex == null) {
      setState(() {
        _firstSelectedIndex = index;
        _gameCards[index]['isFlipped'] = true;
      });
    } else if (_secondSelectedIndex == null && index != _firstSelectedIndex) {
      setState(() {
        _secondSelectedIndex = index;
        _gameCards[index]['isFlipped'] = true;
      });
      _checkMatch();
    }
  }

  void _checkMatch() {
    if (_firstSelectedIndex != null && _secondSelectedIndex != null) {
      final firstCard = _gameCards[_firstSelectedIndex!];
      final secondCard = _gameCards[_secondSelectedIndex!];

      if (firstCard['content'] == secondCard['content']) {
        setState(() {
          _gameCards[_firstSelectedIndex!]['isMatched'] = true;
          _gameCards[_secondSelectedIndex!]['isMatched'] = true;
          _score += 10;
          _firstSelectedIndex = null;
          _secondSelectedIndex = null;
        });
      } else {
        setState(() => _isWaiting = true);
        Future.delayed(const Duration(milliseconds: 800), () {
          setState(() {
            _gameCards[_firstSelectedIndex!]['isFlipped'] = false;
            _gameCards[_secondSelectedIndex!]['isFlipped'] = false;
            _firstSelectedIndex = null;
            _secondSelectedIndex = null;
            _isWaiting = false;
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'لعبة الذاكرة',
          style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.amber,
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
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFE082), Color(0xFFFFB74D)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _gameCards.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _onCardTap(index),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _gameCards[index]['isMatched']
                                ? Colors.green.shade100
                                : (_gameCards[index]['isFlipped']
                                ? Colors.amber.shade100
                                : Colors.blue.shade200),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Center(
                            child: (_gameCards[index]['isFlipped'] ||
                                _gameCards[index]['isMatched'])
                                ? Text(
                              _gameCards[index]['content'],
                              style: const TextStyle(fontSize: 32),
                            )
                                : const Icon(
                              Icons.question_mark,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _initGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text(
                    'لعبة جديدة',
                    style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}