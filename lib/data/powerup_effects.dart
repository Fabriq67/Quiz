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
    required Function hideOptions,
    required Function addTime,
    required Function refreshCoins,
    required Set<int> usedPowerUps,
  }) async {

    final int id = powerUp.id;     // TU POWERUP TIENE ID INT
    final int cost = powerUp.price; // Y PRICE INT — PERFECTO

    // 1. Ya usado
    if (usedPowerUps.contains(id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Comodín ya usado.")),
      );
      return;
    }

    // 2. Suficientes monedas
    final progress = await ProgressManager.loadProgress();
    if (progress.coins < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No tienes suficientes monedas.")),
      );
      return;
    }

    // 3. Restar costo
    await ProgressManager.addCoins(-cost);
    await refreshCoins();

    // Registrar que ya se usó
    usedPowerUps.add(id);

    // 4. Aplicar efecto
    switch (id) {
      case 1: // Clarividencia
        setHint(pregunta.correcta);
        break;

      case 2: // 50-50
        hideOptions();
        break;

      case 3: // Tiempo extra
        addTime();
        break;

      case 4: // Refresh (monedas)
        await refreshCoins();
        break;

      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Comodín no válido.")),
        );
        break;
    }
  }
}
