import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'hud_widget.dart';
import 'comodines_screen.dart';
import 'jefes_screen.dart';
import '../data/progress_manager.dart';
import 'screens/percepcion_menu.dart';
import '../widgets/back_button_widget.dart';

class PurgatorioScreen extends StatefulWidget {
  const PurgatorioScreen({super.key});

  @override
  State<PurgatorioScreen> createState() => _PurgatorioScreenState();
}

class _PurgatorioScreenState extends State<PurgatorioScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  int coins = 0;
  bool _tutorialShown = false;

  final blocks = [
    {
      "title": "PERCEPCIÓN",
      "desc": "Ve más allá de lo evidente.",
      "icon": Icons.visibility,
      "color": Color(0xFF00FFF0),
      "available": true,
    },
    {
      "title": "LÓGICA",
      "desc": "Completa 'Percepción' para desbloquear este nivel.",
      "icon": Icons.extension,
      "color": Color(0xFF4C6FFF),
      "available": false,
    },
    {
      "title": "MEMORIA",
      "desc": "Completa 'Lógica' para desbloquear este nivel.",
      "icon": Icons.memory,
      "color": Color(0xFFFFD700),
      "available": false,
    },
    {
      "title": "CIENCIA Y TECNOLOGÍA",
      "desc": "Completa 'Memoria' para acceder aquí.",
      "icon": Icons.science,
      "color": Color(0xFF32CD32),
      "available": false,
    },
    {
      "title": "CULTURA GENERAL",
      "desc": "Completa 'Ciencia y Tecnología' para desbloquear.",
      "icon": Icons.public,
      "color": Color(0xFFFFA500),
      "available": false,
    },
    {
      "title": "JUICIO CRÍTICO",
      "desc": "Completa todos los niveles para acceder al juicio final.",
      "icon": Icons.flash_on,
      "color": Color(0xFFFF4B82),
      "available": false,
    },
  ];

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 5))
          ..repeat();

    _loadCoins();
    _loadTutorialState();
  }

  Future<void> _loadCoins() async {
    final progress = await ProgressManager.loadProgress();
    setState(() => coins = progress.coins);
  }

  /// 🔄 Actualiza las monedas cuando vuelves del quiz
  void _refreshCoins() async {
    final progress = await ProgressManager.loadProgress();
    setState(() => coins = progress.coins);
  }

  /// 📌 Cargar si el tutorial ya fue mostrado
  Future<void> _loadTutorialState() async {
    _tutorialShown =
        await ProgressManager.getBool("tutorial_purgatorio_shown") ?? false;

    if (!_tutorialShown) {
      Future.delayed(
        Duration(milliseconds: 500),
        () => _showPurgatorioTutorial(),
      );
    }
  }

  /// 📌 Guardar que el tutorial ya se vio
  Future<void> _setTutorialSeen() async {
    await ProgressManager.saveBool("tutorial_purgatorio_shown", true);
  }

  /// 🪧 Ventana de tutorial
  void _showPurgatorioTutorial() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Center(
          child: Container(
            width: 360,
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Color(0xFF2B1E40),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Color(0xFF00FFF0), width: 3),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF00FFF0).withOpacity(0.4),
                  blurRadius: 25,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "BIENVENIDO",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "PressStart2P",
                    fontSize: 16,
                    color: Color(0xFFFF4B82),
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Color(0xFF00FFF0),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Este es el PURGATORIO MENTAL.\n\n"
                  "Escoge PERCEPCIÓN para iniciar tu aventura.\n\n"
                  "Cada nivel desbloquea el siguiente.\n\n"
                  "¡Buena suerte!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "VT323",
                    fontSize: 26,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    _setTutorialSeen();
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    decoration: BoxDecoration(
                      color: Color(0xFFFF4B82),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Color(0xFF00FFF0), width: 2),
                    ),
                    child: Text(
                      "ENTRAR",
                      style: TextStyle(
                        fontFamily: "PressStart2P",
                        fontSize: 14,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 🧠 UI PRINCIPAL
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final small = size.width < 450;

    return Scaffold(
      backgroundColor: Color(0xFF1B0E2E),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) =>
                CustomPaint(painter: PurgatorioBackgroundPainter(_controller.value)),
          ),

          SafeArea(
            child: Column(
              children: [
                /// ⭐ HUD CON MONEDAS
                GameHUD(
                  coins: coins,
                  onOpenComodines: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ComodinesScreen()),
                  ).then((_) => _refreshCoins()),

                  onOpenJefes: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => JefesScreen()),
                  ).then((_) => _refreshCoins()),
                ),

                /// 🧩 GRID DE NIVELES
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.all(20),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: small ? 1 : 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: small ? 1.2 : 1.1,
                    ),
                    itemCount: blocks.length,
                    itemBuilder: (context, index) {
                      final block = blocks[index];

                  return _MindBlockCard(
  title: block["title"] as String,
  description: block["desc"] as String,
  icon: block["icon"] as IconData,
  color: block["color"] as Color,
  available: block["available"] as bool,
  onTap: () {
    if (block["available"] == true) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PercepcionMenuScreen()),
      ).then((_) => _refreshCoins());
    }
  },
);

                    },
                  ),
                ),
              ],
            ),
          ),

          /// 🔙 BOTÓN RETRO
          RetroBackButton(),
        ],
      ),
    );
  }
}

/// -----------------------------------------------------------
///   TARJETAS DE LOS NIVELES
/// -----------------------------------------------------------
class _MindBlockCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool available;
  final VoidCallback onTap;

  const _MindBlockCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.available,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final small = MediaQuery.of(context).size.width < 450;

    return AnimatedContainer(
      duration: Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: Color(0xFF2B1E40),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(available ? 0.8 : 0.2),
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.7),
            offset: Offset(8, 8),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: available ? onTap : null,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: small ? 45 : 55,
                  color: available ? color : Colors.grey),
              SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: small ? 11 : 13,
                  color: available ? color : Colors.grey,
                ),
              ),
              SizedBox(height: 16),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'VT323',
                  fontSize: small ? 22 : 24,
                  color: available ? Colors.white : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// -----------------------------------------------------------
///   FONDO RETRO ANIMADO
/// -----------------------------------------------------------
class PurgatorioBackgroundPainter extends CustomPainter {
  final double progress;
  PurgatorioBackgroundPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF00FFF0).withOpacity(0.1)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    for (double x = 0; x < size.width; x += 30) {
      final o = math.sin(progress * 2 * math.pi + x / 50) * 4;
      canvas.drawLine(Offset(x, o), Offset(x, size.height - o), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
