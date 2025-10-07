import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF00FF7F),
        secondary: Color(0xFF00FF7F),
        surface: Colors.black,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Color(0xFF00FF7F),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
        headlineMedium: TextStyle(color: Color(0xFF00FF7F)),
      ),
    );
  }
}