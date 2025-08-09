import 'package:flutter/material.dart';

class AyannaTheme {
  static const Color primary = Color(0xFF6B4A2B); // Marron foncé
  static const Color accent = Color(0xFFC7A97B); // Beige moyen
  static const Color background = Color(0xFFF8F5F0); // Fond très clair
  static const Color light = Color(0xFFE9D7B0); // Beige clair
  static const Color textDark = Color(0xFF3E2723); // Pour les textes foncés

  static ThemeData get themeData => ThemeData(
    primaryColor: primary,
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: primary,
      secondary: accent,
      surface: background,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: light,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: accent, width: 2),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textDark),
      bodyMedium: TextStyle(color: textDark),
      titleLarge: TextStyle(color: primary, fontWeight: FontWeight.bold),
    ),
  );
}
