import 'package:flutter/material.dart';

final retroTheme = ThemeData(
  scaffoldBackgroundColor: const Color(0xFF1B0E2E),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFFFF4B82), // rosa cálido tipo arcade
    secondary: Color(0xFF00FFF0), // cian retro
    surface: Color(0xFF1B0E2E),
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(
      color: Color(0xFFE6E6E6),
      fontFamily: 'VT323', // tipografía pixelada
      fontSize: 20,
    ),
  ),
  fontFamily: 'VT323',
);
