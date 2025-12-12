import 'package:flutter/material.dart';
import '../models/powerup_model.dart';
import '../data/powerups_service.dart';
import '../data/progress_manager.dart';

class ComodinesScreen extends StatefulWidget {
  const ComodinesScreen({super.key});

  @override
  State<ComodinesScreen> createState() => _ComodinesScreenState();
}

class _ComodinesScreenState extends State<ComodinesScreen> {
  List<PowerUp> allPowerUps = [];
  List<String> unlockedIds = [];
  List<PowerUp> selected = [];

  @override
  void initState() {
    super.initState();
    _loadPowerUps();
    _markAsSeen(); // ✅ Apaga la luz del HUD al entrar
  }

  // ✅ Nueva función para apagar la notificación
  Future<void> _markAsSeen() async {
    await ProgressManager.saveBool("has_new_powerup", false);
  }

  Future<void> _loadPowerUps() async {
    final jsonList = await PowerUpsService.loadPowerUps();
    final progress = await ProgressManager.loadProgress();
    var selectedList = await ProgressManager.loadSelectedPowerUps();

    // ✅ LÓGICA NUEVA: Auto-seleccionar "Pulso Temporal" si la lista está vacía
    if (selectedList.isEmpty && jsonList.isNotEmpty) {
      try {
        final defaultPowerUp = jsonList.firstWhere(
          (p) => p.name.toLowerCase().contains("pulso"), // Busca "Pulso Temporal"
          orElse: () => jsonList.first, // O el primero que haya
        );

        // Solo lo seleccionamos si ya está desbloqueado (el primero suele estarlo)
        if (progress.unlockedPowerUps.contains(defaultPowerUp.id)) {
          selectedList = [defaultPowerUp];
          // Guardamos internamente para que la próxima vez ya aparezca
          await ProgressManager.saveSelectedPowerUps(selectedList);
        }
      } catch (e) {
        debugPrint("Error auto-seleccionando comodín: $e");
      }
    }

    setState(() {
      // ✅ ORDENAR POR PRECIO (ya viene ordenado de PowerUpsService)
      allPowerUps = jsonList;
      unlockedIds = progress.unlockedPowerUps;
      selected = selectedList;
    });
  }

  void toggle(PowerUp p) {
    if (!unlockedIds.contains(p.id)) return;

    setState(() {
      if (selected.any((s) => s.id == p.id)) {
        selected.removeWhere((s) => s.id == p.id);
      } else {
        // Si quieres que solo se seleccione uno a la vez, descomenta:
        // selected.clear();
        selected = [p];
      }
    });
  }

  Future<void> guardar() async {
    await ProgressManager.saveSelectedPowerUps(selected);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF150C25),
      appBar: AppBar(
        title: const Text(
          "Elige tu Comodín",
          // ✅ TAMAÑO ORIGINAL CONSERVADO
          style: TextStyle(fontFamily: "PressStart2P", fontSize: 10),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ✅ MOSTRAR EN ORDEN
          for (final p in allPowerUps) _buildPowerUpCard(p),

          const SizedBox(height: 30),

          ElevatedButton(
            onPressed: guardar,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00FFF0),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              "GUARDAR SELECCIÓN",
              // ✅ TAMAÑO ORIGINAL CONSERVADO
              style: TextStyle(fontFamily: "PressStart2P", fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPowerUpCard(PowerUp p) {
    final bool isUnlocked = unlockedIds.contains(p.id);
    // Comparación segura por ID
    final bool isSelected = selected.any((s) => s.id == p.id);

    return Opacity(
      opacity: isUnlocked ? 1 : 0.3,
      child: GestureDetector(
        onTap: () {
          if (isUnlocked) toggle(p);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 18), // ✅ MARGEN ORIGINAL
          padding: const EdgeInsets.all(16), // ✅ PADDING ORIGINAL
          decoration: BoxDecoration(
            color: const Color(0xFF24133D),
            borderRadius: BorderRadius.circular(18), // ✅ RADIO ORIGINAL
            border: Border.all(
              color: isSelected ? p.color : Colors.white24,
              width: isSelected ? 3 : 1,
            ),
          ),
          child: Row(
            children: [
              isUnlocked
                  ? (p.icon is IconData
                      ? Icon(
                          p.icon as IconData,
                          size: 40, // ✅ TAMAÑO ICONO ORIGINAL
                          color: p.color,
                        )
                      : Text(
                          p.icon.toString(),
                          style: TextStyle(
                            fontSize: 40, // ✅ TAMAÑO TEXTO ICONO ORIGINAL
                            color: p.color,
                          ),
                        ))
                  : const Icon(
                      Icons.lock,
                      size: 40, // ✅ TAMAÑO LOCK ORIGINAL
                      color: Colors.white38,
                    ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      style: TextStyle(
                        fontFamily: "PressStart2P",
                        fontSize: 11, // ✅ FUENTE ORIGINAL
                        color: isUnlocked ? p.color : Colors.white38,
                      ),
                    ),
                    const SizedBox(height: 6),

                    Text(
                      p.effect,
                      style: const TextStyle(
                        fontFamily: "VT323",
                        fontSize: 20, // ✅ FUENTE ORIGINAL
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}