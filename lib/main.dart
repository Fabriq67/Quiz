import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'select_level_screen.dart';

void main() {
  runApp(const QuizMenteApp());
}

class QuizMenteApp extends StatelessWidget {
  const QuizMenteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QuizMente',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF1B0E2E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF4B82),
          secondary: Color(0xFF00FFF0),
          background: Color(0xFF1B0E2E),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            color: Color(0xFFE6E6E6),
            fontFamily: 'VT323',
            fontSize: 20,
          ),
        ),
        fontFamily: 'VT323',
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          // Fondo retro animado (rejilla 3D tipo consola)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: RetroBackgroundPainter(_controller.value),
                size: size,
              );
            },
          ),

          // Contenido principal
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Título tipo pixel arcade
                Text(
                  'QUIZMENTE',
                  style: TextStyle(
                    fontFamily: 'PressStart2P',
                    fontSize: 26,
                    color: const Color(0xFF00FFF0),
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: const Color(0xFFFF4B82).withOpacity(0.7),
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),

                // Botones pixelados arcade
                PixelButton(
                  text: 'JUGAR',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SelectLevelScreen()),
                    );
                  },
                ),
                PixelButton(
                  text: 'INSTRUCCIONES',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: const Color(0xFF2B1E40),
                        title: const Text(
                          'INSTRUCCIONES',
                          style: TextStyle(
                            fontFamily: 'VT323',
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                        content: const Text(
                          'Responde correctamente las preguntas, avanza entre los mundos mentales y derrota a los jefes intelectuales. ¡Demuestra tu poder cognitivo!',
                          style: TextStyle(
                            color: Colors.white70,
                            fontFamily: 'VT323',
                            fontSize: 20,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Cerrar',
                              style: TextStyle(
                                color: Color(0xFF00FFF0),
                                fontFamily: 'VT323',
                                fontSize: 20,
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------- BOTÓN PIXELADO ----------
class PixelButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const PixelButton({super.key, required this.text, required this.onTap});

  @override
  State<PixelButton> createState() => _PixelButtonState();
}

class _PixelButtonState extends State<PixelButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        decoration: BoxDecoration(
          color: _pressed ? const Color(0xFFFF4B82) : const Color(0xFF2B1E40),
          border: Border.all(color: const Color(0xFF00FFF0), width: 3),
          boxShadow: _pressed
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFF00FFF0).withOpacity(0.5),
                    offset: const Offset(3, 3),
                  )
                ],
        ),
        child: Text(
          widget.text,
          style: const TextStyle(
            fontFamily: 'PressStart2P',
            color: Colors.white,
            fontSize: 14,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

/// ---------- FONDO RETRO ANIMADO ----------
class RetroBackgroundPainter extends CustomPainter {
  final double progress;
  RetroBackgroundPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00FFF0).withOpacity(0.15)
      ..strokeWidth = 1.0;

    // Líneas horizontales
    for (double y = 0; y < size.height; y += 25) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Líneas verticales animadas
    for (double x = 0; x < size.width; x += 25) {
      final offset = math.sin(progress * 2 * math.pi + x / 50) * 5;
      canvas.drawLine(Offset(x, 0 + offset), Offset(x, size.height - offset), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
