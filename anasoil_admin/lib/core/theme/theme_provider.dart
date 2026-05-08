import 'package:flutter/material.dart';
import 'package:anasoil_admin/core/theme/app_theme.dart';

/// Controls the active theme mode for the admin panel.
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void setDark(bool value) {
    _themeMode = value ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  ThemeData get theme => isDark ? darkTheme : AppTheme.lightTheme;

  static final ThemeData darkTheme = _buildDarkTheme();

  static ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppTheme.primaryGreen,
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      colorScheme: const ColorScheme.dark(
        primary: AppTheme.primaryGreen,
        onPrimary: AppTheme.baseWhite,
        primaryContainer: AppTheme.primaryGreenLight,
        onPrimaryContainer: AppTheme.baseWhite,
        secondary: AppTheme.secondaryRed,
        onSecondary: AppTheme.baseWhite,
        secondaryContainer: AppTheme.secondaryRedLight,
        onSecondaryContainer: AppTheme.secondaryRedDark,
        surface: Color(0xFF1E293B),
        onSurface: AppTheme.baseWhite,
        surfaceContainerHighest: Color(0xFF334155),
        error: AppTheme.secondaryRed,
        onError: AppTheme.baseWhite,
        errorContainer: AppTheme.secondaryRedLight,
        onErrorContainer: AppTheme.secondaryRedDark,
        outline: Color(0xFF475569),
        outlineVariant: Color(0xFF334155),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E293B),
        foregroundColor: AppTheme.baseWhite,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF1E293B),
        elevation: 1,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF334155),
        thickness: 1,
        space: 1,
      ),
    );
  }
}
