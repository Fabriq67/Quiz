import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../data/progress_manager.dart';
import '../hud_widget.dart';
import '../comodines_screen.dart';
import '../jefes_screen.dart';
import 'cultura_quiz_screen.dart'; // ✅ ÚNICO import de cultura_quiz_screen
import '../purgatorio_screen.dart';

class CulturaMenuScreen extends StatefulWidget {
  const CulturaMenuScreen({super.key});

  @override
  State<CulturaMenuScreen> createState() => _CulturaMenuScreenState();
}

class _CulturaMenuScreenState extends State<CulturaMenuScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  int coins = 0;

  Map<int, bool> unlocked = {1: true, 2: false, 3: false, 4: false};
  Map<int, bool> completed = {1: false, 2: false, 3: false, 4: false};

  final List<Map<String, dynamic>> blocks = [
    {
      "id": 1,
      "title": "Bloque 1",
      "difficulty": "Fácil",
      "questions": 5,
      "isBoss": false,
      "color": Color(0xFFB388FF),
      "bossName": null,
    },
    {
      "id": 2,
      "title": "Bloque 2",
      "difficulty": "Medio",
      "questions": 5,
      "isBoss": false,
      "color": Color(0xFF9C6EFF),
      "bossName": null,
    },
    {
      "id": 3,
      "title": "Bloque 3",
      "difficulty": "Difícil",
      "questions": 10,
      "isBoss": false,
      "color": Color(0xFF7F4DFF),
      "bossName": null,
    },
    {
      "id": 4,
      "title": "Bloque Final (Jefe)",
      "difficulty": "Mega Difícil",
      "questions": 20,
      "isBoss": true,
      "color": Color(0xFFE040FB),
      "bossName": "El Juicio Relámpago",
    },
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _loadCoins();
    _loadUnlocks();
  }

  Future<void> _loadCoins() async {
    final progress = await ProgressManager.loadProgress();
    setState(() => coins = progress.coins);
  }

  Future<void> _loadUnlocks() async {
    final c1 = await ProgressManager.isCultureBlockCompleted(1);
    final c2 = await ProgressManager.isCultureBlockCompleted(2);
    final c3 = await ProgressManager.isCultureBlockCompleted(3);
    final c4 = await ProgressManager.isCultureBlockCompleted(4);
    
    final u2 = await ProgressManager.isCultureBlockUnlocked(2);
    final u3 = await ProgressManager.isCultureBlockUnlocked(3);
    final u4 = await ProgressManager.isCultureBlockUnlocked(4);

    if (!mounted) return;
    setState(() {
      unlocked[1] = true;
      unlocked[2] = u2;
      unlocked[3] = u3;
      unlocked[4] = u4;
      
      completed[1] = c1;
      completed[2] = c2;
      completed[3] = c3;
      completed[4] = c4;
    });
  }

  void _refreshCoins() async {
    final progress = await ProgressManager.loadProgress();
    setState(() => coins = progress.coins);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 450;

    return Scaffold(
      backgroundColor: const Color(0xFF12052F),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => CustomPaint(
              painter: _NatureLavenderPainter(_controller.value),
              size: size,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GameHUD(
                    coins: coins,
                    onOpenComodines: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ComodinesScreen()),
                    ),
                   onOpenJefes: () => Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const JefesScreen()), // ✅ CAMBIAR CodiceScreen() por JefesScreen()
),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "CULTURA GENERAL",
                  style: TextStyle(
                    fontFamily: 'PressStart2P',
                    color: Color(0xFFE6E6FA),
                    fontSize: 14,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 22),

                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(24),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isSmall ? 1 : 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: isSmall ? 1.2 : 1.0,
                    ),
                    itemCount: blocks.length,
                    itemBuilder: (context, index) {
                      final b = blocks[index];
                      final id = b["id"] as int;

                      final isUnlocked = unlocked[id] ?? false;
                      final isCompleted = completed[id] ?? false;
                      final isPlayable = isUnlocked;

                      return _CulturaBlockCard(
                        title: b["title"] as String,
                        difficulty: b["difficulty"] as String,
                        questions: b["questions"] as int,
                        isBoss: b["isBoss"] as bool,
                        color: b["color"] as Color,
                        bossName: b["bossName"] as String?,
                        locked: !isUnlocked,
                        completed: isCompleted,
                        onTap: () {
                          if (!isPlayable) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.redAccent,
                                content: const Text(
                                  "Debes completar el bloque previo.",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                            return;
                          }

                          if (isCompleted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.greenAccent,
                                content: const Text(
                                  "Ya completado. ¡Bien hecho!",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            );
                            return;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CulturaQuizScreen(
                                blockId: id,
                                totalQuestions: b["questions"] as int,
                                isBoss: b["isBoss"] as bool,
                              ),
                            ),
                          ).then((_) => _loadUnlocks());
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.deepPurpleAccent,
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const PurgatorioScreen()),
                (route) => false,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _CulturaBlockCard extends StatelessWidget {
  final String title;
  final String difficulty;
  final int questions;
  final bool isBoss;
  final Color color;
  final String? bossName;
  final bool locked;
  final bool completed;
  final VoidCallback onTap;

  const _CulturaBlockCard({
    required this.title,
    required this.difficulty,
    required this.questions,
    required this.isBoss,
    required this.color,
    required this.locked,
    required this.completed,
    required this.onTap,
    this.bossName,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 450;
    final cardColor = locked ? Colors.grey : color;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: const Color(0xFF1A0C3D),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cardColor, width: 2),
        boxShadow: [
          if (!locked)
            BoxShadow(
              color: cardColor.withValues(alpha: 0.7),
              blurRadius: 18,
              spreadRadius: 2,
            ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: locked ? null : onTap,
        child: Padding(
          padding: EdgeInsets.all(isSmall ? 12 : 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isBoss ? Icons.bolt : Icons.menu_book,
                size: isSmall ? 46 : 60,
                color: cardColor,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: isSmall ? 10 : 12,
                  color: cardColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                difficulty,
                style: const TextStyle(
                  fontFamily: 'VT323',
                  fontSize: 24,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "$questions preguntas",
                style: const TextStyle(
                  fontFamily: 'VT323',
                  fontSize: 22,
                  color: Colors.white,
                ),
              ),
              if (isBoss && bossName != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    bossName!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'VT323',
                      fontSize: 22,
                      color: Colors.purpleAccent,
                    ),
                  ),
                ),
              if (locked)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    "🔒 BLOQUEADO",
                    style: TextStyle(
                      fontFamily: "PressStart2P",
                      fontSize: 9,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              if (completed && !locked)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    "✅ COMPLETADO",
                    style: TextStyle(
                      fontFamily: "PressStart2P",
                      fontSize: 9,
                      color: Colors.greenAccent,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NatureLavenderPainter extends CustomPainter {
  final double progress;
  _NatureLavenderPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFF12052F);
    canvas.drawRect(Offset.zero & size, bg);

    final random = math.Random(99);
    const lavender = Color(0xFFE6E6FA);

    for (int i = 0; i < 40; i++) {
      final x = random.nextDouble() * size.width;
      final y = (random.nextDouble() * size.height +
              progress * 120 * (i % 2 == 0 ? 1 : -1)) %
          size.height;

      final leafPaint = Paint()
        ..color = lavender.withOpacity(0.15);

      canvas.drawCircle(Offset(x, y), i % 5 == 0 ? 6 : 4, leafPaint);
    }

    final glow = Paint()
      ..color = lavender.withOpacity(0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);

    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.4),
      260,
      glow,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}