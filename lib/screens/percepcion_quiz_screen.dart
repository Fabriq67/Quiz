import 'dart:async';
import 'package:flutter/material.dart';
import '../data/percepcion_service.dart';
import '../models/pregunta_model.dart';
import 'percepcion_menu.dart';
import '../data/progress_manager.dart';

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


  Timer? timer;

  String? selectedAnswer;
  bool answerChecked = false;

  @override
  void initState() {
    super.initState();

      if (widget.blockId == 1) {
    timeRemaining = 30;
  } else if (widget.blockId == 2) {
    timeRemaining = 20;
  } else {
    timeRemaining = 12; // default por si usas otros bloques luego
  }

    futurePreguntas =
        PercepcionService.obtenerPreguntasBloque(widget.blockId);

    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeRemaining == 0) {
        t.cancel();
        pasarSiguiente();
      } else {
        setState(() => timeRemaining--);
      }
    });
  }

  void responder(Pregunta pregunta, String opcion) {
    answerChecked = true;
    selectedAnswer = opcion;

    if (opcion == pregunta.correcta) score++;

    timer?.cancel();

    Future.delayed(const Duration(seconds: 1), () {
      pasarSiguiente();
    });
  }

void pasarSiguiente() {
  selectedAnswer = null;
  answerChecked = false;

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
    setState(() => currentIndex++);
    startTimer();
  }
}


  void terminarBloque() async {
    final minimo = widget.isBoss ? 7 : 3;
    final paso = score >= minimo;

    if (widget.blockId == 1 && paso) {
      await ProgressManager.unlockBlock(2);
    }

    Navigator.pushReplacement(
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
    if (!answerChecked) return Colors.cyanAccent;

    if (opcion == p.correcta) return Colors.greenAccent;

    if (opcion == selectedAnswer) return Colors.redAccent;

    return Colors.cyanAccent;
  }

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
          widget.isBoss
              ? "JEFE DEL BLOQUE"
              : "BLOQUE ${widget.blockId}",
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

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  "Puntaje: $score",
                  style: const TextStyle(
                    fontFamily: "PressStart2P",
                    fontSize: 12,
                    color: Colors.cyanAccent,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  "$timeRemaining",
                  style: const TextStyle(
                    fontFamily: "PressStart2P",
                    fontSize: 26,
                    color: Colors.cyanAccent,
                  ),
                ),

                const SizedBox(height: 40),

                Text(
                  pregunta.pregunta,
                  style: const TextStyle(
                    fontFamily: "VT323",
                    fontSize: 32,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

               for (String opcion in pregunta.opciones)
  Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: InkWell(
      onTap: answerChecked
          ? () {} // <- NO ESTÁ deshabilitado, así no se pone gris
          : () {
              setState(() {
                selectedAnswer = opcion;
                answerChecked = true;
              });

              Future.delayed(const Duration(seconds: 1), () {
                responder(pregunta, opcion);
              });
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 22),
        decoration: BoxDecoration(
          color: answerChecked
              ? (opcion == pregunta.correcta
                  ? Colors.greenAccent
                  : (opcion == selectedAnswer
                      ? Colors.redAccent
                      : Colors.cyanAccent))
              : Colors.cyanAccent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            opcion,
            style: const TextStyle(
              fontFamily: "PressStart2P",
              fontSize: 11,
              color: Colors.black,
            ),
          ),
        ),
      ),
    ),
  ),


                const SizedBox(height: 20),

                Text(
                  "Pregunta ${currentIndex + 1} / ${widget.totalQuestions}",
                  style: const TextStyle(
                    fontFamily: "VT323",
                    fontSize: 22,
                    color: Colors.white70,
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

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

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                  // limpia TODAS las pantallas previas y te lleva al menú limpio
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PercepcionMenuScreen(),
                    ),
                    (route) => false,
                  );
                },
                child: const Text("Volver al menú"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
