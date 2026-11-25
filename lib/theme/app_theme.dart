import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const background = Color(0xFFFAF9FD);
  static const purple = Color(0xFF654DAA);
  static const buttonBackground = Color(0xFFEAE4F7);
  static const fieldBorder = Color(0xFFC9C6CE);

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: purple,
        surface: background,
        primary: purple,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: purple,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
