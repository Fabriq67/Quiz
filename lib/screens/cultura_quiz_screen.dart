// ----------------------------------------------------------
//   CULTURA GENERAL — QUIZ SCREEN (VERSIÓN FINAL CORREGIDA)
//   4 Bloques: 5 / 5 / 10 / 20 preguntas
//   JEFE FINAL (Bloque 4): 20 preguntas | 3 errores = MUERTE | Cada error -10 monedas
//   Fondo Normal: Tarde cálida con hojas cayendo
//   JEFE: Kraken gigante con ojo + reloj + monedas flotantes
// ----------------------------------------------------------

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../data/cultura_service.dart';
import '../models/pregunta_model.dart';
import '../data/progress_manager.dart';
import '../models/powerup_model.dart';
import '../data/powerup_effects.dart';
import 'cultura_menu_screen.dart';

class CulturaQuizScreen extends StatefulWidget {
  final int blockId;
  final int totalQuestions;
  final bool isBoss;

  const CulturaQuizScreen({
    super.key,
    required this.blockId,
    required this.totalQuestions,
    required this.isBoss,
  });

  @override
  State<CulturaQuizScreen> createState() => _CulturaQuizScreenState();
}

class _CulturaQuizScreenState extends State<CulturaQuizScreen>
    with TickerProviderStateMixin {
  late Future<List<Pregunta>> futurePreguntas;
  late AnimationController _leafController;
  late AnimationController _bossController;
  late AnimationController _coinController;

  int currentIndex = 0;
  int score = 0;
  int bossErrors = 0;
  late int timeRemaining;
  int coins = 0;

  Timer? timer;
  String? selectedAnswer;
  bool answerChecked = false;

  bool isBossFight = false;
  bool _isProcessing = false;

    List<PowerUp> equipped = [];
  Set<String> usedPowerups = {};
  List<String> opcionesOcultas = []; // ✅ PARA OCULTAR OPCIONES
  String? hintedOption; // ✅ PARA MOSTRAR HINT
  List<String> opcionesBarajadas = []; // ✅ OPCIONES EN ORDEN ALEATORIO
  String? _preguntaClave;  

  @override
  void initState() {
    super.initState();

    // ✅ JEFE ES BLOQUE 4, NO BLOQUE 3
    isBossFight = widget.isBoss && widget.blockId == 4;
    timeRemaining = isBossFight ? 20 : 40;

    futurePreguntas = CulturaService.obtenerPreguntasBloque(widget.blockId);

    _leafController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _bossController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _coinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    startTimer();
    _loadCoins();
    _loadEquipped();
  }

  @override
  void dispose() {
    timer?.cancel();
    _leafController.dispose();
    _bossController.dispose();
    _coinController.dispose();
    super.dispose();
  }

  Future<void> _loadCoins() async {
    final p = await ProgressManager.loadProgress();
    if (!mounted) return;
    setState(() => coins = p.coins);
  }

 // ...existing code...

 // ...existing code...

  // ✅ CARGAR COMODINES
  Future<void> _loadEquipped() async {
    equipped = await ProgressManager.loadSelectedPowerUps();
    // ✅ FILTRAR SOLO LOS QUE SON VÁLIDOS (no nulos o vacíos)
    equipped = equipped.where((p) => p.id.isNotEmpty).toList();
    if (!mounted) return;
    setState(() {});
  }

// ...existing code...
// ...existing code...
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

    // ❌ Tiempo agotado: reinicia todo Cultura
    await ProgressManager.failCultureBlock(widget.blockId);

    if (!mounted) return;
    await _showResultScreen(false, 0);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const CulturaMenuScreen()),
      (route) => false,
    );
  }

  Future<void> responder(Pregunta pregunta, String opcion) async {
    if (_isProcessing || answerChecked) return;

    selectedAnswer = opcion;
    answerChecked = true;
    setState(() {});

    final correct = opcion == pregunta.correcta;

    if (correct) {
      score++;
    } else if (isBossFight) {
      bossErrors++;
      await ProgressManager.addCoins(-10);
      await _loadCoins();

      if (bossErrors >= 3) {
        _isProcessing = true;
        timer?.cancel();

        // ❌ Falló el jefe: reinicia todo Cultura
        await ProgressManager.failCultureBlock(widget.blockId);

        if (!mounted) return;
        await _showResultScreen(false, 0);

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const CulturaMenuScreen()),
          (route) => false,
        );
        return;
      }
    }

    timer?.cancel();
    await Future.delayed(const Duration(milliseconds: 700));
    pasarSiguiente();
  }

  void pasarSiguiente() {
    selectedAnswer = null;
    answerChecked = false;
    usedPowerups.clear();
    opcionesOcultas.clear(); // ✅ LIMPIAR OPCIONES OCULTAS
    hintedOption = null; // ✅ LIMPIAR HINT
    opcionesBarajadas = []; // ✅ Forzar nuevo shuffle

    timeRemaining = isBossFight ? 20 : 40;

    if (currentIndex == widget.totalQuestions - 1) {
      terminarBloque();
    } else {
      setState(() => currentIndex++);
      startTimer();
    }
  }
  int calcularMonedas() {
    if (widget.blockId <= 2) {
      if (score == 5) return 10;
      if (score >= 4) return 5;
      return 0;
    }
    if (widget.blockId == 3) {
      if (score == 10) return 20;
      if (score >= 5) return 10;
      return 0;
    }
    // ✅ BLOQUE 4 ES JEFE
    if (widget.blockId == 4 && isBossFight) {
      if (score == 20) return 50;
      if (score >= 10) return 30;
      return 0;
    }
    return 0;
  }

