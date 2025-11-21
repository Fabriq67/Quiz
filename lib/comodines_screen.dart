import 'package:flutter/material.dart';

class ComodinesScreen extends StatelessWidget {
  const ComodinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF140B24),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Comodines Desbloqueados"),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          "Aquí se mostrarán tus comodines y sus efectos.",
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
