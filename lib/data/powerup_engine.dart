import 'package:flutter/material.dart';
import '../models/powerup_model.dart';
import '../models/pregunta_model.dart';

class PowerUpEngine {
  /// Ejecuta el comodín según su ID del JSON
  static Map<String, dynamic> apply({
    required PowerUp powerUp,
    required Pregunta pregunta,
    required int coins,
    required List<String> opcionesOcultas,
    required Function(int) onCoinsUsed,
    required Function(String) onHint,
    required Function(List<String>) onHideOptions,
    required Function(int) onTimeAdded,
    required BuildContext context,
  }) {
    final data = powerUp.toJson();
    final String id = data["id"].toString();  // aseguramos string
    final int price = data["price"] ?? 0;

    // ---------------------------
    // VERIFICAR MONEDAS
    // ---------------------------
    if (coins < price) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No tienes suficientes monedas.")),
      );
      return {"success": false};
    }

    // Gastar monedas
    onCoinsUsed(price);

    // -------------------------------------------------------------------
    // 1) CLARIVIDENCIA → Revela la respuesta correcta
    // -------------------------------------------------------------------
    if (id == "clarividencia") {
      onHint(pregunta.correcta);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Clarividencia activada.")),
      );

      return {"success": true, "type": "clarividencia"};
    }

    // -------------------------------------------------------------------
    // 2) CORTE MENTAL → 50/50 (quita 2 incorrectas)
    // -------------------------------------------------------------------
    if (id == "corte_mental") {
      final incorrectas = pregunta.opciones
          .where((o) => o != pregunta.correcta)
          .toList();

      incorrectas.shuffle();

      final remove = incorrectas.take(2).toList();

      onHideOptions(remove);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Corte Mental eliminó ${remove.length} opciones.")),
      );

      return {"success": true, "type": "corte_mental"};
    }

    // -------------------------------------------------------------------
    // 3) PULSO TEMPORAL → +10 segundos
    // -------------------------------------------------------------------
    if (id == "pulso_temporal") {
      onTimeAdded(10);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("+10 segundos gracias a Pulso Temporal.")),
      );

      return {"success": true, "type": "pulso_temporal"};
    }

    // -------------------------------------------------------------------
    // 4) SOMBRA COGNITIVA → Oculta todas excepto 2 opciones
    // -------------------------------------------------------------------
       // -------------------------------------------------------------------
    // 4) SOMBRA COGNITIVA → Oculta 1 opción incorrecta
    // -------------------------------------------------------------------
    if (id == "sombra_cognitiva") {
      final incorrectas = pregunta.opciones
          .where((o) => o != pregunta.correcta)
          .toList();

      incorrectas.shuffle();

      final ocultar = incorrectas.take(1).toList(); // ✅ Solo oculta 1

      onHideOptions(ocultar);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sombra Cognitiva ocultó 1 opción.")),
      );

      return {"success": true, "type": "sombra_cognitiva"};
    }

    // ---------------------------
    // DEFAULT
    // ---------------------------
    return {"success": false};
  }
}
