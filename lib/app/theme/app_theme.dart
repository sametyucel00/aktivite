import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0D5C63),
      brightness: Brightness.light,
      primary: const Color(0xFF0D5C63),
      secondary: const Color(0xFFE6B655),
      surface: const Color(0xFFF6F4EE),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF6F4EE),
      appBarTheme: const AppBarTheme(centerTitle: false),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF69A7AA),
      brightness: Brightness.dark,
      primary: const Color(0xFF69A7AA),
      secondary: const Color(0xFFE6B655),
      surface: const Color(0xFF161C1D),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFF101516),
      appBarTheme: const AppBarTheme(centerTitle: false),
      cardTheme: CardThemeData(
        color: const Color(0xFF1A2223),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A2223),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
