import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/pregunta_model.dart';

class CienciaService {
  static Future<List<Pregunta>> _loadAll() async {
    final String jsonString =
        await rootBundle.loadString("questions/ciencia.json");

    final List<dynamic> data = json.decode(jsonString);

    return data.map((e) => Pregunta.fromJson(e)).toList();
  }

  static Future<List<Pregunta>> obtenerPreguntasBloque(int blockId) async {
    final todas = await _loadAll();

    final faciles = todas.where((p) => p.dificultad == "facil").toList();
    final medias = todas.where((p) => p.dificultad == "media").toList();
    final dificiles = todas.where((p) => p.dificultad == "dificil").toList();

    faciles.shuffle();
    medias.shuffle();
    dificiles.shuffle();

    if (blockId == 1) {
      return faciles.take(5).toList();
    } else if (blockId == 2) {
      return medias.take(5).toList();
    } else if (blockId == 3) {
      return dificiles.take(10).toList();
    }

    return [];
  }
}