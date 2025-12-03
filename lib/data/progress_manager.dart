import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/powerup_model.dart';

class PlayerProgress {
  int coins;
  int currentLevel;
  int currentBlock;

  List<String> unlockedPowerUps;
  List<String> selectedPowerUps;
  List<String> defeatedBosses;
  List<String> unlockedBlocks;
  List<String> completedBlocks;

  PlayerProgress({
    required this.coins,
    required this.currentLevel,
    required this.currentBlock,
    required this.unlockedPowerUps,
    required this.selectedPowerUps,
    required this.defeatedBosses,
    required this.unlockedBlocks,
    List<String>? completedBlocks,
  }) : completedBlocks = completedBlocks ?? [];

  Map<String, dynamic> toJson() => {
        'coins': coins,
        'currentLevel': currentLevel,
        'currentBlock': currentBlock,
        'unlockedPowerUps': unlockedPowerUps,
        'selectedPowerUps': selectedPowerUps,
        'defeatedBosses': defeatedBosses,
        'unlockedBlocks': unlockedBlocks,
        'completedBlocks': completedBlocks,
      };

  factory PlayerProgress.fromJson(Map<String, dynamic> json) => PlayerProgress(
        coins: json['coins'] ?? 0,
        currentLevel: json['currentLevel'] ?? 1,
        currentBlock: json['currentBlock'] ?? 1,
        unlockedPowerUps: List<String>.from(json['unlockedPowerUps'] ?? []),
        selectedPowerUps: List<String>.from(json['selectedPowerUps'] ?? []),
        defeatedBosses: List<String>.from(json['defeatedBosses'] ?? []),
        unlockedBlocks: List<String>.from(json['unlockedBlocks'] ?? ["1"]),
        completedBlocks: List<String>.from(json['completedBlocks'] ?? []),
      );
}

class ProgressManager {
  static const _jsonKey = "playerProgress";

  // Orden real de desbloqueo
  static const List<String> allPowerUps = [
    "clarividencia",      // desbloqueado desde el inicio
    "corte_mental",       // jefe 1
    "pulso_temporal",     // jefe 2
    "sombra_cognitiva",   // jefe 3
  ];

