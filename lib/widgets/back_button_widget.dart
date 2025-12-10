import 'package:flutter/material.dart';

class RetroBackButton extends StatelessWidget {
  const RetroBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final navigator = Navigator.of(context, rootNavigator: true);
        if (navigator.canPop()) {
          navigator.pop();
        } else {
          // Opcional: puedes mostrar un mensaje si no hay nada que cerrar
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(content: Text("No hay pantalla anterior.")),
          // );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF24133D),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.cyanAccent, width: 2),
        ),
        child: const Icon(
          Icons.arrow_back,
          color: Colors.cyanAccent,
        ),
      ),
    );
  }
}
