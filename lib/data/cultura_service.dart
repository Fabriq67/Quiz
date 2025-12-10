import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/pregunta_model.dart';

class CulturaService {
  static List<Pregunta>? _cachedPreguntas;

  static Future<List<Pregunta>> _loadAll() async {
    if (_cachedPreguntas != null) {
      return _cachedPreguntas!;
    }

    final String jsonString =
        await rootBundle.loadString("questions/cultura.json");

    final List<dynamic> data = json.decode(jsonString);
    _cachedPreguntas = data.map((e) => Pregunta.fromJson(e)).toList();

    final faciles = _cachedPreguntas!.where((p) => p.dificultad == "facil").length;
    final medias = _cachedPreguntas!.where((p) => p.dificultad == "media").length;
    final dificiles = _cachedPreguntas!.where((p) => p.dificultad == "dificil").length;
    final muyDificiles = _cachedPreguntas!.where((p) => p.dificultad == "muy_dificil").length;

    print("📊 CULTURA - Preguntas cargadas:");
    print("  Fáciles: $faciles (necesarias: 5)");
    print("  Medias: $medias (necesarias: 5)");
    print("  Difíciles: $dificiles (necesarias: 10)");
    print("  Muy Difíciles: $muyDificiles (necesarias: 20)");

    return _cachedPreguntas!;
  }

  static Future<List<Pregunta>> obtenerPreguntasBloque(int blockId) async {
    final todas = await _loadAll();

    final faciles = todas.where((p) => p.dificultad == "facil").toList();
    final medias = todas.where((p) => p.dificultad == "media").toList();
    final dificiles = todas.where((p) => p.dificultad == "dificil").toList();
    final muyDificiles = todas.where((p) => p.dificultad == "muy_dificil").toList();

    faciles.shuffle();
    medias.shuffle();
    dificiles.shuffle();
    muyDificiles.shuffle();

    List<Pregunta> seleccionadas = [];
    int necesarias = 0;

    if (blockId == 1) {
      necesarias = 5;
      seleccionadas = faciles.take(necesarias).toList();
      if (seleccionadas.length < necesarias) {
        print("❌ BLOQUE 1: Solo hay ${seleccionadas.length}/$necesarias preguntas fáciles");
      }
    } 
    else if (blockId == 2) {
      necesarias = 5;
      seleccionadas = medias.take(necesarias).toList();
      if (seleccionadas.length < necesarias) {
        print("❌ BLOQUE 2: Solo hay ${seleccionadas.length}/$necesarias preguntas medias");
      }
    } 
    else if (blockId == 3) {
      necesarias = 10;
      seleccionadas = dificiles.take(necesarias).toList();
      if (seleccionadas.length < necesarias) {
        print("❌ BLOQUE 3: Solo hay ${seleccionadas.length}/$necesarias preguntas difíciles");
        // ✅ FALLBACK: Rellenar con medias si no hay suficientes difíciles
        if (seleccionadas.isNotEmpty) {
          final faltantes = necesarias - seleccionadas.length;
          seleccionadas.addAll(medias.skip(5).take(faltantes));
          print("   Añadidas $faltantes preguntas medias como fallback");
        }
      }
    } 
    else if (blockId == 4) {
      necesarias = 20;
      seleccionadas = muyDificiles.take(necesarias).toList();
      if (seleccionadas.length < necesarias) {
        print("❌ BLOQUE 4 (JEFE): Solo hay ${seleccionadas.length}/$necesarias preguntas muy difíciles");
        // ✅ FALLBACK: Rellenar con difíciles si no hay suficientes muy difíciles
        if (seleccionadas.isNotEmpty) {
          final faltantes = necesarias - seleccionadas.length;
          seleccionadas.addAll(dificiles.skip(10).take(faltantes));
          print("   Añadidas $faltantes preguntas difíciles como fallback");
        }
      }
    }

    print("✅ BLOQUE $blockId: ${seleccionadas.length} preguntas seleccionadas");
    return seleccionadas;
  }

  static void resetCache() {
    _cachedPreguntas = null;
  }
}