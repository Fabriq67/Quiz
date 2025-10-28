import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'purgatorio_screen.dart';

class SelectLevelScreen extends StatefulWidget {
  const SelectLevelScreen({super.key});

  @override
  State<SelectLevelScreen> createState() => _SelectLevelScreenState();
}

class _SelectLevelScreenState extends State<SelectLevelScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final levels = [
    {
      "title": "PURGATORIO MENTAL",
      "desc": "Comienza el viaje del conocimiento. Lo fácil no existe.",
      "color": const Color(0xFF00FFF0),
      "available": true,
    },
    {
      "title": "POZO ROJO",
      "desc": "Solo los que piensan rápido salen con vida.",
      "color": const Color(0xFFFF4B2B),
      "available": false,
    },
    {
      "title": "CEREBRO DORADO",
      "desc": "Tu mente empieza a brillar, pero el tiempo es tu enemigo.",
      "color": const Color(0xFFFFD700),
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
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 5))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 450; // 📱 Responsive móvil

    return Scaffold(
      backgroundColor: const Color(0xFF1B0E2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "ELIGE TU DESTINO MENTAL",
          style: TextStyle(
            color: const Color(0xFF00FFF0),
            fontFamily: 'PressStart2P',
            fontSize: isSmallScreen ? 10 : 12,
            letterSpacing: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        iconTheme: const IconThemeData(color: Color(0xFF00FFF0)),
      ),
      body: Stack(
        children: [
          /// Fondo animado tipo rejilla retro
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: RetroGridPainter(_controller.value),
                size: size,
              );
            },
          ),

          /// Contenido principal
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isSmallScreen ? 1 : 2,
                  mainAxisSpacing: 24,
                  crossAxisSpacing: 24,
                  childAspectRatio: isSmallScreen ? 1.25 : 1.1,
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
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: const Color(0xFF2B1E40),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: widget.color.withOpacity(widget.available ? 0.8 : 0.2),
              width: 2),
          boxShadow: _hover && widget.available
              ? [
                  BoxShadow(
                    color: widget.color.withOpacity(0.7),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.available ? widget.onTap : null,
          splashColor:
              widget.available ? widget.color.withOpacity(0.4) : Colors.grey,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bolt_rounded,
                      size: isSmallScreen ? 45 : 55,
                      color: widget.available
                          ? widget.color
                          : Colors.grey.shade600,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: widget.available
                            ? widget.color
                            : Colors.grey.shade500,
                        fontSize: isSmallScreen ? 10 : 12,
                        fontFamily: 'PressStart2P',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontFamily: 'VT323',
                        fontSize: isSmallScreen ? 16 : 18,
                      ),
                    ),
                  ],
                ),
              ),

              /// Etiqueta "PRÓXIMAMENTE"
              if (!widget.available)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black87.withOpacity(0.6),
                      border: Border.all(
                          color: widget.color.withOpacity(0.6), width: 1),
                    ),
                    child: const Text(
                      "PRÓXIMAMENTE",
                      style: TextStyle(
                        color: Colors.white70,
                        fontFamily: 'PressStart2P',
                        fontSize: 7,
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

/// ---------- FONDO RETRO ----------
class RetroGridPainter extends CustomPainter {
  final double progress;
  RetroGridPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00FFF0).withOpacity(0.08)
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
