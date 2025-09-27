import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF335C3B), // Verde Escuro
    scaffoldBackgroundColor: const Color(0xFFF2F2F2), // Branco/Cinza Claro
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF335C3B), // Verde Escuro
      secondary: Color(0xFF69AE42), // Verde Claro
      error: Color(0xFF962C2D), // Vermelho Escuro
      onPrimary: Color(0xFFF2F2F2),
      onSecondary: Color(0xFF1C100D),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF335C3B), // Verde Escuro
      foregroundColor: Color(0xFFF2F2F2), // Textos e ícones na AppBar
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Color(0xFF1C100D)), // Preto/Marrom Escuro
    ),
  );
}
