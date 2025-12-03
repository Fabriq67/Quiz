import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/powerup_model.dart';

class PowerUpsService {
  static Future<List<PowerUp>> loadPowerUps() async {
    final raw = await rootBundle.loadString("assets/powerups.json");
    final List data = json.decode(raw);

    return data.map((p) => PowerUp.fromJson(p)).toList();
  }
}
