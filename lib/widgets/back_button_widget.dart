import 'package:flutter/material.dart';

class RetroBackButton extends StatelessWidget {
  const RetroBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GestureDetector(
            onTap: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
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
          ),
        ),
      ),
    );
  }
}
