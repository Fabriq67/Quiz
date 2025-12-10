import 'package:flutter/material.dart';

class PowerUp {
  final String id;
  final String name;
  final String effect;
  final int price;
  final Object icon; // can be String (emoji) or IconData
  final Color color;

  PowerUp({
    required this.id,
    required this.name,
    required this.effect,
    required this.price,
    required this.icon,
    required this.color,
  });

  // ------------------------------
  // FACTORY SEGURO DESDE JSON
  // ------------------------------
  factory PowerUp.fromJson(Map<String, dynamic> json) {
    final rawId = json["id"];

    // Si el id viene null → asignamos uno por defecto
    final id = rawId?.toString() ?? "clarividencia";

    return PowerUp(
      id: id,
      name: json["name"]?.toString() ?? id,
      effect: json["effect"]?.toString() ?? "",
      price: json["price"] is int ? json["price"] : 0,
      icon: json["icon"]?.toString() ?? "⭐",
      color: _safeColor(json["color"]),
    );
  }

  // ---------------------
  // COLOR SEGURO
  // ---------------------
  static Color _safeColor(dynamic value) {
    if (value == null) return Colors.white;
    try {
      return Color(int.parse(value.toString(), radix: 16));
    } catch (_) {
      return Colors.white;
    }
  }

  // ---------------------
  // SERIALIZAR A JSON
  // ---------------------
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "effect": effect,
      "price": price,
      "icon": icon.toString(),
      "color": color.value.toRadixString(16),
    };
  }
}