  // -------------------------------------------------------------
  // LOAD / SAVE
  // -------------------------------------------------------------
  static Future<PlayerProgress> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_jsonKey);

    if (data == null) {
      return PlayerProgress(
        coins: 0,
        currentLevel: 1,
        currentBlock: 1,
        unlockedPowerUps: ["clarividencia"],
        selectedPowerUps: ["clarividencia"],
        defeatedBosses: [],
        unlockedBlocks: ["1"],
        completedBlocks: [],
      );
    }

    try {
      return PlayerProgress.fromJson(jsonDecode(data));
    } catch (_) {
      return PlayerProgress(
        coins: 0,
        currentLevel: 1,
        currentBlock: 1,
        unlockedPowerUps: ["clarividencia"],
        selectedPowerUps: ["clarividencia"],
        defeatedBosses: [],
        unlockedBlocks: ["1"],
        completedBlocks: [],
      );
    }
  }

  static Future<void> saveProgress(PlayerProgress p) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_jsonKey, jsonEncode(p.toJson()));
  }

  // -------------------------------------------------------------
  // COINS
  // -------------------------------------------------------------
  static Future<void> addCoins(int amount) async {
    final p = await loadProgress();
    p.coins = (p.coins + amount).clamp(0, 999999);
    await saveProgress(p);
  }

  // -------------------------------------------------------------
  // BLOCKS
  // -------------------------------------------------------------
  static Future<bool> isBlockUnlocked(int id) async {
    final p = await loadProgress();
    return p.unlockedBlocks.contains(id.toString());
  }

  static Future<bool> isBlockCompleted(int id) async {
    final p = await loadProgress();
    return p.completedBlocks.contains(id.toString());
  }

  static Future<bool> isBlockPlayable(int id) async {
    final p = await loadProgress();
    final key = id.toString();
    return p.unlockedBlocks.contains(key) && !p.completedBlocks.contains(key);
  }

  static Future<void> unlockBlock(int id) async {
    final p = await loadProgress();
    final key = id.toString();
    if (!p.unlockedBlocks.contains(key)) {
      p.unlockedBlocks.add(key);
      await saveProgress(p);
    }
  }

  static Future<void> lockBlock(int id) async {
    final p = await loadProgress();
    final key = id.toString();
    p.unlockedBlocks.remove(key);
    p.completedBlocks.remove(key);
    await saveProgress(p);
  }

  static Future<void> completeBlock(int id) async {
    final p = await loadProgress();
    final key = id.toString();

    if (!p.completedBlocks.contains(key)) {
      p.completedBlocks.add(key);
    }

    // No rejugabilidad
    p.unlockedBlocks.remove(key);

    // desbloquea siguiente
    final next = (id + 1).toString();
    if (!p.unlockedBlocks.contains(next)) {
      p.unlockedBlocks.add(next);
    }

    p.currentBlock = id + 1;

    await saveProgress(p);
  }

  // -------------------------------------------------------------
  // RESET DE NIVEL
  // -------------------------------------------------------------
  static Future<void> failBlock(int id, {int maxBlocks = 20}) async {
    final p = await loadProgress();

    p.unlockedBlocks.remove(id.toString());
    p.completedBlocks.clear();
    p.unlockedBlocks = ["1"];
    p.currentBlock = 1;

    // reset powerups (solo clarividencia)
    p.unlockedPowerUps = ["clarividencia"];
    p.selectedPowerUps = ["clarividencia"];

    await saveBool("percepcion_reset", true);
    await saveProgress(p);
  }

  static Future<void> resetPercepcionProgress({int maxBlocks = 20}) async {
    final p = await loadProgress();

    p.currentBlock = 1;
    p.unlockedBlocks = ["1"];
    p.completedBlocks.clear();

    p.unlockedPowerUps = ["clarividencia"];
    p.selectedPowerUps = ["clarividencia"];

    await saveBool("percepcion_reset", true);
    await saveProgress(p);
  }

  // -------------------------------------------------------------
  // BOSS → DESBLOQUEAR COMODÍN
  // -------------------------------------------------------------
  static Future<void> defeatBoss(String id) async {
    final p = await loadProgress();

    if (!p.defeatedBosses.contains(id)) {
      p.defeatedBosses.add(id);
    }

    final index = p.defeatedBosses.length; // 1,2,3...

    if (index < allPowerUps.length) {
      final unlockId = allPowerUps[index];
      if (!p.unlockedPowerUps.contains(unlockId)) {
        p.unlockedPowerUps.add(unlockId);
      }
    }

    await saveProgress(p);
  }

  static Future<bool> isBossDefeated(String id) async {
    final p = await loadProgress();
    return p.defeatedBosses.contains(id);
  }

  // -------------------------------------------------------------
  // FLAGS
  // -------------------------------------------------------------
  static Future<bool> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  static Future<void> saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  // -------------------------------------------------------------
  // SELECTED POWERUPS
  // -------------------------------------------------------------
  static Future<void> saveSelectedPowerUps(List<PowerUp> list) async {
    final prefs = await SharedPreferences.getInstance();
    final p = await loadProgress();

    // filtrar solo powerups realmente desbloqueados
    final valid = list.where((pu) => p.unlockedPowerUps.contains(pu.id)).toList();

    // guardar JSON completo
    await prefs.setString(
      "selectedPowerUps_full",
      jsonEncode(valid.map((e) => e.toJson()).toList()),
    );

    // guardar solo IDs
    p.selectedPowerUps = valid.map((e) => e.id).toList();

    await saveProgress(p);
  }

  // ---------------------------------------------------------
// DESBLOQUEAR COMODÍN POR ID
// ---------------------------------------------------------
static Future<void> unlockPowerUp(String id) async {
  final p = await loadProgress();

  // ya está desbloqueado
  if (!p.unlockedPowerUps.contains(id)) {
    p.unlockedPowerUps.add(id);
  }

  // si no está en la selección, no lo activamos automáticamente
  await saveProgress(p);
}


  static Future<List<PowerUp>> loadSelectedPowerUps() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString("selectedPowerUps_full");

    if (saved != null) {
      try {
        final decoded = jsonDecode(saved) as List<dynamic>;
        return decoded
            .map<PowerUp>((e) => PowerUp.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } catch (_) {}
    }

    // fallback minimal
    final p = await loadProgress();
    final list = <PowerUp>[];

    for (final id in p.selectedPowerUps) {
      try {
        list.add(PowerUp.fromJson({'id': id}));
      } catch (_) {}
    }

    return list;
  }

  // -------------------------------------------------------------
  // RESET TOTAL (debug)
  // -------------------------------------------------------------
  static Future<void> resetAll({int coins = 0}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    final p = PlayerProgress(
      coins: coins,
      currentLevel: 1,
      currentBlock: 1,
      unlockedPowerUps: ["clarividencia"],
      selectedPowerUps: ["clarividencia"],
      defeatedBosses: [],
      unlockedBlocks: ["1"],
      completedBlocks: [],
    );

    await saveProgress(p);
    await prefs.remove("selectedPowerUps_full");
 
  }

  
}
