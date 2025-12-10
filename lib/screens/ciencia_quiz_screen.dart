// ----------------------------------------------------------
//   CIENCIA — QUIZ SCREEN (Versión Especial)
//   3 Bloques: 5 / 5 / 10 preguntas
//   Jefe (blockId == 3 + isBoss): cada error quita 2 monedas
//   MEJORADO: Fondo espacial animado + agujero negro
// ----------------------------------------------------------

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../data/ciencia_service.dart';
import '../models/pregunta_model.dart';
import '../data/progress_manager.dart';
import '../models/powerup_model.dart';
import '../data/powerup_effects.dart';

import 'ciencia_menu_screen.dart';

class CienciaQuizScreen extends StatefulWidget {
  final int blockId;
  final int totalQuestions;
  final bool isBoss;

  const CienciaQuizScreen({
    super.key,
    required this.blockId,
    required this.totalQuestions,
    required this.isBoss,
  });

  @override
  State<CienciaQuizScreen> createState() => _CienciaQuizScreenState();
}

class _CienciaQuizScreenState extends State<CienciaQuizScreen>
    with TickerProviderStateMixin {
  late Future<List<Pregunta>> futurePreguntas;
  late AnimationController _starsController;
  late AnimationController _blackHoleController;

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
    timeRemaining = isBossFight ? 30 : 40;

    futurePreguntas = CienciaService.obtenerPreguntasBloque(widget.blockId);

    _starsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _blackHoleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    startTimer();
    _loadEquipped();
    _loadCoins();
  }

  @override
  void dispose() {
    timer?.cancel();
    _starsController.dispose();
    _blackHoleController.dispose();
    super.dispose();
  }

// ...existing code...

  Future<void> _loadEquipped() async {
    equipped = await ProgressManager.loadSelectedPowerUps();
    // ✅ FILTRAR SOLO LOS QUE SON VÁLIDOS (no nulos o vacíos)
    equipped = equipped.where((p) => p.id.isNotEmpty).toList();
    if (!mounted) return;
    setState(() {});
  }

