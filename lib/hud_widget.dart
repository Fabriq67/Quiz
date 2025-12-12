import 'package:flutter/material.dart';
import 'dart:async';

class GameHUD extends StatefulWidget {
  final int coins;
  final VoidCallback onOpenComodines;
  final VoidCallback onOpenJefes;
  final bool showNotification; // Controla si hay algo nuevo

  const GameHUD({
    super.key,
    required this.coins,
    required this.onOpenComodines,
    required this.onOpenJefes,
    this.showNotification = false,
  });

  @override
  State<GameHUD> createState() => _GameHUDState();
}

class _GameHUDState extends State<GameHUD> with SingleTickerProviderStateMixin {
  late AnimationController _blinkController;
  late Animation<Color?> _colorAnimation;
  bool _isBlinking = false;
  Timer? _stopTimer;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // Más rápido para llamar la atención
    )..repeat(reverse: true);

    // ✅ COLOR FOSFORESCENTE: De Cian a Magenta Neón
    _colorAnimation = ColorTween(
      begin: const Color(0xFF00FFF0), // Cian Neón
      end: const Color(0xFFFF00FF),   // Magenta Neón
    ).animate(_blinkController);

    _checkNotification();
  }

  @override
  void didUpdateWidget(covariant GameHUD oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showNotification != oldWidget.showNotification) {
      _checkNotification();
    }
  }

  void _checkNotification() {
    if (widget.showNotification) {
      setState(() => _isBlinking = true);
      
      // ✅ "SOLO POR UNOS SEGUNDOS": Se apaga solo a los 6 segundos
      _stopTimer?.cancel();
      _stopTimer = Timer(const Duration(seconds: 6), () {
        if (mounted) setState(() => _isBlinking = false);
      });
    } else {
      setState(() => _isBlinking = false);
      _stopTimer?.cancel();
    }
  }

  @override
  void dispose() {
    _blinkController.dispose();
    _stopTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 380;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 12,
        vertical: isSmall ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1B0E2E).withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          // Si está parpadeando, el borde también brilla
          color: _isBlinking ? _colorAnimation.value! : Colors.white.withOpacity(0.15),
          width: _isBlinking ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _isBlinking 
                ? _colorAnimation.value!.withOpacity(0.6) 
                : Colors.black.withOpacity(0.5),
            offset: const Offset(4, 4),
            blurRadius: _isBlinking ? 15 : 8, // Más brillo si hay notificación
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // ------------- MONEDAS -------------
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.stars_rounded,
                  color: const Color(0xFFFFD700),
                  size: isSmall ? 20 : 26,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.coins.toString(),
                  style: TextStyle(
                    fontFamily: 'PressStart2P',
                    color: Colors.white,
                    fontSize: isSmall ? 10 : 12,
                    letterSpacing: 1.0,
                    shadows: const [
                      Shadow(color: Colors.amber, blurRadius: 8),
                    ],
                  ),
                ),
              ],
            ),

            _buildSeparator(),

            // ------------- COMODINES (CON ANIMACIÓN) -------------
            GestureDetector(
              onTap: widget.onOpenComodines,
              child: AnimatedBuilder(
                animation: _blinkController,
                builder: (context, child) {
                  // Usamos el color animado solo si _isBlinking es true
                  final activeColor = _isBlinking 
                      ? _colorAnimation.value 
                      : const Color(0xFF00FFF0);
                  
                  final textColor = _isBlinking
                      ? _colorAnimation.value
                      : Colors.white;

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: _isBlinking ? BoxDecoration(
                      color: activeColor!.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6)
                    ) : null,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isBlinking ? Icons.notifications_active : Icons.flash_on,
                          color: activeColor,
                          size: isSmall ? 18 : 24,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Comodines",
                          style: TextStyle(
                            fontFamily: 'VT323',
                            color: textColor,
                            fontSize: isSmall ? 18 : 22,
                            letterSpacing: 0.5,
                            fontWeight: _isBlinking ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            _buildSeparator(),

            // ------------- CÓDICE / JEFES -------------
            GestureDetector(
              onTap: widget.onOpenJefes,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: const Color(0xFFFF4B82),
                    size: isSmall ? 18 : 24,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "Códice",
                    style: TextStyle(
                      fontFamily: 'VT323',
                      color: Colors.white,
                      fontSize: isSmall ? 18 : 22,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeparator() {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Colors.white.withOpacity(0.2),
    );
  }
}