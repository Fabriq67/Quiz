// ----------------------------------------------------------
//   PERCEPCIÓN — QUIZ SCREEN (VERSIÓN FINAL)
//   Incluye: tiempo agotado, reinicio total de nivel,
//   muerte del jefe, reinicio de bloques, monedas ✓
//   + Comodines con coste en monedas (gaste al usar)
//   + 50/50 elimina hasta 2 respuestas incorrectas
// ----------------------------------------------------------

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data/percepcion_service.dart';
import '../models/pregunta_model.dart';
import '../data/progress_manager.dart';
import '../models/powerup_model.dart';
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

class _PercepcionQuizScreenState extends State<PercepcionQuizScreen> {
  late Future<List<Pregunta>> futurePreguntas;

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

  // COMODINES: control
  Set<String> usedPowerups = {};
  String? hintedOption; // show eye hint

  @override
  void initState() {
    super.initState();

    isBossFight = widget.isBoss && widget.blockId == 2;

    // Tiempo por bloque
    timeRemaining = widget.blockId == 1
        ? 30
        : widget.blockId == 2
            ? 20
            : 12;

    futurePreguntas = PercepcionService.obtenerPreguntasBloque(widget.blockId);

    startTimer();
    _loadEquipped();
    _loadCoins();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _loadEquipped() async {
    equipped = await ProgressManager.loadSelectedPowerUps();
    setState(() {});
  }

  Future<void> _loadCoins() async {
    final p = await ProgressManager.loadProgress();
    setState(() => coins = p.coins);
  }

  // ----------------------------------------------------------
  // TEMPORIZADOR
  // ----------------------------------------------------------
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

  // ----------------------------------------------------------
  // TIEMPO AGOTADO → REINICIAR NIVEL COMPLETO (failBlock)
  // ----------------------------------------------------------
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
          "\nPerdiste el progreso del nivel.\nVuelve a empezar desde el Bloque 1.",
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

  // ----------------------------------------------------------
  // RESPUESTA DEL JUGADOR
  // ----------------------------------------------------------
  void responder(Pregunta pregunta, String opcion) {
    if (_isProcessing) return;

    // Bloquear input
    selectedAnswer = opcion;
    answerChecked = true;
    setState(() {});

    bool correct = opcion == pregunta.correcta;

    // JEFE → muerte instantánea
    if (isBossFight && !correct) {
      timer?.cancel();
      bossFailed = true;
      Future.delayed(const Duration(milliseconds: 600), () {
        muerteInstantanea();
      });
      return;
    }

    // Puntaje normal
    if (correct) score++;

    // Detener tiempo
    timer?.cancel();

    // Pasar a la siguiente pregunta
    Future.delayed(const Duration(milliseconds: 700), () {
      pasarSiguiente();
    });
  }

  // ----------------------------------------------------------
  // MUERTE DEL JEFE → REINICIAR NIVEL (failBlock)
  // ----------------------------------------------------------
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
        backgroundColor: Colors.red.withOpacity(0.85),
        content: const Center(
          child: Text(
            "¡FALLASTE!\n\nEL JEFE TE ANIQUILÓ",
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
              "VOLVER AL MENÚ",
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

  // ----------------------------------------------------------
  // SIGUIENTE PREGUNTA
  // ----------------------------------------------------------
  void pasarSiguiente() {
    selectedAnswer = null;
    answerChecked = false;
    opcionesOcultas = [];
    hintedOption = null;
       usedPowerups.clear(); // <<< LIMPIA COMODINES CADA PREGUNTA

    if (widget.blockId == 1) {
      timeRemaining = 30;
    } else if (widget.blockId == 2) {
      timeRemaining = 20;
    } else {
      timeRemaining = 12;
    }

    if (currentIndex == widget.totalQuestions - 1) {
      terminarBloque();
    } else {
      setState(() {
        currentIndex++;
      });
      startTimer();
    }
  }

  // ----------------------------------------------------------
  // CALCULAR MONEDAS GANADAS
  // ----------------------------------------------------------
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

  // ----------------------------------------------------------
  // TERMINAR BLOQUE
  // ----------------------------------------------------------
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
            "\nPerdiste el progreso del nivel.\nVuelve a empezar desde el Bloque 1.",
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

    if (isBossFight) {
      await ProgressManager.defeatBoss("boss_1");
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

  // ----------------------------------------------------------
  // MANEJO DE COMODINES (USO Y EFECTOS) CON COSTE
  // ----------------------------------------------------------
  IconData _iconForPowerUpId(String id) {
    switch (id) {
      case 'clarividencia':
        return Icons.visibility;
      case 'ocultar':
      case '50_50':
        return Icons.close;
      case 'tiempo_extra':
        return Icons.timer;
      default:
        return Icons.shield;
    }
  }

  int _extractPriceFromPowerUp(PowerUp p) {
    try {
      final data = p.toJson();
      final possible = data['price'] ?? data['cost'] ?? data['value'] ?? data['coins'];
      if (possible == null) return 0;
      return int.tryParse(possible.toString()) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> _usePowerUp(PowerUp p, Pregunta pregunta) async {
    try {
      final data = p.toJson();
      final id = (data['id'] ?? data['name'] ?? data['_id'] ?? p.toString()).toString();
      final price = _extractPriceFromPowerUp(p);

      if (usedPowerups.contains(id)) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Comodín ya usado en este bloque.")));
        return;
      }

      // comprobaremos monedas
      final progress = await ProgressManager.loadProgress();
      if (progress.coins < price) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No tienes suficientes monedas para usar este comodín.")));
        return;
      }

      // gasta monedas
      if (price > 0) {
        await ProgressManager.addCoins(-price);
        await _loadCoins(); // refresh coins on HUD
      }

      // Example effects:
      if (id == 'clarividencia') {
        setState(() {
          hintedOption = pregunta.correcta;
          usedPowerups.add(id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Se ha revelado la respuesta correcta.")),
        );
      } else if (id == 'ocultar' || id == '50_50') {
        // Remove up to 2 incorrect options
        final posibles = pregunta.opciones
            .where((o) => o != pregunta.correcta && !opcionesOcultas.contains(o))
            .toList();
        if (posibles.isNotEmpty) {
          final rnd = math.Random();

          // choose 2 unique incorrects or fewer if not enough
          final toRemove = <String>{};
          if (posibles.length == 1) {
            toRemove.add(posibles.first);
          } else {
            while (toRemove.length < 2 && toRemove.length < posibles.length) {
              toRemove.add(posibles[rnd.nextInt(posibles.length)]);
            }
          }

          setState(() {
            opcionesOcultas.addAll(toRemove);
            usedPowerups.add(id);
          });

          final removedCount = toRemove.length;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Se han eliminado $removedCount opción(es) incorrecta(s).")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No quedan opciones para eliminar.")),
          );
        }
      } else if (id == 'tiempo_extra') {
        setState(() {
          timeRemaining += 10;
          usedPowerups.add(id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Se han añadido 10 segundos.")),
        );
      } else {
        setState(() => usedPowerups.add(id));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Comodín utilizado.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error usando el comodín: $e")));
    }
  }

  // ----------------------------------------------------------
  // COLOR DE OPCIONES
  // ----------------------------------------------------------
  Color getColor(Pregunta p, String opcion) {
    if (!answerChecked) {
      if (opcion == hintedOption) return Colors.lightBlueAccent;
      return Colors.cyanAccent;
    }
    if (opcion == p.correcta) return Colors.greenAccent;
    if (opcion == selectedAnswer) return Colors.redAccent;
    return Colors.cyanAccent;
  }

  double _scaleFromWidth(double base, double width) {
    final ratio = (width / 360);
    final clamped = ratio.clamp(0.85, 1.3);
    return base * clamped;
  }

  // ----------------------------------------------------------
  // UI
  // ----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF150C25),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          isBossFight ? "JEFE: La sombra del ojo" : "BLOQUE ${widget.blockId}",
          style: const TextStyle(
            color: Colors.cyanAccent,
            fontFamily: "PressStart2P",
            fontSize: 10,
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

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final scale = (width / 360).clamp(0.85, 1.25);

                  return Stack(
                    children: [
                      // Fondo jefe
                      if (isBossFight)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.18),
                                  Colors.transparent,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),

                      Padding(
                        padding: EdgeInsets.all(18 * scale),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            //-----------------------------------------------------
                            // MAIN CONTENT (HUD + preguntas)
                            //-----------------------------------------------------
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    //----------------------
                                    // HUD (coins + comodines)
                                    //----------------------
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.star,
                                            color: Colors.yellowAccent,
                                            size: 18 * scale),
                                        SizedBox(width: 4 * scale),
                                        Text(
                                          "$coins",
                                          style: TextStyle(
                                            fontFamily: "PressStart2P",
                                            fontSize: _scaleFromWidth(12, width),
                                            color: Colors.white,
                                          ),
                                        ),

                                        SizedBox(width: 20 * scale),

                                        if (equipped.isNotEmpty)
                                          Row(
                                            children: equipped.map((p) {
                                              final data = p.toJson();
                                              final id = (data['id'] ?? data['name'] ?? data['_id'] ?? p.toString()).toString();
                                              final used = usedPowerups.contains(id);
                                              final icon = _iconForPowerUpId(id);
                                              final price = _extractPriceFromPowerUp(p);

                                              return Padding(
                                                padding: EdgeInsets.only(left: 8 * scale),
                                                child: Tooltip(
                                                  message: "$id - $price monedas",
                                                  child: Column(
                                                    children: [
                                                      CircleAvatar(
                                                        backgroundColor: used ? Colors.grey.shade700 : Colors.white,
                                                        radius: 14 * scale,
                                                        child: IconButton(
                                                          padding: EdgeInsets.zero,
                                                          onPressed: (used || coins < price) ? null : () => _usePowerUp(p, pregunta),
                                                          icon: Icon(icon,
                                                              color: used ? Colors.black45 : Colors.black,
                                                              size: 16 * scale),
                                                        ),
                                                      ),
                                                      SizedBox(height: 2 * scale),
                                                      Text(
                                                        "$price",
                                                        style: TextStyle(
                                                          color: coins < price ? Colors.redAccent : Colors.white,
                                                          fontSize: 10 * scale,
                                                          fontFamily: 'PressStart2P',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                      ],
                                    ),

                                    SizedBox(height: 12 * scale),

                                    //----------------------
                                    // SCORE
                                    //----------------------
                                    Text(
                                      "Puntaje: $score",
                                      style: TextStyle(
                                        fontFamily: "PressStart2P",
                                        fontSize: _scaleFromWidth(12, width),
                                        color: Colors.cyanAccent,
                                      ),
                                    ),

                                    SizedBox(height: 8 * scale),

                                    //----------------------
                                    // TIMER
                                    //----------------------
                                    Text(
                                      "$timeRemaining",
                                      style: TextStyle(
                                        fontFamily: "PressStart2P",
                                        fontSize: _scaleFromWidth(26, width),
                                        color: Colors.cyanAccent,
                                      ),
                                    ),

                                    SizedBox(height: 28 * scale),

                                    //----------------------
                                    // PREGUNTA
                                    //----------------------
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 6 * scale),
                                      child: Text(
                                        pregunta.pregunta,
                                        style: TextStyle(
                                          fontFamily: "VT323",
                                          fontSize: _scaleFromWidth(28, width),
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),

                                    SizedBox(height: 26 * scale),

                                    //----------------------
                                    // OPCIONES
                                    //----------------------
                                    if (hintedOption != null)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: Text(
                                          "Comodín aplicado: respuesta sugerida",
                                          style: TextStyle(
                                            color: Colors.lightBlueAccent,
                                            fontFamily: 'VT323',
                                            fontSize: _scaleFromWidth(16, width),
                                          ),
                                        ),
                                      ),

                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: opcionesVisibles.length,
                                      itemBuilder: (context, idx) {
                                        final opcion = opcionesVisibles[idx];
                                        return Padding(
                                          padding: EdgeInsets.only(bottom: 12 * scale),
                                          child: InkWell(
                                            onTap: answerChecked
                                                ? null
                                                : () {
                                                    setState(() {
                                                      selectedAnswer = opcion;
                                                      answerChecked = true;
                                                    });
                                                    Future.delayed(const Duration(milliseconds: 500), () => responder(pregunta, opcion));
                                                  },
                                            child: AnimatedContainer(
                                              duration: const Duration(milliseconds: 200),
                                              padding: EdgeInsets.symmetric(
                                                vertical: 14 * scale,
                                                horizontal: 18 * scale,
                                              ),
                                              decoration: BoxDecoration(
                                                color: getColor(pregunta, opcion),
                                                borderRadius: BorderRadius.circular(18 * scale),
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: Center(
                                                      child: Text(
                                                        opcion,
                                                        style: TextStyle(
                                                          fontFamily: "PressStart2P",
                                                          fontSize: _scaleFromWidth(11, width),
                                                          color: Colors.black,
                                                        ),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    ),
                                                  ),
                                                  if (opcion == hintedOption)
                                                    Padding(
                                                      padding: EdgeInsets.only(left: 8 * scale),
                                                      child: Icon(
                                                        Icons.remove_red_eye,
                                                        color: Colors.black54,
                                                        size: 18 * scale,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),

                                    SizedBox(height: 20 * scale),

                                    //----------------------
                                    // PROGRESO
                                    //----------------------
                                    Text(
                                      "Pregunta ${currentIndex + 1} / ${widget.totalQuestions}",
                                      style: TextStyle(
                                        fontFamily: "VT323",
                                        fontSize: _scaleFromWidth(20, width),
                                        color: Colors.white70,
                                      ),
                                    ),

                                    SizedBox(height: 40 * scale),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
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