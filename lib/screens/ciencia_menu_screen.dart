import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../data/progress_manager.dart';
import '../hud_widget.dart';
import '../comodines_screen.dart';
import '../jefes_screen.dart';
import 'ciencia_quiz_screen.dart';
import '../purgatorio_screen.dart';

class CienciaMenuScreen extends StatefulWidget {
  const CienciaMenuScreen({super.key});

  @override
  State<CienciaMenuScreen> createState() => _CienciaMenuScreenState();
}

class _CienciaMenuScreenState extends State<CienciaMenuScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _spaceController;

  int coins = 0;
  
  // ✅ Variable Anti-Spam para logs
  DateTime? _lastSnackTime;

  // ✅ Variable para notificación HUD (Titileo)
  bool _showComodinesNotification = false;

  Map<int, bool> unlocked = {1: true, 2: false, 3: false};
  Map<int, bool> completed = {1: false, 2: false, 3: false};

  final List<Map<String, dynamic>> blocks = [
    {
      "id": 1,
      "title": "Bloque 1",
      "difficulty": "Fácil",
      "questions": 5,
      "isBoss": false,
      "color": Color(0xFF32CD32), // Verde Lima Neón
      "bossName": null,
    },
    {
      "id": 2,
      "title": "Bloque 2",
      "difficulty": "Medio",
      "questions": 5,
      "isBoss": false,
      "color": Color(0xFF26E6A3), // Turquesa Neón
      "bossName": null,
    },
    {
      "id": 3,
      "title": "Bloque 3", // (Jefe)
      "difficulty": "Difícil",
      "questions": 10,
      "isBoss": true,
      "color": Color(0xFFFF33A1), // Magenta Neón (Jefe)
      "bossName": "El Guardián",
    },
  ];

  @override
  void initState() {
    super.initState();

    _spaceController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _loadCoins();
    _loadUnlocks();
    _checkNotification(); // ✅ Revisar notificación al entrar
  }

  // ✅ Lógica de notificación: Lee si se desbloqueó un comodín
  Future<void> _checkNotification() async {
    final hasNew = await ProgressManager.getBool("has_new_powerup") ?? false;
    if (mounted) setState(() => _showComodinesNotification = hasNew);
  }

  Future<void> _loadCoins() async {
    final progress = await ProgressManager.loadProgress();
    setState(() => coins = progress.coins);
  }

  void _refreshCoins() async {
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

  // ✅ FUNCIÓN SEGURA PARA MOSTRAR MENSAJES (3 seg de espera)
  void _showSafeSnackBar(String message, Color bgColor, Color textColor) {
    final now = DateTime.now();
    
    if (_lastSnackTime != null && 
        now.difference(_lastSnackTime!) < const Duration(seconds: 3)) {
      return; 
    }

    _lastSnackTime = now; 
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: bgColor,
        duration: const Duration(seconds: 2),
        content: Text(
          message,
          style: TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 10,
            color: textColor,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _spaceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 500;

    return Scaffold(
      backgroundColor: const Color(0xFF060218),
      body: Stack(
        children: [
          // FONDO ESPACIAL (Original de Ciencia)
          AnimatedBuilder(
            animation: _spaceController,
            builder: (context, _) => CustomPaint(
              painter: _ScienceSpacePainter(_spaceController.value),
              size: size,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),

                // ✅ HUD CON NOTIFICACIÓN
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GameHUD(
                    coins: coins,
                    showNotification: _showComodinesNotification, // ✅ Activa titileo
                    onOpenComodines: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ComodinesScreen()),
                    ).then((_) {
                      _refreshCoins();
                      _checkNotification(); // Se apaga al volver
                    }),
                    onOpenJefes: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const JefesScreen()),
                    ).then((_) => _refreshCoins()),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  "CIENCIA",
                  style: TextStyle(
                    fontFamily: 'PressStart2P',
                    color: const Color(0xFF32CD32),
                    fontSize: isSmall ? 18 : 22,
                    letterSpacing: 3,
                    shadows: const [
                      Shadow(blurRadius: 15, color: Color(0xFF32CD32)),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

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

                      return _ScienceNeonCard(
                        title: block["title"],
                        difficulty: block["difficulty"],
                        questions: block["questions"],
                        isBoss: block["isBoss"],
                        color: block["color"],
                        bossName: block["bossName"],
                        isUnlocked: isUnlocked,
                        isCompleted: isCompleted,
                        onTap: () {
                          if (isCompleted) {
                            _showSafeSnackBar(
                              "¡Ya completaste este bloque!",
                              const Color(0xFF69F0AE),
                              Colors.black,
                            );
                            return;
                          }

                          if (id != 1 && !isUnlocked) {
                            _showSafeSnackBar(
                              "Completa el bloque anterior",
                              Colors.redAccent,
                              Colors.white,
                            );
                            return;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CienciaQuizScreen(
                                blockId: id,
                                totalQuestions: block["questions"],
                                isBoss: block["isBoss"],
                              ),
                            ),
                          ).then((_) {
                            _refreshCoins();
                            _loadUnlocks();
                            _checkNotification(); // ✅ Revisar si ganó al jefe y encender HUD
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
          
          // BOTÓN DE REGRESO
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
                  color: const Color(0xFF060218),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color.fromARGB(255, 92, 159, 92),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF32CD32).withOpacity(0.4),
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
                      color: Color.fromARGB(255, 82, 183, 82),
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Text(
                      "VOLVER",
                      style: TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 13,
                        color: Color.fromARGB(255, 83, 174, 83),
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
// TARJETA DE BLOQUE (DISEÑO UNIFICADO NEON)
// ----------------------------------------------------------
class _ScienceNeonCard extends StatefulWidget {
  final String title;
  final String difficulty;
  final int questions;
  final bool isBoss;
  final Color color;
  final String? bossName;
  final bool isUnlocked;
  final bool isCompleted;
  final VoidCallback onTap;

  const _ScienceNeonCard({
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
  State<_ScienceNeonCard> createState() => _ScienceNeonCardState();
}

class _ScienceNeonCardState extends State<_ScienceNeonCard>
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
    if (widget.isCompleted) {
      displayColor = const Color(0xFF69F0AE); // Verde Neón Mate
    } else if (!widget.isUnlocked) {
      displayColor = Colors.grey.shade700;
    } else {
      displayColor = widget.color;
    }

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulseOpacity = (widget.isUnlocked && !widget.isCompleted)
            ? 0.3 + (_pulseController.value * 0.3)
            : 0.0;

        return GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              color: const Color(0xFF0B0525).withOpacity(
                widget.isUnlocked ? 0.9 : 0.6,
              ),
              border: Border.all(
                color: displayColor,
                width: widget.isUnlocked ? 3 : 2,
              ),
              boxShadow: [
                if (widget.isUnlocked && !widget.isCompleted)
                  BoxShadow(
                    color: displayColor.withOpacity(pulseOpacity),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: isSmall ? 8 : 12, horizontal: isSmall ? 16 : 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.isBoss ? Icons.shield : Icons.science,
                    color: displayColor,
                    size: isSmall ? 45 : 55,
                  ),
                  const SizedBox(height: 8),
                  
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'PressStart2P',
                        color: displayColor,
                        fontSize: isSmall ? 12 : 14,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  if (!widget.isBoss || widget.bossName == null)
                    Text(
                      widget.difficulty,
                      style: TextStyle(
                        fontFamily: 'VT323',
                        color: Colors.white70,
                        fontSize: isSmall ? 18 : 22,
                      ),
                    ),

                  if (widget.bossName != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          widget.bossName!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'VT323',
                            color: Colors.white,
                            fontSize: isSmall ? 18 : 22,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 6),
                  
                  Text(
                    "${widget.questions} preguntas",
                    style: TextStyle(
                      fontFamily: 'VT323',
                      color: Colors.white60,
                      fontSize: isSmall ? 18 : 20,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  if (widget.isCompleted)
                    const Text(
                      "✅ COMPLETADO",
                      style: TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 9,
                        color: Color(0xFF69F0AE),
                      ),
                    )
                  else if (!widget.isUnlocked)
                    const Text(
                      "🔒 BLOQUEADO",
                      style: TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 9,
                        color: Colors.redAccent,
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
// PINTOR ESPACIAL (FONDO)
// ----------------------------------------------------------
class _ScienceSpacePainter extends CustomPainter {
  final double progress;
  _ScienceSpacePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFF060218);
    canvas.drawRect(Offset.zero & size, bg);

    final starPaint = Paint()..color = Colors.white.withOpacity(0.7);
    final random = math.Random(100);

    for (int i = 0; i < 120; i++) {
      double x = random.nextDouble() * size.width;
      double y = (random.nextDouble() * size.height +
              progress * 80 * (i % 2 == 0 ? 1 : -1)) %
          size.height;

      canvas.drawCircle(Offset(x, y), i % 10 == 0 ? 1.6 : 1.1, starPaint);
    }

    final nebula = Paint()
      ..color = Colors.blue.withOpacity(0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.3), 180, nebula);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.7), 220, nebula);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}