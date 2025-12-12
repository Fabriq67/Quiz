import 'package:flutter/material.dart';
import '../models/powerup_model.dart';
import '../data/progress_manager.dart';
import '../models/pregunta_model.dart';

class PowerUpEffects {
  // ✅ Variable para controlar el tiempo (Anti-Spam de 3 segundos)
  static DateTime? _lastActionTime;

  static Future<void> apply({
    required BuildContext context,
    required PowerUp powerUp,
    required Pregunta pregunta,
    required Function(String) setHint,
    required Function(List<String>) hideSpecificOptions,
    required Function(int) addExtraSeconds,
    required Function refreshCoins,
    required Set<String> usedPowerUps,
  }) async {
    
    // ---------------------------------------------------------
    // ✅ 1. BLOQUEO DE TIEMPO (Debounce de 3 Segundos)
    // ---------------------------------------------------------
    final now = DateTime.now();
    if (_lastActionTime != null && 
        now.difference(_lastActionTime!) < const Duration(seconds: 3)) {
      return; // ⛔ Si pasaron menos de 3 seg, ignoramos el toque.
    }
    _lastActionTime = now; // Guardamos el momento de este toque

    // Limpiamos mensajes viejos para que no se acumulen
    ScaffoldMessenger.of(context).clearSnackBars(); 

    // ---------------------------------------------------------
    // LÓGICA ORIGINAL (INTACTA)
    // ---------------------------------------------------------
    
    final String id = powerUp.id;
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