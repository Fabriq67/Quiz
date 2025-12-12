import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'hud_widget.dart';
import 'comodines_screen.dart';
import 'jefes_screen.dart';
import '../data/progress_manager.dart';
import '../data/powerups_service.dart'; // ✅ Necesario para cargar info de comodines

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
  bool _isLiberated = false;
  
  // Variable para controlar si el HUD debe titilar
  bool _showComodinesNotification = false;

  final blocks = [
    {
      "title": "PERCEPCIÓN",
      "desc": "Ve más allá de lo evidente.",
      "icon": Icons.visibility,
      "color": Color(0xFF6BE3FF),
      "available": true,
    },
    {
      "title": "LÓGICA",
      "desc": "Completa 'Percepción' para desbloquear.",
      "icon": Icons.extension,
      "color": Color.fromARGB(255, 144, 25, 180),
      "available": false,
    },
    {
      "title": "CIENCIA",
      "desc": "Completa 'Lógica' para acceder.",
      "icon": Icons.science,
      "color": Color.fromARGB(255, 31, 174, 23),
      "available": false,
    },
    {
      "title": "CULTURA",
      "desc": "El juicio final te espera.",
      "icon": Icons.public,
      "color": Color.fromARGB(255, 202, 34, 34),
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
    _checkLiberation();
    
    // ✅ AQUÍ ESTÁ LA MAGIA: Ejecutamos la lógica al iniciar la app
    _checkPowerUpsLogic();
  }

  // ✅ LÓGICA DE COMODINES (AUTO-SELECCIÓN + NOTIFICACIÓN)
  Future<void> _checkPowerUpsLogic() async {
    final progress = await ProgressManager.loadProgress();
    final selected = await ProgressManager.loadSelectedPowerUps();
    
    // 1. AUTO-SELECCIÓN CON TU CONDICIÓN ESPECÍFICA:
    // - No hay nada seleccionado (selected.isEmpty)
    // - Y ADEMÁS, solo hay 1 comodín desbloqueado (progress.unlockedPowerUps.length == 1)
    //   (Esto evita que se cambie solo si ya desbloqueaste otros y los desmarcaste a propósito)
    if (selected.isEmpty && progress.unlockedPowerUps.length == 1) {
      try {
        final allPowerUps = await PowerUpsService.loadPowerUps();
        // Buscamos "Pulso Temporal" (o el primero por defecto)
        final defaultPowerUp = allPowerUps.firstWhere(
          (p) => p.name.toLowerCase().contains("pulso"), 
          orElse: () => allPowerUps.first,
        );

        // Verificamos que ese único desbloqueado sea este
        if (progress.unlockedPowerUps.contains(defaultPowerUp.id)) {
          await ProgressManager.saveSelectedPowerUps([defaultPowerUp]);
          debugPrint("✅ Auto-seleccionado por defecto: ${defaultPowerUp.name}");
        }
      } catch (e) {
        debugPrint("Error en auto-selección: $e");
      }
    }

    // 2. NOTIFICACIÓN: Verificar si hay que titilar el HUD
    final hasNew = await ProgressManager.getBool("has_new_powerup") ?? false;
    
    if (mounted) {
      setState(() {
        _showComodinesNotification = hasNew;
      });
    }
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

        return Center(
          child: Container(
            width: math.min(size.width * 0.9, 420),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF15152B),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFF6BE3FF), width: 3),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6BE3FF).withOpacity(0.35),
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
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Este es el PURGATORIO MENTAL.\n\n"
                  "Desbloquea los candados superando cada bloque.\n\n"
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
                        horizontal: 40, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB84D),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "ENTRAR",
                      style: TextStyle(
                        fontFamily: "PressStart2P",
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    ).then((_) => _setTutorialSeen());
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
      backgroundColor:
          _isLiberated ? const Color(0xFFFFE8CC) : const Color(0xFF0D0D1A),
      body: Stack(
        children: [
          // 1. Fondo Animado
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => CustomPaint(
              painter: _isLiberated
                  ? LiberationPainter(_controller.value)
                  : RainPainter(_controller.value),
              size: size,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),
                
                // ✅ HUD ACTUALIZADO: Recibe la notificación para titilar
                GameHUD(
                  coins: coins,
                  showNotification: _showComodinesNotification, // <-- AQUÍ
                  onOpenComodines: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ComodinesScreen()),
                    ).then((_) {
                      _refreshCoins();
                      _checkPowerUpsLogic(); // Recargar al volver (debería apagarse el brillo)
                    });
                  },
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
                          ? const Color.fromARGB(255, 100, 61, 3)
                          : const Color(0xFF6BE3FF),
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          blurRadius: 15,
                          color: _isLiberated
                              ? const Color(0xFFFFB84D)
                              : const Color(0xFF6BE3FF),
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

                      return _ReferenceStyleCard(
                        title: block["title"] as String,
                        description: block["desc"] as String,
                        icon: block["icon"] as IconData,
                        color: block["color"] as Color,
                        available: block["available"] as bool,
                        onTap: () {
                          if ((block["available"] as bool) == false) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor:
                                    (block["color"] as Color).withOpacity(0.3),
                                duration: const Duration(milliseconds: 800),
                                content: Text(
                                  "🔒 Nivel Bloqueado",
                                  style: TextStyle(
                                      fontFamily: 'PressStart2P',
                                      fontSize: 10,
                                      color: (block["color"] as Color)),
                                ),
                              ),
                            );
                            return;
                          }

                          // ✅ Callback al volver del nivel para actualizar todo
                          if (block["title"] == "PERCEPCIÓN") {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const PercepcionMenuScreen()))
                                .then((_) => _onReturnFromLevel());
                          } else if (block["title"] == "LÓGICA") {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => LogicaMenuScreen()))
                                .then((_) => _onReturnFromLevel());
                          } else if (block["title"] == "CIENCIA") {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const CienciaMenuScreen()))
                                .then((_) => _onReturnFromLevel());
                          } else if (block["title"] == "CULTURA") {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const CulturaMenuScreen()))
                                .then((_) => _onReturnFromLevel());
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
                  MaterialPageRoute(
                      builder: (_) => const SelectLevelScreen()),
                  (route) => false,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _isLiberated
                        ? const Color(0xFFFFB84D)
                        : const Color(0xFF6BE3FF),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_isLiberated
                              ? const Color(0xFFFFB84D)
                              : const Color(0xFF6BE3FF))
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
                          : const Color(0xFF6BE3FF),
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
                            : const Color(0xFF6BE3FF),
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

  // ✅ Método para recargar todo al volver de un nivel
  void _onReturnFromLevel() {
    _refreshCoins();
    _loadUnlockedLevels();
    _checkLiberation();
    _checkPowerUpsLogic(); // Chequeamos si se desbloqueó algún comodín nuevo
  }
}

