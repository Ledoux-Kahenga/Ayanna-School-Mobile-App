import 'package:flutter/material.dart';

class AyannaColors {
  static const Color orange = Color(0xFFFFA500); // Orange Principal
  static const Color darkGrey = Color(0xFF333333); // Gris Foncé (Texte)
  static const Color lightGrey = Color(0xFFF4F4F4); // Gris Clair (Fond)
  static const Color white = Color(0xFFFFFFFF); // Blanc Pur
  static const Color successGreen = Color(0xFF28A745); // Vert de Succès
  static const Color selectionBlue = Color(0xFF3C8DBC); // Bleu de Sélection
}

final ThemeData ayannaTheme = ThemeData(
  primaryColor: AyannaColors.orange,
  scaffoldBackgroundColor: AyannaColors.lightGrey,
  cardColor: AyannaColors.white,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AyannaColors.orange,
    primary: AyannaColors.orange,
    secondary: AyannaColors.selectionBlue,
    background: AyannaColors.lightGrey,
    surface: AyannaColors.white,
    onPrimary: AyannaColors.white,
    onSecondary: AyannaColors.white,
    onBackground: AyannaColors.darkGrey,
    onSurface: AyannaColors.darkGrey,
    error: Colors.red,
    onError: AyannaColors.white,
    brightness: Brightness.light,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AyannaColors.orange,
    foregroundColor: AyannaColors.white,
    titleTextStyle: TextStyle(
      color: AyannaColors.white,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
    iconTheme: IconThemeData(color: AyannaColors.white),
    elevation: 2,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AyannaColors.white,
    selectedItemColor: AyannaColors.orange,
    unselectedItemColor: AyannaColors.darkGrey,
    selectedIconTheme: IconThemeData(color: AyannaColors.orange),
    unselectedIconTheme: IconThemeData(color: AyannaColors.darkGrey),
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
  ),
  cardTheme: const CardTheme(
    color: AyannaColors.white,
    elevation: 2,
    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AyannaColors.orange,
    foregroundColor: AyannaColors.white,
    elevation: 2,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStatePropertyAll(AyannaColors.orange),
      foregroundColor: MaterialStatePropertyAll(AyannaColors.white),
      textStyle: MaterialStatePropertyAll(TextStyle(fontWeight: FontWeight.bold)),
      shape: MaterialStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStatePropertyAll(AyannaColors.white),
      foregroundColor: MaterialStatePropertyAll(AyannaColors.orange),
      side: MaterialStatePropertyAll(BorderSide(color: AyannaColors.orange)),
      textStyle: MaterialStatePropertyAll(TextStyle(fontWeight: FontWeight.bold)),
      shape: MaterialStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: AyannaColors.darkGrey),
    bodyMedium: TextStyle(color: AyannaColors.darkGrey),
    titleLarge: TextStyle(color: AyannaColors.darkGrey, fontWeight: FontWeight.bold),
    titleMedium: TextStyle(color: AyannaColors.darkGrey),
    labelLarge: TextStyle(color: AyannaColors.orange),
    displaySmall: TextStyle(color: AyannaColors.darkGrey),
    headlineSmall: TextStyle(color: AyannaColors.darkGrey),
    bodySmall: TextStyle(color: Color(0xFF666666)), // Texte secondaire
  ),
  iconTheme: const IconThemeData(color: AyannaColors.darkGrey),
  dividerColor: AyannaColors.lightGrey,
  chipTheme: ChipThemeData(
    backgroundColor: AyannaColors.white,
    selectedColor: AyannaColors.selectionBlue.withOpacity(0.2),
    disabledColor: AyannaColors.lightGrey,
    labelStyle: const TextStyle(color: AyannaColors.darkGrey),
    secondaryLabelStyle: const TextStyle(color: AyannaColors.selectionBlue),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    brightness: Brightness.light,
  ),
);
