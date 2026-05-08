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

abstract final class AnaSoilSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

abstract final class AnaSoilRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
}
