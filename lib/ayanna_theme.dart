import 'package:flutter/material.dart';

class AyannaTheme {
  // Palette de couleurs professionnelle inspirée du logo
  static const Color primary = Color(0xFF6B4A2B); // Marron foncé principal
  static const Color primaryLight = Color(0xFF8B6340); // Marron plus clair
  static const Color primaryDark = Color(0xFF4A3320); // Marron très foncé

  static const Color accent = Color(0xFFC7A97B); // Beige doré
  static const Color accentLight = Color(0xFFE2C699); // Beige très clair
  static const Color accentDark = Color(0xFFA6895D); // Beige foncé

  static const Color background = Color(0xFFFAF8F5); // Fond crème très léger
  static const Color surface = Color(0xFFF5F2EE); // Surface beige très pâle
  static const Color cardBackground = Color(
    0xFFFFFFFF,
  ); // Blanc pur pour les cartes

  static const Color textPrimary = Color(
    0xFF2C1810,
  ); // Texte principal très foncé
  static const Color textSecondary = Color(0xFF5D4A3A); // Texte secondaire
  static const Color textLight = Color(0xFF8A7A6B); // Texte clair

  static const Color success = Color(0xFF4CAF50); // Vert succès
  static const Color warning = Color(0xFFFF9800); // Orange avertissement
  static const Color error = Color(0xFFE53935); // Rouge erreur
  static const Color info = Color(0xFF2196F3); // Bleu information

  static ThemeData get themeData => ThemeData(
    primaryColor: primary,
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: primary,
      secondary: accent,
      surface: surface,
      error: error,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 2,
      shadowColor: primaryDark.withOpacity(0.3),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: primary,
        elevation: 3,
        shadowColor: primaryDark.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
    ),
    cardTheme: CardThemeData(
      color: cardBackground,
      elevation: 3,
      shadowColor: primaryDark.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: accentDark, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: accentLight, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: accent, width: 2),
      ),
      labelStyle: TextStyle(color: textSecondary),
      hintStyle: TextStyle(color: textLight),
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        color: textPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 32,
      ),
      headlineMedium: TextStyle(
        color: textPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 28,
      ),
      headlineSmall: TextStyle(
        color: textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 24,
      ),
      titleLarge: TextStyle(
        color: primary,
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
      titleMedium: TextStyle(
        color: primary,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      titleSmall: TextStyle(
        color: textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
      bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
      bodySmall: TextStyle(color: textLight, fontSize: 12),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accentDark, width: 1),
        ),
      ),
    ),
  );
}
