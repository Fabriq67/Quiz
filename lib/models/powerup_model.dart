import 'package:flutter/material.dart';

class PowerUp {
  final String id;
  final IconData icon;
  final String name;
  final int price;
  final String effect;
  final Color color;

  PowerUp({
    required this.id,
    required this.icon,
    required this.name,
    required this.price,
    required this.effect,
    required this.color,
  });

  factory PowerUp.fromJson(Map<String, dynamic> json) {
    return PowerUp(
      id: json["id"],
      icon: Icons.visibility, // único por ahora
      name: json["name"],
      price: json["price"],      // <-- AQUI
      effect: json["effect"],
      color: const Color(0xFF00FFF0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "price": price,
      "effect": effect,
    };
  }
}
