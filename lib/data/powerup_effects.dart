import 'package:flutter/material.dart';
import '../models/powerup_model.dart';
import '../data/progress_manager.dart';
import '../models/pregunta_model.dart';

class PowerUpEffects {
  static Future<void> apply({
    required BuildContext context,
    required PowerUp powerUp,
    required Pregunta pregunta,
    required Function(String) setHint,
    required Function(List<String>) hideSpecificOptions, // ← FIX
    required Function(int) addExtraSeconds,
    required Function refreshCoins,
    required Set<String> usedPowerUps, // ← FIX también debe ser String
  }) async {
    
    final String id = powerUp.id; // ahora es String
    final int cost = powerUp.price;

    // 1. Ya usado
    if (usedPowerUps.contains(id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Comodín ya usado.")),
      );
      return;
    }

    // 2. Revisar monedas
    final progress = await ProgressManager.loadProgress();
    if (progress.coins < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No tienes suficientes monedas.")),
      );
      return;
    }

    // 3. Restar monedas
    await ProgressManager.addCoins(-cost);
    await refreshCoins();

    usedPowerUps.add(id);

    // 4. Aplicar efectos
    switch (id) {
      case "clarividencia":
        setHint(pregunta.correcta);
        break;

      case "corte_mental":
        final incorrectas = pregunta.opciones
            .where((o) => o != pregunta.correcta)
            .toList();

        incorrectas.shuffle();
        final remove = incorrectas.take(2).toList();

        hideSpecificOptions(remove);
        break;

      case "pulso_temporal":
        addExtraSeconds(10);
        break;

            case "sombra_cognitiva":
        final incorrectas = pregunta.opciones
            .where((o) => o != pregunta.correcta)
            .toList();

        incorrectas.shuffle();
        final ocultar = incorrectas.take(1).toList(); // ✅ Solo oculta 1

        hideSpecificOptions(ocultar);
        break;

      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Comodín no válido.")),
        );
    }
  }
}
