import 'package:flutter/material.dart';

class InstructionsScreen extends StatefulWidget {
  const InstructionsScreen({super.key});

  @override
  State<InstructionsScreen> createState() => _InstructionsScreenState();
}

class _InstructionsScreenState extends State<InstructionsScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final int _totalPages = 4;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    if (index < 0 || index >= _totalPages) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12091F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F102F),
        elevation: 6,
        centerTitle: true,
        title: const Text(
          'LIBRO DE QUIZMENTE',
          style: TextStyle(
            fontFamily: 'PressStart2P',
            fontSize: 14,
            letterSpacing: 2,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          // --- Título dinámico por página ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              _pageTitle(_currentPage),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'VT323',
                fontSize: 26,
                color: Color(0xFFFFE6B3),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // --- Libro central con páginas ---
          Expanded(
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bookWidth =
                      (constraints.maxWidth * 0.95).clamp(320.0, 900.0);
                  final bookHeight =
                      (constraints.maxHeight * 0.90).clamp(420.0, 720.0);

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    width: bookWidth,
                    height: bookHeight,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF3B2335),
                          Color(0xFF261426),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFFB38C4D),
                        width: 3,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x99000000),
                          blurRadius: 18,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // “Páginas” internas estilo pergamino
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4E3C3),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x33000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: PageView(
                                controller: _pageController,
                                onPageChanged: (index) {
                                  setState(() {
                                    _currentPage = index;
                                  });
                                },
                                children: [
                                  _buildIntroPage(),
                                  _buildPowerUpsPage(),
                                  _buildCodexPage(),
                                  _buildTopicsPage(),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Esquina superior decorativa
                        Positioned(
                          top: 8,
                          left: 16,
                          child: Opacity(
                            opacity: 0.7,
                            child: Row(
                              children: const [
                                Icon(Icons.auto_stories, size: 18, color: Color(0xFFB38C4D)),
                                SizedBox(width: 6),
                                Text(
                                  'Capítulo',
                                  style: TextStyle(
                                    fontFamily: 'VT323',
                                    fontSize: 18,
                                    color: Color(0xFFB38C4D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Número de página
                        Positioned(
                          bottom: 8,
                          right: 16,
                          child: Text(
                            '${_currentPage + 1} / $_totalPages',
                            style: const TextStyle(
                              fontFamily: 'VT323',
                              fontSize: 18,
                              color: Color(0xFFB38C4D),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 12),

          // --- Barra inferior con puntos y botones ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Botón Anterior
                _NavButton(
                  text: '<< Anterior',
                  enabled: _currentPage > 0,
                  onTap: () => _goToPage(_currentPage - 1),
                ),

                // Dots de progreso
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    _totalPages,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 18 : 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? const Color(0xFFFF4B82)
                            : const Color(0xFF6C4E91),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),

                // Botón Siguiente / Cerrar
                _NavButton(
                  text: _currentPage == _totalPages - 1 ? 'Cerrar' : 'Siguiente >>',
                  enabled: true,
                  onTap: () {
                    if (_currentPage == _totalPages - 1) {
                      Navigator.pop(context);
                    } else {
                      _goToPage(_currentPage + 1);
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  String _pageTitle(int index) {
    switch (index) {
      case 0:
        return '¿Qué es QuizMente?';
      case 1:
        return 'Comodines y estrategias';
      case 2:
        return 'El Códice y los Jefes';
      case 3:
        return 'Mundos mentales y temas';
      default:
        return '';
    }
  }

  // ----------------- PÁGINA 1: INTRO DEL JUEGO -----------------
  Widget _buildIntroPage() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'QuizMente es un juego de quiz tipo roguelike cognitivo. '
              'Cada partida es un recorrido por mundos mentales donde los errores tienen consecuencias '
              'y el conocimiento es tu mejor arma.',
              style: TextStyle(
                fontFamily: 'VT323',
                fontSize: 22,
                color: Colors.black87,
                height: 1.3,
              ),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 18),
            Text(
              'Mecánicas principales:',
              style: TextStyle(
                fontFamily: 'VT323',
                fontSize: 24,
                color: Colors.black,
                decoration: TextDecoration.underline,
              ),
            ),
            SizedBox(height: 12),
            Text(
              '• Avanzas respondiendo preguntas en bloques.\n'
              '• Cada bloque pertenece a un nivel mental (Percepción, Lógica, etc.).\n'
              '• Si fallas demasiado, pierdes el progreso del nivel y debes repetirlo.\n'
              '• Los jefes mentales ponen a prueba todo lo que has aprendido.\n'
              '• Con cada victoria desbloqueas nuevos bloques, jefes y contenido.',
              style: TextStyle(
                fontFamily: 'VT323',
                fontSize: 22,
                color: Colors.black87,
                height: 1.3,
              ),
            ),
            SizedBox(height: 18),
            Text(
              'Tu objetivo es superar el Purgatorio Mental, dominar los mundos de QuizMente y demostrar '
              'que tu intelecto puede resistir la presión de los errores y del tiempo.',
              style: TextStyle(
                fontFamily: 'VT323',
                fontSize: 22,
                color: Colors.black87,
                height: 1.3,
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }

  // ----------------- PÁGINA 2: COMODINES -----------------
  Widget _buildPowerUpsPage() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'En QuizMente existe un menú de comodines (poderes especiales) que puedes usar '
              'durante los quiz para salvarte en momentos críticos.',
              style: TextStyle(
                fontFamily: 'VT323',
                fontSize: 22,
                color: Colors.black87,
                height: 1.3,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 16),

            // Imagen del menú de comodines
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/image/Comodines.png',
                height: 240, // aumentado
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(
                  height: 240,
                  child: Center(
                    child: Text(
                      'No se encontró assets/image/Comodines.png',
                      style: TextStyle(
                        fontFamily: 'VT323',
                        fontSize: 18,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '(Vista del menú de comodines.)',
              style: TextStyle(
                fontFamily: 'VT323',
                fontSize: 18,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              'Cómo funciona el menú de comodines:',
              style: TextStyle(
                fontFamily: 'VT323',
                fontSize: 24,
                color: Colors.black,
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '• Antes de iniciar un quiz, puedes abrir el menú de comodines.\n'
              '• Verás los comodines que has desbloqueado y cuántas monedas cuestan.\n'
              '• Puedes seleccionar los que mejor se adapten a tu estilo de juego.\n'
              '• En la partida, cada comodín se puede usar una vez por pregunta.\n'
              '• Si planeas bien, un solo comodín puede salvar un bloque entero.',
              style: TextStyle(
                fontFamily: 'VT323',
                fontSize: 22,
                color: Colors.black87,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Ejemplos de comodines (según la versión final):\n'
              '• Clarividencia: te muestra una pista o te ayuda a descartar opciones.\n'
              '• 50/50: elimina respuestas incorrectas para aumentar tus probabilidades.\n'
              '• Tiempo extra: aumenta el tiempo disponible para responder.\n'
              '• Ocultar opciones: reduce el ruido visual para concentrarte mejor.',
              style: TextStyle(
                fontFamily: 'VT323',
                fontSize: 22,
                color: Colors.black87,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------- PÁGINA 3: CÓDICE & JEFES -----------------
  Widget _buildCodexPage() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'El Códice es la biblioteca de conocimiento de QuizMente. Aquí puedes leer '
              'sobre los jefes, sus mecánicas, su lore y preparar tu mejor estrategia antes '
              'de enfrentarlos.',
              style: TextStyle(
                fontFamily: 'VT323',
                fontSize: 22,
                color: Colors.black87,
                height: 1.3,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 16),

            // Imagen de la pantalla Códice / Jefes
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/image/Codice.png',
                height: 240, // aumentado
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(
                  height: 240,
                  child: Center(
                    child: Text(
                      'No se encontró assets/image/Codice.png',
                      style: TextStyle(
                        fontFamily: 'VT323',
                        fontSize: 18,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '(Vista del Códice y jefes.)',
              style: TextStyle(
                fontFamily: 'VT323',
                fontSize: 18,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              'Cómo progresa el nivel:',
              style: TextStyle(
                fontFamily: 'VT323',
                fontSize: 24,
                color: Colors.black,
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '• Cada nivel de QuizMente está dividido en bloques de preguntas.\n'
              '• Al completar un bloque con éxito, se desbloquea el siguiente.\n'
              '• Algunos bloques terminan en un jefe mental (un quiz especial).\n'
              '• Si derrotas al jefe, se guarda un “checkpoint” para ese nivel.\n'
              '• Si pierdes contra un jefe importante, puedes perder el avance del nivel '
              'y tendrás que repetirlo desde bloques anteriores.',
              style: TextStyle(
                fontFamily: 'VT323',
                fontSize: 22,
                color: Colors.black87,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Los jefes no solo miden tu memoria: castigan los errores, reducen el tiempo, '
              'cambian las reglas o exigen un porcentaje de aciertos más alto. Leer el Códice '
              'antes de enfrentarlos es clave para sobrevivir al Purgatorio Mental.',
              style: TextStyle(
                fontFamily: 'VT323',
                fontSize: 22,
                color: Colors.black87,
                height: 1.3,
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }

  // ----------------- PÁGINA 4: TEMAS / MUNDOS MENTALES -----------------
  Widget _buildTopicsPage() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'QuizMente está dividido en mundos mentales, cada uno asociado a un tipo de '
              'habilidad cognitiva. Dominar estos mundos requiere práctica dentro y fuera del juego.',
              style: TextStyle(
                fontFamily: 'VT323',
                fontSize: 22,
                color: Colors.black87,
                height: 1.3,
              ),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 18),
            Text(
              'Mundos y temas principales:',
              style: TextStyle(
                fontFamily: 'VT323',
                fontSize: 24,
                color: Colors.black,
                decoration: TextDecoration.underline,
              ),
            ),
            SizedBox(height: 12),
            Text(
              '• PERCEPCIÓN:\n'
              '  Preguntas que ponen a prueba tu atención a los detalles, patrones visuales, '
              'diferencias sutiles y capacidad de observar con precisión.\n\n'
              '• LÓGICA:\n'
              '  Razonamiento, deducción, patrones numéricos, secuencias y problemas donde '
              'importa más cómo piensas que lo que recuerdas.\n\n'
              '• CIENCIA Y TECNOLOGÍA:\n'
              '  Conceptos básicos de ciencia, tecnología, informática, innovación y cómo se '
              'aplican a la vida real.\n\n'
              '• CULTURA GENERAL:\n'
              '  Historia, arte, geografía, literatura y datos generales del mundo que te rodea.',
              style: TextStyle(
                fontFamily: 'VT323',
                fontSize: 22,
                color: Colors.black87,
                height: 1.3,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Puedes usar QuizMente como una forma de estudio: si ves que fallas mucho en un tema, '
              'puedes repasar fuera del juego y luego volver a intentar el bloque. Cada partida es '
              'una nueva oportunidad para mejorar tus habilidades mentales.',
              style: TextStyle(
                fontFamily: 'VT323',
                fontSize: 22,
                color: Colors.black87,
                height: 1.3,
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}

// --------------- BOTÓN DE NAVEGACIÓN INFERIOR ---------------
class _NavButton extends StatelessWidget {
  final String text;
  final bool enabled;
  final VoidCallback onTap;

  const _NavButton({
    required this.text,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF2B1E40),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFB38C4D),
              width: 2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'VT323',
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}