import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/pregunta_model.dart';

class CienciaService {
  static List<Pregunta>? _pool;

  static Future<void> _ensurePool() async {
    if (_pool != null) return;
    final String jsonString =
        await rootBundle.loadString('assets/questions/ciencia.json');
    final List<dynamic> data = json.decode(jsonString);
    _pool = data.map((e) => Pregunta.fromJson(e)).toList();
  }

  static Future<List<Pregunta>> obtenerPreguntasBloque(int blockId) async {
    await _ensurePool();
    final todas = List<Pregunta>.from(_pool!);
    todas.shuffle();

    if (blockId == 1) return todas.take(5).toList();
    if (blockId == 2) return todas.skip(5).take(5).toList();
    if (blockId == 3) return todas.skip(10).take(10).toList();
    return [];
  }
}