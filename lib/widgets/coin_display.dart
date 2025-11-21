import 'package:flutter/material.dart';

class CoinDisplay extends StatelessWidget {
  final int coins;
  final double size;

  const CoinDisplay({super.key, required this.coins, this.size = 26});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.monetization_on,
          color: Colors.amberAccent,
          size: size,
          shadows: [
            const Shadow(color: Colors.yellow, blurRadius: 12),
          ],
        ),
        const SizedBox(width: 6),
        Text(
          coins.toString(),
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'VT323',
            fontSize: size,
            shadows: [
              const Shadow(color: Colors.yellowAccent, blurRadius: 8),
            ],
          ),
        ),
      ],
    );
  }
}
