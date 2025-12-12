import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../data/progress_manager.dart';
import '../hud_widget.dart';
import '../comodines_screen.dart';
import 'percepcion_quiz_screen.dart';
import '../jefes_screen.dart';
import '../purgatorio_screen.dart';

class PercepcionMenuScreen extends StatefulWidget {
  const PercepcionMenuScreen({super.key});

  @override
  State<PercepcionMenuScreen> createState() => _PercepcionMenuScreenState();
}

class _PercepcionMenuScreenState extends State<PercepcionMenuScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fogController;

  int coins = 0;
  
  // ✅ Variable para controlar el tiempo entre mensajes (Anti-Spam)
  DateTime? _lastSnackTime;

  // ✅ Variable para controlar el titileo del HUD
  bool _showComodinesNotification = false;

  // Inicializamos con el 1 desbloqueado por defecto
  Map<int, bool> unlocked = {1: true, 2: false};
  Map<int, bool> completed = {1: false, 2: false};

  final List<Map<String, dynamic>> blocks = [
    {
      "id": 1,
      "title": "Bloque 1",
      "questions": 5,
      "isBoss": false,
      "color": const Color(0xFF6BE3FF),
      "bossName": null,
    },
    {
      "id": 2,
      "title": "Bloque Jefe",
      "questions": 10,
      "isBoss": true,
      "color": const Color(0xFFFF5C5C),
      "bossName": "La sombra del ojo",
    },
  ];

  @override
  void initState() {
    super.initState();

    _fogController =
        AnimationController(vsync: this, duration: const Duration(seconds: 18))
          ..repeat();

    _loadCoins();
    _loadUnlocks();
    _checkNotification(); // ✅ Revisar notificación al entrar
  }

  // ✅ Lógica de notificación
  Future<void> _checkNotification() async {
    final hasNew = await ProgressManager.getBool("has_new_powerup") ?? false;
    if (mounted) setState(() => _showComodinesNotification = hasNew);
  }

  Future<void> _loadUnlocks() async {
    final u2 = await ProgressManager.isBlockUnlocked(2);
    final c1 = await ProgressManager.isBlockCompleted(1);
    final c2 = await ProgressManager.isBlockCompleted(2);

    setState(() {
      unlocked[1] = true; // ✅ Nivel 1 siempre abierto
      unlocked[2] = u2;
      completed[1] = c1;
      completed[2] = c2;
    });
  }

  Future<void> _loadCoins() async {
    final progress = await ProgressManager.loadProgress();
    setState(() => coins = progress.coins);
  }

  void _refreshCoins() async {
    final progress = await ProgressManager.loadProgress();
    setState(() => coins = progress.coins);
  }

  // ✅ FUNCIÓN SEGURA PARA MOSTRAR MENSAJES (Con 3 seg de espera)
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
    _fogController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 500;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      body: Stack(
        children: [
          // Niebla animada
          AnimatedBuilder(
            animation: _fogController,
            builder: (context, _) => CustomPaint(
              painter: _FogPainter(_fogController.value),
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
                    showNotification: _showComodinesNotification, // ✅ Activar titileo
                    onOpenComodines: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ComodinesScreen()),
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

                const SizedBox(height: 28),

                // Título
                Text(
                  "PERCEPCIÓN",
                  style: TextStyle(
                    fontFamily: 'PressStart2P',
                    color: const Color(0xFF6BE3FF),
                    fontSize: isSmall ? 18 : 22,
                    letterSpacing: 3,
                    shadows: const [
                      Shadow(
                        blurRadius: 18,
                        color: Color(0xFF6BE3FF),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 35),

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
                      final int id = block["id"];

                      final bool isUnlocked = unlocked[id] ?? false;
                      final bool isCompleted = completed[id] ?? false;

                      return _SilentBlockCard(
                        title: block["title"],
                        questions: block["questions"],
                        isBoss: block["isBoss"],
                        color: block["color"],
                        isUnlocked: isUnlocked,
                        isCompleted: isCompleted,
                        bossName: block["bossName"],
                        onTap: () {
                          // 1. VERIFICAR SI ESTÁ COMPLETADO
                          if (isCompleted) {
                            _showSafeSnackBar(
                              "¡Ya completaste este bloque!",
                              const Color(0xFF69F0AE),
                              Colors.black,
                            );
                            return; 
                          }

                          // 2. VERIFICAR SI ESTÁ BLOQUEADO
                          if (id != 1 && !isUnlocked) {
                            _showSafeSnackBar(
                              "Completa el bloque anterior",
                              Colors.redAccent,
                              Colors.white,
                            );
                            return;
                          }

                          // 3. SI TODO ESTÁ BIEN, NAVEGAR
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PercepcionQuizScreen(
                                blockId: block["id"],
                                totalQuestions: block["questions"],
                                isBoss: block["isBoss"],
                              ),
                            ),
                          ).then((_) {
                            _loadCoins();
                            _loadUnlocks();
                            _checkNotification(); // ✅ Revisar si ganó al jefe
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

          // Botón Volver
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
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF6BE3FF),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6BE3FF).withOpacity(0.4),
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
                      color: Color(0xFF6BE3FF),
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Text(
                      "VOLVER",
                      style: TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 13,
                        color: Color(0xFF6BE3FF),
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
// TARJETA DE BLOQUE (CORREGIDA: SIN NEÓN AL COMPLETAR)
// ----------------------------------------------------------
class _SilentBlockCard extends StatefulWidget {
  final String title;
  final int questions;
  final bool isBoss;
  final Color color;
  final bool isUnlocked;
  final bool isCompleted;
  final String? bossName;
  final VoidCallback onTap;

  const _SilentBlockCard({
    required this.title,
    required this.questions,
    required this.isBoss,
    required this.color,
    required this.isUnlocked,
    required this.isCompleted,
    required this.onTap,
    this.bossName,
  });

  @override
  State<_SilentBlockCard> createState() => _SilentBlockCardState();
}

class _SilentBlockCardState extends State<_SilentBlockCard>
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

    // ✅ LÓGICA DE COLOR
    Color displayColor;
    if (widget.isCompleted) {
      displayColor = const Color(0xFF69F0AE); // Verde
    } else if (!widget.isUnlocked) {
      displayColor = Colors.grey.shade700;
    } else {
      displayColor = widget.color;
    }

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        // ✅ Solo pulsa si está desbloqueado Y NO completado.
        final pulseOpacity = (widget.isUnlocked && !widget.isCompleted)
            ? 0.3 + (_pulseController.value * 0.3)
            : 0.0;

        return GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: const Color(0xFF1A1A2E).withOpacity(
                widget.isUnlocked ? 0.9 : 0.5,
              ),
              border: Border.all(
                color: displayColor,
                width: widget.isUnlocked ? 3 : 2,
              ),
              boxShadow: [
                // ✅ Sin sombra neon si está completado
                if (widget.isUnlocked && !widget.isCompleted)
                  BoxShadow(
                    color: displayColor.withOpacity(pulseOpacity),
                    blurRadius: 30,
                    spreadRadius: 3,
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
                    widget.isBoss ? Icons.flash_on : Icons.remove_red_eye,
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

                  if (widget.bossName != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          widget.bossName!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'VT323',
                            color: Colors.white70,
                            fontSize: isSmall ? 18 : 22,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 8), 
                  
                  // CANTIDAD PREGUNTAS
                  Text(
                    "${widget.questions} preguntas",
                    style: TextStyle(
                      fontFamily: 'VT323',
                      color: Colors.white,
                      fontSize: isSmall ? 20 : 24,
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
// PINTOR DE NIEBLA
// ----------------------------------------------------------
class _FogPainter extends CustomPainter {
  final double progress;
  _FogPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);

    for (int i = 0; i < 8; i++) {
      final dx = math.sin(progress * 2 * math.pi + i * 0.7) * 180;
      final dy = size.height * i / 8;
      final rect = Rect.fromLTWH(
        dx,
        dy,
        size.width * 1.6,
        140,
      );
      canvas.drawOval(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}