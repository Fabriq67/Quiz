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
          surface: Color(0xFF1B0E2E),
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

    // Mostrar aviso 0.5 segundos después de cargar
    Future.delayed(const Duration(milliseconds: 500), () {
      _showUpdateNotice();
    });
  }

  /// ---------- AVISO EMERGENTE ----------
  void _showUpdateNotice() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Center(
          child: Container(
            width: 330,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2B1E40),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF00FFF0), width: 3),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FFF0).withOpacity(0.4),
                  blurRadius: 18,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "AVISO",
                  style: TextStyle(
                    fontFamily: "PressStart2P",
                    color: const Color(0xFFFF4B82),
                    fontSize: 14,
                    shadows: [
                      Shadow(
                        color: const Color(0xFF00FFF0).withOpacity(0.7),
                        blurRadius: 8,
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  "Esta versión entrega la funcionalidad completa del quiz en PERCEPCIÓN, "
                  "la lógica de bloques y la navegación del Purgatorio Mental.\n\n"
                  "Las monedas, jefes, comodines y el resto de niveles serán añadidos "
                  "en las siguientes actualizaciones antes de la entrega final.",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'VT323',
                    fontSize: 20,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 25),

                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4B82),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF00FFF0),
                        width: 2,
                      ),
                    ),
                    child: const Text(
                      "CERRAR",
                      style: TextStyle(
                        fontFamily: "PressStart2P",
                        color: Colors.white,
                        fontSize: 12,
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          /// ---------- FONDO RETRO ----------
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: RetroBackgroundPainter(_controller.value),
                size: size,
              );
            },
          ),

          /// ---------- CONTENIDO CENTRAL ----------
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Título estilo arcade
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
                ),
                const SizedBox(height: 60),

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
      canvas.drawLine(
          Offset(x, 0 + offset), Offset(x, size.height - offset), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
