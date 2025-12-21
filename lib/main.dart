import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'firebase_options.dart'; 
import 'dart:math' as math;

// Tus pantallas
import 'main_menu_screen.dart';
import 'select_level_screen.dart';
import 'instructions_screen.dart';
import 'screens/settings_screen.dart'; 

void main() async {
  // 4. Asegurar inicialización de enlaces de Flutter
  WidgetsFlutterBinding.ensureInitialized();
  
  // 5. Inicializar Firebase (MODO A PRUEBA DE ERRORES)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Si entra aquí, es porque ya estaba conectado. 
    // No hacemos nada y dejamos que la app continúe feliz.
    print("Firebase ya estaba inicializado, continuando...");
  }

  runApp(const QuizMenteApp());
}

class QuizMenteApp extends StatelessWidget {
  const QuizMenteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QuizMente',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF1B0E2E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF4B82),
          secondary: Color(0xFF00FFF0),
          surface: Color(0xFF1B0E2E),
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(
            color: const Color(0xFFE6E6E6),
            fontFamily: 'VT323',
            fontSize: MediaQuery.of(context).size.width * 0.08,
          ),
        ),
        fontFamily: 'VT323',
      ),
      home: const MainMenuScreen(),
    );
  }
}