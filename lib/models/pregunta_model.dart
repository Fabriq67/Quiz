class Pregunta {
  final String id;
  final String pregunta;
  final List<String> opciones;
  final String correcta;
  final String dificultad;
  final String explicacion;

  Pregunta({
    required this.id,
    required this.pregunta,
    required this.opciones,
    required this.correcta,
    required this.dificultad,
    required this.explicacion,
  });

  factory Pregunta.fromJson(Map<String, dynamic> json) {
    // Crear lista de opciones desde JSON
    List<String> ops = List<String>.from(json["opciones"]);

    // MEZCLAR (shuffle)
    ops.shuffle();

    return Pregunta(
      id: json["id"],
      pregunta: json["pregunta"],
      opciones: ops,
      correcta: json["respuesta_correcta"],
      dificultad: json["dificultad"],
      explicacion: json["explicacion"],
    );
  }
}
