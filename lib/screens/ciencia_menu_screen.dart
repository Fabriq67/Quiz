import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../data/progress_manager.dart';
import '../hud_widget.dart';
import '../comodines_screen.dart';
import '../jefes_screen.dart'; 
import 'ciencia_quiz_screen.dart';
import '../purgatorio_screen.dart'; // ✅ CORREGIDO: Quitar la / inicial

class CienciaMenuScreen extends StatefulWidget {
  const CienciaMenuScreen({super.key});

  @override
  State<CienciaMenuScreen> createState() => _CienciaMenuScreenState();
}

class _CienciaMenuScreenState extends State<CienciaMenuScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

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
      "color": Color(0xFF32CD32),
      "bossName": null,
    },
    {
      "id": 2,
      "title": "Bloque 2",
      "difficulty": "Medio",
      "questions": 5,
      "isBoss": false,
      "color": Color(0xFF26E6A3),
      "bossName": null,
    },
    {
      "id": 3,
      "title": "Bloque 3 (Jefe)",
      "difficulty": "Difícil",
      "questions": 10,
      "isBoss": true,
      "color": Color(0xFFFF33A1),
      "bossName": "El Guardián de la Memoria",
    },
  ];

  @override
  void initState() {
    super.initState();
    debugPrint('[CienciaMenuScreen] initState');

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _loadCoins();
    _loadUnlocks();
  }

  Future<void> _loadCoins() async {
    final progress = await ProgressManager.loadProgress();
    setState(() => coins = progress.coins);
  }

  Future<void> _loadUnlocks() async {
    final u1 = await ProgressManager.isScienceBlockUnlocked(1);
    final u2 = await ProgressManager.isScienceBlockUnlocked(2);
    final u3 = await ProgressManager.isScienceBlockUnlocked(3);

    final c1 = await ProgressManager.isScienceBlockCompleted(1);
    final c2 = await ProgressManager.isScienceBlockCompleted(2);
    final c3 = await ProgressManager.isScienceBlockCompleted(3);

    bool newU1 = true;
    bool newU2 = u2 || c1;
    bool newU3 = u3 || c2;

    if (!u1) await ProgressManager.unlockScienceBlock(1);
    if (newU2 && !u2) await ProgressManager.unlockScienceBlock(2);
    if (newU3 && !u3) await ProgressManager.unlockScienceBlock(3);

    setState(() {
      unlocked[1] = newU1;
      unlocked[2] = newU2;
      unlocked[3] = newU3;

      completed[1] = c1;
      completed[2] = c2;
      completed[3] = c3;
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
    debugPrint('[CienciaMenuScreen] build');
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final isSmall = width < 450;

    return Scaffold(
      backgroundColor: const Color(0xFF060218),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => CustomPaint(
              painter: _ScienceSpacePainter(_controller.value),
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
                    ).then((_) => _refreshCoins()),
                    onOpenJefes: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const JefesScreen()),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "CIENCIA Y TECNOLOGÍA",
                  style: TextStyle(
                    fontFamily: 'PressStart2P',
                    color: Color(0xFF32CD32),
                    fontSize: 15,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 25),

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

                      return _ScienceBlockCard(
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
                              builder: (_) => CienciaQuizScreen(
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
            child: _BackButton(
              onTap: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const PurgatorioScreen()),
                (route) => false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatefulWidget {
  final VoidCallback onTap;

  const _BackButton({required this.onTap});

  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton>
    with TickerProviderStateMixin {

  late AnimationController _scaleController;
  late AnimationController _pulseController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final buttonSize = isMobile ? 60.0 : 70.0;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _scaleController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _scaleController.reverse();
      },
      child: GestureDetector(
        onTapDown: (_) => _scaleController.forward(),
        onTapUp: (_) {
          _scaleController.reverse();
          widget.onTap();
        },
        onTapCancel: () => _scaleController.reverse(),
        child: AnimatedBuilder(
          animation: Listenable.merge([_scaleController, _pulseController]),
          builder: (context, child) {
            final scale = 1.0 + (_scaleController.value * 0.2);
            final pulseScale = 1.0 + (_pulseController.value * 0.08);
            final finalScale = scale * pulseScale;

            return Transform.scale(
              scale: finalScale,
              child: Container(
                width: buttonSize,
                height: buttonSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: _isHovered
                        ? [
                            const Color(0xFF26E6A3).withValues(alpha: 0.9),
                            const Color(0xFF1FD98F).withValues(alpha: 0.8),
                          ]
                        : [
                            const Color(0xFF32CD32).withValues(alpha: 0.8),
                            const Color(0xFF26E6A3).withValues(alpha: 0.7),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF26E6A3).withValues(
                        alpha: _isHovered ? 0.8 : 0.5,
                      ),
                      blurRadius: _isHovered ? 25 : 15,
                      spreadRadius: _isHovered ? 4 : 2,
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withValues(
                      alpha: _isHovered ? 0.9 : 0.5,
                    ),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                    size: isMobile ? 28 : 32,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ScienceBlockCard extends StatelessWidget {
  final String title;
  final String difficulty;
  final int questions;
  final bool isBoss;
  final Color color;
  final String? bossName;
  final bool locked;
  final bool completed;
  final VoidCallback onTap;

  const _ScienceBlockCard({
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
        color: const Color(0xFF0B0525).withValues(
          alpha: locked ? 0.4 : (completed ? 0.7 : 0.95),
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cardColor, width: 2),
        boxShadow: [
          if (!locked)
            BoxShadow(
              color: cardColor.withValues(alpha: 0.7),
              blurRadius: 20,
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
                isBoss ? Icons.shield : Icons.science,
                size: isSmall ? 45 : 60,
                color: cardColor,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: isSmall ? 10 : 12,
                  color: cardColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                difficulty,
                style: const TextStyle(
                  fontFamily: 'VT323',
                  fontSize: 24,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              if (isBoss && bossName != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    bossName!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'VT323',
                      fontSize: 20,
                      color: Colors.pinkAccent,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                "$questions preguntas",
                style: const TextStyle(
                  fontFamily: 'VT323',
                  fontSize: 24,
                  color: Colors.white,
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

class _ScienceSpacePainter extends CustomPainter {
  final double progress;
  _ScienceSpacePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFF060218);
    canvas.drawRect(Offset.zero & size, bg);

    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.7);
    final random = math.Random(100);

    for (int i = 0; i < 120; i++) {
      double x = random.nextDouble() * size.width;
      double y = (random.nextDouble() * size.height +
              progress * 80 * (i % 2 == 0 ? 1 : -1)) %
          size.height;

      canvas.drawCircle(Offset(x, y), i % 10 == 0 ? 1.6 : 1.1, starPaint);
    }

    final nebula = Paint()
      ..color = Colors.blue.withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.3), 180, nebula);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.7), 220, nebula);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}