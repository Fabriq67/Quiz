import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/powerup_model.dart'; // Asegúrate de que esta ruta sea correcta en tu proyecto
import '../services/cloud_service.dart'; // <--- AGREGA ESTO
// =============================================================
//   MODELO PRINCIPAL
// =============================================================
class PlayerProgress {
  int coins;
  int currentLevel;
  int currentBlock;

  List<String> unlockedPowerUps;
  List<String> selectedPowerUps;
  List<String> defeatedBosses;

  // 🔥 BLOQUES DE PERCEPCIÓN (NUMÉRICOS) Y OTROS
  List<String> unlockedBlocks;
  List<String> completedBlocks;

  // 🔥 NIVELES DESBLOQUEADOS (Categorías: percepcion, logica, etc)
  List<String> unlockedLevels;

  // 🎮 MODO LIBRE: SE ACTIVA AL COMPLETAR TODAS LAS CATEGORÍAS
  bool freeModePermanent; // Si es true, modo libre siempre disponible

  PlayerProgress({
    required this.coins,
    required this.currentLevel,
    required this.currentBlock,
    required this.unlockedPowerUps,
    required this.selectedPowerUps,
    required this.defeatedBosses,
    required this.unlockedBlocks,
    List<String>? completedBlocks,
    List<String>? unlockedLevels,
    bool? freeModePermanent,
  })  : completedBlocks = completedBlocks ?? [],
        unlockedLevels = unlockedLevels ?? ["percepcion"],
        freeModePermanent = freeModePermanent ?? false;

  Map<String, dynamic> toJson() => {
        'coins': coins,
        'currentLevel': currentLevel,
        'currentBlock': currentBlock,
        'unlockedPowerUps': unlockedPowerUps,
        'selectedPowerUps': selectedPowerUps,
        'defeatedBosses': defeatedBosses,
        'unlockedBlocks': unlockedBlocks,
        'completedBlocks': completedBlocks,
        'unlockedLevels': unlockedLevels,
        'freeModePermanent': freeModePermanent,
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
        unlockedLevels: List<String>.from(json['unlockedLevels'] ?? ["percepcion"]),
        freeModePermanent: json['freeModePermanent'] ?? false,
      );
}

// =============================================================
//   GESTOR DE PROGRESO
// =============================================================
class ProgressManager {
  static const _jsonKey = "playerProgress";

  // ✅ ORDEN CORRECTO: predeterminado primero
  static const List<String> allPowerUps = [
    "pulso_temporal",      // predeterminado (gratis al inicio)
    "sombra_cognitiva",    // jefe percepción
    "corte_mental",        // jefe lógica
    "clarividencia",       // jefe ciencia
  ];

