import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'select_level_screen.dart';
import 'percepcion_screen.dart';

class PurgatorioScreen extends StatefulWidget {
  const PurgatorioScreen({super.key});

  @override
  State<PurgatorioScreen> createState() => _PurgatorioScreenState();
}

class _PurgatorioScreenState extends State<PurgatorioScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final blocks = [
    {
      "title": "PERCEPCIÓN",
      "desc": "Ve más allá de lo evidente.",
      "icon": Icons.visibility,
      "color": const Color(0xFF00FFF0),
      "available": true,
    },
    {
      "title": "LÓGICA",
      "desc": "Completa 'Percepción' para desbloquear este nivel.",
      "icon": Icons.extension,
      "color": const Color(0xFF4C6FFF),
      "available": false,
    },
    {
      "title": "MEMORIA",
      "desc": "Completa 'Lógica' para desbloquear este nivel.",
      "icon": Icons.memory,
      "color": const Color(0xFFFFD700),
      "available": false,
    },
    {
      "title": "CIENCIA Y TECNOLOGÍA",
      "desc": "Completa 'Memoria' para acceder aquí.",
      "icon": Icons.science,
      "color": const Color(0xFF32CD32),
      "available": false,
    },
    {
      "title": "CULTURA GENERAL",
      "desc": "Completa 'Ciencia y Tecnología' para desbloquear.",
      "icon": Icons.public,
      "color": const Color(0xFFFFA500),
      "available": false,
    },
    {
      "title": "JUICIO CRÍTICO",
      "desc": "Completa todos los niveles para acceder al juicio final.",
      "icon": Icons.flash_on,
      "color": const Color(0xFFFF4B82),
      "available": false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 6))
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
    final isSmallScreen = size.width < 450; // 📱 Responsividad móvil

    return Scaffold(
      backgroundColor: const Color(0xFF1B0E2E),
      body: Stack(
        children: [
          // Fondo retro animado
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: PurgatorioBackgroundPainter(_controller.value),
                size: size,
              );
            },
          ),

          SafeArea(
            child: Column(
              children: [
                /// 🔙 Flecha + título
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFF00FFF0),
                              width: 2,
                            ),
                            color: const Color(0xFF2B1E40),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(0xFF00FFF0).withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Color(0xFF00FFF0),
                            size: 22,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            "PURGATORIO MENTAL",
                            style: TextStyle(
                              fontFamily: 'PressStart2P',
                              fontSize: isSmallScreen ? 10 : 14,
                              color: const Color(0xFF00FFF0),
                              letterSpacing: 2,
                              shadows: [
                                Shadow(
                                  blurRadius: 12,
                                  color: const Color(0xFFFF4B82)
                                      .withOpacity(0.8),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),

                /// 📦 Bloques
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isSmallScreen ? 1 : 2,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      childAspectRatio: isSmallScreen ? 1.2 : 1.1,
                    ),
                    itemCount: blocks.length,
                    itemBuilder: (context, index) {
                      final block = blocks[index];
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration:
                            Duration(milliseconds: 400 + (index * 180)),
                        curve: Curves.easeOutBack,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Opacity(
                              opacity: value.clamp(0.0, 1.0),
                              child: _MindBlockCard(
                                title: block["title"] as String,
                                description: block["desc"] as String,
                                icon: block["icon"] as IconData,
                                color: block["color"] as Color,
                                available: block["available"] as bool,
                                onTap: () {
                                  if (block["available"] == true) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const PercepcionScreen(),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------- BLOQUE DE NIVEL ----------
class _MindBlockCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool available;
  final VoidCallback onTap;

  const _MindBlockCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.available,
    required this.onTap,
  });

  @override
  State<_MindBlockCard> createState() => _MindBlockCardState();
}

class _MindBlockCardState extends State<_MindBlockCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 450;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: const Color(0xFF2B1E40),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: widget.color, width: 2),
          boxShadow: _hover
              ? [
                  BoxShadow(
                    color: widget.color.withOpacity(0.6),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: widget.available ? widget.onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon,
                    size: isSmallScreen ? 40 : 50, color: widget.color),
                const SizedBox(height: 16),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'PressStart2P',
                    fontSize: isSmallScreen ? 9 : 11,
                    color: widget.color,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'VT323',
                    fontSize: isSmallScreen ? 16 : 18,
                    color: widget.available
                        ? Colors.white70
                        : Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ---------- FONDO RETRO ----------
class PurgatorioBackgroundPainter extends CustomPainter {
  final double progress;
  PurgatorioBackgroundPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00FFF0).withOpacity(0.1)
      ..strokeWidth = 1.0;

    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    for (double x = 0; x < size.width; x += 30) {
      final offset = math.sin(progress * 2 * math.pi + x / 50) * 4;
      canvas.drawLine(
        Offset(x, 0 + offset),
        Offset(x, size.height - offset),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
