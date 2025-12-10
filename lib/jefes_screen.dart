import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'data/progress_manager.dart';

class JefesScreen extends StatefulWidget {
  const JefesScreen({super.key});

  @override
  State<JefesScreen> createState() => _JefesScreenState();
}

class _JefesScreenState extends State<JefesScreen>
    with TickerProviderStateMixin {
  late AnimationController _snowController;
  late AnimationController _mountainController;

  final List<Map<String, dynamic>> bosses = const [
    {
      "id": "purgatorio",
      "icon": Icons.auto_awesome,
      "name": "El Purgatorio Mental",
      "desc": "El juicio del Guerrero Mental",
      "mechanic": "",
      "lore":
          "Fuiste un antiguo Guerrero Mental. Bendecido con sabiduría, razón y control absoluto de tu mente. Pero el mundo te tentó. Dudaste. Traicionaste tus valores. Y caíste.\n\nNo al infierno… sino a algo peor:\nEL PURGATORIO MENTAL.\n\nAquí no se castiga el cuerpo, se castiga la conciencia. Seres cósmicos observan cada pensamiento. Cada decisión. Cada error.\n\nAhora debes probar que aún eres digno. Que la sabiduría no ha muerto en ti.\n\nSolo venciendo a los jueces del purgatorio, recuperarás tu lugar en el Paraíso Mental.",
      "isLoreCard": true,
      "color": Color(0xFF9D4EDD),
    },
    {
      "id": "boss_percepcion",
      "icon": Icons.visibility,
      "name": "La Sombra del Ojo",
      "desc": "Observa cada error",
      "mechanic": "Fallar una vez es morir",
      "lore":
          "Nació del primer pensamiento impuro del Guerrero Mental.\n\nTodo lo observa. Todo lo recuerda.\nEs el vigilante eterno de la culpa.\n\nQuien falla ante él, queda marcado por su mirada infinita.",
      "implemented": true,
      "color": Color(0xFFE63946),
    },
    {
      "id": "boss_logica",
      "icon": Icons.extension,
      "name": "El Rompecódigos",
      "desc": "El amo del tiempo",
      "mechanic": "Reduce el tiempo a la mitad",
      "lore":
          "Forjado de la ansiedad del guerrero cuando intentó huir del juicio.\n\nNo te mata con fuerza.\nTe mata con presión.",
      "implemented": true,
      "color": Color(0xFF5A9FD4),
    },
    {
      "id": "boss_ciencia",
      "icon": Icons.shield,
      "name": "El Guardián de la Memoria",
      "desc": "El cobrador del pasado",
      "mechanic": "Pierdes monedas al fallar",
      "lore":
          "Protege los recuerdos más dolorosos.\n\nCada error del pasado lo fortaleció.\n\nCastiga no solo el fallo… sino el olvido.",
      "implemented": true,
      "color": Color(0xFF32CD32),
    },
    {
      "id": "boss_cultura",
      "icon": Icons.bolt,
      "name": "El Juicio Relámpago",
      "desc": "El juez supremo",
      "mechanic": "Tres fallos = muerte",
      "lore":
          "Nació del último fragmento de sabiduría divina del guerrero.\n\nNo castiga el error.\nCastiga la indignidad.\n\nSi no eres digno, simplemente… te borra.",
      "implemented": true,
      "color": Color(0xFFE040FB),
    },
  ];

  Map<String, bool> defeated = {};

  @override
  void initState() {
    super.initState();
    _loadBossState();

    _snowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 45),
    )..repeat();

    _mountainController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _snowController.dispose();
    _mountainController.dispose();
    super.dispose();
  }

  Future<void> _loadBossState() async {
    for (var b in bosses) {
      if (b["id"].toString().startsWith("boss")) {
        defeated[b["id"]] = await ProgressManager.isBossDefeated(b["id"]);
      }
    }
    setState(() {});
  }

  // ================= LIBRO DE LORE =================
  void _showLore(Map<String, dynamic> entity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Center(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B2335), Color(0xFF261426)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: Color(0xFFB38C4D), width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black87,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  entity["name"],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: "PressStart2P",
                    fontSize: 14,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  entity["desc"],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: "VT323",
                    fontSize: 24,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4E3C3),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (entity["mechanic"].toString().isNotEmpty) ...[
                            const Text(
                              "Mecánica:",
                              style: TextStyle(
                                fontFamily: "VT323",
                                fontSize: 24,
                                color: Colors.black,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              entity["mechanic"],
                              style: const TextStyle(
                                fontFamily: "VT323",
                                fontSize: 22,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          const Text(
                            "Relato:",
                            style: TextStyle(
                              fontFamily: "VT323",
                              fontSize: 24,
                              color: Colors.black,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            entity["lore"],
                            style: const TextStyle(
                              fontFamily: "VT323",
                              fontSize: 22,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 36, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2B1E40),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: Colors.white70, width: 2),
                    ),
                    child: const Text(
                      "CERRAR LIBRO",
                      style: TextStyle(
                        fontFamily: "PressStart2P",
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1929),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _mountainController,
            builder: (context, _) => CustomPaint(
              painter: _IcyMountainPainter(_mountainController.value),
              size: size,
            ),
          ),
          AnimatedBuilder(
            animation: _snowController,
            builder: (context, _) => CustomPaint(
              painter: _SnowflakePainter(_snowController.value),
              size: size,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "CÓDICE DEL PURGATORIO",
                    style: TextStyle(
                      fontFamily: "PressStart2P",
                      fontSize: isSmall ? 14 : 18,
                      color: Colors.white,
                      shadows: const [
                        Shadow(
                            blurRadius: 12,
                            color: Colors.black54),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmall ? 16 : 24,
                      vertical: 10,
                    ),
                    itemCount: bosses.length,
                    itemBuilder: (context, index) {
                      final boss = bosses[index];
                      final String id = boss["id"];
                      final bool isDefeated = defeated[id] ?? false;
                      final bool isLore =
                          boss["id"] == "purgatorio";

                      return _BossCard(
                        boss: boss,
                        isDefeated: isDefeated,
                        isLore: isLore,
                        index: index,
                        onTap: () => _showLore(boss),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: FloatingActionButton.extended(
                    backgroundColor: const Color(0xFF1B3A52),
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.white),
                    label: const Text(
                      "VOLVER",
                      style: TextStyle(
                        fontFamily: "PressStart2P",
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
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

// ================= BOSS CARD =================
class _BossCard extends StatefulWidget {
  final Map<String, dynamic> boss;
  final bool isDefeated;
  final bool isLore;
  final int index;
  final VoidCallback onTap;

  const _BossCard({
    required this.boss,
    required this.isDefeated,
    required this.isLore,
    required this.index,
    required this.onTap,
  });

  @override
  State<_BossCard> createState() => _BossCardState();
}

class _BossCardState extends State<_BossCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration:
          Duration(milliseconds: 2500 + (widget.index * 300)),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 600;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 1.0 + (_pulseController.value * 0.015);

        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: EdgeInsets.all(isSmall ? 18 : 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.isLore
                      ? [
                          const Color(0xFF9D4EDD)
                              .withOpacity(0.2),
                          const Color(0xFF5A189A)
                              .withOpacity(0.2),
                        ]
                      : [
                          (widget.boss["color"] as Color)
                              .withOpacity(0.25),
                          (widget.boss["color"] as Color)
                              .withOpacity(0.1),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: widget.boss["color"],
                  width: 2.5,
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        widget.boss["icon"],
                        color: widget.boss["color"],
                        size: isSmall ? 50 : 60,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          widget.boss["name"],
                          style: TextStyle(
                            fontFamily:
                                "PressStart2P",
                            fontSize:
                                isSmall ? 13 : 16,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.boss["desc"],
                    style: TextStyle(
                      color: Colors.white70,
                      fontFamily: "VT323",
                      fontSize:
                          isSmall ? 24 : 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ================= PINTORS =================
class _IcyMountainPainter extends CustomPainter {
  final double progress;
  _IcyMountainPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF1B3A52), Color(0xFF0F1C2E)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(
          Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    path.lineTo(0, size.height * 0.6);

    for (double x = 0;
        x <= size.width;
        x += 50) {
      final y = size.height * 0.6 +
          math.sin((x / size.width * 4 * math.pi) +
                  progress *
                      2 *
                      math.pi) *
              30;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => true;
}

class _SnowflakePainter extends CustomPainter {
  final double progress;
  _SnowflakePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white70;
    final random = math.Random(42);

    for (int i = 0; i < 80; i++) {
      final x = random.nextDouble() * size.width;
      final y = (random.nextDouble() * size.height +
              progress *
                  size.height *
                  0.5) %
          size.height;

      final drift =
          math.sin(progress * 2 * math.pi + i) *
              15;

      canvas.drawCircle(
        Offset(x + drift, y),
        i % 7 == 0 ? 3 : 2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => true;
}
