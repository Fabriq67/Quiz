// ----------------------------------------------------------
//   CULTURA GENERAL — QUIZ SCREEN (VERSIÓN FINAL PERFECTA)
//   + HUD: Tamaños aumentados (más grandes y visibles).
//   + Fix: Protección contra desbordamiento y crash.
//   + Diseño: Jefe (Neón/Dark) y Comodines Originales.
// ----------------------------------------------------------

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui'; // Necesario para el efecto Blur
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
  final bool freeMode; // ← MODO LIBRE

  const CulturaQuizScreen({
    super.key,
    required this.blockId,
    required this.totalQuestions,
    required this.isBoss,
    this.freeMode = false, // Default: false
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
  List<String> opcionesOcultas = [];
  String? hintedOption;
  List<String> opcionesBarajadas = [];
  String? _preguntaClave;

  // COLORES TEMA CÁLIDO
  final Color _warmTextColor = const Color(0xFF3E2723);
  final Color _warmContainerColor = const Color(0xFF4E342E).withOpacity(0.9);
  final Color _warmBorderColor = const Color(0xFF8D6E63);
  final Color _warmOptionColor = const Color(0xFFFFF3E0).withOpacity(0.95);

  // COLORES TEMA JEFE
  final Color _bossTextColor = const Color(0xFFE6E6FA);
  final Color _bossContainerColor = const Color(0xFF1A0C3D).withOpacity(0.85);
  final Color _bossBorderColor = const Color(0xFFE6E6FA);

  @override
  void initState() {
    super.initState();
    isBossFight = widget.isBoss && widget.blockId == 4;
    timeRemaining = isBossFight ? 25 : 40;
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

  Future<void> _loadEquipped() async {
    equipped = await ProgressManager.loadSelectedPowerUps();
    equipped = equipped.where((p) => p.id.isNotEmpty).toList();
    if (!mounted) return;
    setState(() {});
  }

  void _setHint(String h) {
    if (mounted) setState(() => hintedOption = h);
  }

  void _hideSpecificOptions(List<String> ops) {
    if (mounted) setState(() => opcionesOcultas.addAll(ops));
  }

  void _addExtraSeconds(int s) {
    if (mounted)
      setState(() => timeRemaining = (timeRemaining + s).clamp(0, 60));
  }

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

    if (!widget.freeMode) {
      await ProgressManager.failCultureBlock(widget.blockId);
    }

    if (!mounted) return;
    await _showResultScreen(false, 0, widget.freeMode);

    if (!mounted) return;
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
      if (!widget.freeMode) {
        await ProgressManager.addCoins(-10);
      }

      if (!mounted) return;
      await _loadCoins();

      if (bossErrors >= 3) {
        _isProcessing = true;
        timer?.cancel();
        if (!widget.freeMode) {
          await ProgressManager.failCultureBlock(widget.blockId);
        }

        if (!mounted) return;
        await _showResultScreen(false, 0, widget.freeMode);

        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const CulturaMenuScreen()),
          (route) => false,
        );
        return;
      }
    }

    timer?.cancel();
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    pasarSiguiente();
  }

  void pasarSiguiente() {
    selectedAnswer = null;
    answerChecked = false;
    usedPowerups.clear();
    opcionesOcultas.clear();
    hintedOption = null;
    opcionesBarajadas = [];
    timeRemaining = isBossFight ? 25 : 40;

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
    if (widget.blockId == 4 && isBossFight) {
      if (score == 20) return 50;
      if (score >= 10) return 30;
      return 0;
    }
    return 0;
  }

  Future<void> terminarBloque() async {
    if (_isProcessing) return;
    _isProcessing = true;
    timer?.cancel();

    final minimo = widget.blockId == 4 ? 10 : (widget.blockId == 3 ? 5 : 4);
    final paso = score >= minimo;
    final monedas = paso ? calcularMonedas() : 0;

    if (paso) {
      // ✅ GANAR MONEDAS EN AMBOS MODOS
      if (monedas > 0) await ProgressManager.addCoins(monedas);

      // ✅ DESBLOQUEAR COMODÍN Y PROGRESO SOLO EN MODO NORMAL
      if (!widget.freeMode) {
        if (isBossFight) {
          await ProgressManager.defeatBoss("boss_cultura_4");
          await ProgressManager.saveBool("has_new_powerup", true);
        }

        await ProgressManager.completeCultureBlock(widget.blockId);

        if (widget.blockId < 4) {
          await ProgressManager.unlockCultureBlock(widget.blockId + 1);
        }

        if (isBossFight && mounted) {
          await _showEscapeDialog();
        }
      } else {
        // EN MODO LIBRE: mostrar mensaje con monedas ganadas
        if (monedas > 0 && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFFB388FF),
              duration: const Duration(seconds: 2),
              content: Text(
                "Has ganado $monedas monedas.",
                style: const TextStyle(color: Colors.black, fontFamily: "VT323"),
              ),
            ),
          );
        }
      }
    } else {
      // En modo libre, no fallar = no guardar
      if (!widget.freeMode) {
        await ProgressManager.failCultureBlock(widget.blockId);
      }
    }

    if (!mounted) return;
    await _showResultScreen(paso, monedas, widget.freeMode);

    if (!mounted) return;
    if (widget.freeMode) {
      Navigator.pop(context);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const CulturaMenuScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _showResultScreen(bool passed, int earnedCoins, bool freeMode) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(color: Colors.black.withOpacity(0.2)),
          ),
          AlertDialog(
            backgroundColor: isBossFight
                ? _bossContainerColor
                : _warmContainerColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              passed ? "🎉 ¡BLOQUE SUPERADO!" : "❌ BLOQUE FALLIDO",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "PressStart2P",
                fontSize: 16,
                color: passed ? Colors.greenAccent : Colors.redAccent,
                shadows: [
                  Shadow(
                    blurRadius: 10,
                    color: (passed ? Colors.greenAccent : Colors.redAccent)
                        .withOpacity(0.6),
                  ),
                ],
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
                    fontSize: 32,
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
                      color: Colors.cyanAccent,
                      fontFamily: "PressStart2P",
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showEscapeDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
          AlertDialog(
            backgroundColor: const Color(0xFF0A0A1A).withOpacity(0.9),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: const Text(
              "¡FELICIDADES!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "PressStart2P",
                fontSize: 18,
                color: Colors.greenAccent,
              ),
            ),
            content: const Text(
              "¡Felicidades!\n\n¡Saliste del purgatorio!\n\n🎮 MODO ARCADE DESBLOQUEADO 🎮\n\nVuelve al menú principal para jugar todos los niveles de forma libre, sin penalizaciones ni limitaciones de tiempo.\n\n¡Eres libre, guerrero mental!",
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
        ],
      ),
    );
  }

  Color getColor(Pregunta p, String opcion) {
    if (isBossFight) {
      if (!answerChecked) {
        if (opcion == hintedOption) return Colors.lightBlueAccent;
        return const Color(0xFFE6E6FA).withOpacity(0.9);
      }
      if (opcion == p.correcta) return Colors.greenAccent;
      if (opcion == selectedAnswer) return Colors.redAccent;
      return const Color(0xFFE6E6FA).withOpacity(0.7);
    } else {
      if (!answerChecked) {
        if (opcion == hintedOption) return Colors.orangeAccent;
        return _warmOptionColor;
      }
      if (opcion == p.correcta) return Colors.green;
      if (opcion == selectedAnswer) return Colors.red;
      return _warmOptionColor.withOpacity(0.7);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 450;

    // Colores base
    final clockColor = isBossFight
        ? (timeRemaining < 6 ? Colors.redAccent : Colors.cyanAccent)
        : (timeRemaining < 6 ? Colors.red : const Color(0xFF00838F));
    final coinColor = isBossFight
        ? Colors.amberAccent
        : const Color.fromARGB(255, 159, 80, 11);

    return Scaffold(
      backgroundColor:
          isBossFight ? const Color(0xFF0A0A1A) : const Color(0xFFFFD54F),
      body: Stack(
        children: [
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
          SafeArea(
            child: FutureBuilder<List<Pregunta>>(
              future: futurePreguntas,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: isBossFight
                          ? const Color(0xFFE6E6FA)
                          : _warmTextColor,
                    ),
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

                if (_preguntaClave != p.pregunta) {
                  opcionesBarajadas = List<String>.from(p.opciones)..shuffle();
                  _preguntaClave = p.pregunta;
                }

                final opcionesVisibles = opcionesBarajadas
                    .where((op) => !opcionesOcultas.contains(op))
                    .toList();

                return Column(
                  children: [
                    // --- 1. CABECERA: Título y Contador ---
                    SizedBox(height: size.height * 0.015), 
                    Text(
                      isBossFight
                          ? "🐙 EL KRAKEN DEL JUICIO 🐙"
                          : "CULTURA GENERAL - BLOQUE ${widget.blockId}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "PressStart2P",
                        color: isBossFight ? Colors.redAccent : _warmTextColor,
                        fontSize: isSmall ? 10 : 12,
                        shadows: [
                          Shadow(
                            blurRadius: 12,
                            color: isBossFight
                                ? Colors.redAccent
                                : _warmTextColor.withOpacity(0.5),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Pregunta ${currentIndex + 1} / ${widget.totalQuestions}",
                      style: TextStyle(
                        fontFamily: "VT323",
                        fontSize: isSmall ? 20 : 24,
                        color: isBossFight
                            ? Colors.cyanAccent
                            : const Color(0xFF00695C),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    SizedBox(height: size.height * 0.02),

                    // --- 2. HUD AUMENTADO: Monedas, Reloj, Estrellas ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // MONEDAS (Más grande)
                          Column(
                            children: [
                              Icon(Icons.attach_money,
                                  color: coinColor, size: 36), // Aumentado de 30 -> 36
                              Text(
                                "$coins",
                                style: TextStyle(
                                  color: coinColor,
                                  fontFamily: "PressStart2P",
                                  fontSize: isSmall ? 14 : 16, // Aumentado de 12 -> 16
                                ),
                              ),
                            ],
                          ),

                          // RELOJ CENTRAL (Más grande)
                          Container(
                            width: 82, // Aumentado de 70 -> 82
                            height: 82,
                            padding: isBossFight
                                ? const EdgeInsets.all(10)
                                : null,
                            decoration: isBossFight
                                ? BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.cyanAccent
                                            .withOpacity(0.4),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      )
                                    ],
                                  )
                                : null,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if(isBossFight)
                                Icon(
                                  Icons.schedule,
                                  color: clockColor,
                                  size: 28, // Aumentado de 24 -> 28
                                ) else 
                                Icon(
                                  Icons.schedule,
                                  color: clockColor,
                                  size: 42, // Aumentado de 40 -> 42
                                ),
                                Text(
                                  "$timeRemaining",
                                  style: TextStyle(
                                    fontFamily: "PressStart2P",
                                    fontSize: isSmall ? 22 : 26, // Aumentado de 20 -> 26
                                    color: clockColor,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ACIERTOS (Más grande)
                          Column(
                            children: [
                              Icon(Icons.star,
                                  color: isBossFight
                                      ? Colors.greenAccent
                                      : const Color.fromARGB(255, 0, 0, 0),
                                  size: 36), // Aumentado de 30 -> 36
                              Text(
                                "$score",
                                style: TextStyle(
                                  color: isBossFight
                                      ? Colors.greenAccent
                                      : Colors.black,
                                  fontFamily: "PressStart2P",
                                  fontSize: isSmall ? 14 : 16, // Aumentado de 12 -> 16
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // --- 3. ERRORES (Solo Jefe) ---
                    if (isBossFight)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A0A0A).withOpacity(0.9),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.redAccent.withOpacity(0.6),
                              width: 2,
                            ),
                          ),
                          child: Text(
                            "💀 Errores: $bossErrors / 3",
                            style: const TextStyle(
                                fontFamily: "PressStart2P",
                                fontSize: 10,
                                color: Colors.redAccent),
                          ),
                        ),
                      ),

                    SizedBox(height: size.height * 0.02), 

                    // --- 4. COMODINES (Estilo Original) ---
                    if (equipped.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 10,
                          alignment: WrapAlignment.center,
                          children: equipped.map((powerup) {
                            final usado = usedPowerups.contains(powerup.id);
                            return PowerUpGameButton(
                              powerUp: powerup,
                              isUsed: usado,
                              isSmall: isSmall,
                              isDisabled: answerChecked,
                              onPressed: () async {
                                await PowerUpEffects.apply(
                                  context: context,
                                  powerUp: powerup,
                                  pregunta: p,
                                  setHint: _setHint,
                                  hideSpecificOptions: _hideSpecificOptions,
                                  addExtraSeconds: _addExtraSeconds,
                                  refreshCoins: _refreshCoins,
                                  usedPowerUps: usedPowerups,
                                );
                                if (mounted) setState(() {});
                              },
                            );
                          }).toList(),
                        ),
                      ),

                    SizedBox(height: size.height * 0.02),

                    // --- 5. CAJA DE PREGUNTA ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isBossFight
                              ? _bossContainerColor
                              : _warmContainerColor,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                              color: isBossFight
                                  ? _bossBorderColor
                                  : _warmBorderColor,
                              width: 2),
                        ),
                        child: Text(
                          p.pregunta,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: "VT323",
                            fontSize: isSmall ? 23 : 24, 
                            color: Colors.white,
                            height: 1.2,
                            fontWeight: FontWeight.w700
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.025),

                    // --- 6. OPCIONES ---
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: opcionesVisibles.length,
                        itemBuilder: (context, i) {
                          final opcion = opcionesVisibles[i];

                          if (opcionesOcultas.contains(opcion)) {
                            return const SizedBox.shrink();
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: answerChecked
                                  ? null
                                  : () => responder(p, opcion),
                              child: Container(
                                padding: const EdgeInsets.all(16),
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
                                          fontSize: isSmall ? 20 : 24,
                                          color: isBossFight
                                              ? Colors.black87
                                              : Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (opcion == hintedOption)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8),
                                        child: Icon(
                                          Icons.lightbulb,
                                          color: isBossFight
                                              ? Colors.black87
                                              : Colors.black54,
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
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- WIDGETS AUXILIARES Y PAINTERS (SIN CAMBIOS) ---

class PowerUpGameButton extends StatelessWidget {
  final PowerUp powerUp;
  final bool isUsed;
  final bool isSmall;
  final bool isDisabled;
  final VoidCallback? onPressed;

  const PowerUpGameButton({
    super.key,
    required this.powerUp,
    required this.isUsed,
    required this.isSmall,
    required this.isDisabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final label = (powerUp.name.isNotEmpty) ? powerUp.name : powerUp.id;
    final Color priceColor =
        isUsed ? Colors.black38 : const Color(0xFFF57F17);
    final Color textColor =
        isUsed ? Colors.black54 : const Color(0xFF00695C);

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isUsed
            ? Colors.grey.withOpacity(0.5)
            : const Color(0xFFFFF8E1),
        foregroundColor: textColor,
        padding: EdgeInsets.symmetric(
          vertical: isSmall ? 10 : 14,
          horizontal: isSmall ? 15 : 16,
        ),
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isUsed
                ? Colors.transparent
                : const Color(0xFF8D6E63),
            width: 1,
          ),
        ),
      ),
      onPressed: (isUsed || isDisabled) ? null : onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'PressStart2P',
              fontSize: isSmall ? 11 : 13,
              color: textColor,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.stars_rounded,
                size: 17,
                color: priceColor,
              ),
              const SizedBox(width: 5),
              Text(
                "${powerUp.price}",
                style: TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 16,
                  color: priceColor,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

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