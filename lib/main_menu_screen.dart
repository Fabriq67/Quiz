import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'data/progress_manager.dart';
import 'select_level_screen.dart';
import 'free_mode_screen.dart';
import 'instructions_screen.dart';
import 'screens/settings_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgController;
  bool freeModeUnlocked = false;
  bool isGameCompleted = false;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _checkGameStatus();
  }

  Future<void> _checkGameStatus() async {
    final freeModeStatus = await ProgressManager.isFreeModeUnlocked();
    final gameCompletedStatus = await ProgressManager.isGameCompleted();

    if (mounted) {
      setState(() {
        freeModeUnlocked = freeModeStatus;
        isGameCompleted = gameCompletedStatus;
      });

      // Si completó el juego pero no tiene modo libre unlocked, activarlo
      if (gameCompletedStatus && !freeModeStatus) {
        await ProgressManager.unlockFreeMode();
        if (mounted) {
          setState(() => freeModeUnlocked = true);
        }
      }
    }
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      body: Stack(
        children: [
          // Fondo animado
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) => CustomPaint(
              painter: _MainMenuBgPainter(_bgController.value),
              size: size,
            ),
          ),

          // Contenido
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.only(
                    top: size.height * 0.05,
                    left: size.width * 0.04,
                    right: size.width * 0.04,
                  ),
                  child: Column(
                    children: [
                      Text(
                        "QUIZMENTE",
                        style: TextStyle(
                          fontSize: size.width * 0.12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF00FF88),
                          fontFamily: "PressStart2P",
                          shadows: const [
                            Shadow(
                              color: Color(0xFF00FF88),
                              blurRadius: 10,
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.04,
                          vertical: size.height * 0.01,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFFF33A1),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isGameCompleted
                              ? "¡JUEGO COMPLETADO!"
                              : "Desafía tu mente",
                          style: TextStyle(
                            fontSize: size.width * 0.045,
                            color: isGameCompleted
                                ? const Color(0xFFFFD700)
                                : const Color(0xFF00FF88),
                            fontFamily: "VT323",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Botones principales
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Botón JUGAR
                      _MenuButton(
                        label: "JUGAR",
                        color: const Color(0xFF00FF88),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SelectLevelScreen(),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: size.height * 0.02),

                      // Botón ARCADE (solo si modo libre desbloqueado)
                      if (freeModeUnlocked)
                        _MenuButton(
                          label: "ARCADE",
                          color: const Color(0xFFFF33A1),
                          subtitle: "Sin penalizaciones",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const FreeModeScreen(),
                              ),
                            );
                          },
                        ),

                      if (freeModeUnlocked) SizedBox(height: size.height * 0.02),

                      // Botón INSTRUCCIONES
                      _MenuButton(
                        label: "INSTRUCCIONES",
                        color: const Color(0xFF6BE3FF),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const InstructionsScreen(),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: size.height * 0.02),

                      // Botón PROGRESO
                      _MenuButton(
                        label: "PROGRESO",
                        color: const Color(0xFFFFD700),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Footer
                Padding(
                  padding: EdgeInsets.all(size.width * 0.06),
                  child: Column(
                    children: [
                      if (isGameCompleted)
                        Container(
                          padding: EdgeInsets.all(size.width * 0.03),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFFFD700),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "¡Derrota a todos los jefes y desbloquea ARCADE MODE!",
                            style: TextStyle(
                              fontSize: size.width * 0.035,
                              color: const Color(0xFFFFD700),
                              fontFamily: "VT323",
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      if (!isGameCompleted && !freeModeUnlocked)
                        Container(
                          padding: EdgeInsets.all(size.width * 0.03),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFF00FF88),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Completa todos los niveles para desbloquear ARCADE MODE",
                            style: TextStyle(
                              fontSize: size.width * 0.035,
                              color: const Color(0xFF00FF88),
                              fontFamily: "VT323",
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
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

// ============================================================
// BOTÓN PERSONALIZADO DEL MENÚ
// ============================================================
class _MenuButton extends StatefulWidget {
  final String label;
  final Color color;
  final String? subtitle;
  final VoidCallback onTap;

  const _MenuButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.subtitle,
  });

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton>
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
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulseOpacity = 0.3 + (_pulseController.value * 0.2);

        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: size.width * 0.75,
            padding: EdgeInsets.symmetric(
              vertical: size.height * 0.02,
              horizontal: size.width * 0.04,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: widget.color.withOpacity(pulseOpacity + 0.5),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(pulseOpacity),
                  blurRadius: 12,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: size.width * 0.055,
                    fontWeight: FontWeight.bold,
                    color: widget.color,
                    fontFamily: "PressStart2P",
                  ),
                  textAlign: TextAlign.center,
                ),
                if (widget.subtitle != null) ...[
                  SizedBox(height: size.height * 0.01),
                  Text(
                    widget.subtitle!,
                    style: TextStyle(
                      fontSize: size.width * 0.032,
                      color: widget.color.withOpacity(0.7),
                      fontFamily: "VT323",
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// PINTOR DE FONDO
// ============================================================
class _MainMenuBgPainter extends CustomPainter {
  final double progress;

  _MainMenuBgPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFF0B0F14);
    canvas.drawRect(Offset.zero & size, bg);

    // Líneas horizontales animadas
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;

    for (int i = 0; i < 30; i++) {
      final y = (i * 30 + progress * 150) % size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    // Puntos de luz flotantes
    final particlePaint = Paint()..color = Colors.white.withOpacity(0.15);
    final random = math.Random(42);

    for (int i = 0; i < 40; i++) {
      final x = random.nextDouble() * size.width;
      final y = (random.nextDouble() * size.height + progress * 300) %
          size.height;
      final radius = random.nextDouble() * 2;
      canvas.drawCircle(Offset(x, y), radius, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
