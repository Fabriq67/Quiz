// ----------------------------------------------------------
//   LÓGICA — QUIZ SCREEN (VERSIÓN FUTURISTA MEJORADA)
//   Cada bloque tiene su propio tema visual futurista
//   Jefe: Reloj cibernético imponente
// ----------------------------------------------------------

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../data/logica_service.dart';
import '../models/pregunta_model.dart';
import '../data/progress_manager.dart';
import '../models/powerup_model.dart';
import '../data/powerup_effects.dart';

import 'logica_menu_screen.dart';

class LogicaQuizScreen extends StatefulWidget {
  final int blockId;
  final int totalQuestions;
  final bool isBoss;

  const LogicaQuizScreen({
    super.key,
    required this.blockId,
    required this.totalQuestions,
    required this.isBoss,
  });

  @override
  State<LogicaQuizScreen> createState() => _LogicaQuizScreenState();
}

class _LogicaQuizScreenState extends State<LogicaQuizScreen>
    with TickerProviderStateMixin {
  late Future<List<Pregunta>> futurePreguntas;
  late AnimationController _circuitController;
  late AnimationController _clockController;
  late AnimationController _pulseController;

  int currentIndex = 0;
  int score = 0;
  late int timeRemaining;
  int coins = 0;

  Timer? timer;
  String? selectedAnswer;
  bool answerChecked = false;

  List<PowerUp> equipped = [];
  List<String> opcionesOcultas = [];

  bool isBossFight = false;
  bool _isProcessing = false;

  Set<String> usedPowerups = {};
  String? hintedOption;

  @override
  void initState() {
    super.initState();

    isBossFight = widget.isBoss && widget.blockId == 3;

    timeRemaining = widget.blockId == 1
        ? 45
        : widget.blockId == 2
            ? 35
            : isBossFight
                ? 25
                : 25;

    futurePreguntas = LogicaService.obtenerPreguntasBloque(widget.blockId);

    _circuitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _clockController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    startTimer();
    _loadEquipped();
    _loadCoins();
  }

  @override
  void dispose() {
    timer?.cancel();
    _circuitController.dispose();
    _clockController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadEquipped() async {
    equipped = await ProgressManager.loadSelectedPowerUps();
    equipped = equipped.where((p) => p.id.isNotEmpty).toList();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _loadCoins() async {
    final p = await ProgressManager.loadProgress();
    if (!mounted) return;
    setState(() => coins = p.coins);
  }

  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeRemaining == 0) {
        t.cancel();
        tiempoAgotado();
      } else {
        if (!mounted) return;
        setState(() => timeRemaining--);
      }
    });
  }

  void tiempoAgotado() async {
    if (_isProcessing) return;
    _isProcessing = true;

    timer?.cancel();
    await ProgressManager.failLogicBlock(widget.blockId);

    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.85),
        title: const Text(
          "¡TIEMPO AGOTADO!",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: "PressStart2P",
            fontSize: 14,
            color: Colors.redAccent,
          ),
        ),
        content: const Text(
          "\nPerdiste el progreso completo.\nRegresa al menú.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: "VT323",
            fontSize: 26,
            color: Colors.white,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LogicaMenuScreen()),
                (route) => false,
              );
            },
            child: const Text(
              "VOLVER AL MENÚ",
              style: TextStyle(
                color: Colors.cyanAccent,
                fontFamily: "PressStart2P",
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> responder(Pregunta pregunta, String opcion) async {
    if (_isProcessing) return;

    selectedAnswer = opcion;
    answerChecked = true;
    setState(() {});

    bool correct = opcion == pregunta.correcta;

    if (correct) score++;

    timer?.cancel();

    await Future.delayed(const Duration(milliseconds: 600));
    pasarSiguiente();
  }

  void pasarSiguiente() {
    selectedAnswer = null;
    answerChecked = false;
    opcionesOcultas = [];
    hintedOption = null;
    usedPowerups.clear();

    if (widget.blockId == 1) {
      timeRemaining = 45;
    } else if (widget.blockId == 2) {
      timeRemaining = 35;
    } else {
      timeRemaining = isBossFight ? 25 : 25;
    }

    currentIndex++;

    if (currentIndex >= widget.totalQuestions) {
      terminarBloque();
    } else {
      setState(() {});
      startTimer();
    }
  }

  int calcularMonedas() {
    if (widget.blockId == 1) {
      if (score == 5) return 10;
      if (score >= 3) return 5;
      return 0;
    }
    if (widget.blockId == 2) {
      if (score == 5) return 10;
      if (score >= 3) return 5;
      return 0;
    }
    if (widget.blockId == 3) {
      if (score == 10) return 20;
      if (score >= 5) return 10;
      return 0;
    }
    return 0;
  }

  void terminarBloque() async {
    if (_isProcessing) return;
    _isProcessing = true;

    timer?.cancel();

    final minimo = widget.blockId == 3 ? 5 : 3;
    final paso = score >= minimo;

    if (!paso) {
      await ProgressManager.failLogicBlock(widget.blockId);

      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.black.withOpacity(0.85),
          title: const Text(
            "BLOQUE FALLIDO",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: "PressStart2P",
              fontSize: 14,
              color: Colors.redAccent,
            ),
          ),
          content: const Text(
            "\nPerdiste el progreso completo.\nRegresa al menú.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: "VT323",
              fontSize: 26,
              color: Colors.white,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LogicaMenuScreen()),
                  (route) => false,
                );
              },
              child: const Text(
                "VOLVER AL MENÚ",
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontFamily: "PressStart2P",
                ),
              ),
            )
          ],
        ),
      );
      return;
    }

    // ✅ DESBLOQUEAR COMODÍN AL DERROTAR JEFE DE LÓGICA
    if (isBossFight) {
      await ProgressManager.defeatBoss("boss_logica");
      // 👇👇👇 AÑADIDO: Activa la notificación para el HUD 👇👇👇
      await ProgressManager.saveBool("has_new_powerup", true);
    }

    final monedasGanadas = calcularMonedas();
    if (monedasGanadas > 0) {
      await ProgressManager.addCoins(monedasGanadas);
    }
    await ProgressManager.completeLogicBlock(widget.blockId);

    if (monedasGanadas > 0 && mounted) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF0F1420),
          title: const Text(
            "¡Monedas Ganadas!",
            style: TextStyle(
              color: Color(0xFF5A9FD4),
              fontFamily: "PressStart2P",
              fontSize: 12,
            ),
          ),
          content: Text(
            "Has ganado $monedasGanadas monedas.",
            style: const TextStyle(
              color: Colors.white,
              fontFamily: "VT323",
              fontSize: 22,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "OK",
                style: TextStyle(
                  color: Color(0xFF5A9FD4),
                  fontFamily: "PressStart2P",
                ),
              ),
            )
          ],
        ),
      );
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LogicaResultadoScreen(
          blockId: widget.blockId,
          score: score,
          total: widget.totalQuestions,
          paso: paso,
        ),
      ),
    );
  }

  Color getColor(Pregunta p, String opcion) {
    if (!answerChecked) {
      if (opcion == hintedOption) return const Color(0xFF7FA8C9);
      return const Color(0xFF5A9FD4);
    }
    if (opcion == p.correcta) return const Color(0xFF4CAF50);
    if (opcion == selectedAnswer) return const Color(0xFFD47A7A);
    return const Color(0xFF5A9FD4);
  }

  Color _getThemeColor() {
    if (widget.blockId == 1) return const Color(0xFF5A9FD4);
    if (widget.blockId == 2) return const Color(0xFF7FA8C9);
    return const Color(0xFFD47A7A);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 500;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          isBossFight ? "⏱️ EL ROMPECÓDIGOS ⏱️" : "BLOQUE ${widget.blockId}",
          style: TextStyle(
            color: _getThemeColor(),
            fontFamily: "PressStart2P",
            fontSize: isSmall ? 9 : 11,
          ),
        ),
      ),
      body: FutureBuilder<List<Pregunta>>(
        future: futurePreguntas,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF5A9FD4)),
            );
          }

          final preguntas = snapshot.data!;
          final totalDisponibles = preguntas.length;

          // Solo verificar que no nos salimos del array
          if (currentIndex >= totalDisponibles) {
            Future.microtask(terminarBloque);
            return const SizedBox.shrink();
          }

          final pregunta = preguntas[currentIndex];
          final opcionesVisibles = pregunta.opciones
              .where((op) => !opcionesOcultas.contains(op))
              .toList();

          return Stack(
            children: [
              // FONDO ANIMADO SEGÚN BLOQUE
              AnimatedBuilder(
                animation: _circuitController,
                builder: (context, _) => CustomPaint(
                  painter: _FuturisticBgPainter(
                    _circuitController.value,
                    widget.blockId,
                    isBossFight,
                  ),
                  size: size,
                ),
              ),

              // RELOJ GIGANTE DEL JEFE
              if (isBossFight)
                AnimatedBuilder(
                  animation: _clockController,
                  builder: (context, _) => Positioned(
                    top: size.height * 0.15,
                    left: size.width * 0.5 - 100,
                    child: Opacity(
                      opacity: 0.12,
                      child: Transform.rotate(
                        angle: _clockController.value * 2 * math.pi,
                        child: Icon(
                          Icons.access_time,
                          size: 200,
                          color: _getThemeColor(),
                        ),
                      ),
                    ),
                  ),
                ),

              // CONTENIDO PRINCIPAL
              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Padding(
                      padding: EdgeInsets.all(isSmall ? 18 : 24),
                      child: Column(
                        children: [
                          // HUD
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.star,
                                  color: Colors.yellowAccent,
                                  size: isSmall ? 16 : 20),
                              const SizedBox(width: 6),
                              Text(
                                "$coins",
                                style: TextStyle(
                                  fontFamily: "PressStart2P",
                                  fontSize: isSmall ? 11 : 13,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // ✅ BOTONES DE COMODINES CON PRECIO Y DISEÑO
                          if (equipped.isNotEmpty)
                            Wrap(
                              spacing: 10,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: equipped.map((p) {
                                final usado = usedPowerups.contains(p.id);
                                final label =
                                    (p.name.isNotEmpty) ? p.name : p.id;
                                return ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: usado
                                        ? Colors.grey
                                        : const Color.fromARGB(255, 100, 2, 125),
                                    foregroundColor: _getThemeColor(),
                                    padding: EdgeInsets.symmetric(
                                      vertical: isSmall ? 9 : 11,
                                      horizontal: isSmall ? 15 : 16,
                                    ),
                                  ),
                                  onPressed: (usado || answerChecked)
                                      ? null
                                      : () async {
                                          await PowerUpEffects.apply(
                                            context: context,
                                            powerUp: p,
                                            pregunta: pregunta,
                                            setHint: (h) =>
                                                setState(() => hintedOption = h),
                                            hideSpecificOptions: (ops) =>
                                                setState(() => opcionesOcultas
                                                    .addAll(ops)),
                                            addExtraSeconds: (s) => setState(
                                                () => timeRemaining += s),
                                            refreshCoins: _loadCoins,
                                            usedPowerUps: usedPowerups,
                                          );
                                          if (mounted) setState(() {});
                                        },
                                  // ✅ CAMBIO AQUI: Contenido del Botón con Precio
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Nombre
                                      Text(
                                        label,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'PressStart2P',
                                          fontSize: isSmall ? 12 : 13,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // Precio con Icono
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.stars_rounded, // Icono Moneda
                                            size: 17,
                                            color: usado
                                                ? Colors.white38
                                                : const Color(0xFFFFD700),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "${p.price}",
                                            style: TextStyle(
                                              fontFamily: 'PressStart2P',
                                              fontSize: 16,
                                              color: usado
                                                  ? Colors.white38
                                                  : const Color(0xFFFFD700),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),

                          const SizedBox(height: 16),

                          // SCORE
                          Text(
                            "Puntaje: $score",
                            style: TextStyle(
                              fontFamily: "PressStart2P",
                              fontSize: isSmall ? 11 : 13,
                              color: _getThemeColor(),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // TIMER
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              final scale = timeRemaining < 6
                                  ? 1.0 + (_pulseController.value * 0.15)
                                  : 1.0;
                              return Transform.scale(
                                scale: scale,
                                child: Text(
                                  "$timeRemaining",
                                  style: TextStyle(
                                    fontFamily: "PressStart2P",
                                    fontSize: isSmall ? 24 : 30,
                                    color: timeRemaining < 6
                                        ? Colors.redAccent
                                        : _getThemeColor(),
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 24),

                          // PREGUNTA
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              pregunta.pregunta,
                              style: TextStyle(
                                fontFamily: "VT323",
                                fontSize: isSmall ? 24 : 30,
                                color: Colors.white,
                                shadows: isBossFight
                                    ? [
                                        Shadow(
                                          blurRadius: 12,
                                          color: _getThemeColor(),
                                        ),
                                      ]
                                    : null,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          const SizedBox(height: 26),

                          // OPCIONES
                          Expanded(
                            child: ListView.builder(
                              itemCount: opcionesVisibles.length,
                              itemBuilder: (context, idx) {
                                final opcion = opcionesVisibles[idx];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: InkWell(
                                    onTap: answerChecked
                                        ? null
                                        : () {
                                            setState(() {
                                              selectedAnswer = opcion;
                                              answerChecked = true;
                                            });
                                            Future.delayed(
                                              const Duration(milliseconds: 500),
                                              () => responder(pregunta, opcion),
                                            );
                                          },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeOut,
                                      padding: EdgeInsets.symmetric(
                                        vertical: isSmall ? 14 : 18,
                                        horizontal: isSmall ? 16 : 20,
                                      ),
                                      decoration: BoxDecoration(
                                        color: getColor(pregunta, opcion),
                                        borderRadius: BorderRadius.circular(18),
                                        boxShadow: answerChecked &&
                                                opcion == selectedAnswer
                                            ? [
                                                BoxShadow(
                                                  color: getColor(
                                                          pregunta, opcion)
                                                      .withOpacity(0.6),
                                                  blurRadius: 20,
                                                  spreadRadius: 3,
                                                ),
                                              ]
                                            : [],
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              opcion,
                                              style: TextStyle(
                                                fontFamily: "PressStart2P",
                                                fontSize: isSmall ? 11 : 13,
                                                color: Colors.black,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          if (opcion == hintedOption)
                                            const Padding(
                                              padding: EdgeInsets.only(left: 8),
                                              child: Icon(
                                                Icons.lightbulb,
                                                color: Colors.white70,
                                                size: 18,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 16),

                          // PROGRESO
                          Text(
                            "Pregunta ${currentIndex + 1} / ${widget.totalQuestions}",
                            style: TextStyle(
                              fontFamily: "VT323",
                              fontSize: isSmall ? 20 : 24,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ----------------------------------------------------------
// PINTOR DE FONDO FUTURISTA
// ----------------------------------------------------------
class _FuturisticBgPainter extends CustomPainter {
  final double progress;
  final int blockId;
  final bool isBoss;

  _FuturisticBgPainter(this.progress, this.blockId, this.isBoss);

  @override
  void paint(Canvas canvas, Size size) {
    Color color;
    if (blockId == 1) {
      color = const Color(0xFF5A9FD4);
    } else if (blockId == 2) {
      color = const Color(0xFF7FA8C9);
    } else {
      color = isBoss ? const Color(0xFFD47A7A) : const Color(0xFF7FA8C9);
    }

    final paint = Paint()
      ..color = color.withOpacity(0.08)
      ..strokeWidth = 1.5;

    // GRID ONDULANTE
    for (double y = 0; y < size.height; y += 40) {
      final offset = math.sin(progress * 2 * math.pi + y / 60) * 10;
      canvas.drawLine(
        Offset(offset, y),
        Offset(size.width + offset, y),
        paint,
      );
    }

    for (double x = 0; x < size.width; x += 40) {
      final offset = math.cos(progress * 2 * math.pi + x / 60) * 10;
      canvas.drawLine(
        Offset(x, offset),
        Offset(x, size.height + offset),
        paint,
      );
    }

    // CIRCUITOS PARA JEFE
    if (isBoss) {
      final circuitPaint = Paint()
        ..color = color.withOpacity(0.15)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      for (int i = 0; i < 5; i++) {
        final radius = 80.0 +
            (i * 30) +
            (math.sin(progress * 2 * math.pi + i) * 15);
        canvas.drawCircle(
          Offset(size.width * 0.5, size.height * 0.5),
          radius,
          circuitPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ----------------------------------------------------------
// RESULTADO FINAL
// ----------------------------------------------------------
class LogicaResultadoScreen extends StatelessWidget {
  final int blockId;
  final int score;
  final int total;
  final bool paso;

  const LogicaResultadoScreen({
    super.key,
    required this.blockId,
    required this.score,
    required this.total,
    required this.paso,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                paso ? "¡BLOQUE SUPERADO!" : "BLOQUE FALLIDO",
                style: const TextStyle(
                  fontFamily: "PressStart2P",
                  fontSize: 16,
                  color: Color(0xFF5A9FD4),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                "Puntuación: $score / $total",
                style: const TextStyle(
                  fontFamily: "VT323",
                  fontSize: 30,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 55),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F1420),
                  foregroundColor: const Color(0xFF5A9FD4),
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 12,
                  ),
                  elevation: 10,
                  shadowColor: const Color(0xFF5A9FD4).withOpacity(0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: const BorderSide(
                      color: Color(0xFF5A9FD4),
                      width: 3,
                    ),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'PressStart2P',
                    fontSize: 14,
                    letterSpacing: 2,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LogicaMenuScreen()),
                    (route) => false,
                  );
                },
                child: const Text("VOLVER AL MENÚ"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}