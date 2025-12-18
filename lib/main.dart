import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'firebase_options.dart'; 
import 'dart:math' as math;

// Tus pantallas
import 'select_level_screen.dart';
import 'instructions_screen.dart';
import 'screens/settings_screen.dart'; 

void main() async {
  // 4. Asegurar inicialización de enlaces de Flutter
  WidgetsFlutterBinding.ensureInitialized();
  
  // 5. Inicializar Firebase (MODO A PRUEBA DE ERRORES)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Si entra aquí, es porque ya estaba conectado. 
    // No hacemos nada y dejamos que la app continúe feliz.
    print("Firebase ya estaba inicializado, continuando...");
  }

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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InstructionsScreen(),
                      ),
                    );
                  },
                ),

                // BOTÓN AJUSTES
                PixelButton(
                  text: 'AJUSTES',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
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