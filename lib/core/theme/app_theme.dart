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

  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF00FF7F),
        secondary: Color(0xFF00FF7F),
        surface: Colors.white,
        onSurface: Colors.black87,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        shadowColor: Colors.black12,
      ),
      cardColor: Colors.white,
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black12,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black87),
        headlineMedium: TextStyle(color: Color(0xFF00FF7F)),
        titleLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
      ),
      dividerTheme: const DividerThemeData(
        color: Colors.black12,
        thickness: 1,
      ),
      iconTheme: const IconThemeData(
        color: Colors.black54,
      ),
      listTileTheme: const ListTileThemeData(
        textColor: Colors.black87,
        iconColor: Colors.black54,
      ),
    );
  }
}