// ---------------------------------------------------------------------------
// ✅ TARJETA SUTIL (Se mantiene igual que antes)
// ---------------------------------------------------------------------------
class _ReferenceStyleCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool available;
  final VoidCallback onTap;

  const _ReferenceStyleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.available,
    required this.onTap,
  });

  @override
  State<_ReferenceStyleCard> createState() => _ReferenceStyleCardState();
}

class _ReferenceStyleCardState extends State<_ReferenceStyleCard>
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
    final small = MediaQuery.of(context).size.width < 450;
    final displayColor = widget.available
        ? widget.color
        : widget.color.withOpacity(0.4);

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulseOpacity = widget.available
            ? 0.2 + (_pulseController.value * 0.25)
            : 0.0;

        return GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E).withOpacity(
                widget.available ? 0.95 : 0.85,
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: displayColor,
                width: widget.available ? 3 : 2,
              ),
              boxShadow: widget.available
                  ? [
                      BoxShadow(
                        color: displayColor.withOpacity(pulseOpacity),
                        blurRadius: 12,
                        spreadRadius: 0, 
                      ),
                    ]
                  : [],
            ),
            child: Padding(
              padding: EdgeInsets.all(small ? 18 : 22),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.available ? widget.icon : Icons.lock_outline_rounded,
                    color: displayColor,
                    size: small ? 55 : 65,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'PressStart2P',
                      color: displayColor,
                      fontSize: small ? 13 : 15,
                      letterSpacing: 1.5,
                      shadows: widget.available
                          ? [Shadow(blurRadius: 8, color: displayColor)]
                          : [],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    widget.description,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'VT323',
                      fontSize: small ? 22 : 24,
                      color: Colors.white
                          .withOpacity(widget.available ? 0.95 : 0.5),
                      height: 1.2,
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

// ---------------------------------------------------------------------------
// PAINTERS
// ---------------------------------------------------------------------------
class RainPainter extends CustomPainter {
  final double progress;
  RainPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6BE3FF).withOpacity(0.15)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final random = math.Random(42);
    for (int i = 0; i < 80; i++) {
      final x = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final y = (baseY + progress * size.height * 1.5) % size.height;
      final dropLength = 20 + random.nextDouble() * 30;
      canvas.drawLine(Offset(x, y), Offset(x - 3, y + dropLength), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class LiberationPainter extends CustomPainter {
  final double progress;
  LiberationPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final sunGlow = Paint()
      ..color = const Color(0xFFFFE082)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);
    canvas.drawCircle(
        Offset(size.width * 0.85, size.height * 0.15), 90, sunGlow);
    final sunCore = Paint()..color = const Color(0xFFFFD54F);
    canvas.drawCircle(
        Offset(size.width * 0.85, size.height * 0.15), 60, sunCore);

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