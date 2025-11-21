import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'purgatorio_screen.dart';
import 'hud_widget.dart';
import 'comodines_screen.dart';
import 'jefes_screen.dart';
import '../data/progress_manager.dart';
import '../widgets/back_button_widget.dart';


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
      "desc": "Comienza el viaje del conocimiento. Lo fácil no existe.",
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
    duration: const Duration(seconds: 5),
  )..repeat(); // 🔹 Crea la animación del fondo
  _loadCoins(); // 🔹 Cargar monedas
}


Future<void> _loadCoins() async {
  final progress = await ProgressManager.loadProgress();
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
    final isSmallScreen = size.width < 450;

    return Scaffold(
      backgroundColor: const Color(0xFF140B24),
      body: Stack(
         
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => CustomPaint(
              painter: RetroGridPainter(_controller.value),
              size: size,
            ),
          ),

          SafeArea(
            
            child: Column(
              children: [
                GameHUD(
                  coins: coins,
                  onOpenComodines: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ComodinesScreen()),
                  ),
                  onOpenJefes: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const JefesScreen()),
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(22.0),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isSmallScreen ? 1 : 2,
                        mainAxisSpacing: 26,
                        crossAxisSpacing: 26,
                        childAspectRatio: isSmallScreen ? 1.25 : 1.1,
                      ),
                      itemCount: levels.length,
                      itemBuilder: (context, index) {
                        final level = levels[index];
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration:
                              Duration(milliseconds: 600 + (index * 200)),
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
                                          builder: (context) =>
                                              const PurgatorioScreen(),
                                        ),
                                      );
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
              ],
            ),
          ),
        const RetroBackButton(), // ← ESTE ES EL NOMBRE CORRECTO
        ],
      ),
    );
  }
}

/// ---------- TARJETAS DE NIVELES ----------
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
    final isSmallScreen = MediaQuery.of(context).size.width < 450;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: const Color(0xFF24133D),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bolt_rounded,
                      size: isSmallScreen ? 60 : 70,
                      color: widget.available
                          ? widget.color
                          : Colors.grey.shade600,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: widget.available
                            ? widget.color
                            : const Color(0xFF666666),
                        fontSize: isSmallScreen ? 20 : 26,
                        fontFamily: 'PressStart2P',
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: widget.color.withOpacity(0.4),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      widget.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: widget.available
                            ? Colors.white
                            : const Color(0xFF888888),
                        fontFamily: 'VT323',
                        fontSize: isSmallScreen ? 22 : 24,
                        height: 1.5,
                        letterSpacing: 1.3,
                        shadows: [
                          Shadow(
                            color: Colors.white.withOpacity(0.4),
                            blurRadius: 8,
                          ),
                        ],
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: widget.color.withOpacity(0.8),
                        width: 1.4,
                      ),
                    ),
                    child: const Text(
                      "PRÓXIMAMENTE",
                      style: TextStyle(
                        color: Colors.white70,
                        fontFamily: 'PressStart2P',
                        fontSize: 8,
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

class RetroGridPainter extends CustomPainter {
  final double progress;
  RetroGridPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00FFF7).withOpacity(0.1)
      ..strokeWidth = 1.0;

    for (double y = 0; y < size.height; y += 25) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    for (double x = 0; x < size.width; x += 25) {
      final offset = math.sin(progress * 2 * math.pi + x / 60) * 3;
      canvas.drawLine(
        Offset(x + offset, 0),
        Offset(x - offset, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
