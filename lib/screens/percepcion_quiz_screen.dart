// ----------------------------------------------------------
//   PERCEPCIÓN — QUIZ SCREEN (VERSIÓN MEJORADA ATERRADORA)
//   + Niebla animada, efectos de horror en el jefe
//   + Interactividad mejorada en respuestas
//   + Diseño responsive y aterrador
// ----------------------------------------------------------

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data/percepcion_service.dart';
import '../models/pregunta_model.dart';
import '../data/progress_manager.dart';
import '../models/powerup_model.dart';
import '../data/powerup_effects.dart';
import 'percepcion_menu.dart';


class PercepcionQuizScreen extends StatefulWidget {
  final int blockId;
  final int totalQuestions;
  final bool isBoss;

  const PercepcionQuizScreen({
    super.key,
    required this.blockId,
    required this.totalQuestions,
    required this.isBoss,
  });

  @override
  State<PercepcionQuizScreen> createState() => _PercepcionQuizScreenState();
}

class _PercepcionQuizScreenState extends State<PercepcionQuizScreen>
    with TickerProviderStateMixin {
  late Future<List<Pregunta>> futurePreguntas;
  late AnimationController _fogController;
  late AnimationController _eyeController;
  late AnimationController _shakeController;

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
  bool bossFailed = false;
  bool _isProcessing = false;

  Set<String> usedPowerups = {};
  String? hintedOption;

  @override
  void initState() {
    super.initState();

    // ✅ EL JEFE ES EL BLOQUE 2
   isBossFight = widget.isBoss && widget.blockId == 2;

    timeRemaining = widget.blockId == 1 ? 80 : widget.blockId == 2 ? 70 : 12;

    futurePreguntas = PercepcionService.obtenerPreguntasBloque(widget.blockId);

    _fogController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _eyeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    startTimer();
    _loadEquipped();
    _loadCoins();
  }

  @override
  void dispose() {
    timer?.cancel();
    _fogController.dispose();
    _eyeController.dispose();
    _shakeController.dispose();
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
    await ProgressManager.failBlock(widget.blockId);

    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.9),
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
          "\nLa oscuridad te ha consumido.\nVuelve a empezar.",
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
                MaterialPageRoute(builder: (_) => const PercepcionMenuScreen()),
                (route) => false,
              );

              
            },

            
            child: const Text(
              "VOLVER",
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

    if (!correct && isBossFight) {
      _shakeController.forward(from: 0);
    }

    if (isBossFight && !correct) {
      timer?.cancel();
      bossFailed = true;
      await ProgressManager.failBlock(widget.blockId);
      Future.delayed(const Duration(milliseconds: 800), () {
        muerteInstantanea();
      });
      return;
    }

    if (correct) score++;

    timer?.cancel();
    await Future.delayed(const Duration(milliseconds: 700));
    pasarSiguiente();
  }

  void muerteInstantanea() async {
    if (_isProcessing) return;
    _isProcessing = true;

    timer?.cancel();
    await ProgressManager.failBlock(widget.blockId);

    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.red.shade900.withOpacity(0.95),
        content: const Center(
          child: Text(
            "¡EL OJO TE HA DEVORADO!\n\nINTENTA DE NUEVO",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: "PressStart2P",
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const PercepcionMenuScreen()),
                (route) => false,
              );
            },
            child: const Text(
              "VOLVER",
              style: TextStyle(
                color: Colors.cyanAccent,
                fontFamily: "PressStart2P",
              ),
            ),
          ),
        ],
      ),
    );
  }

   void pasarSiguiente() {
    selectedAnswer = null;
    answerChecked = false;
    opcionesOcultas = [];
    hintedOption = null;
    usedPowerups.clear();

    timeRemaining = widget.blockId == 1 ? 80 : widget.blockId == 2 ? 70 : 12;

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
      if (score == 10) return 14;
      if (score >= 5) return 7;
      return 0;
    }
    return 0;
  }

  void terminarBloque() async {
    if (_isProcessing) return;
    _isProcessing = true;

    timer?.cancel();

    final minimo = isBossFight ? 7 : 3;
    final paso = score >= minimo;

    if (!paso) {
      await ProgressManager.failBlock(widget.blockId);
      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.black.withOpacity(0.9),
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
            "\nLa sombra te ha vencido.\nVuelve a intentarlo.",
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
                  MaterialPageRoute(
                      builder: (_) => const PercepcionMenuScreen()),
                  (route) => false,
                );
              },
              child: const Text(
                "VOLVER",
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

    // ✅ DESBLOQUEAR COMODÍN AL DERROTAR JEFE DE PERCEPCIÓN
    if (isBossFight) {
      await ProgressManager.defeatBoss("boss_percepcion");
    }

    final monedasGanadas = calcularMonedas();
    if (monedasGanadas > 0) {
      await ProgressManager.addCoins(monedasGanadas);
    }

    await ProgressManager.completeBlock(widget.blockId);

    if (monedasGanadas > 0 && mounted) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF24133D),
          title: const Text(
            "¡Monedas Ganadas!",
            style: TextStyle(
              color: Colors.cyanAccent,
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
                  color: Colors.cyanAccent,
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
        builder: (_) => PercepcionResultadoScreen(
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
      if (opcion == hintedOption) return Colors.lightBlueAccent;
      return isBossFight ? const Color(0xFF6BE3FF) : Colors.cyanAccent;
    }
    if (opcion == p.correcta) return Colors.greenAccent;
    if (opcion == selectedAnswer) return Colors.redAccent;
    return isBossFight ? const Color(0xFF6BE3FF) : Colors.cyanAccent;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 500;

    return Scaffold(
      backgroundColor: isBossFight ? const Color(0xFF0A0012) : const Color(0xFF150C25),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          isBossFight ? "👁️ LA SOMBRA DEL OJO 👁️" : "BLOQUE ${widget.blockId}",
          style: TextStyle(
            color: isBossFight ? Colors.redAccent : Colors.cyanAccent,
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
              child: CircularProgressIndicator(color: Colors.cyanAccent),
            );
          }

          final preguntas = snapshot.data!;
          final pregunta = preguntas[currentIndex];
          final opcionesVisibles = pregunta.opciones
              .where((op) => !opcionesOcultas.contains(op))
              .toList();

          return Stack(
            children: [
              AnimatedBuilder(
                animation: _fogController,
                builder: (context, _) => CustomPaint(
                  painter: _HorrorFogPainter(_fogController.value, isBossFight),
                  size: size,
                ),
              ),
              if (isBossFight)
                AnimatedBuilder(
                  animation: _eyeController,
                  builder: (context, _) => Positioned(
                    top: size.height * 0.1,
                    left: size.width * 0.5 - 80,
                    child: Opacity(
                      opacity: 0.15 + (_eyeController.value * 0.15),
                      child: const Icon(
                        Icons.remove_red_eye,
                        size: 160,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ),
              SafeArea(
                child: AnimatedBuilder(
                  animation: _shakeController,
                  builder: (context, child) {
                    final offset =
                        math.sin(_shakeController.value * math.pi * 4) * 5;
                    return Transform.translate(
                      offset: Offset(offset, 0),
                      child: child,
                    );
                  },
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: Padding(
                        padding: EdgeInsets.all(isSmall ? 18 : 24),
                        child: Column(
                          children: [
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
                                              addExtraSeconds: _addExtraSeconds,
                                              refreshCoins: _refreshCoins,
                                              usedPowerUps: usedPowerups,
                                            );
                                            if (mounted) setState(() {});
                                          },
                                    child: Text(
                                      label,
                                      style: TextStyle(
                                        fontFamily: 'PressStart2P',
                                        fontSize: isSmall ? 9 : 10,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            const SizedBox(height: 16),
                            Text(
                              "Puntaje: $score",
                              style: TextStyle(
                                fontFamily: "PressStart2P",
                                fontSize: isSmall ? 11 : 13,
                                color: isBossFight
                                    ? Colors.redAccent
                                    : Colors.cyanAccent,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "$timeRemaining",
                              style: TextStyle(
                                fontFamily: "PressStart2P",
                                fontSize: isSmall ? 24 : 30,
                                color: timeRemaining < 6
                                    ? Colors.redAccent
                                    : (isBossFight
                                        ? Colors.redAccent
                                        : Colors.cyanAccent),
                              ),
                            ),
                            const SizedBox(height: 24),
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
                                          const Shadow(
                                            blurRadius: 12,
                                            color: Colors.redAccent,
                                          ),
                                        ]
                                      : null,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 26),
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
                                                const Duration(
                                                    milliseconds: 500),
                                                () =>
                                                    responder(pregunta, opcion),
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
                                          borderRadius:
                                              BorderRadius.circular(18),
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
                                                padding:
                                                    EdgeInsets.only(left: 8),
                                                child: Icon(
                                                  Icons.remove_red_eye,
                                                  color: Colors.black54,
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
              ),
            ],
          );
        },
      ),
    );
  }
}

// ----------------------------------------------------------
// PINTOR DE NIEBLA ATERRADORA
// ----------------------------------------------------------
class _HorrorFogPainter extends CustomPainter {
  final double progress;
  final bool isBoss;

  _HorrorFogPainter(this.progress, this.isBoss);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isBoss ? Colors.red : Colors.white).withOpacity(0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

    for (int i = 0; i < 12; i++) {
      final dx = math.sin(progress * 2 * math.pi + i * 0.5) * 200;
      final dy = size.height * i / 12;
      final rect = Rect.fromLTWH(dx, dy, size.width * 1.8, 160);
      canvas.drawOval(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ----------------------------------------------------------
// RESULTADO FINAL
// ----------------------------------------------------------
class PercepcionResultadoScreen extends StatelessWidget {
  final int blockId;
  final int score;
  final int total;
  final bool paso;

  const PercepcionResultadoScreen({
    super.key,
    required this.blockId,
    required this.score,
    required this.total,
    required this.paso,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF150C25),
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
                  color: Colors.cyanAccent,
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
                  backgroundColor: const Color(0xFF24133D),
                  foregroundColor: Colors.cyanAccent,
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 12,
                  ),
                  elevation: 10,
                  shadowColor: Colors.cyanAccent.withOpacity(0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: const BorderSide(
                      color: Color.fromARGB(255, 155, 24, 255),
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
                        builder: (_) => const PercepcionMenuScreen()),
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