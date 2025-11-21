import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/pregunta_model.dart';

class PercepcionService {
  static Future<List<Pregunta>> cargarPreguntas() async {
    final String data =
        await rootBundle.loadString('assets/questions/percepcion.json');

    final jsonMap = json.decode(data);

    final List preguntasJson = jsonMap["preguntas"];

    return preguntasJson.map((e) => Pregunta.fromJson(e)).toList();
  }

  static Future<List<Pregunta>> obtenerPreguntasBloque(int blockId) async {
    List<Pregunta> todas = await cargarPreguntas();
    todas.shuffle(); // mezcla preguntas al azar

    if (blockId == 1) {
      return todas.take(5).toList();
    } else if (blockId == 2) {
      return todas.take(10).toList();
    } else {
      return [];
    }
  }
}
