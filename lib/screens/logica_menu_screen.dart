import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../data/progress_manager.dart';
// ...existing code...

import '../comodines_screen.dart'; // ✅ CAMBIAR: /comodines_screen.dart por ../comodines_screen.dart
import '../hud_widget.dart';
import '../jefes_screen.dart'; 
import '../purgatorio_screen.dart'; // ✅ CAMBIAR: /purgatorio_screen.dart por ../purgatorio_screen.dart
import 'logica_quiz_screen.dart';

// ...existing code...

class LogicaMenuScreen extends StatefulWidget {
  const LogicaMenuScreen({super.key});

  @override
  State<LogicaMenuScreen> createState() => _LogicaMenuScreenState();
}

class _LogicaMenuScreenState extends State<LogicaMenuScreen>
    with TickerProviderStateMixin {
  late AnimationController _gridController;
  late AnimationController _particleController;

  int coins = 0;

  Map<int, bool> unlocked = {1: true, 2: false, 3: false};
  Map<int, bool> completed = {1: false, 2: false, 3: false};

  final List<Map<String, dynamic>> blocks = [
    {
      "id": 1,
      "title": "Bloque 1",
      "difficulty": "Fácil",
      "questions": 5,
      "isBoss": false,
      "color": Color(0xFF5A9FD4),
      "bossName": null,
    },
    {
      "id": 2,
      "title": "Bloque 2",
      "difficulty": "Medio",
      "questions": 5,
      "isBoss": false,
      "color": Color(0xFF7FA8C9),
      "bossName": null,
    },
    {
      "id": 3,
      "title": "Bloque 3 (Jefe)",
      "difficulty": "Difícil",
      "questions": 10,
      "isBoss": true,
      "color": Color(0xFFD47A7A),
      "bossName": "El Rompecódigos",
    },
  ];

  @override
  void initState() {
    super.initState();

    _gridController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 8),
    )..repeat();

    _particleController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 12),
    )..repeat();

    _loadCoins();
    _loadUnlocks();
  }

  Future<void> _loadCoins() async {
    final progress = await ProgressManager.loadProgress();
    setState(() => coins = progress.coins);
  }

  Future<void> _loadUnlocks() async {
    final u1 = await ProgressManager.isLogicBlockUnlocked(1);
    final u2 = await ProgressManager.isLogicBlockUnlocked(2);
    final u3 = await ProgressManager.isLogicBlockUnlocked(3);

    final c1 = await ProgressManager.isLogicBlockCompleted(1);
    final c2 = await ProgressManager.isLogicBlockCompleted(2);
    final c3 = await ProgressManager.isLogicBlockCompleted(3);

    setState(() {
      unlocked[1] = u1;
      unlocked[2] = u2;
      unlocked[3] = u3;

      completed[1] = c1;
      completed[2] = c2;
      completed[3] = c3;
    });
  }

  @override
  void dispose() {
    _gridController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 500;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Stack(
        children: [
          // FONDO GRID FUTURISTA
          AnimatedBuilder(
            animation: _gridController,
            builder: (context, _) => CustomPaint(
              painter: _FuturisticGridPainter(_gridController.value),
              size: size,
            ),
          ),

          // PARTÍCULAS FLOTANTES
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, _) => CustomPaint(
              painter: _ParticlePainter(_particleController.value),
              size: size,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),

                // HUD
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GameHUD(
                    coins: coins,
                    onOpenComodines: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ComodinesScreen()),
                    ).then((_) => _loadCoins()),
                    onOpenJefes: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const JefesScreen()),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // TÍTULO
                Text(
                  "LÓGICA",
                  style: TextStyle(
                    fontFamily: 'PressStart2P',
                    color: const Color(0xFF5A9FD4),
                    fontSize: isSmall ? 18 : 22,
                    letterSpacing: 3,
                    shadows: const [
                      Shadow(
                        blurRadius: 15,
                        color: Color(0xFF5A9FD4),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // GRID DE BLOQUES
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmall ? 18 : 28,
                      vertical: 10,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isSmall ? 1 : 2,
                      crossAxisSpacing: isSmall ? 18 : 26,
                      mainAxisSpacing: isSmall ? 18 : 26,
                      childAspectRatio: isSmall ? 1.4 : 1.2,
                    ),
                    itemCount: blocks.length,
                    itemBuilder: (context, index) {
                      final block = blocks[index];
                      final id = block["id"] as int;

                      final bool isUnlocked = unlocked[id] ?? false;
                      final bool isCompleted = completed[id] ?? false;

                      return _FuturisticBlockCard(
                        title: block["title"],
                        difficulty: block["difficulty"],
                        questions: block["questions"],
                        isBoss: block["isBoss"],
                        color: block["color"],
                        bossName: block["bossName"],
                        isUnlocked: isUnlocked,
                        isCompleted: isCompleted,
                        onTap: () {
                          if (!isUnlocked) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.redAccent,
                                content: Text(
                                  "Completa el bloque anterior",
                                  style: TextStyle(
                                    fontFamily: 'PressStart2P',
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            );
                            return;
                          }

                          if (isCompleted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.greenAccent,
                                content: Text(
                                  "Ya completaste este bloque",
                                  style: TextStyle(
                                    fontFamily: 'PressStart2P',
                                    fontSize: 10,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            );
                            return;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LogicaQuizScreen(
                                blockId: id,
                                totalQuestions: block["questions"],
                                isBoss: block["isBoss"],
                              ),
                            ),
                          ).then((_) {
                            _loadCoins();
                            _loadUnlocks();
                          });
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),

          // BOTÓN DE REGRESO FUTURISTA
          Positioned(
            left: 20,
            bottom: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const PurgatorioScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0E1A),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF5A9FD4),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5A9FD4).withOpacity(0.4),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.arrow_back_rounded,
                      color: Color(0xFF5A9FD4),
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Text(
                      "VOLVER",
                      style: TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 13,
                        color: Color(0xFF5A9FD4),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
// TARJETA DE BLOQUE FUTURISTA
// ----------------------------------------------------------
class _FuturisticBlockCard extends StatefulWidget {
  final String title;
  final String difficulty;
  final int questions;
  final bool isBoss;
  final Color color;
  final String? bossName;
  final bool isUnlocked;
  final bool isCompleted;
  final VoidCallback onTap;

  const _FuturisticBlockCard({
    required this.title,
    required this.difficulty,
    required this.questions,
    required this.isBoss,
    required this.color,
    required this.isUnlocked,
    required this.isCompleted,
    required this.onTap,
    this.bossName,
  });

  @override
  State<_FuturisticBlockCard> createState() => _FuturisticBlockCardState();
}

class _FuturisticBlockCardState extends State<_FuturisticBlockCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 500;

    Color displayColor;
    if (!widget.isUnlocked) {
      displayColor = Colors.grey.shade700;
    } else if (widget.isCompleted) {
      displayColor = Colors.greenAccent;
    } else {
      displayColor = widget.color;
    }

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulseOpacity = widget.isUnlocked && !widget.isCompleted
            ? 0.3 + (_pulseController.value * 0.3)
            : 0.2;

        return GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: const Color(0xFF0F1420).withOpacity(
                widget.isUnlocked ? 0.9 : 0.5,
              ),
              border: Border.all(
                color: displayColor,
                width: widget.isUnlocked ? 3 : 2,
              ),
              boxShadow: [
                if (widget.isUnlocked && !widget.isCompleted)
                  BoxShadow(
                    color: displayColor.withOpacity(pulseOpacity),
                    blurRadius: 30,
                    spreadRadius: 3,
                  ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(isSmall ? 20 : 26),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.isBoss ? Icons.extension : Icons.settings,
                    color: displayColor,
                    size: isSmall ? 55 : 65,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'PressStart2P',
                      color: displayColor,
                      fontSize: isSmall ? 14 : 16,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.difficulty,
                    style: TextStyle(
                      fontFamily: 'VT323',
                      color: Colors.white70,
                      fontSize: isSmall ? 22 : 26,
                    ),
                  ),
                  if (widget.bossName != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        widget.bossName!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'VT323',
                          color: Colors.redAccent.shade100,
                          fontSize: isSmall ? 20 : 24,
                        ),
                      ),
                    ),
                  const SizedBox(height: 14),
                  Text(
                    "${widget.questions} preguntas",
                    style: TextStyle(
                      fontFamily: 'VT323',
                      color: Colors.white,
                      fontSize: isSmall ? 24 : 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (!widget.isUnlocked)
                    const Text(
                      "🔒 BLOQUEADO",
                      style: TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 10,
                        color: Colors.redAccent,
                      ),
                    ),
                  if (widget.isCompleted)
                    const Text(
                      "✅ COMPLETADO",
                      style: TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 10,
                        color: Colors.greenAccent,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ----------------------------------------------------------
// PINTOR DE GRID FUTURISTA
// ----------------------------------------------------------
class _FuturisticGridPainter extends CustomPainter {
  final double progress;
  _FuturisticGridPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF5A9FD4).withOpacity(0.08)
      ..strokeWidth = 1.5;

    // Líneas horizontales
    for (double y = 0; y < size.height; y += 35) {
      final offset = math.sin(progress * 2 * math.pi + y / 50) * 8;
      canvas.drawLine(
        Offset(offset, y),
        Offset(size.width + offset, y),
        paint,
      );
    }

    // Líneas verticales
    for (double x = 0; x < size.width; x += 35) {
      final offset = math.cos(progress * 2 * math.pi + x / 50) * 8;
      canvas.drawLine(
        Offset(x, offset),
        Offset(x, size.height + offset),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ----------------------------------------------------------
// PINTOR DE PARTÍCULAS
// ----------------------------------------------------------
class _ParticlePainter extends CustomPainter {
  final double progress;
  _ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF5A9FD4).withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final random = math.Random(42);

    for (int i = 0; i < 30; i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;

      final x = baseX + math.sin(progress * 2 * math.pi + i) * 20;
      final y = (baseY + progress * size.height * 0.5) % size.height;

      canvas.drawCircle(Offset(x, y), 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}