// ...existing code...


  Future<void> terminarBloque() async {
    if (_isProcessing) return;
    _isProcessing = true;

    timer?.cancel();

    // ✅ MÍNIMO DIFERENTE PARA JEFE
    final minimo = widget.blockId == 4 ? 10 : (widget.blockId == 3 ? 5 : 4);
    final paso = score >= minimo;

    final monedas = paso ? calcularMonedas() : 0;

    if (paso) {
      if (monedas > 0) await ProgressManager.addCoins(monedas);

      if (isBossFight) {
        await ProgressManager.defeatBoss("boss_cultura_4");
      }

      await ProgressManager.completeCultureBlock(widget.blockId);

      if (widget.blockId < 4) {
        await ProgressManager.unlockCultureBlock(widget.blockId + 1);
      }

      // ✅ Ya no limpiamos unlockedBlocks; se mostrará “completado”, no “bloqueado”.
      if (isBossFight && mounted) {
        await _showEscapeDialog(); // Mensaje “saliste del purgatorio”
      }
    } else {
      // ❌ FALLASTE: RESETEAR TODO EL NIVEL
      await ProgressManager.failCultureBlock(widget.blockId);
    }

    if (!mounted) return;
    await _showResultScreen(paso, monedas);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const CulturaMenuScreen()),
      (route) => false,
    );
  }


