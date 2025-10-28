import 'package:flutter/material.dart';

class AppTheme {
  // Paleta de cores
  static const Color primaryGreen = Color(0xFF2D5A32); // Verde escuro
  static const Color primaryGreenLight = Color(
    0xFF4A7C59,
  ); // Verde escuro claro
  static const Color primaryGreenDark = Color(0xFF1B3A1F); // Verde muito escuro

  static const Color secondaryRed = Color(0xFFDC3545); // Vermelho
  static const Color secondaryRedLight = Color(0xFFF8D7DA); // Vermelho claro
  static const Color secondaryRedDark = Color(0xFFB02A37); // Vermelho escuro

  static const Color baseWhite = Color(0xFFFFFFFF); // Branco
  static const Color baseGray50 = Color(0xFFFAFAFA); // Cinza muito claro
  static const Color baseGray100 = Color(0xFFF5F5F5); // Cinza claro
  static const Color baseGray200 = Color(0xFFEEEEEE); // Cinza
  static const Color baseGray300 = Color(0xFFE0E0E0); // Cinza médio
  static const Color baseGray400 = Color(0xFFBDBDBD); // Cinza escuro
  static const Color baseGray500 = Color(0xFF9E9E9E); // Cinza muito escuro
  static const Color baseGray600 = Color(0xFF757575); // Cinza quase preto
  static const Color baseGray900 = Color(0xFF212121); // Preto

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Cores principais
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: baseGray50,

    colorScheme: const ColorScheme.light(
      primary: primaryGreen,
      onPrimary: baseWhite,
      primaryContainer: primaryGreenLight,
      onPrimaryContainer: baseWhite,

      secondary: secondaryRed,
      onSecondary: baseWhite,
      secondaryContainer: secondaryRedLight,
      onSecondaryContainer: secondaryRedDark,

      surface: baseWhite,
      onSurface: baseGray900,
      surfaceContainerHighest: baseGray100,

      error: secondaryRed,
      onError: baseWhite,
      errorContainer: secondaryRedLight,
      onErrorContainer: secondaryRedDark,

      outline: baseGray300,
      outlineVariant: baseGray200,
    ),

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: baseWhite,
      foregroundColor: baseGray900,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: baseGray900,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: baseGray600),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: baseWhite,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: baseWhite,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: baseGray600,
        side: const BorderSide(color: baseGray300),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: baseGray300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: baseGray300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: secondaryRed),
      ),
      filled: true,
      fillColor: baseWhite,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),

    // Data Table Theme
    dataTableTheme: const DataTableThemeData(
      headingRowColor: WidgetStatePropertyAll(baseGray100),
      headingTextStyle: TextStyle(
        color: baseGray900,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      dataTextStyle: TextStyle(color: baseGray900, fontSize: 14),
      dividerThickness: 1,
      horizontalMargin: 24,
      columnSpacing: 32,
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: baseGray200,
      thickness: 1,
      space: 1,
    ),
  );
}
