import 'package:flutter/material.dart';

class GameHUD extends StatelessWidget {
  final int coins;
  final VoidCallback onOpenComodines;
  final VoidCallback onOpenJefes;

  const GameHUD({
    super.key,
    required this.coins,
    required this.onOpenComodines,
    required this.onOpenJefes,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 420;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 12 : 18,
        vertical: isSmall ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1B0E2E).withOpacity(0.85),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            offset: const Offset(4, 4),
            blurRadius: 10,
          ),
          const BoxShadow(
            color: Color(0xFF2B1840),
            offset: Offset(-4, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ------------- MONEDAS -------------
          Row(
            children: [
              Icon(
                Icons.stars_rounded,
                color: const Color(0xFFFFD700),
                size: isSmall ? 22 : 28,
              ),
              const SizedBox(width: 6),
              Text(
                coins.toString(),
                style: TextStyle(
                  fontFamily: 'PressStart2P',
                  color: Colors.white,
                  fontSize: isSmall ? 10 : 14,
                  letterSpacing: 1.2,
                  shadows: const [
                    Shadow(color: Colors.amber, blurRadius: 10),
                  ],
                ),
              ),
            ],
          ),

          // ------------- COMODINES -------------
          GestureDetector(
            onTap: onOpenComodines,
            child: Row(
              children: [
                Icon(
                  Icons.flash_on,
                  color: const Color(0xFF00FFF0),
                  size: isSmall ? 18 : 26,
                ),
                const SizedBox(width: 4),
                Text(
                  "Comodines",
                  style: TextStyle(
                    fontFamily: 'VT323',
                    color: Colors.white,
                    fontSize: isSmall ? 16 : 18,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),

          // ------------- JEFES -------------
          GestureDetector(
            onTap: onOpenJefes,
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: const Color(0xFFFF4B82),
                  size: isSmall ? 18 : 26,
                ),
                const SizedBox(width: 4),
                Text(
                  "Jefes",
                  style: TextStyle(
                    fontFamily: 'VT323',
                    color: Colors.white,
                    fontSize: isSmall ? 16 : 18,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
