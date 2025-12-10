import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'hud_widget.dart';
import 'comodines_screen.dart';
import 'jefes_screen.dart';
import '../data/progress_manager.dart';
import 'screens/percepcion_menu.dart';
import 'screens/logica_menu_screen.dart';
import 'screens/ciencia_menu_screen.dart';
import 'screens/cultura_menu_screen.dart';
import 'select_level_screen.dart';

class PurgatorioScreen extends StatefulWidget {
  const PurgatorioScreen({super.key});

  @override
  State<PurgatorioScreen> createState() => _PurgatorioScreenState();
}

class _PurgatorioScreenState extends State<PurgatorioScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  int coins = 0;
  bool _tutorialShown = false;
  bool _isLiberated = false; // ✅ NUEVO: indica si completó todos los niveles

  final blocks = [
    {
      "title": "PERCEPCIÓN",
      "desc": "Ve más allá de lo evidente.",
      "icon": Icons.visibility,
      "color": Color(0xFF5A9FB8),
      "available": true,
    },
    {
      "title": "LÓGICA",
      "desc": "Completa 'Percepción' para desbloquear.",
      "icon": Icons.extension,
      "color": Color(0xFF6B7BC4),
      "available": false,
    },
    {
      "title": "CIENCIA Y TECNOLOGÍA",
      "desc": "Completa 'Lógica' para acceder.",
      "icon": Icons.science,
      "color": Color(0xFF5B9970),
      "available": false,
    },
    {
      "title": "CULTURA GENERAL",
      "desc": "Completa 'Ciencia y Tecnología' para el juicio final.",
      "icon": Icons.public,
      "color": Color(0xFFB8667A),
      "available": false,
    },
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _loadCoins();
    _loadTutorialState();
    _loadUnlockedLevels();
    _checkLiberation(); // ✅ NUEVO
  }

  Future<void> _loadCoins() async {
    final progress = await ProgressManager.loadProgress();
    setState(() => coins = progress.coins);
  }

  void _refreshCoins() async {
    final progress = await ProgressManager.loadProgress();
    setState(() => coins = progress.coins);
  }

  Future<void> _loadUnlockedLevels() async {
    final progress = await ProgressManager.loadProgress();
    final unlocked = progress.unlockedLevels;

    blocks[0]["available"] = true;
    blocks[1]["available"] = unlocked.contains("logica");
    blocks[2]["available"] = unlocked.contains("ciencia");
    blocks[3]["available"] = unlocked.contains("cultura");

    setState(() {});
  }

  // ✅ NUEVO: verificar si derrotó a los 4 jefes
  Future<void> _checkLiberation() async {
    final boss1 = await ProgressManager.isBossDefeated("boss_percepcion");
    final boss2 = await ProgressManager.isBossDefeated("boss_logica");
    final boss3 = await ProgressManager.isBossDefeated("boss_ciencia");
    final boss4 = await ProgressManager.isBossDefeated("boss_cultura_4");

    setState(() {
      _isLiberated = boss1 && boss2 && boss3 && boss4;
    });
  }

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

  Future<void> _setTutorialSeen() async {
    await ProgressManager.saveBool("tutorial_purgatorio_shown", true);
  }

  void _showPurgatorioTutorial() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final size = MediaQuery.of(context).size;
        final small = size.width < 380;
        final titleSize = small ? 20.0 : 24.0;
        final bodySize = small ? 24.0 : 28.0;
        final buttonSize = small ? 13.0 : 15.0;

        return Center(
          child: Container(
            width: math.min(size.width * 0.9, 420),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF15152B), Color(0xFF0F1A2F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFF5A9FB8), width: 3),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5A9FB8).withOpacity(0.35),
                  blurRadius: 28,
                  spreadRadius: 4,
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
                    fontSize: titleSize,
                    color: const Color(0xFFFFB84D),
                    letterSpacing: 1.5,
                    shadows: const [
                      Shadow(
                        blurRadius: 10,
                        color: Color(0xFFFFB84D),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Este es el PURGATORIO MENTAL.\n\n"
                  "Escoge PERCEPCIÓN para iniciar tu aventura.\n\n"
                  "Cada nivel desbloquea el siguiente.\n\n"
                  "¡Buena suerte!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "VT323",
                    fontSize: bodySize,
                    color: const Color(0xFFEFF4FF),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: () {
                    _setTutorialSeen();
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB84D),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: const Color(0xFF5A9FB8), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFB84D).withOpacity(0.35),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Text(
                      "ENTRAR",
                      style: TextStyle(
                        fontFamily: "PressStart2P",
                        fontSize: buttonSize,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    ).then((_) => _setTutorialSeen()); // ✅ Se marca visto aunque lo cierre
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final small = size.width < 450;

    return Scaffold(
      backgroundColor: _isLiberated
          ? const Color(0xFFFFE8CC) // ✅ Fondo cálido (liberado)
          : const Color(0xFF0D0D1A), // Purgatorio oscuro
      body: Stack(
        children: [
          // ✅ Fondo animado: LLUVIA vs HOJAS + SOL
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => CustomPaint(
              painter: _isLiberated
                  ? LiberationPainter(_controller.value) // ✅ NUEVO
                  : RainPainter(_controller.value),
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
                    _isLiberated ? "LIBERACIÓN MENTAL" : "PURGATORIO MENTAL",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: small ? 16 : 20,
                      color: _isLiberated
                          ? const Color(0xFFFFB84D) // ✅ Dorado cálido
                          : const Color(0xFF5A9FB8),
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          blurRadius: 12,
                          color: _isLiberated
                              ? const Color(0xFFFFB84D)
                              : const Color(0xFF5A9FB8),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: small ? 16 : 30,
                      vertical: 10,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: small ? 1 : 2,
                      crossAxisSpacing: small ? 16 : 24,
                      mainAxisSpacing: small ? 16 : 24,
                      childAspectRatio: small ? 1.3 : 1.15,
                    ),
                    itemCount: blocks.length,
                    itemBuilder: (context, index) {
                      final block = blocks[index];

                      return _MindBlockCard(
                        title: block["title"] as String,
                        description: block["desc"] as String,
                        icon: block["icon"] as IconData,
                        color: block["color"] as Color,
                        available: block["available"] as bool,
                        isLiberated: _isLiberated, // ✅ NUEVO
                        onTap: () {
                          if ((block["available"] as bool) == false) return;

                          if (block["title"] == "PERCEPCIÓN") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PercepcionMenuScreen(),
                              ),
                            ).then((_) {
                              _refreshCoins();
                              _loadUnlockedLevels();
                              _checkLiberation(); // ✅ RECARGAR LIBERACIÓN
                            });
                          }

                          if (block["title"] == "LÓGICA") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => LogicaMenuScreen()),
                            ).then((_) {
                              _refreshCoins();
                              _loadUnlockedLevels();
                              _checkLiberation();
                            });
                          }

                          if (block["title"] == "CIENCIA Y TECNOLOGÍA") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const CienciaMenuScreen()),
                            ).then((_) {
                              _refreshCoins();
                              _loadUnlockedLevels();
                              _checkLiberation();
                            });
                          }

                          if (block["title"] == "CULTURA GENERAL") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const CulturaMenuScreen()),
                            ).then((_) {
                              _refreshCoins();
                              _loadUnlockedLevels();
                              _checkLiberation();
                            });
                          }
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),

          Positioned(
            left: 20,
            bottom: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const SelectLevelScreen()),
                  (route) => false,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: _isLiberated
                      ? const Color(0xFFFFD89E).withOpacity(0.9)
                      : const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _isLiberated
                        ? const Color(0xFFFFB84D)
                        : const Color(0xFF5A9FB8),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_isLiberated
                              ? const Color(0xFFFFB84D)
                              : const Color(0xFF5A9FB8))
                          .withOpacity(0.4),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_back_rounded,
                      color: _isLiberated
                          ? const Color(0xFFFFB84D)
                          : const Color(0xFF5A9FB8),
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "MENU",
                      style: TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 14,
                        color: _isLiberated
                            ? const Color(0xFFFFB84D)
                            : const Color(0xFF5A9FB8),
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

