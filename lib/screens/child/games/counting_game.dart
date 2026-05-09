import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class CountingGame extends StatefulWidget {
  const CountingGame({super.key});

  @override
  State<CountingGame> createState() => _CountingGameState();
}

class _CountingGameState extends State<CountingGame> {
  final List<Map<String, dynamic>> _questions = [
    {'count': 3, 'answers': [2, 3, 4, 5], 'emoji': '🐶'},
    {'count': 5, 'answers': [4, 5, 6, 7], 'emoji': '🐱'},
    {'count': 2, 'answers': [1, 2, 3, 4], 'emoji': '🍎'},
    {'count': 4, 'answers': [3, 4, 5, 6], 'emoji': '🚗'},
  ];

  late int _currentQuestionIndex;
  late int _score;
  bool _showResult = false;
  bool _answered = false;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _showResult = false;
      _answered = false;
      _questions.shuffle();
    });
  }

  void _checkAnswer(int selected) {
    if (_answered) return;

    setState(() {
      _answered = true;
      if (selected == _questions[_currentQuestionIndex]['count']) {
        _score += 10;
        _message = '✅ أحسنت!';
      } else {
        _message = '❌ حاول مرة أخرى';
      }
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _answered = false;
        });
      } else {
        setState(() {
          _showResult = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (_showResult) {
      return Scaffold(
        appBar: AppBar(
          title: Text('النتيجة', style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: Colors.orange,
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
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('لقد حصلت على', style: GoogleFonts.cairo(fontSize: 28, color: Colors.white)),
                  const SizedBox(height: 20),
                  Text('$_score', style: GoogleFonts.cairo(fontSize: 80, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 10),
                  Text('نقطة', style: GoogleFonts.cairo(fontSize: 28, color: Colors.white)),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _resetGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text('العب مرة أخرى', style: GoogleFonts.cairo(fontSize: 20, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final question = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'لعبة العد',
          style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.orange,
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
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: List.generate(question['count'], (index) {
                        return Text(question['emoji'], style: const TextStyle(fontSize: 50));
                      }),
                    ),
                  ),
                ),
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 2,
                  children: List.generate(question['answers'].length, (index) {
                    int answer = question['answers'][index];
                    return ElevatedButton(
                      onPressed: _answered ? null : () => _checkAnswer(answer),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _answered
                            ? (answer == question['count'] ? Colors.green : Colors.red)
                            : Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text(
                        answer.toString(),
                        style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                if (_message.isNotEmpty)
                  Text(
                    _message,
                    style: GoogleFonts.cairo(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}