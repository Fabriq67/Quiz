import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PlayerProgress {
  int coins;
  int currentLevel;
  int currentBlock;
  List<String> unlockedPowerUps;
  List<String> defeatedBosses;
  static const String keyBlock1 = "block1";
  static const String keyBlock2 = "block2";

  PlayerProgress({
    required this.coins,
    required this.currentLevel,
    required this.currentBlock,
    required this.unlockedPowerUps,
    required this.defeatedBosses,
  });

  Map<String, dynamic> toJson() => {
        'coins': coins,
        'currentLevel': currentLevel,
        'currentBlock': currentBlock,
        'unlockedPowerUps': unlockedPowerUps,
        'defeatedBosses': defeatedBosses,
      };

  factory PlayerProgress.fromJson(Map<String, dynamic> json) => PlayerProgress(
        coins: json['coins'],
        currentLevel: json['currentLevel'],
        currentBlock: json['currentBlock'],
        unlockedPowerUps: List<String>.from(json['unlockedPowerUps'] ?? []),
        defeatedBosses: List<String>.from(json['defeatedBosses'] ?? []),
      );
}

class ProgressManager {
  static Future<PlayerProgress> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('playerProgress');
    if (data == null) {
      return PlayerProgress(
        coins: 0,
        currentLevel: 0,
        currentBlock: 0,
        unlockedPowerUps: [],
        defeatedBosses: [],
      );
    }
    return PlayerProgress.fromJson(jsonDecode(data));
  }

   static Future<void> unlockBlock(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("block_$id", true);
  }

  static Future<void> saveProgress(PlayerProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('playerProgress', jsonEncode(progress.toJson()));
  }

  static Future<void> addCoins(int amount) async {
    final progress = await loadProgress();
    progress.coins += amount;
    await saveProgress(progress);
  }

  static Future<void> spendCoins(int amount) async {
    final progress = await loadProgress();
    if (progress.coins >= amount) {
      progress.coins -= amount;
      await saveProgress(progress);
    }
  }

  static Future<bool> isBlockUnlocked(int id) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("block_$id") ?? (id == 1 ? true : false);
  }

  static Future<bool> wasTutorialShown(String key) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(key) ?? false;
}

static Future<void> setTutorialShown(String key) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(key, true);
}

  static Future<void> saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  /// Obtiene un valor booleano guardado
  static Future<bool?> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

}
