import 'package:flutter/material.dart';
import 'dart:math' as math;

class PercepcionScreen extends StatefulWidget {
  const PercepcionScreen({super.key});

  @override
  State<PercepcionScreen> createState() => _PercepcionScreenState();
}

class _PercepcionScreenState extends State<PercepcionScreen>
    with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> preguntas = [
    {
      "pregunta": "¿Cuál de estos colores no pertenece al espectro visible?",
      "opciones": ["Rojo", "Verde", "Ultravioleta", "Azul"],
      "respuestaCorrecta": "Ultravioleta",
    },
    {
      "pregunta": "Si una figura parece moverse pero no lo hace, estamos ante...",
      "opciones": [
        "Una ilusión óptica",
        "Un reflejo",
        "Un holograma",
        "Una proyección"
      ],
      "respuestaCorrecta": "Una ilusión óptica",
    },
    {
      "pregunta": "¿Qué sentido engaña más fácilmente al cerebro?",
      "opciones": ["Oído", "Vista", "Tacto", "Gusto"],
      "respuestaCorrecta": "Vista",
    },
  ];

  int preguntaActual = 0;
  int puntaje = 0;
  bool respondido = false;
  String? respuestaSeleccionada;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 6))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void responder(String opcion) {
    if (respondido) return;
    setState(() {
      respondido = true;
      respuestaSeleccionada = opcion;
      if (opcion == preguntas[preguntaActual]["respuestaCorrecta"]) {
        puntaje += 10;
      }
    });
  }

  void siguientePregunta() {
    if (preguntaActual < preguntas.length - 1) {
      setState(() {
        preguntaActual++;
        respondido = false;
        respuestaSeleccionada = null;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultadoScreen(puntaje: puntaje),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pregunta = preguntas[preguntaActual];
    final progreso = (preguntaActual + 1) / preguntas.length;

    return Scaffold(
      backgroundColor: const Color(0xFF1B0E2E),
      body: Stack(
        children: [
          /// Fondo retro animado
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: RetroPercepcionPainter(_controller.value),
                size: MediaQuery.of(context).size,
              );
            },
          ),

          /// Contenido
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  /// Barra de progreso mental
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progreso,
                      minHeight: 10,
                      backgroundColor: Colors.white10,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        const Color(0xFF00FFF0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  /// Pregunta
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                    child: Text(
                      pregunta["pregunta"],
                      key: ValueKey(pregunta["pregunta"]),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'VT323',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 40),

                  /// Opciones
                  ...pregunta["opciones"].map<Widget>((opcion) {
                    bool esCorrecta =
                        opcion == pregunta["respuestaCorrecta"];
                    bool esSeleccionada = opcion == respuestaSeleccionada;

                    Color color;
                    if (!respondido) {
                      color = const Color(0xFF2B1E40);
                    } else if (esSeleccionada && esCorrecta) {
                      color = const Color(0xFF00FF9D);
                    } else if (esSeleccionada && !esCorrecta) {
                      color = const Color(0xFFFF4B82);
                    } else {
                      color = const Color(0xFF2B1E40);
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: GestureDetector(
                        onTap: () => responder(opcion),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF00FFF0),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00FFF0)
                                    .withOpacity(0.3),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              opcion,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: 'VT323',
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 30),

                  /// Botón siguiente
                  if (respondido)
                    ElevatedButton(
                      onPressed: siguientePregunta,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00FFF0),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 14),
                      ),
                      child: const Text(
                        "SIGUIENTE →",
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'PressStart2P',
                          fontSize: 12,
                        ),
                      ),
                    ),

                  const Spacer(),

                  Text(
                    "Puntaje: $puntaje",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontFamily: 'VT323',
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------- FONDO RETRO PIXELADO ----------
class RetroPercepcionPainter extends CustomPainter {
  final double progress;
  RetroPercepcionPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00FFF0).withOpacity(0.08)
      ..strokeWidth = 1.2;

    for (double y = 0; y < size.height; y += 25) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    for (double x = 0; x < size.width; x += 25) {
      final offset = math.sin(progress * 2 * math.pi + x / 50) * 5;
      canvas.drawLine(
          Offset(x + offset, 0), Offset(x - offset, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// ---------- PANTALLA DE RESULTADO ----------
class ResultadoScreen extends StatelessWidget {
  final int puntaje;
  const ResultadoScreen({super.key, required this.puntaje});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B0E2E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome,
                size: 100, color: Color(0xFF00FFF0)),
            const SizedBox(height: 20),
            const Text(
              "¡Bloque Completado!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontFamily: 'PressStart2P',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              "Puntaje total: $puntaje",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontFamily: 'VT323',
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00FFF0),
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
              ),
              child: const Text(
                "VOLVER AL PURGATORIO",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'PressStart2P',
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
