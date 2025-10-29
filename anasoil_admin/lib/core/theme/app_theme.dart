import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

    // Typography with Poppins font
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      // Headings
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: baseGray900,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: baseGray900,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: baseGray900,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: baseGray900,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: baseGray900,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: baseGray900,
      ),
      // Titles
      titleLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: baseGray900,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: baseGray900,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: baseGray900,
      ),
      // Body text
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: baseGray900,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: baseGray900,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: baseGray600,
      ),
      // Labels
      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: baseGray900,
      ),
      labelMedium: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: baseGray600,
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: baseGray600,
      ),
    ),

    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: baseWhite,
      foregroundColor: baseGray900,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.poppins(
        color: baseGray900,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(color: baseGray600),
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
        textStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: baseGray600,
        side: const BorderSide(color: baseGray300),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
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
    dataTableTheme: DataTableThemeData(
      headingRowColor: const WidgetStatePropertyAll(baseGray100),
      headingTextStyle: GoogleFonts.poppins(
        color: baseGray900,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      dataTextStyle: GoogleFonts.poppins(color: baseGray900, fontSize: 14),
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
