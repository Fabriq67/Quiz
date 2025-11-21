import 'package:flutter/material.dart';

class JefesScreen extends StatelessWidget {
  const JefesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF140B24),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Jefes Derrotados"),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          "Aquí verás los jefes vencidos y los que faltan.",
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
