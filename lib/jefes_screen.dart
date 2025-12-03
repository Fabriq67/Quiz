import 'package:flutter/material.dart';
import '../data/progress_manager.dart';

class JefesScreen extends StatefulWidget {
  const JefesScreen({super.key});

  @override
  State<JefesScreen> createState() => _JefesScreenState();
}

class _JefesScreenState extends State<JefesScreen> {

  final List<Map<String, dynamic>> bosses = const [
    {
      "id": "boss_1",
      "icon": Icons.visibility,
      "name": "La Sombra del Ojo",
      "desc": "Observa cada error y castiga las fallas de percepción.",
      "mechanic": "Si fallas una sola pregunta, pierdes inmediatamente.",
      "implemented": true,
    },
    {
      "id": "boss_2",
      "icon": Icons.extension,
      "name": "El Rompecódigos",
      "desc": "Maestro absoluto de la lógica imposible.",
      "mechanic": "Reduce el tiempo por pregunta a la mitad.",
      "implemented": false,
    },
    {
      "id": "boss_3",
      "icon": Icons.shield,
      "name": "El Guardián de la Memoria",
      "desc": "Distorsiona tus recuerdos recientes.",
      "mechanic": "Cambia el orden de las respuestas constantemente.",
      "implemented": false,
    },
    {
      "id": "boss_4",
      "icon": Icons.bolt,
      "name": "El Juicio Relámpago",
      "desc": "No perdona la duda.",
      "mechanic": "Solo 3 segundos por pregunta.",
      "implemented": false,
    },
  ];

  Map<String, bool> defeated = {};

  @override
  void initState() {
    super.initState();
    _loadBossState();
  }

  Future<void> _loadBossState() async {
    for (var b in bosses) {
      defeated[b["id"]] = await ProgressManager.isBossDefeated(b["id"]);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF150C25),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Jefes del Purgatorio Mental",
          style: TextStyle(fontFamily: "PressStart2P", fontSize: 12),
        ),
        centerTitle: true,
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bosses.length,
        itemBuilder: (context, index) {
          final boss = bosses[index];
          final String id = boss["id"];
          final bool implemented = boss["implemented"];
          final bool isDefeated = defeated[id] ?? false;

          // ESTADOS:
          // ✔️ Boss 1 → DERROTADO o BLOQUEADO según progreso real
          // ✔️ Boss 2+ → siempre BLOQUEADO (NO implementados)
          String stateText;
          Color stateColor;

          if (!implemented) {
            stateText = "BLOQUEADO";
            stateColor = Colors.redAccent;
          } else {
            if (isDefeated) {
              stateText = "DESBLOQUEADO";
              stateColor = Colors.greenAccent;
            } else {
              stateText = "BLOQUEADO";
              stateColor = Colors.redAccent;
            }
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 18),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF24133D),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.cyanAccent, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withOpacity(0.3),
                  blurRadius: 12,
                ),
              ],
            ),

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(boss["icon"], color: Colors.cyanAccent, size: 40),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        boss["name"],
                        style: const TextStyle(
                          fontFamily: "PressStart2P",
                          fontSize: 11,
                          color: Colors.cyanAccent,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        boss["desc"],
                        style: const TextStyle(
                          color: Colors.white70,
                          fontFamily: "VT323",
                          fontSize: 20,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Mecánica: ${boss["mechanic"]}",
                        style: const TextStyle(
                          color: Colors.pinkAccent,
                          fontFamily: "VT323",
                          fontSize: 20,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Estado
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: stateColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          stateText,
                          style: TextStyle(
                            color: stateColor,
                            fontFamily: "PressStart2P",
                            fontSize: 10,
                          ),
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
