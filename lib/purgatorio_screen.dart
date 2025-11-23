import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'hud_widget.dart';
import 'comodines_screen.dart';
import 'jefes_screen.dart';
import '../data/progress_manager.dart';
import 'screens/percepcion_menu.dart';
import '../widgets/back_button_widget.dart';

class PurgatorioScreen extends StatefulWidget {
  const PurgatorioScreen({super.key});

  @override
  State<PurgatorioScreen> createState() => _PurgatorioScreenState();
}

class _PurgatorioScreenState extends State<PurgatorioScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  int coins = 0;

  bool _tutorialShown = false; // <<< NUEVO

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

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _loadCoins();
    _loadTutorialState(); // <<< NUEVO
  }

  Future<void> _loadCoins() async {
    final progress = await ProgressManager.loadProgress();
    setState(() {
      coins = progress.coins;
    });
  }

  /// --------------------------------------------------
  /// 🔥 Cargar si el tutorial ya se mostró antes
  /// --------------------------------------------------
  Future<void> _loadTutorialState() async {
    _tutorialShown =
        await ProgressManager.getBool("tutorial_purgatorio_shown") ?? false;

    if (!_tutorialShown) {
      Future.delayed(
        const Duration(milliseconds: 500),
        () => _showPurgatorioTutorial(),
      );
    }
  }

  /// --------------------------------------------------
  /// Guardar que el tutorial ya fue visto
  /// --------------------------------------------------
  Future<void> _setTutorialSeen() async {
    await ProgressManager.saveBool("tutorial_purgatorio_shown", true);
  }

  /// --------------------------------------------------
  /// VENTANA EMERGENTE (TUTORIAL)
  /// --------------------------------------------------
  void _showPurgatorioTutorial() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Center(
          child: Container(
            width: 360,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF2B1E40),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFF00FFF0),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FFF0).withOpacity(0.4),
                  blurRadius: 25,
                  spreadRadius: 3,
                ),
              ],
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "BIENVENIDO",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "PressStart2P",
                    fontSize: 16,
                    color: const Color(0xFFFF4B82),
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: const Color(0xFF00FFF0),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Este es el PURGATORIO MENTAL.\n\n"
                  "Escoge PERCEPCIÓN para iniciar tu aventura.\n\n"
                  "Cada nivel desbloquea el siguiente.\n\n"
                  "¡Buena suerte!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "VT323",
                    fontSize: 26,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 30),

                GestureDetector(
                  onTap: () {
                    _setTutorialSeen(); // <<< MARCAR COMO VISTO
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4B82),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF00FFF0),
                        width: 2,
                      ),
                    ),
                    child: const Text(
                      "ENTRAR",
                      style: TextStyle(
                        fontFamily: "PressStart2P",
                        fontSize: 14,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// --------------------------------------------------
  /// UI PRINCIPAL
  /// --------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 450;

    return Scaffold(
      backgroundColor: const Color(0xFF1B0E2E),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => CustomPaint(
              painter: PurgatorioBackgroundPainter(_controller.value),
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
                        builder: (context, value, _) => Transform.scale(
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
                                      builder: (_) =>
                                          const PercepcionMenuScreen(),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const RetroBackButton(),
        ],
      ),
    );
  }
}

/// -------------------------------------------
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
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: const Color(0xFF2B1E40),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.7),
              offset: const Offset(8, 8),
              blurRadius: 16,
              spreadRadius: 1,
            ),
            const BoxShadow(
              color: Color(0xFF3D2A5F),
              offset: Offset(-6, -6),
              blurRadius: 14,
              spreadRadius: 1,
            ),
            if (_hover)
              BoxShadow(
                color: widget.color.withOpacity(0.8),
                blurRadius: 30,
                spreadRadius: 3,
              ),
          ],
          border: Border.all(
            color: widget.color.withOpacity(widget.available ? 0.8 : 0.2),
            width: 1.8,
          ),
        ),

        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: widget.available ? widget.onTap : null,

          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        widget.color.withOpacity(0.15),
                        Colors.transparent
                      ],
                      radius: 1.2,
                    ),
                  ),
                  child: Icon(
                    widget.icon,
                    size: isSmallScreen ? 45 : 55,
                    color: widget.color,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'PressStart2P',
                    fontSize: isSmallScreen ? 11 : 13,
                    color: widget.available
                        ? widget.color
                        : const Color(0xFF777777),
                    letterSpacing: 1.8,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  widget.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'VT323',
                    fontSize: isSmallScreen ? 22 : 24,
                    color: widget.available
                        ? Colors.white
                        : const Color(0xFFAAAAAA),
                  ),
                ),

                if (!widget.available)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      "Próximamente disponible",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: isSmallScreen ? 8 : 10,
                        color: widget.color.withOpacity(0.7),
                      ),
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

/// --------------------------------------------------
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
