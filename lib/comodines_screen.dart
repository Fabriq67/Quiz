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
  }

  Future<void> _loadPowerUps() async {
    final jsonList = await PowerUpsService.loadPowerUps();
    final progress = await ProgressManager.loadProgress();

    setState(() {
      allPowerUps = jsonList;
      unlockedIds = progress.unlockedPowerUps; // ["clarividencia", ...]
    });

    // cargar selección previa
    final selectedList = await ProgressManager.loadSelectedPowerUps();
    setState(() => selected = selectedList);
  }

  void toggle(PowerUp p) {
    if (!unlockedIds.contains(p.id)) return; // bloqueado → no tocar

    setState(() {
      if (selected.contains(p)) {
        selected.remove(p);
      } else {
        selected = [p]; // solo 1 comodín equipado
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
          style: TextStyle(fontFamily: "PressStart2P", fontSize: 10),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          for (final p in allPowerUps)
            _buildPowerUpCard(p),

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
              style: TextStyle(fontFamily: "PressStart2P", fontSize: 12),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPowerUpCard(PowerUp p) {
    final bool isUnlocked = unlockedIds.contains(p.id);
    final bool isSelected = selected.contains(p);

    return Opacity(
      opacity: isUnlocked ? 1 : 0.3, // bloqueados casi grises
      child: GestureDetector(
        onTap: () {
          if (isUnlocked) toggle(p);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 18),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF24133D),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? p.color : Colors.white24,
              width: isSelected ? 3 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isUnlocked ? p.icon : Icons.lock,
                color: isUnlocked ? p.color : Colors.white38,
                size: 40,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  p.name,
                  style: TextStyle(
                    fontFamily: "PressStart2P",
                    fontSize: 11,
                    color: isUnlocked ? p.color : Colors.white38,
                  ),
                ),
              ),
              Text(
                "${p.price}",
                style: TextStyle(
                  color: isUnlocked ? p.color : Colors.white38,
                  fontFamily: "PressStart2P",
                  fontSize: 12,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
