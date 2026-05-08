import 'package:anasoil_shared/anasoil_shared.dart';
import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const Color primaryGreen = AnaSoilColors.primaryGreen;
  static const Color primaryGreenLight = AnaSoilColors.primaryGreenLight;
  static const Color primaryGreenDark = AnaSoilColors.primaryGreenDark;
  static const Color primaryGreenSoft = AnaSoilColors.primaryGreenSoft;

  static const Color warningAmber = AnaSoilColors.warningAmber;
  static const Color warningAmberLight = AnaSoilColors.warningAmberLight;
  static const Color warningAmberDark = AnaSoilColors.warningAmberDark;

  static const Color secondaryRed = AnaSoilColors.secondaryRed;
  static const Color secondaryRedLight = AnaSoilColors.secondaryRedLight;
  static const Color secondaryRedDark = AnaSoilColors.secondaryRedDark;

  static const Color baseWhite = AnaSoilColors.baseWhite;
  static const Color baseGray50 = AnaSoilColors.baseGray50;
  static const Color baseGray100 = AnaSoilColors.baseGray100;
  static const Color baseGray200 = AnaSoilColors.baseGray200;
  static const Color baseGray300 = AnaSoilColors.baseGray300;
  static const Color baseGray400 = AnaSoilColors.baseGray400;
  static const Color baseGray500 = AnaSoilColors.baseGray500;
  static const Color baseGray600 = AnaSoilColors.baseGray600;
  static const Color baseGray900 = AnaSoilColors.baseGray900;

  static ThemeData get lightTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AnaSoilColors.primaryGreen,
      primary: AnaSoilColors.primaryGreen,
    ),
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: AnaSoilColors.baseWhite,
      foregroundColor: AnaSoilColors.baseGray900,
      iconTheme: IconThemeData(color: AnaSoilColors.baseGray900),
      titleTextStyle: TextStyle(
        color: AnaSoilColors.baseGray900,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AnaSoilRadius.md),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AnaSoilColors.baseGray50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AnaSoilRadius.sm),
        borderSide: const BorderSide(color: AnaSoilColors.baseGray300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AnaSoilRadius.sm),
        borderSide: const BorderSide(color: AnaSoilColors.baseGray300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AnaSoilRadius.sm),
        borderSide: const BorderSide(
          color: AnaSoilColors.primaryGreen,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AnaSoilRadius.sm),
        borderSide: const BorderSide(color: Colors.red),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AnaSoilRadius.sm),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AnaSoilColors.primaryGreen),
    ),
  );
}
