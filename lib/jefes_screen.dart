import 'package:flutter/material.dart';

class JefesScreen extends StatelessWidget {
  const JefesScreen({super.key});

  final List<Map<String, dynamic>> bosses = const [
    {
      "icon": Icons.visibility,
      "name": "La Sombra del Ojo",
      "desc": "Observa cada error y castiga las fallas de percepción.",
      "mechanic": "Si fallas una sola pregunta, pierdes inmediatamente.",
    },
    {
      "icon": Icons.extension,
      "name": "El Rompecódigos",
      "desc": "Maestro absoluto de la lógica imposible.",
      "mechanic": "Reduce el tiempo por pregunta a la mitad.",
    },
    {
      "icon": Icons.memory,
      "name": "El Archivista",
      "desc": "Guardián de los recuerdos más profundos.",
      "mechanic": "Te exige un mayor puntaje en el quiz.",
    },
    {
      "icon": Icons.science,
      "name": "Neurón Alfa",
      "desc": "Una entidad creada en laboratorio obsesionada con la precisión.",
      "mechanic": "Cada respuesta incorrecta resta una moneda de comodín.",
    },
    {
      "icon": Icons.psychology,
      "name": "El Juez Mental",
      "desc": "Juzga tu criterio y presión bajo estrés.",
      "mechanic": "Pone respuestas trampa.",
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
                )
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  boss["icon"],
                  color: Colors.cyanAccent,
                  size: 40,
                ),
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
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.pinkAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          "PRÓXIMAMENTE",
                          style: TextStyle(
                            color: Colors.pinkAccent,
                            fontFamily: "PressStart2P",
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
