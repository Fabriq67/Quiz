import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../data/progress_manager.dart';
import '../hud_widget.dart';
import '/comodines_screen.dart';
import 'percepcion_quiz_screen.dart';
import '/jefes_screen.dart';
import '../widgets/back_button_widget.dart';

class PercepcionMenuScreen extends StatefulWidget {
  const PercepcionMenuScreen({super.key});

  @override
  State<PercepcionMenuScreen> createState() => _PercepcionMenuScreenState();
}

class _PercepcionMenuScreenState extends State<PercepcionMenuScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  int coins = 0;

  Map<int, bool> unlocked = {1: true, 2: false};

  final List<Map<String, dynamic>> blocks = [
    {
      "id": 1,
      "title": "Bloque 1",
      "questions": 5,
      "isBoss": false,
      "color": Color(0xFF00FFF0),
    },
    {
      "id": 2,
      "title": "Bloque 2 (Jefe)",
      "questions": 10,
      "isBoss": true,
      "color": Color(0xFFFF3366),
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 6))
          ..repeat();

    _loadCoins();
    _loadUnlocks();
  }

  Future<void> _loadUnlocks() async {
    final u1 = await ProgressManager.isBlockUnlocked(1);
    final u2 = await ProgressManager.isBlockUnlocked(2);

    setState(() {
      unlocked[1] = u1;
      unlocked[2] = u2;
    });
  }

  Future<void> _loadCoins() async {
    final progress = await ProgressManager.loadProgress();
    setState(() => coins = progress.coins);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    // ASPECT RATIO DINÁMICO
    final double cardAspectRatio = (width < 420) ? 0.70 : 1.0;

    return Scaffold(
      backgroundColor: Color(0xFF150C25),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => CustomPaint(
              painter: _PercepcionBackgroundPainter(_controller.value),
              size: size,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 8),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: GameHUD(
                    coins: coins,
                    onOpenComodines: () =>
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => ComodinesScreen())),
                    onOpenJefes: () =>
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => JefesScreen())),
                  ),
                ),

                SizedBox(height: 24),

                Text(
                  "PERCEPCIÓN",
                  style: TextStyle(
                    fontFamily: 'PressStart2P',
                    color: Color(0xFF00FFF0),
                    fontSize: 18,
                    letterSpacing: 2,
                  ),
                ),

                SizedBox(height: 24),

                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.all(24),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: cardAspectRatio,
                    ),
                    itemCount: blocks.length,
                    itemBuilder: (context, index) {
                      final block = blocks[index];
                      final bool isUnlocked =
                          unlocked[block["id"]] ?? false;

                      return _PercepcionBlockCard(
                        title: block["title"],
                        questions: block["questions"],
                        isBoss: block["isBoss"],
                        color: block["color"],
                        locked: !isUnlocked,
                        onTap: () {
                          if (!isUnlocked) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              backgroundColor: Colors.redAccent,
                              content: Text(
                                "Debes completar el Bloque ${block["id"] - 1} primero.",
                                style: TextStyle(color: Colors.white),
                              ),
                            ));
                            return;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PercepcionQuizScreen(
                                blockId: block["id"],
                                totalQuestions: block["questions"],
                                isBoss: block["isBoss"],
                              ),
                            ),
                          ).then((_) => _loadUnlocks());
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 16, bottom: 16),
              child: RetroBackButton(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PercepcionBlockCard extends StatefulWidget {
  final String title;
  final int questions;
  final bool isBoss;
  final Color color;
  final bool locked;
  final VoidCallback onTap;

  const _PercepcionBlockCard({
    required this.title,
    required this.questions,
    required this.isBoss,
    required this.color,
    required this.locked,
    required this.onTap,
  });

  @override
  State<_PercepcionBlockCard> createState() => _PercepcionBlockCardState();
}

class _PercepcionBlockCardState extends State<_PercepcionBlockCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 430;
    final icon = widget.isBoss ? Icons.flash_on : Icons.visibility;
    final displayColor = widget.locked ? Colors.grey : widget.color;

    return MouseRegion(
      onEnter: (_) => !widget.locked ? setState(() => _hover = true) : null,
      onExit: (_) => !widget.locked ? setState(() => _hover = false) : null,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        height: isSmall ? 200 : 230,
        width: isSmall ? 170 : 200,
        decoration: BoxDecoration(
          color: Color(0xFF24133D).withOpacity(widget.locked ? 0.4 : 1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: displayColor, width: 2),
          boxShadow: [
            if (_hover && !widget.locked)
              BoxShadow(
                color: displayColor.withOpacity(0.8),
                blurRadius: 20,
                spreadRadius: 2,
              ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: widget.onTap,
          child: Padding(
            padding: EdgeInsets.all(isSmall ? 12 : 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: displayColor,
                  size: isSmall ? 40 : 55,
                ),

                SizedBox(height: isSmall ? 12 : 16),

                Text(
                  widget.title,
                  style: TextStyle(
                    fontFamily: 'PressStart2P',
                    fontSize: isSmall ? 11 : 14,
                    color: displayColor,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: isSmall ? 8 : 12),

                Text(
                  "${widget.questions} preguntas",
                  style: TextStyle(
                    fontFamily: 'VT323',
                    fontSize: isSmall ? 18 : 24,
                    color: Colors.white,
                  ),
                ),

                if (widget.locked)
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      "Bloque bloqueado",
                      style: TextStyle(
                        fontFamily: "VT323",
                        fontSize: isSmall ? 15 : 18,
                        color: Colors.redAccent,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PercepcionBackgroundPainter extends CustomPainter {
  final double progress;
  _PercepcionBackgroundPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF00FFF7).withOpacity(0.08)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 25) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    for (double x = 0; x < size.width; x += 25) {
      final offset =
          math.sin(progress * 2 * math.pi + x / 50) * 4;
      canvas.drawLine(
        Offset(x + offset, 0),
        Offset(x - offset, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