  // -------------------------------------------------------------
  // LOAD / SAVE
  // -------------------------------------------------------------
  static Future<PlayerProgress> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_jsonKey);

    if (data == null) {
      return _getInitialProgress();
    }

    try {
      return PlayerProgress.fromJson(jsonDecode(data));
    } catch (_) {
      return _getInitialProgress();
    }
  }

  // Helper privado para el estado inicial
  static PlayerProgress _getInitialProgress() {
    return PlayerProgress(
      coins: 0,
      currentLevel: 1,
      currentBlock: 1,
      unlockedPowerUps: ["pulso_temporal"],
      selectedPowerUps: [], 
      defeatedBosses: [],
      unlockedBlocks: ["1", "science_1", "culture_1"],
      completedBlocks: [],
    );
  }

  // ✅ Método público para sobrescribir todo (Usado por la Nube)
  static Future<void> saveProgress(PlayerProgress p) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_jsonKey, jsonEncode(p.toJson()));

    // 🔥🔥 LA MAGIA: CADA VEZ QUE GUARDAS EN LOCAL, SE SUBE A LA NUBE 🔥🔥
    // No usamos 'await' aquí para que el juego no se trabe esperando internet
    CloudService().autoSave(); 
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
  // PERCEPCIÓN — BLOQUES
  // -------------------------------------------------------------
  static Future<bool> isBlockUnlocked(int id) async {
    final p = await loadProgress();
    return p.unlockedBlocks.contains(id.toString());
  }

  static Future<bool> isBlockCompleted(int id) async {
    final p = await loadProgress();
    return p.completedBlocks.contains(id.toString());
  }

  static Future<void> unlockBlock(int id) async {
    final p = await loadProgress();
    String key = id.toString();
    if (!p.unlockedBlocks.contains(key)) {
      p.unlockedBlocks.add(key);
    }
    await saveProgress(p);
  }

  static Future<void> completeBlock(int id) async {
    final p = await loadProgress();
    String key = id.toString();

    if (!p.completedBlocks.contains(key)) {
      p.completedBlocks.add(key);
    }

    p.unlockedBlocks.remove(key);

    String next = (id + 1).toString();
    if (!p.unlockedBlocks.contains(next)) {
      p.unlockedBlocks.add(next);
    }

    p.currentBlock = id + 1;

    await saveProgress(p);
  }

  // -------------------------------------------------------------
  // PERCEPCIÓN — REINICIO
  // -------------------------------------------------------------
  static Future<void> failBlock(int id) async {
    final p = await loadProgress();

    p.completedBlocks.clear();
    p.unlockedBlocks = ["1"];
    p.currentBlock = 1;

    await saveProgress(p);
  }

  // -------------------------------------------------------------
  // LÓGICA
  // -------------------------------------------------------------
  static Future<void> completeLogicBlock(int id) async {
    final p = await loadProgress();
    final key = "logica_$id";

    if (!p.completedBlocks.contains(key)) {
      p.completedBlocks.add(key);
    }

    await saveProgress(p);
  }

  static Future<bool> isLogicBlockCompleted(int id) async {
    final p = await loadProgress();
    return p.completedBlocks.contains("logica_$id");
  }

  static Future<bool> isLogicBlockUnlocked(int id) async {
    if (id == 1) return true;
    final p = await loadProgress();

    if (id == 2) return p.completedBlocks.contains("logica_1");
    if (id == 3) return p.completedBlocks.contains("logica_2");

    return false;
  }

  static Future<void> failLogicBlock(int id) async {
    final p = await loadProgress();
    p.completedBlocks.removeWhere((b) => b.startsWith("logica_"));
    p.unlockedBlocks.removeWhere((b) => b.startsWith("logica_"));
    if (!p.unlockedBlocks.contains("logica_1")) {
      p.unlockedBlocks.add("logica_1");
    }
    await saveProgress(p);
  }

  // -------------------------------------------------------------
  // CULTURA GENERAL
  // -------------------------------------------------------------
  static Future<bool> isCultureBlockUnlocked(int id) async {
    final p = await loadProgress();
    return p.unlockedBlocks.contains("culture_$id");
  }

  static Future<bool> isCultureBlockCompleted(int id) async {
    final p = await loadProgress();
    return p.completedBlocks.contains("culture_$id");
  }

  static Future<void> completeCultureBlock(int id) async {
    final p = await loadProgress();
    final key = "culture_$id";

    if (!p.completedBlocks.contains(key)) {
      p.completedBlocks.add(key);
    }

    if (id < 4) {
      final next = "culture_${id + 1}";
      if (!p.unlockedBlocks.contains(next)) {
        p.unlockedBlocks.add(next);
      }
    }
    await saveProgress(p);
  }

  static Future<void> unlockCultureBlock(int id) async {
    final p = await loadProgress();
    final key = "culture_$id";
    if (!p.unlockedBlocks.contains(key)) {
      p.unlockedBlocks.add(key);
    }
    await saveProgress(p);
  }

  static Future<void> failCultureBlock(int id) async {
    final p = await loadProgress();
    p.completedBlocks.removeWhere((e) => e.startsWith("culture_"));
    p.unlockedBlocks.removeWhere((e) => e.startsWith("culture_"));
    p.unlockedBlocks.add("culture_1");
    await saveProgress(p);
  }

  // -------------------------------------------------------------
  // CIENCIA Y TECNOLOGÍA
  // -------------------------------------------------------------
  static Future<bool> isScienceBlockUnlocked(int id) async {
    final p = await loadProgress();
    return p.unlockedBlocks.contains("science_$id");
  }

  static Future<bool> isScienceBlockCompleted(int id) async {
    final p = await loadProgress();
    return p.completedBlocks.contains("science_$id");
  }

  static Future<void> completeScienceBlock(int id) async {
    final p = await loadProgress();
    final key = "science_$id";

    if (!p.completedBlocks.contains(key)) {
      p.completedBlocks.add(key);
    }

    final next = "science_${id + 1}";
    if (!p.unlockedBlocks.contains(next)) {
      p.unlockedBlocks.add(next);
    }
    await saveProgress(p);
  }

  static Future<void> unlockScienceBlock(int id) async {
    final p = await loadProgress();
    final key = "science_$id";
    if (!p.unlockedBlocks.contains(key)) {
      p.unlockedBlocks.add(key);
    }
    await saveProgress(p);
  }

  static Future<void> failScienceBlock(int id) async {
    final p = await loadProgress();
    p.completedBlocks.removeWhere((e) => e.startsWith("science_"));
    p.unlockedBlocks.removeWhere((e) => e.startsWith("science_"));
    p.unlockedBlocks.add("science_1");
    await saveProgress(p);
  }

  // -------------------------------------------------------------
  // POWERUPS & BOSS
  // -------------------------------------------------------------
  static Future<void> defeatBoss(String id) async {
    final p = await loadProgress();

    if (!p.defeatedBosses.contains(id)) {
      p.defeatedBosses.add(id);
    }

    String? powerUpToUnlock;
    String? levelToUnlock;

    switch (id) {
      case "boss_percepcion":
        powerUpToUnlock = "sombra_cognitiva";
        levelToUnlock = "logica";
        if (!p.unlockedBlocks.contains("logica_1")) {
          p.unlockedBlocks.add("logica_1");
        }
        break;
      case "boss_logica":
        powerUpToUnlock = "corte_mental";
        levelToUnlock = "ciencia";
        if (!p.unlockedBlocks.contains("science_1")) {
          p.unlockedBlocks.add("science_1");
        }
        break;
      case "boss_ciencia":
        powerUpToUnlock = "clarividencia";
        levelToUnlock = "cultura";
        if (!p.unlockedBlocks.contains("culture_1")) {
          p.unlockedBlocks.add("culture_1");
        }
        break;
      default:
        break;
    }

    if (powerUpToUnlock != null && !p.unlockedPowerUps.contains(powerUpToUnlock)) {
      p.unlockedPowerUps.add(powerUpToUnlock);
    }

    if (levelToUnlock != null && !p.unlockedLevels.contains(levelToUnlock)) {
      p.unlockedLevels.add(levelToUnlock);
    }

    await saveProgress(p);
  }

  static Future<void> unlockPowerUp(String id) async {
    final p = await loadProgress();
    if (!p.unlockedPowerUps.contains(id)) {
      p.unlockedPowerUps.add(id);
    }
    await saveProgress(p);
  }

  static Future<List<PowerUp>> loadSelectedPowerUps() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString("selectedPowerUps_full");

    if (raw != null) {
      try {
        final list = (jsonDecode(raw) as List)
            .map((e) => PowerUp.fromJson(Map<String, dynamic>.from(e)))
            .where((pu) => pu.id.isNotEmpty)
            .toList();
        if (list.isNotEmpty) return list;
      } catch (_) {}
    }

    final p = await loadProgress();
    if (p.selectedPowerUps.isEmpty) return [];

    p.selectedPowerUps.removeWhere((e) => e.isEmpty);
    return p.selectedPowerUps
        .map((id) => PowerUp.fromJson({'id': id}))
        .toList();
  }

  static Future<void> saveSelectedPowerUps(List<PowerUp> list) async {
    final prefs = await SharedPreferences.getInstance();
    final p = await loadProgress();

    final valid = list.where((pu) => p.unlockedPowerUps.contains(pu.id)).toList();

    prefs.setString(
      "selectedPowerUps_full",
      jsonEncode(valid.map((e) => e.toJson()).toList()),
    );

    p.selectedPowerUps = valid.map((e) => e.id).toList();
    await saveProgress(p);
  }

  static Future<bool> isBossDefeated(String id) async {
    final p = await loadProgress();
    return p.defeatedBosses.contains(id);
  }

  // -------------------------------------------------------------
  // OTROS
  // -------------------------------------------------------------
  static Future<bool> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  static Future<void> saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  static Future<void> unlockLevel(String id) async {
    final p = await loadProgress();
    if (!p.unlockedLevels.contains(id)) {
      p.unlockedLevels.add(id);
    }
    await saveProgress(p);
  }

  static Future<bool> isLevelUnlocked(String id) async {
    final p = await loadProgress();
    return p.unlockedLevels.contains(id);
  }

  // ========================================================
  // MODO LIBRE (ARCADE MODE)
  // ========================================================
  
  /// Detecta si el jugador completó el juego completo:
  /// - Percepción: 2 bloques completados
  /// - Lógica: 3 bloques completados
  /// - Cultura: 4 bloques completados
  /// - Ciencia: 3 bloques completados
  static Future<bool> isGameCompleted() async {
    final percepcion1 = await isBlockCompleted(1);
    final percepcion2 = await isBlockCompleted(2);
    
    final logica1 = await isLogicBlockCompleted(1);
    final logica2 = await isLogicBlockCompleted(2);
    final logica3 = await isLogicBlockCompleted(3);
    
    final cultura1 = await isCultureBlockCompleted(1);
    final cultura2 = await isCultureBlockCompleted(2);
    final cultura3 = await isCultureBlockCompleted(3);
    final cultura4 = await isCultureBlockCompleted(4);
    
    final ciencia1 = await isScienceBlockCompleted(1);
    final ciencia2 = await isScienceBlockCompleted(2);
    final ciencia3 = await isScienceBlockCompleted(3);

    return percepcion1 &&
        percepcion2 &&
        logica1 &&
        logica2 &&
        logica3 &&
        cultura1 &&
        cultura2 &&
        cultura3 &&
        cultura4 &&
        ciencia1 &&
        ciencia2 &&
        ciencia3;
  }

  /// Activa permanentemente el modo libre
  static Future<void> unlockFreeMode() async {
    final p = await loadProgress();
    p.freeModePermanent = true;
    await saveProgress(p);
  }

  /// Verifica si el modo libre está activo
  static Future<bool> isFreeModeUnlocked() async {
    final p = await loadProgress();
    return p.freeModePermanent;
  }

  static Future<void> resetAll({int coins = 0}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    final p = _getInitialProgress();
    p.coins = coins;
    await saveProgress(p);
  }
}