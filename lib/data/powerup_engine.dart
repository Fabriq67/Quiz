import 'dart:math';
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
    final id = data["id"];
    final price = data["price"] ?? 0;

    // Verificar monedas
    if (coins < price) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No tienes suficientes monedas.")),
      );
      return {
        "success": false,
      };
    }

    // Gastar monedas
    onCoinsUsed(price);

    // ---------------------------
    // CLARIVIDENCIA
    // ---------------------------
    if (id == "clarividencia") {
      onHint(pregunta.correcta);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("La respuesta correcta fue revelada.")),
      );

      return {"success": true, "type": "hint"};
    }

    // ---------------------------
    // 50/50 UNIVERSAL
    // ---------------------------
    if (id == "5050") {
      final incorrectas = pregunta.opciones
          .where((o) => o != pregunta.correcta)
          .toList();

      incorrectas.shuffle();

      final remove = incorrectas.take(2).toList();

      onHideOptions(remove);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Se eliminaron ${remove.length} opciones.")),
      );

      return {"success": true, "type": "5050"};
    }

    // ---------------------------
    // TIEMPO EXTRA
    // ---------------------------
    if (id == "tiempo_extra") {
      onTimeAdded(10);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("+10 segundos agregados.")),
      );

      return {"success": true, "type": "time"};
    }

    // Si el ID no existe
    return {"success": false};
  }
}
