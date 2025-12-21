import 'package:flutter/material.dart';
import 'dart:math' as math;

// Asegúrate de que estas rutas coincidan con tu estructura de archivos
import 'data/progress_manager.dart';
import 'hud_widget.dart';
import 'screens/ciencia_quiz_screen.dart';
import 'screens/cultura_quiz_screen.dart';
import 'screens/logica_quiz_screen.dart';
import 'screens/percepcion_quiz_screen.dart';

class FreeModeScreen extends StatefulWidget {
  const FreeModeScreen({super.key});

  @override
  State<FreeModeScreen> createState() => _FreeModeScreenState();
}

class _FreeModeScreenState extends State<FreeModeScreen>
    with TickerProviderStateMixin {
  late AnimationController _spinController;
  late AnimationController _pulseController;

  int coins = 0;

  final List<Map<String, dynamic>> categories = [
    {
      "id": "percepcion",
      "name": "Percepción",
      "icon": "👁️",
      "color": const Color(0xFF6BE3FF),
      "blockCount": 2,
    },
    {
      "id": "logica",
      "name": "Lógica",
      "icon": "🧠",
      "color": const Color(0xFF5A9FD4),
      "blockCount": 3,
    },
    {
      "id": "cultura",
      "name": "Cultura",
      "icon": "📚",
      "color": const Color(0xFFB388FF),
      "blockCount": 4,
    },
    {
      "id": "ciencia",
      "name": "Ciencia",
      "icon": "🔬",
      "color": const Color(0xFF32CD32),
      "blockCount": 3,
    },
  ];

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _loadCoins();
  }

  Future<void> _loadCoins() async {
    try {
      final progress = await ProgressManager.loadProgress();
      if (mounted) setState(() => coins = progress.coins);
    } catch (e) {
      debugPrint("Error cargando monedas: $e");
    }
  }

  @override
  void dispose() {
    _spinController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _selectCategory(String categoryId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true, // Permite que el contenido respire
      builder: (context) => _CategoryBlockSelector(
        categoryId: categoryId,
        categoryName: categories.firstWhere((c) => c["id"] == categoryId)["name"],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      body: Stack(
        children: [
          // Fondo Animado
          AnimatedBuilder(
            animation: _spinController,
            builder: (context, child) => CustomPaint(
              painter: _ArcadeBgPainter(_spinController.value),
              size: size,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // --- HEADER ---
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.04,
                    vertical: size.height * 0.02,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildBackButton(size),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              "🎮 ARCADE MODE 🎮",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: size.width * 0.065, // Letra grande
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF00FF88),
                                fontFamily: "VT323",
                              ),
                            ),
                            Text(
                              "Modo Libre - Sin penalizaciones",
                              style: TextStyle(
                                fontSize: size.width * 0.042, // Subtítulo claro
                                color: const Color(0xFFFFD700),
                                fontFamily: "VT323",
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildCoinDisplay(size),
                    ],
                  ),
                ),

                // --- GRILLA DE CATEGORÍAS ---
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    padding: EdgeInsets.all(size.width * 0.05),
                    mainAxisSpacing: size.width * 0.05,
                    crossAxisSpacing: size.width * 0.05,
                    children: categories.map((cat) {
                      return _CategoryCard(
                        name: cat["name"],
                        icon: cat["icon"],
                        color: cat["color"],
                        blockCount: cat["blockCount"],
                        onTap: () => _selectCategory(cat["id"]),
                      );
                    }).toList(),
                  ),
                ),

                // --- FOOTER INFORMATIVO ---
                _buildFooter(size),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(Size size) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: EdgeInsets.all(size.width * 0.03),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.arrow_back,
          color: const Color(0xFF00FF88),
          size: size.width * 0.07,
        ),
      ),
    );
  }

  Widget _buildCoinDisplay(Size size) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.03,
        vertical: size.height * 0.008,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        border: Border.all(color: const Color(0xFFFFD700), width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "💰 $coins",
        style: TextStyle(
          fontSize: size.width * 0.045,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFFFD700),
          fontFamily: "VT323",
        ),
      ),
    );
  }

  Widget _buildFooter(Size size) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(size.width * 0.05),
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.5), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "✨ Juega sin restricciones. Tus intentos no afectan el progreso general.",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: size.width * 0.042, // Letra de advertencia legible
          color: const Color(0xFFFFD700),
          fontFamily: "VT323",
          height: 1.3,
        ),
      ),
    );
  }
}

