import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'purgatorio_screen.dart';
import 'hud_widget.dart';
import 'comodines_screen.dart';
import 'jefes_screen.dart';
import '../data/progress_manager.dart';
import 'main.dart';

class SelectLevelScreen extends StatefulWidget {
  const SelectLevelScreen({super.key});

  @override
  State<SelectLevelScreen> createState() => _SelectLevelScreenState();
}

class _SelectLevelScreenState extends State<SelectLevelScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int coins = 0;

  final levels = [
    {
      "title": "PURGATORIO MENTAL",
      "desc": "Comienza el viaje del conocimiento.",
      "color": const Color(0xFF00FFF7),
      "available": true,
    },
    {
      "title": "POZO ROJO",
      "desc": "Solo los que piensan rápido salen con vida.",
      "color": const Color(0xFFFF3366),
      "available": false,
    },
    {
      "title": "CEREBRO DORADO",
      "desc": "Tu mente empieza a brillar, pero el tiempo es tu enemigo.",
      "color": const Color(0xFFFFE066),
      "available": false,
    },
    {
      "title": "LA FRONTERA DEL CAOS",
      "desc": "Las preguntas son trampas. ¿Qué tan lejos puedes llegar?",
      "color": const Color(0xFF00FF9D),
      "available": false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
    _loadCoins();
  }

  Future<void> _loadCoins() async {
    final progress = await ProgressManager.loadProgress();
    if (!mounted) return;
    setState(() {
      coins = progress.coins;
    });
  }

  void _refreshCoins() async {
    final progress = await ProgressManager.loadProgress();
    if (!mounted) return;
    setState(() {
      coins = progress.coins;
    });
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
      backgroundColor: const Color(0xFF1A1A2E),
      body: Stack(
        children: [
          // ✅ FONDO CASTILLO MEDIEVAL ANIMADO CON NUBES Y ANTORCHAS
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => CustomPaint(
              painter: MedievalCastlePainter(_controller.value),
              size: size,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),
                GameHUD(
                  coins: coins,
                  onOpenComodines: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ComodinesScreen()),
                  ).then((_) => _refreshCoins()),
                 onOpenJefes: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const JefesScreen()),
                  ).then((_) => _refreshCoins()),

                ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "SELECCIONA TU DESTINO",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: isSmall ? 16 : 22,
                      color: const Color(0xFFFFD700),
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          blurRadius: 12,
                          color: const Color(0xFFFFD700).withOpacity(0.8),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmall ? 16 : 30,
                      vertical: 10,
                    ),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isSmall ? 1 : 2,
                        mainAxisSpacing: isSmall ? 20 : 26,
                        crossAxisSpacing: isSmall ? 16 : 26,
                        childAspectRatio: isSmall ? 1.2 : 1.1,
                      ),
                      itemCount: levels.length,
                      itemBuilder: (context, index) {
                        final level = levels[index];
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: Duration(milliseconds: 600 + (index * 200)),
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, (1 - value) * 40),
                              child: Opacity(
                                opacity: value,
                                child: _LevelCard(
                                  title: level["title"] as String,
                                  description: level["desc"] as String,
                                  color: level["color"] as Color,
                                  available: level["available"] as bool,
                                  onTap: () {
                                    if (level["available"] == true) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const PurgatorioScreen(),
                                        ),
                                      ).then((_) => _refreshCoins());
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),

          // ✅ BOTÓN MEJORADO CON ÍCONO DE PUERTA
          Positioned(
            left: 20,
            bottom: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E1A4F), Color(0xFF1A1A2E)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFFFD700),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(0.4),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.exit_to_app,
                      color: Color(0xFFFFD700),
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Text(
                      "SALIR",
                      style: TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 14,
                        color: Color(0xFFFFD700),
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

class _LevelCard extends StatefulWidget {
  final String title;
  final String description;
  final Color color;
  final bool available;
  final VoidCallback onTap;

  const _LevelCard({
    required this.title,
    required this.description,
    required this.color,
    required this.available,
    required this.onTap,
  });

  @override
  State<_LevelCard> createState() => _LevelCardState();
}

class _LevelCardState extends State<_LevelCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 450;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: const Color(0xFF24133D).withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              offset: const Offset(6, 6),
              blurRadius: 10,
            ),
            const BoxShadow(
              color: Color(0xFF2E1A4F),
              offset: Offset(-4, -4),
              blurRadius: 10,
            ),
            if (_hover && widget.available)
              BoxShadow(
                color: widget.color.withOpacity(0.7),
                blurRadius: 25,
                spreadRadius: 3,
              ),
          ],
          border: Border.all(
            color: widget.color.withOpacity(widget.available ? 0.9 : 0.3),
            width: 1.8,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: widget.available ? widget.onTap : null,
          splashColor: widget.color.withOpacity(0.25),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmall ? 12 : 14,
                  vertical: isSmall ? 16 : 18,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.castle_rounded,
                      size: isSmall ? 55 : 70,
                      color: widget.available
                          ? widget.color
                          : Colors.grey.shade600,
                    ),
                    SizedBox(height: isSmall ? 12 : 14),
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: widget.available
                            ? widget.color
                            : const Color(0xFF666666),
                        fontSize: isSmall ? 14 : 18,
                        fontFamily: 'PressStart2P',
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: widget.color.withOpacity(0.4),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isSmall ? 14 : 18),
                    Text(
                      widget.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: widget.available
                            ? Colors.white
                            : const Color(0xFF888888),
                        fontFamily: 'VT323',
                        fontSize: isSmall ? 22 : 26,
                        height: 1.4,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              if (!widget.available)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: widget.color.withOpacity(0.8),
                        width: 1.4,
                      ),
                    ),
                    child: Text(
                      "PRÓXIMAMENTE",
                      style: TextStyle(
                        color: Colors.white70,
                        fontFamily: 'PressStart2P',
                        fontSize: isSmall ? 7 : 8,
                      ),
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

// ================================================================
// FONDO CASTILLO MEDIEVAL MEJORADO
// ================================================================
class MedievalCastlePainter extends CustomPainter {
  final double progress;

  MedievalCastlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    // Cielo nocturno
    final skyGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF0A0A1A),
        const Color(0xFF1A1A2E),
        const Color(0xFF2E1A4F),
      ],
    );

    canvas.drawRect(
      Offset.zero & size,
      Paint()..shader = skyGradient.createShader(Offset.zero & size),
    );

    // ✅ NUBES FLOTANTES
    final cloudPaint = Paint()
      ..color = const Color(0xFF1E1E2E).withOpacity(0.5);

    final random = math.Random(123);
    for (int i = 0; i < 8; i++) {
      final x = ((random.nextDouble() * size.width) + progress * size.width * 0.3) % size.width;
      final y = size.height * 0.2 + random.nextDouble() * size.height * 0.2;

      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 120, height: 40),
        cloudPaint,
      );
    }

    // Estrellas parpadeantes
    for (int i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height * 0.6;

      final brightness = (math.sin(progress * math.pi * 2 + i) + 1) / 2;
      final starPaint = Paint()
        ..color = Colors.white.withOpacity(brightness * 0.8);

      canvas.drawCircle(Offset(x, y), i % 3 == 0 ? 2 : 1, starPaint);
    }

    // Luna
    final moonGlow = Paint()
      ..color = const Color(0xFFE6E6FA).withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);

    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.15),
      60,
      moonGlow,
    );

    final moonCore = Paint()..color = const Color(0xFFE6E6FA);
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.15),
      40,
      moonCore,
    );

    // Castillo silueta
    final castlePaint = Paint()
      ..color = const Color(0xFF0D0D1A).withOpacity(0.9);

    final castlePath = Path()
      ..moveTo(0, size.height * 0.7)
      ..lineTo(size.width * 0.2, size.height * 0.55)
      ..lineTo(size.width * 0.2, size.height * 0.45)
      ..lineTo(size.width * 0.25, size.height * 0.45)
      ..lineTo(size.width * 0.25, size.height * 0.5)
      ..lineTo(size.width * 0.3, size.height * 0.5)
      ..lineTo(size.width * 0.3, size.height * 0.45)
      ..lineTo(size.width * 0.35, size.height * 0.45)
      ..lineTo(size.width * 0.35, size.height * 0.55)
      ..lineTo(size.width * 0.5, size.height * 0.65)
      ..lineTo(size.width * 0.65, size.height * 0.55)
      ..lineTo(size.width * 0.65, size.height * 0.45)
      ..lineTo(size.width * 0.7, size.height * 0.45)
      ..lineTo(size.width * 0.7, size.height * 0.5)
      ..lineTo(size.width * 0.75, size.height * 0.5)
      ..lineTo(size.width * 0.75, size.height * 0.45)
      ..lineTo(size.width * 0.8, size.height * 0.45)
      ..lineTo(size.width * 0.8, size.height * 0.55)
      ..lineTo(size.width, size.height * 0.7)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(castlePath, castlePaint);

    // ✅ ANTORCHAS CON FUEGO ANIMADO
    final torchPositions = [
      Offset(size.width * 0.22, size.height * 0.48),
      Offset(size.width * 0.78, size.height * 0.48),
    ];

    for (final pos in torchPositions) {
      // Llama base
      final flameGlow = Paint()
        ..color = const Color(0xFFFF6600).withOpacity(0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

      final flameSize = 18 + math.sin(progress * math.pi * 4) * 4;

      canvas.drawOval(
        Rect.fromCenter(center: pos, width: flameSize, height: flameSize * 1.5),
        flameGlow,
      );

      // Núcleo de llama
      final flameCore = Paint()
        ..color = const Color(0xFFFFD700);

      canvas.drawOval(
        Rect.fromCenter(center: pos, width: flameSize * 0.5, height: flameSize * 0.8),
        flameCore,
      );
    }

    // Ventanas iluminadas
    final windowPaint = Paint()..color = const Color(0xFFFFD700).withOpacity(0.8);

    final windows = [
      Offset(size.width * 0.28, size.height * 0.52),
      Offset(size.width * 0.68, size.height * 0.5),
      Offset(size.width * 0.74, size.height * 0.52),
    ];

    for (final pos in windows) {
      canvas.drawRect(
        Rect.fromCenter(center: pos, width: 8, height: 12),
        windowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}