import 'package:flutter/material.dart';

class ComodinesScreen extends StatelessWidget {
  const ComodinesScreen({super.key});

  final List<Map<String, dynamic>> powerUps = const [
    {
      "icon": Icons.visibility_outlined,
      "name": "Clarividencia",
      "effect": "Elimina dos opciones incorrectas.",
      "cost": 5,
      "color": Color(0xFF00FFF0),
    },
    {
      "icon": Icons.replay,
      "name": "Rebobinar",
      "effect": "Repite la última pregunta fallada.",
      "cost": 8,
      "color": Color(0xFF9B4DFF),
    },
    {
      "icon": Icons.timer,
      "name": "Instinto",
      "effect": "Aumenta el tiempo disponible.",
      "cost": 6,
      "color": Color(0xFF00E676),
    },
    {
      "icon": Icons.flash_on,
      "name": "Visión Fugaz",
      "effect": "Muestra la respuesta correcta por 2 segundos.",
      "cost": 10,
      "color": Color(0xFFFF3366),
    },
    {
      "icon": Icons.control_point_duplicate,
      "name": "Doble Mente",
      "effect": "Duplica los puntos de la pregunta actual.",
      "cost": 7,
      "color": Color(0xFF42A5F5),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF150C25),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Comodines Desbloqueados",
          style: TextStyle(fontFamily: "PressStart2P", fontSize: 10),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: powerUps.length,
        itemBuilder: (context, index) {
          final p = powerUps[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 18),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF24133D),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: p["color"], width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: p["color"].withOpacity(0.3),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  p["icon"],
                  color: p["color"],
                  size: 40,
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //  NOMBRE
                      Text(
                        p["name"],
                        style: TextStyle(
                          fontFamily: "PressStart2P",
                          fontSize: 11,
                          color: p["color"],
                        ),
                      ),

                      const SizedBox(height: 6),

                      // EFECTO
                      Text(
                        p["effect"],
                        style: const TextStyle(
                          fontFamily: "VT323",
                          fontSize: 20,
                          color: Colors.white70,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // COSTO
                      Text(
                        "Costo: ${p["cost"]} monedas",
                        style: const TextStyle(
                          fontFamily: "VT323",
                          fontSize: 20,
                          color: Colors.cyanAccent,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // PROXIMAMENTE
                      const Text(
                        "Próximamente desbloqueable...",
                        style: TextStyle(
                          fontFamily: "VT323",
                          fontSize: 18,
                          color: Colors.white38,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