// ============================================================
// SELECTOR DE BLOQUES (Optimizado para legibilidad)
// ============================================================
class _CategoryBlockSelector extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const _CategoryBlockSelector({
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<_CategoryBlockSelector> createState() => _CategoryBlockSelectorState();
}

class _CategoryBlockSelectorState extends State<_CategoryBlockSelector> {
  late List<Map<String, dynamic>> blocks;

  @override
  void initState() {
    super.initState();
    _initializeBlocks();
  }

  void _initializeBlocks() {
    // Definición de bloques según ID
    if (widget.categoryId == "percepcion") {
      blocks = [
        {"id": 1, "title": "Bloque 1", "questions": 5, "isBoss": false},
        {"id": 2, "title": "Bloque Jefe", "questions": 10, "isBoss": true},
      ];
    } else if (widget.categoryId == "logica") {
      blocks = [
        {"id": 1, "title": "Bloque 1", "questions": 5, "isBoss": false},
        {"id": 2, "title": "Bloque 2", "questions": 5, "isBoss": false},
        {"id": 3, "title": "Bloque Jefe", "questions": 10, "isBoss": true},
      ];
    } else if (widget.categoryId == "cultura") {
      blocks = [
        {"id": 1, "title": "Bloque 1", "questions": 5, "isBoss": false},
        {"id": 2, "title": "Bloque 2", "questions": 5, "isBoss": false},
        {"id": 3, "title": "Bloque 3", "questions": 10, "isBoss": false},
        {"id": 4, "title": "Bloque Final", "questions": 20, "isBoss": true},
      ];
    } else { // ciencia
      blocks = [
        {"id": 1, "title": "Bloque 1", "questions": 5, "isBoss": false},
        {"id": 2, "title": "Bloque 2", "questions": 5, "isBoss": false},
        {"id": 3, "title": "Bloque Jefe", "questions": 10, "isBoss": true},
      ];
    }
  }

  void _startLevel(int blockId, int totalQuestions, bool isBoss) {
    Navigator.pop(context);
    
    Widget targetScreen;
    switch (widget.categoryId) {
      case "percepcion":
        targetScreen = PercepcionQuizScreen(blockId: blockId, totalQuestions: totalQuestions, isBoss: isBoss, freeMode: true);
        break;
      case "logica":
        targetScreen = LogicaQuizScreen(blockId: blockId, totalQuestions: totalQuestions, isBoss: isBoss, freeMode: true);
        break;
      case "cultura":
        targetScreen = CulturaQuizScreen(blockId: blockId, totalQuestions: totalQuestions, isBoss: isBoss, freeMode: true);
        break;
      default:
        targetScreen = CienciaQuizScreen(blockId: blockId, totalQuestions: totalQuestions, isBoss: isBoss, freeMode: true);
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) => targetScreen));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      padding: EdgeInsets.only(bottom: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF0B0F14),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        border: Border(top: BorderSide(color: Color(0xFF00FF88), width: 3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 15),
            width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(10)),
          ),
          Text(
            widget.categoryName.toUpperCase(),
            style: TextStyle(
              fontSize: size.width * 0.07, // Título de bottom sheet muy claro
              fontWeight: FontWeight.bold,
              color: const Color(0xFF00FF88),
              fontFamily: "VT323",
            ),
          ),
          SizedBox(height: 10),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: size.height * 0.6),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: blocks.length,
              itemBuilder: (context, index) {
                final block = blocks[index];
                final bool isBoss = block["isBoss"];
                final Color accentColor = isBoss ? const Color(0xFFFF33A1) : const Color(0xFF00FF88);

                return GestureDetector(
                  onTap: () => _startLevel(block["id"], block["questions"], isBoss),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    padding: EdgeInsets.all(18), // Más espacio interno
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.05),
                      border: Border.all(color: accentColor, width: 2.5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Icon(isBoss ? Icons.stars : Icons.play_circle_fill, color: accentColor, size: 35),
                        SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                block["title"],
                                style: TextStyle(
                                  fontSize: size.width * 0.055, // Letra de bloque grande
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: "VT323",
                                ),
                              ),
                              Text(
                                "${block["questions"]} Desafíos ${isBoss ? '• NIVEL JEFE' : ''}",
                                style: TextStyle(
                                  fontSize: size.width * 0.04,
                                  color: Colors.grey[400],
                                  fontFamily: "VT323",
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: accentColor),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// TARJETA DE CATEGORÍA
// ============================================================
class _CategoryCard extends StatelessWidget {
  final String name;
  final String icon;
  final Color color;
  final int blockCount;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.name,
    required this.icon,
    required this.color,
    required this.blockCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          border: Border.all(color: color, width: 3), // Borde más grueso
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 10, spreadRadius: 1)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: TextStyle(fontSize: size.width * 0.12)), // Icono grande
            const SizedBox(height: 10),
            Text(
              name.toUpperCase(),
              style: TextStyle(
                fontSize: size.width * 0.05, // Texto legible
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: "VT323",
              ),
            ),
            Text(
              "$blockCount BLOQUES",
              style: TextStyle(
                fontSize: size.width * 0.038,
                color: color.withOpacity(0.7),
                fontFamily: "VT323",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PINTOR DE FONDO
// ============================================================
class _ArcadeBgPainter extends CustomPainter {
  final double progress;
  _ArcadeBgPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFF0B0F14);
    canvas.drawRect(Offset.zero & size, bg);

    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1.5;

    // Líneas Verticales
    for (int i = 0; i < 15; i++) {
      final x = (i * (size.width / 10) + progress * 50) % size.width;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }

    final particlePaint = Paint()..color = Colors.white.withOpacity(0.15);
    final random = math.Random(42);
    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = (random.nextDouble() * size.height + progress * 150) % size.height;
      canvas.drawCircle(Offset(x, y), 2, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}