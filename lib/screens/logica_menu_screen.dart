import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../data/progress_manager.dart';
import '../comodines_screen.dart';
import '../hud_widget.dart';
import '../jefes_screen.dart'; 
import '../purgatorio_screen.dart';
import 'logica_quiz_screen.dart';

class LogicaMenuScreen extends StatefulWidget {
  const LogicaMenuScreen({super.key});

  @override
  State<LogicaMenuScreen> createState() => _LogicaMenuScreenState();
}

class _LogicaMenuScreenState extends State<LogicaMenuScreen>
    with TickerProviderStateMixin {
  late AnimationController _gridController;
  late AnimationController _particleController;

  int coins = 0;
  
  // ✅ Variable Anti-Spam para logs (3 segundos)
  DateTime? _lastSnackTime;
  
  // ✅ Variable para el titileo del HUD
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
      "color": Color(0xFF5A9FD4), // Azul Lógica
      "bossName": null,
    },
    {
      "id": 2,
      "title": "Bloque 2",
      "difficulty": "Medio",
      "questions": 5,
      "isBoss": false,
      "color": Color(0xFF7FA8C9), // Azul Grisáceo
      "bossName": null,
    },
    {
      "id": 3,
      "title": "Bloque 3", // (Jefe)
      "difficulty": "Difícil",
      "questions": 10,
      "isBoss": true,
      "color": Color(0xFFD47A7A), // Rojo Deslavado
      "bossName": "El Rompecódigos",
    },
  ];

  @override
  void initState() {
    super.initState();

    _gridController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _loadCoins();
    _loadUnlocks();
    _checkNotification(); // ✅ Verificamos si debe titilar al entrar
  }

  // ✅ Función para checar notificación
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
    final u1 = await ProgressManager.isLogicBlockUnlocked(1);
    final u2 = await ProgressManager.isLogicBlockUnlocked(2);
    final u3 = await ProgressManager.isLogicBlockUnlocked(3);

    final c1 = await ProgressManager.isLogicBlockCompleted(1);
    final c2 = await ProgressManager.isLogicBlockCompleted(2);
    final c3 = await ProgressManager.isLogicBlockCompleted(3);

    setState(() {
      unlocked[1] = true; // ✅ FORZADO: Nivel 1 siempre abierto
      unlocked[2] = u2;
      unlocked[3] = u3;

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
    _gridController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 500;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Stack(
        children: [
          // FONDO GRID FUTURISTA
          AnimatedBuilder(
            animation: _gridController,
            builder: (context, _) => CustomPaint(
              painter: _FuturisticGridPainter(_gridController.value),
              size: size,
            ),
          ),

          // PARTÍCULAS FLOTANTES
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, _) => CustomPaint(
              painter: _ParticlePainter(_particleController.value),
              size: size,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),

                // ✅ HUD ACTUALIZADO
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GameHUD(
                    coins: coins,
                    showNotification: _showComodinesNotification, // ✅ Pasar estado
                    onOpenComodines: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ComodinesScreen()),
                    ).then((_) {
                      _refreshCoins();
                      _checkNotification(); // Recargar estado (debería apagarse)
                    }),
                    onOpenJefes: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const JefesScreen()),
                    ).then((_) => _refreshCoins()), // Refrescar al volver
                  ),
                ),

                const SizedBox(height: 24),

                // TÍTULO
                Text(
                  "LÓGICA",
                  style: TextStyle(
                    fontFamily: 'PressStart2P',
                    color: const Color(0xFF5A9FD4),
                    fontSize: isSmall ? 18 : 22,
                    letterSpacing: 3,
                    shadows: const [
                      Shadow(
                        blurRadius: 15,
                        color: Color(0xFF5A9FD4),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

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
                      childAspectRatio: isSmall ? 1.4 : 1.2,
                    ),
                    itemCount: blocks.length,
                    itemBuilder: (context, index) {
                      final block = blocks[index];
                      final id = block["id"] as int;

                      final bool isUnlocked = unlocked[id] ?? false;
                      final bool isCompleted = completed[id] ?? false;

                      return _LogicBlockCard(
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

                          // 3. NAVEGACIÓN (con callback de retorno)
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LogicaQuizScreen(
                                blockId: id,
                                totalQuestions: block["questions"],
                                isBoss: block["isBoss"],
                              ),
                            ),
                          ).then((_) {
                            _refreshCoins();
                            _loadUnlocks();
                            _checkNotification(); // Revisar si desbloqueó comodín
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
                  color: const Color(0xFF0A0E1A),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF5A9FD4),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5A9FD4).withOpacity(0.4),
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
                      color: Color(0xFF5A9FD4),
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Text(
                      "VOLVER",
                      style: TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 13,
                        color: Color(0xFF5A9FD4),
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
// TARJETA DE BLOQUE (DISEÑO UNIFICADO CON PERCEPCIÓN)
// ----------------------------------------------------------
class _LogicBlockCard extends StatefulWidget {
  final String title;
  final String difficulty;
  final int questions;
  final bool isBoss;
  final Color color;
  final String? bossName;
  final bool isUnlocked;
  final bool isCompleted;
  final VoidCallback onTap;

  const _LogicBlockCard({
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
  State<_LogicBlockCard> createState() => _LogicBlockCardState();
}

class _LogicBlockCardState extends State<_LogicBlockCard>
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

    // ✅ LÓGICA DE COLOR (Igual que Percepción)
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
              color: const Color(0xFF0F1420).withOpacity(
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
              // ✅ Padding ajustado
              padding: EdgeInsets.symmetric(
                  vertical: isSmall ? 8 : 12, horizontal: isSmall ? 16 : 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.isBoss ? Icons.extension : Icons.settings,
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

                  // JEFE NOMBRE
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
// PAINTERS
// ----------------------------------------------------------
class _FuturisticGridPainter extends CustomPainter {
  final double progress;
  _FuturisticGridPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF5A9FD4).withOpacity(0.08)
      ..strokeWidth = 1.5;

    for (double y = 0; y < size.height; y += 35) {
      final offset = math.sin(progress * 2 * math.pi + y / 50) * 8;
      canvas.drawLine(
        Offset(offset, y),
        Offset(size.width + offset, y),
        paint,
      );
    }

    for (double x = 0; x < size.width; x += 35) {
      final offset = math.cos(progress * 2 * math.pi + x / 50) * 8;
      canvas.drawLine(
        Offset(x, offset),
        Offset(x, size.height + offset),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  _ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF5A9FD4).withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final random = math.Random(42);

    for (int i = 0; i < 30; i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;

      final x = baseX + math.sin(progress * 2 * math.pi + i) * 20;
      final y = (baseY + progress * size.height * 0.5) % size.height;

      canvas.drawCircle(Offset(x, y), 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}