// ...existing code...
  Future<void> _loadCoins() async {
    final p = await ProgressManager.loadProgress();
    if (!mounted) return;
    setState(() => coins = p.coins);
  }

  void _setHint(String h) => setState(() => hintedOption = h);
  void _hideSpecificOptions(List<String> ops) =>
      setState(() => opcionesOcultas.addAll(ops));
  void _addExtraSeconds(int s) =>
      setState(() => timeRemaining = (timeRemaining + s).clamp(0, 60));
  Future<void> _refreshCoins() async => _loadCoins();

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
    await ProgressManager.failScienceBlock(widget.blockId);

    if (!mounted) return;
    await _popup("¡TIEMPO AGOTADO!", "Perdiste todo el progreso.\nRegresa al menú.");

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const CienciaMenuScreen()),
      (route) => false,
    );
  }

  Future<void> responder(Pregunta pregunta, String opcion) async {
    if (_isProcessing) return;

    selectedAnswer = opcion;
    answerChecked = true;
    setState(() {});

    final correct = opcion == pregunta.correcta;

    if (correct) {
      score++;
    } else if (isBossFight) {
      await ProgressManager.addCoins(-2);
      await _loadCoins();
    }

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

    timeRemaining = isBossFight ? 30 : 40;

    if (currentIndex == widget.totalQuestions - 1) {
      terminarBloque();
    } else {
      setState(() => currentIndex++);
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
      await ProgressManager.failScienceBlock(widget.blockId);

      if (!mounted) return;
      await _popup("BLOQUE FALLIDO", "Perdiste todo el progreso.");

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const CienciaMenuScreen()),
        (route) => false,
      );
      return;
    }

    // ✅ DESBLOQUEAR COMODÍN AL DERROTAR JEFE DE CIENCIA
    if (isBossFight) {
      await ProgressManager.defeatBoss("boss_ciencia");
    }

    final monedas = calcularMonedas();
    if (monedas > 0) await ProgressManager.addCoins(monedas);

    await ProgressManager.completeScienceBlock(widget.blockId);

    if (monedas > 0 && mounted) {
      await _popup("¡Monedas Ganadas!", "Has ganado $monedas monedas.");
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CienciaResultadoScreen(
          blockId: widget.blockId,
          score: score,
          total: widget.totalQuestions,
          paso: paso,
        ),
      ),
    );
  }

  Future<void> _popup(String title, String msg) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.85),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: "PressStart2P",
            fontSize: 14,
            color: Colors.cyanAccent,
          ),
        ),
        content: Text(
          msg,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: "VT323",
            fontSize: 26,
            color: Colors.white,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "OK",
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

  Color getColor(Pregunta p, String opcion) {
    if (!answerChecked) {
      if (opcion == hintedOption) return Colors.lightBlueAccent;
      return Colors.cyanAccent;
    }
    if (opcion == p.correcta) return Colors.greenAccent;
    if (opcion == selectedAnswer) return Colors.redAccent;
    return Colors.cyanAccent;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 500;

    return Scaffold(
      backgroundColor: const Color(0xFF050A1F),
      body: Stack(
        children: [
          // FONDO ANIMADO CON ESTRELLAS Y COSMOS
          AnimatedBuilder(
            animation: _starsController,
            builder: (context, _) => CustomPaint(
              painter: _CosmicBackgroundPainter(
                _starsController.value,
                isBossFight,
                _blackHoleController.value,
              ),
              size: size,
            ),
          ),

          // AGUJERO NEGRO (Solo para jefe)
          if (isBossFight)
            AnimatedBuilder(
              animation: _blackHoleController,
              builder: (context, _) => Positioned(
                top: -50,
                right: -50,
                child: Transform.scale(
                  scale: 1.0 + (_blackHoleController.value * 0.1),
                  child: Opacity(
                    opacity: 0.15,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.purple.withValues(alpha: 0.6),
                            Colors.deepPurple.withValues(alpha: 0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // CONTENIDO PRINCIPAL
          SafeArea(
            child: Column(
              children: [
                // APP BAR
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    isBossFight
                        ? "⚫ JEFE: Guardián de la Memoria ⚫"
                        : "BLOQUE ${widget.blockId}",
                    style: TextStyle(
                      color: isBossFight ? Colors.purpleAccent : Colors.cyanAccent,
                      fontFamily: "PressStart2P",
                      fontSize: isSmall ? 9 : 11,
                      letterSpacing: 2,
                      shadows: isBossFight
                          ? [
                              Shadow(
                                blurRadius: 15,
                                color: Colors.purpleAccent.withValues(alpha: 0.8),
                              ),
                            ]
                          : null,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // HUD
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isSmall ? 16 : 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // MONEDAS
                      Column(
                        children: [
                          const Icon(Icons.attach_money,
                              color: Colors.yellowAccent, size: 24),
                          Text(
                            "$coins",
                            style: TextStyle(
                              color: Colors.yellowAccent,
                              fontFamily: "PressStart2P",
                              fontSize: isSmall ? 10 : 12,
                            ),
                          ),
                        ],
                      ),

                      // TIMER
                      Column(
                        children: [
                          Icon(
                            Icons.schedule,
                            color: timeRemaining < 6
                                ? Colors.redAccent
                                : Colors.cyanAccent,
                            size: 24,
                          ),
                          Text(
                            "$timeRemaining",
                            style: TextStyle(
                              fontFamily: "PressStart2P",
                              fontSize: isSmall ? 14 : 16,
                              color: timeRemaining < 6
                                  ? Colors.redAccent
                                  : Colors.cyanAccent,
                            ),
                          ),
                        ],
                      ),

                      // PUNTUACIÓN
                      Column(
                        children: [
                          const Icon(Icons.star,
                              color: Colors.greenAccent, size: 24),
                          Text(
                            "$score",
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontFamily: "PressStart2P",
                              fontSize: isSmall ? 10 : 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // CONTENIDO PRINCIPAL
                Expanded(
                  child: FutureBuilder<List<Pregunta>>(
                    future: futurePreguntas,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(
                              color: Colors.cyanAccent),
                        );
                      }

                      final preguntas = snapshot.data!;
                      final pregunta = preguntas[currentIndex];
                      final opcionesVisibles = pregunta.opciones
                          .where((op) => !opcionesOcultas.contains(op))
                          .toList();

                      return Center(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: isSmall ? 12 : 24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // PREGUNTA
                                Container(
                                  padding: EdgeInsets.all(isSmall ? 16 : 20),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isBossFight
                                          ? Colors.purpleAccent
                                          : Colors.cyanAccent,
                                      width: 2,
                                    ),
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                                  child: Text(
                                    pregunta.pregunta,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: "VT323",
                                      color: Colors.white,
                                      fontSize: isSmall ? 22 : 26,
                                      letterSpacing: 1,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 10,
                                          color: Colors.cyanAccent
                                              .withValues(alpha: 0.5),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // OPCIONES
                                ...opcionesVisibles.map((opcion) {
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
                                                const Duration(
                                                    milliseconds: 500),
                                                () =>
                                                    responder(pregunta, opcion),
                                              );
                                            },
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                            milliseconds: 300),
                                        padding: EdgeInsets.symmetric(
                                          vertical: isSmall ? 14 : 18,
                                          horizontal: isSmall ? 14 : 20,
                                        ),
                                        decoration: BoxDecoration(
                                          color: getColor(pregunta, opcion),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: answerChecked &&
                                                  opcion == selectedAnswer
                                              ? [
                                                  BoxShadow(
                                                    color: getColor(pregunta,
                                                            opcion)
                                                        .withValues(
                                                            alpha: 0.8),
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
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily: "PressStart2P",
                                                  fontSize: isSmall ? 10 : 11,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            if (opcion == hintedOption)
                                              const Padding(
                                                padding:
                                                    EdgeInsets.only(left: 8),
                                                child: Icon(
                                                  Icons.lightbulb,
                                                  color: Colors.black87,
                                                  size: 16,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),

                                const SizedBox(height: 20),

                                // COMODINES
                                if (equipped.isNotEmpty)
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 8,
                                    alignment: WrapAlignment.center,
                                  // ...existing code...
                                children: equipped.map((p) {
                                  final usado = usedPowerups.contains(p.id);
                                  final label = (p.name.isNotEmpty) ? p.name : p.id ?? "?";
                                  return ElevatedButton(
// ...existing code...
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: usado
                                              ? Colors.grey
                                              : const Color(0xFF24133D),
                                          foregroundColor: Colors.cyanAccent,
                                          padding: EdgeInsets.symmetric(
                                            vertical: isSmall ? 8 : 10,
                                            horizontal: isSmall ? 10 : 12,
                                          ),
                                          elevation: 8,
                                          shadowColor:
                                              Colors.cyanAccent.withValues(
                                                  alpha: 0.5),
                                        ),
                                        onPressed: (usado || answerChecked)
                                            ? null
                                            : () async {
                                                await PowerUpEffects.apply(
                                                  context: context,
                                                  powerUp: p,
                                                  pregunta: pregunta,
                                                  setHint: _setHint,
                                                  hideSpecificOptions:
                                                      _hideSpecificOptions,
                                                  addExtraSeconds:
                                                      _addExtraSeconds,
                                                  refreshCoins: _refreshCoins,
                                                  usedPowerUps: usedPowerups,
                                                );
                                                if (mounted) setState(() {});
                                              },
                                        child: Text(
                                          label,
                                          style: TextStyle(
                                            fontFamily: 'PressStart2P',
                                            fontSize: isSmall ? 8 : 9,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),

                                const SizedBox(height: 20),

                                // PROGRESO
                                Text(
                                  "Pregunta ${currentIndex + 1} / ${widget.totalQuestions}",
                                  style: TextStyle(
                                    fontFamily: "VT323",
                                    fontSize: isSmall ? 18 : 20,
                                    color: Colors.white70,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------
// PINTOR DE FONDO CÓSMICO
// ----------------------------------------------------------
class _CosmicBackgroundPainter extends CustomPainter {
  final double starsProgress;
  final bool isBoss;
  final double blackHoleProgress;

  _CosmicBackgroundPainter(this.starsProgress, this.isBoss, this.blackHoleProgress);

  @override
  void paint(Canvas canvas, Size size) {
    // FONDO BASE OSCURO
    final bgPaint = Paint()..color = const Color(0xFF050A1F);
    canvas.drawRect(Offset.zero & size, bgPaint);

    // NEBULOSA DE FONDO
    if (isBoss) {
      final nebulaPaint = Paint()
        ..color = Colors.purple.withValues(alpha: 0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);

      canvas.drawCircle(
        Offset(size.width * 0.7, size.height * 0.3),
        250,
        nebulaPaint,
      );
      canvas.drawCircle(
        Offset(size.width * 0.2, size.height * 0.8),
        280,
        nebulaPaint,
      );
    } else {
      final nebulaPaint = Paint()
        ..color = Colors.cyan.withValues(alpha: 0.06)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);

      canvas.drawCircle(
        Offset(size.width * 0.8, size.height * 0.2),
        220,
        nebulaPaint,
      );
    }

    // ESTRELLAS ANIMADAS
    final starPaint = Paint()..color = Colors.white;
    final random = math.Random(42);

    for (int i = 0; i < 150; i++) {
      double x = random.nextDouble() * size.width;
      double y = (random.nextDouble() * size.height +
              starsProgress * 100 * (i % 3 == 0 ? 1 : -1)) %
          size.height;

      final starSize = i % 20 == 0 ? 2.0 : (i % 10 == 0 ? 1.5 : 1.0);
      final opacity = 0.3 + (math.sin(starsProgress * math.pi * 2 + i) * 0.7);

      starPaint.color = Colors.white.withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), starSize, starPaint);
    }

    // AGUJERO NEGRO (Solo para jefe)
    if (isBoss) {
      final blackHolePaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);

      final radius = 120 + (math.sin(blackHoleProgress * math.pi * 2) * 20);
      canvas.drawCircle(
        Offset(size.width * 0.85, size.height * 0.15),
        radius,
        blackHolePaint,
      );

      // Anillo del agujero negro
      final ringPaint = Paint()
        ..color = Colors.purpleAccent.withValues(alpha: 0.4)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(
        Offset(size.width * 0.85, size.height * 0.15),
        radius + 10,
        ringPaint,
      );

      canvas.drawCircle(
        Offset(size.width * 0.85, size.height * 0.15),
        radius - 15,
        ringPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
// ----------------------------------------------------------
// RESULTADO FINAL
// ----------------------------------------------------------
class CienciaResultadoScreen extends StatelessWidget {
  final int blockId;
  final int score;
  final int total;
  final bool paso;

  const CienciaResultadoScreen({
    super.key,
    required this.blockId,
    required this.score,
    required this.total,
    required this.paso,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050A1F),
      body: Stack(
        children: [
          // Fondo cósmico
          CustomPaint(
            painter: _ResultadoBackgroundPainter(),
            size: MediaQuery.of(context).size,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    paso ? "¡BLOQUE SUPERADO!" : "BLOQUE FALLIDO",
                    style: TextStyle(
                      fontFamily: "PressStart2P",
                      fontSize: 18,
                      color: paso ? Colors.greenAccent : Colors.redAccent,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          blurRadius: 15,
                          color: (paso ? Colors.greenAccent : Colors.redAccent)
                              .withValues(alpha: 0.8),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Puntuación: $score / $total",
                    style: const TextStyle(
                      fontFamily: "VT323",
                      fontSize: 28,
                      color: Colors.cyanAccent,
                    ),
                  ),
                  const SizedBox(height: 60),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF24133D),
                      foregroundColor: Colors.cyanAccent,
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 40,
                      ),
                      elevation: 15,
                      shadowColor: Colors.cyanAccent.withOpacity(0.8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(
                          color: Colors.cyanAccent,
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
                        MaterialPageRoute(
                            builder: (_) => const CienciaMenuScreen()),
                        (route) => false,
                      );
                    },
                    child: const Text("VOLVER AL MENÚ"),
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

class _ResultadoBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFF050A1F);
    canvas.drawRect(Offset.zero & size, bgPaint);

    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.5);
    final random = math.Random(100);

    for (int i = 0; i < 100; i++) {
      double x = random.nextDouble() * size.width;
      double y = random.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), i % 5 == 0 ? 1.5 : 0.8, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}