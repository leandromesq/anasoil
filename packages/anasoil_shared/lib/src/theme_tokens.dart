import 'package:flutter/material.dart';

/// Shared AnaSoil design tokens. Apps can adapt typography/layout per platform.
abstract final class AnaSoilColors {
  static const primaryGreen = Color(0xFF2D5A32);
  static const primaryGreenLight = Color(0xFF4A7C59);
  static const primaryGreenDark = Color(0xFF1B3A1F);
  static const primaryGreenSoft = Color(0xFFE9F0EA);

  static const warningAmber = Color(0xFFB7791F);
  static const warningAmberLight = Color(0xFFFFF3D6);
  static const warningAmberDark = Color(0xFF7A4F12);

  static const secondaryRed = Color(0xFFDC3545);
  static const secondaryRedLight = Color(0xFFF8D7DA);
  static const secondaryRedDark = Color(0xFFB02A37);

  static const baseWhite = Color(0xFFFFFFFF);
  static const baseGray50 = Color(0xFFFAFAFA);
  static const baseGray100 = Color(0xFFF5F5F5);
  static const baseGray200 = Color(0xFFEEEEEE);
  static const baseGray300 = Color(0xFFE0E0E0);
  static const baseGray400 = Color(0xFFBDBDBD);
  static const baseGray500 = Color(0xFF9E9E9E);
  static const baseGray600 = Color(0xFF757575);
  static const baseGray900 = Color(0xFF212121);
}

abstract final class AnaSoilSemanticColors {
  static const surface = AnaSoilColors.baseWhite;
  static const surfaceSubtle = AnaSoilColors.baseGray50;
  static const surfaceMuted = AnaSoilColors.baseGray100;

  static const textPrimary = AnaSoilColors.baseGray900;
  static const textSecondary = AnaSoilColors.baseGray600;
  static const textMuted = AnaSoilColors.baseGray500;

  static const borderSubtle = AnaSoilColors.baseGray200;
  static const borderStrong = AnaSoilColors.baseGray300;

  static const actionPrimary = AnaSoilColors.primaryGreen;
  static const actionPrimaryHover = AnaSoilColors.primaryGreenDark;
  static const actionPrimarySoft = AnaSoilColors.primaryGreenSoft;

  static const statusSuccess = AnaSoilColors.primaryGreen;
  static const statusSuccessSoft = AnaSoilColors.primaryGreenSoft;
  static const statusWarning = AnaSoilColors.warningAmber;
  static const statusWarningSoft = AnaSoilColors.warningAmberLight;
  static const statusDanger = AnaSoilColors.secondaryRed;
  static const statusDangerSoft = AnaSoilColors.secondaryRedLight;

  static const soilLow = Color(0xFFE53935);
  static const soilLowSoft = Color(0xFFFFEBEE);
  static const soilMedium = Color(0xFFFFA726);
  static const soilMediumSoft = Color(0xFFFFF3E0);
  static const soilHigh = Color(0xFF43A047);
  static const soilHighSoft = Color(0xFFE8F5E9);
}

abstract final class AnaSoilSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const xxxl = 40.0;
}

abstract final class AnaSoilRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
}

abstract final class AnaSoilBreakpoints {
  static const mobile = 700.0;
  static const tablet = 800.0;
  static const desktop = 1024.0;
}

abstract final class AnaSoilElevation {
  static const subtleBlur = 8.0;
  static const cardBlur = 10.0;
  static const subtleOffset = Offset(0, 2);
}