class _MindBlockCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool available;
  final bool isLiberated; // ✅ NUEVO
  final VoidCallback onTap;

  const _MindBlockCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.available,
    required this.isLiberated,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final small = MediaQuery.of(context).size.width < 450;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: isLiberated
            ? const Color(0xFFFFF8DC).withOpacity(available ? 0.95 : 0.5)
            : const Color(0xFF1A1A2E).withOpacity(available ? 0.95 : 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: available ? color : Colors.grey.shade700,
          width: 2.5,
        ),
        boxShadow: available
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: available ? onTap : null,
        child: Padding(
          padding: EdgeInsets.all(small ? 18 : 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: small ? 55 : 70,
                color: available ? color : Colors.grey,
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: small ? 13 : 15,
                  color: available ? color : Colors.grey,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'VT323',
                  fontSize: small ? 24 : 28,
                  color: available
                      ? (isLiberated ? Colors.black87 : Colors.white)
                      : Colors.grey.shade600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ✅ LLUVIA (PURGATORIO)
class RainPainter extends CustomPainter {
  final double progress;

  RainPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF5A9FB8).withOpacity(0.15)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final random = math.Random(42);

    for (int i = 0; i < 80; i++) {
      final x = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final y = (baseY + progress * size.height * 1.5) % size.height;

      final dropLength = 20 + random.nextDouble() * 30;

      canvas.drawLine(
        Offset(x, y),
        Offset(x - 3, y + dropLength),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ✅ NUEVO: SOL + HOJAS CAYENDO (LIBERACIÓN)
class LiberationPainter extends CustomPainter {
  final double progress;

  LiberationPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    // ✅ SOL RADIANTE
    final sunGlow = Paint()
      ..color = const Color(0xFFFFE082)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);

    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.15),
      90,
      sunGlow,
    );

    final sunCore = Paint()..color = const Color(0xFFFFD54F);
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.15),
      60,
      sunCore,
    );

    // ✅ HOJAS CAYENDO
    final random = math.Random(42);
    for (int i = 0; i < 60; i++) {
      final x = random.nextDouble() * size.width;
      final y = (random.nextDouble() * size.height +
              progress * 200 * (i % 2 == 0 ? 1 : -1)) %
          size.height;

      final leafColor = i % 3 == 0
          ? const Color(0xFFD4A574)
          : i % 2 == 0
              ? const Color(0xFFE6C79C)
              : const Color(0xFFFFF8DC);

      final leafPaint = Paint()..color = leafColor.withOpacity(0.8);

      canvas.drawCircle(Offset(x, y), i % 4 == 0 ? 6 : 4, leafPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}