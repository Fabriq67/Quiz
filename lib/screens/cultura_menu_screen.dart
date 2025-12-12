import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../data/progress_manager.dart';
import '../hud_widget.dart';
import '../comodines_screen.dart';
import '../jefes_screen.dart';
import 'cultura_quiz_screen.dart';
import '../purgatorio_screen.dart';

class CulturaMenuScreen extends StatefulWidget {
  const CulturaMenuScreen({super.key});

  @override
  State<CulturaMenuScreen> createState() => _CulturaMenuScreenState();
}

class _CulturaMenuScreenState extends State<CulturaMenuScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  int coins = 0;
  
  // ✅ Variable Anti-Spam para logs (3 segundos)
  DateTime? _lastSnackTime;

  Map<int, bool> unlocked = {1: true, 2: false, 3: false, 4: false};
  Map<int, bool> completed = {1: false, 2: false, 3: false, 4: false};

  final List<Map<String, dynamic>> blocks = [
    {
      "id": 1,
      "title": "Bloque 1",
      "difficulty": "Fácil",
      "questions": 5,
      "isBoss": false,
      "color": Color(0xFFB388FF), // Lavanda Neón
      "bossName": null,
    },
    {
      "id": 2,
      "title": "Bloque 2",
      "difficulty": "Medio",
      "questions": 5,
      "isBoss": false,
      "color": Color(0xFF9C6EFF), // Púrpura Medio
      "bossName": null,
    },
    {
      "id": 3,
      "title": "Bloque 3",
      "difficulty": "Difícil",
      "questions": 10,
      "isBoss": false,
      "color": Color(0xFF7F4DFF), // Violeta Intenso
      "bossName": null,
    },
    {
      "id": 4,
      "title": "Bloque Final", // (Jefe)
      "difficulty": "Mega Difícil",
      "questions": 20,
      "isBoss": true,
      "color": Color(0xFFE040FB), // Magenta Eléctrico
      "bossName": "El Juicio Relámpago",
    },
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _loadCoins();
    _loadUnlocks();
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
    final u2 = await ProgressManager.isCultureBlockUnlocked(2);
    final u3 = await ProgressManager.isCultureBlockUnlocked(3);
    final u4 = await ProgressManager.isCultureBlockUnlocked(4);

    final c1 = await ProgressManager.isCultureBlockCompleted(1);
    final c2 = await ProgressManager.isCultureBlockCompleted(2);
    final c3 = await ProgressManager.isCultureBlockCompleted(3);
    final c4 = await ProgressManager.isCultureBlockCompleted(4);

    setState(() {
      unlocked[1] = true; // ✅ Nivel 1 siempre abierto
      unlocked[2] = u2;
      unlocked[3] = u3;
      unlocked[4] = u4;
      
      completed[1] = c1;
      completed[2] = c2;
      completed[3] = c3;
      completed[4] = c4;
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 500;

    return Scaffold(
      backgroundColor: const Color(0xFF12052F),
      body: Stack(
        children: [
          // FONDO ANIMADO (Original de Cultura)
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => CustomPaint(
              painter: _NatureLavenderPainter(_controller.value),
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
                      MaterialPageRoute(builder: (_) => const ComodinesScreen()),
                    ).then((_) => _refreshCoins()),
                    onOpenJefes: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const JefesScreen()),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // TÍTULO
                const Text(
                  "CULTURA GENERAL",
                  style: TextStyle(
                    fontFamily: 'PressStart2P',
                    color: Color(0xFFE040FB), // Magenta a juego con el jefe
                    fontSize: 14,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        blurRadius: 15,
                        color: Color(0xFFE040FB),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 22),

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
                      // ✅ Aspect Ratio corregido (Gordito)
                      childAspectRatio: isSmall ? 1.4 : 1.2,
                    ),
                    itemCount: blocks.length,
                    itemBuilder: (context, index) {
                      final block = blocks[index];
                      final id = block["id"] as int;

                      final bool isUnlocked = unlocked[id] ?? false;
                      final bool isCompleted = completed[id] ?? false;

                      return _CultureNeonCard(
                        title: block["title"],
                        difficulty: block["difficulty"],
                        questions: block["questions"],
                        isBoss: block["isBoss"],
                        color: block["color"],
                        bossName: block["bossName"],
                        isUnlocked: isUnlocked,
                        isCompleted: isCompleted,
                        onTap: () {
                          // 1. CHEQUEO DE COMPLETADO
                          if (isCompleted) {
                            _showSafeSnackBar(
                              "¡Ya completaste este bloque!",
                              const Color(0xFF69F0AE),
                              Colors.black,
                            );
                            return;
                          }

                          // 2. CHEQUEO DE BLOQUEO
                          if (id != 1 && !isUnlocked) {
                            _showSafeSnackBar(
                              "Completa el bloque anterior",
                              Colors.redAccent,
                              Colors.white,
                            );
                            return;
                          }

                          // 3. NAVEGACIÓN
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CulturaQuizScreen(
                                blockId: id,
                                totalQuestions: block["questions"],
                                isBoss: block["isBoss"],
                              ),
                            ),
                          ).then((_) {
                            _refreshCoins();
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

          // BOTÓN DE REGRESO (Estilo Unificado Neon - Púrpura)
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
                  color: const Color(0xFF12052F),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color.fromARGB(255, 165, 124, 172),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE040FB).withOpacity(0.4),
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
                      color: Color(0xFFE040FB),
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Text(
                      "VOLVER",
                      style: TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 13,
                        color: Color.fromARGB(255, 141, 57, 155),
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
class _CultureNeonCard extends StatefulWidget {
  final String title;
  final String difficulty;
  final int questions;
  final bool isBoss;
  final Color color;
  final String? bossName;
  final bool isUnlocked;
  final bool isCompleted;
  final VoidCallback onTap;

  const _CultureNeonCard({
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
  State<_CultureNeonCard> createState() => _CultureNeonCardState();
}

class _CultureNeonCardState extends State<_CultureNeonCard>
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

    // ✅ LÓGICA DE COLOR (Igual que los otros menús)
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
        // Solo pulsa si está desbloqueado Y NO completado
        final pulseOpacity = (widget.isUnlocked && !widget.isCompleted)
            ? 0.3 + (_pulseController.value * 0.3)
            : 0.0;

        return GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              // ✅ Borde Redondeado 32
              borderRadius: BorderRadius.circular(32),
              color: const Color(0xFF1A0C3D).withOpacity(
                widget.isUnlocked ? 0.9 : 0.6,
              ),
              border: Border.all(
                color: displayColor,
                width: widget.isUnlocked ? 3 : 2,
              ),
              boxShadow: [
                // ✅ Sombra Neón controlada
                if (widget.isUnlocked && !widget.isCompleted)
                  BoxShadow(
                    color: displayColor.withOpacity(pulseOpacity),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
              ],
            ),
            child: Padding(
              // ✅ Padding ajustado para evitar Overflow
              padding: EdgeInsets.symmetric(
                  vertical: isSmall ? 8 : 12, horizontal: isSmall ? 16 : 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min, // Comprimir contenido
                children: [
                  Icon(
                    widget.isBoss ? Icons.bolt : Icons.menu_book,
                    color: displayColor,
                    size: isSmall ? 45 : 55,
                  ),
                  const SizedBox(height: 8),
                  
                  // TÍTULO
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

                  // DIFICULTAD
                  if (!widget.isBoss || widget.bossName == null)
                    Text(
                      widget.difficulty,
                      style: TextStyle(
                        fontFamily: 'VT323',
                        color: Colors.white70,
                        fontSize: isSmall ? 18 : 22,
                      ),
                    ),

                  // JEFE NOMBRE (Si existe)
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
                  
                  // PREGUNTAS
                  Text(
                    "${widget.questions} preguntas",
                    style: TextStyle(
                      fontFamily: 'VT323',
                      color: Colors.white60,
                      fontSize: isSmall ? 18 : 20,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // ESTADO
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
// PINTOR LAVANDA (FONDO CULTURA)
// ----------------------------------------------------------
class _NatureLavenderPainter extends CustomPainter {
  final double progress;
  _NatureLavenderPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFF12052F);
    canvas.drawRect(Offset.zero & size, bg);

    final random = math.Random(99);
    const lavender = Color(0xFFE6E6FA);

    for (int i = 0; i < 40; i++) {
      final x = random.nextDouble() * size.width;
      final y = (random.nextDouble() * size.height +
              progress * 120 * (i % 2 == 0 ? 1 : -1)) %
          size.height;

      final leafPaint = Paint()
        ..color = lavender.withOpacity(0.15);

      canvas.drawCircle(Offset(x, y), i % 5 == 0 ? 6 : 4, leafPaint);
    }

    final glow = Paint()
      ..color = lavender.withOpacity(0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);

    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.4),
      260,
      glow,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}