// ...existing code...
  Future<void> _showResultScreen(bool passed, int earnedCoins) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A0C3D).withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          passed ? "🎉 ¡BLOQUE SUPERADO!" : "❌ BLOQUE FALLIDO",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: "PressStart2P",
            fontSize: 14,
            color: passed ? Colors.greenAccent : Colors.redAccent,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Aciertos: $score / ${widget.totalQuestions}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: "VT323",
                fontSize: 28,
                color: Colors.white,
              ),
            ),
            if (passed && earnedCoins > 0) ...[
              const SizedBox(height: 16),
              Text(
                "💰 +$earnedCoins monedas",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: "VT323",
                  fontSize: 32,
                  color: Color(0xFFFFD700),
                ),
              ),
            ],
            if (!passed) ...[
              const SizedBox(height: 16),
              Text(
                isBossFight
                    ? "El Kraken te ha devorado."
                    : "No has alcanzado el mínimo requerido.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: "VT323",
                  fontSize: 24,
                  color: Colors.white70,
                ),
              ),
            ],
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "CONTINUAR",
                style: TextStyle(
                  color: Color(0xFFE6E6FA),
                  fontFamily: "PressStart2P",
                  fontSize: 12,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

    Future<void> _showEscapeDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0A0A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          "¡Felicidades!",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: "PressStart2P",
            fontSize: 14,
            color: Colors.greenAccent,
          ),
        ),
        content: const Text(
          "Saliste del purgatorio.\n\nNuevas aventuras te esperan próximamente.\n\nEres libre. ¡Bien hecho, guerrero mental!",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: "VT323",
            fontSize: 26,
            color: Colors.white,
            height: 1.3,
          ),
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "CONTINUAR",
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontFamily: "PressStart2P",
                  fontSize: 12,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Color getColor(Pregunta p, String opcion) {
    if (!answerChecked) {
      // ✅ MOSTRAR HINT EN AZUL CLARO
      if (opcion == hintedOption) return Colors.lightBlueAccent;
      return const Color(0xFFE6E6FA).withOpacity(0.9);
    }
    if (opcion == p.correcta) return Colors.greenAccent;
    if (opcion == selectedAnswer) return Colors.redAccent;
    return const Color(0xFFE6E6FA).withOpacity(0.7);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 450;

    return Scaffold(
      backgroundColor:
          isBossFight ? const Color(0xFF0A0A1A) : const Color(0xFF2A1A4D),
      body: Stack(
        children: [
          // FONDO ANIMADO
          AnimatedBuilder(
            animation: Listenable.merge(
                [_leafController, _bossController, _coinController]),
            builder: (context, _) => CustomPaint(
              painter: _CulturaPainter(
                _leafController.value,
                _bossController.value,
                _coinController.value,
                isBossFight,
              ),
              size: size,
            ),
          ),

          // CONTENIDO
          SafeArea(
            child: FutureBuilder<List<Pregunta>>(
              future: futurePreguntas,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE6E6FA)),
                  );
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return Center(
                    child: Text(
                      "Error al cargar preguntas",
                      style: TextStyle(
                          fontFamily: "PressStart2P",
                          color: Colors.redAccent,
                          fontSize: isSmall ? 10 : 12),
                    ),
                  );
                }

                final preguntas = snapshot.data!;
                if (currentIndex >= preguntas.length) {
                  return const Center(child: Text("FIN"));
                }

                     final p = preguntas[currentIndex];

                // ✅ Barajar opciones una sola vez por pregunta
                if (_preguntaClave != p.pregunta) {
                  opcionesBarajadas = List<String>.from(p.opciones)..shuffle();
                  _preguntaClave = p.pregunta;
                }

                final opcionesVisibles = opcionesBarajadas
                    .where((op) => !opcionesOcultas.contains(op))
                    .toList();


                return Column(
                  children: [
                    const SizedBox(height: 20),

                    // TÍTULO
                    Text(
                      isBossFight
                          ? "🐙 EL KRAKEN DEL JUICIO 🐙"
                          : "CULTURA GENERAL - BLOQUE ${widget.blockId}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "PressStart2P",
                        color: isBossFight
                            ? Colors.redAccent
                            : const Color(0xFFE6E6FA),
                        fontSize: isSmall ? 11 : 14,
                        shadows: [
                          Shadow(
                            blurRadius: 12,
                            color: isBossFight
                                ? Colors.redAccent
                                : const Color(0xFFE6E6FA),
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // HUD
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _hudBox("⏱️ $timeRemaining", isSmall),
                          _hudBox(
                              "${currentIndex + 1}/${widget.totalQuestions}",
                              isSmall),
                          _hudBox("💰 $coins", isSmall),
                        ],
                      ),
                    ),

                    if (isBossFight)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          "💀 Errores: $bossErrors / 3",
                          style: const TextStyle(
                              fontFamily: "PressStart2P",
                              fontSize: 10,
                              color: Colors.redAccent),
                        ),
                      ),

                    const SizedBox(height: 30),

                    // PREGUNTA
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A0C3D).withOpacity(0.85),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                              color: const Color(0xFFE6E6FA), width: 2),
                        ),
                        child: Text(
                          p.pregunta,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: "VT323",
                            fontSize: isSmall ? 24 : 28,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // OPCIONES
                   Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: opcionesVisibles.length,
                        itemBuilder: (context, i) {
                          final opcion = opcionesVisibles[i];

                          // ✅ OCULTAR OPCIONES SI ESTÁN EN LA LISTA
                          if (opcionesOcultas.contains(opcion)) {
                            return const SizedBox.shrink();
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: GestureDetector(
                              onTap: answerChecked
                                  ? null
                                  : () => responder(p, opcion),
                              child: Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: getColor(p, opcion),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          getColor(p, opcion).withOpacity(0.4),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        opcion,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: "VT323",
                                          fontSize: isSmall ? 22 : 26,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    // ✅ MOSTRAR ICONO DE BOMBILLA EN HINT
                                    if (opcion == hintedOption)
                                      const Padding(
                                        padding: EdgeInsets.only(left: 8),
                                        child: Icon(
                                          Icons.lightbulb,
                                          color: Colors.black87,
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

                    // ✅ COMODINES CON EFECTOS FUNCIONALES
                    if (equipped.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: equipped.map((powerup) {
                            final usado = usedPowerups.contains(powerup.id);
                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: usado
                                    ? Colors.grey
                                    : const Color(0xFF6A2E7F),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  vertical: isSmall ? 6 : 8,
                                  horizontal: isSmall ? 8 : 12,
                                ),
                                elevation: 8,
                              ),
                              onPressed: (usado || answerChecked)
                                  ? null
                                  : () async {
                                      await PowerUpEffects.apply(
                                        context: context,
                                        powerUp: powerup,
                                        pregunta: preguntas[currentIndex],
                                        setHint: (h) {
                                          setState(() => hintedOption = h);
                                        },
                                        hideSpecificOptions: (ops) {
                                          setState(() => opcionesOcultas.addAll(ops));
                                        },
                                        addExtraSeconds: (s) {
                                          setState(() => timeRemaining += s);
                                        },
                                        refreshCoins: _loadCoins,
                                        usedPowerUps: usedPowerups,
                                      );
                                      if (mounted) setState(() {});
                                    },
                              child: Text(
                                powerup.name.isNotEmpty ? powerup.name : powerup.id ?? "?",
                                style: TextStyle(
                                  fontFamily: 'PressStart2P',
                                  fontSize: isSmall ? 7 : 8,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _hudBox(String text, bool isSmall) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 10 : 14, vertical: isSmall ? 6 : 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A0C3D).withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6E6FA), width: 2),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: "PressStart2P",
          fontSize: isSmall ? 9 : 11,
          color: const Color(0xFFE6E6FA),
        ),
      ),
    );
  }
}

// ================================================================
// PAINTERS
// ================================================================

class _CulturaPainter extends CustomPainter {
  final double leafProgress;
  final double bossProgress;
  final double coinProgress;
  final bool isBoss;

  _CulturaPainter(
      this.leafProgress, this.bossProgress, this.coinProgress, this.isBoss);

  @override
  void paint(Canvas canvas, Size size) {
    if (isBoss) {
      _paintBoss(canvas, size);
    } else {
      _paintNormal(canvas, size);
    }
  }

  void _paintNormal(Canvas canvas, Size size) {
    final skyGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFFFFB84D),
        const Color(0xFFFF9A5C),
        const Color(0xFFFFD89E),
      ],
    );

    canvas.drawRect(
      Offset.zero & size,
      Paint()..shader = skyGradient.createShader(Offset.zero & size),
    );

    final sunPaint = Paint()
      ..color = const Color(0xFFFFE082)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);

    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.15),
      80,
      sunPaint,
    );

    final sunCore = Paint()..color = const Color(0xFFFFD54F);
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.15),
      50,
      sunCore,
    );

    final random = math.Random(42);
    for (int i = 0; i < 60; i++) {
      final x = random.nextDouble() * size.width;
      final y = (random.nextDouble() * size.height +
              leafProgress * 180 * (i % 2 == 0 ? 1 : -1)) %
          size.height;

      final leafColor = i % 3 == 0
          ? const Color(0xFFD4A574)
          : i % 2 == 0
              ? const Color(0xFFE6C79C)
              : const Color(0xFFFFF8DC);

      final leafPaint = Paint()..color = leafColor.withOpacity(0.7);

      canvas.drawCircle(Offset(x, y), i % 4 == 0 ? 5 : 3, leafPaint);
    }
  }

  void _paintBoss(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFF0A0A1A);
    canvas.drawRect(Offset.zero & size, bg);

    final tentaclePaint = Paint()
      ..color = const Color(0xFF2D1B4E).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30;

    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi / 3) + bossProgress * math.pi * 2;
      final startX = size.width / 2;
      final startY = size.height * 0.35;
      final endX = startX + math.cos(angle) * 180;
      final endY = startY + math.sin(angle) * 180;

      canvas.drawLine(
          Offset(startX, startY), Offset(endX, endY), tentaclePaint);
    }

    final eyeGlow = Paint()
      ..color = Colors.redAccent.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.35),
      120,
      eyeGlow,
    );

    final eyeWhite = Paint()..color = const Color(0xFFFFE0B2);
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.35),
      80,
      eyeWhite,
    );

    final iris = Paint()..color = Colors.deepOrange;
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.35),
      50,
      iris,
    );

    final pupil = Paint()..color = Colors.black;
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.35),
      25,
      pupil,
    );

    final clockPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final clockCenter = Offset(size.width / 2, size.height * 0.15);
    canvas.drawCircle(clockCenter, 35, clockPaint);

    final handPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final hourAngle = bossProgress * math.pi * 2;
    canvas.drawLine(
      clockCenter,
      clockCenter +
          Offset(math.cos(hourAngle) * 20, math.sin(hourAngle) * 20),
      handPaint,
    );

    final random = math.Random(99);
    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = (random.nextDouble() * size.height +
              coinProgress * 150 * (i % 2 == 0 ? 1 : -1)) %
          size.height;

      final coinPaint = Paint()
        ..color = const Color(0xFFFFD700).withOpacity(0.8);
      canvas.drawCircle(Offset(x, y), i % 3 == 0 ? 8 : 6, coinPaint);

      final coinInner = Paint()..color = const Color(0xFFFFE57F);
      canvas.drawCircle(Offset(x, y), i % 3 == 0 ? 5 : 3, coinInner);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}