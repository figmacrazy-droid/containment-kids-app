import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'games/memory_game.dart';
import 'games/puzzle_game.dart';
import 'games/maze_game.dart';
import 'games/counting_game.dart';
import 'games/racing_game.dart';
import 'games/bubble_game.dart' as bubble;

class GamesListScreen extends StatelessWidget {
  GamesListScreen({super.key});

  final List<Map<String, dynamic>> games = [
    {
      'name': 'لعبة الذاكرة',
      'icon': Icons.psychology,
      'color': Colors.amber,
      'route': const MemoryGame(), // MemoryGame قد يكون const
    },
    {
      'name': 'لعبة التركيب',
      'icon': Icons.extension,
      'color': Colors.blue,
      'route': const PuzzleGame(),
    },
    {
      'name': 'لعبة المتاهة',
      'icon': Icons.merge_type,
      'color': Colors.teal,
      'route': const MazeGame(),
    },
    {
      'name': 'لعبة العد',
      'icon': Icons.calculate,
      'color': Colors.orange,
      'route': const CountingGame(),
    },
    {
      'name': 'لعبة السباق',
      'icon': Icons.speed,
      'color': Colors.red,
      'route': const RacingGame(),
    },
    {
      'name': 'لعبة البالونات',
      'icon': Icons.emoji_emotions,
      'color': Colors.pink,
      'route': bubble.BubbleGame(), // تم إزالة const
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'اختر لعبتك',
          style: GoogleFonts.cairo(
            fontSize: size.width * 0.06,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.amber.shade700,
        centerTitle: true,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
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
          GridView.builder(
            padding: EdgeInsets.all(size.width * 0.05),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: size.width * 0.04,
              mainAxisSpacing: size.width * 0.04,
              childAspectRatio: 0.9,
            ),
            itemCount: games.length,
            itemBuilder: (context, index) {
              final game = games[index];
              return _buildGameCard(context, game);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(BuildContext context, Map<String, dynamic> game) {
    final size = MediaQuery.of(context).size;
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => game['route'] as Widget),
      ),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: size.width * 0.1,
              backgroundColor: (game['color'] as Color).withOpacity(0.2),
              child: Icon(
                game['icon'] as IconData,
                size: size.width * 0.1,
                color: game['color'] as Color,
              ),
            ),
            SizedBox(height: size.height * 0.01),
            Text(
              game['name'] as String,
              style: GoogleFonts.cairo(
                fontSize: size.width * 0.04,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}