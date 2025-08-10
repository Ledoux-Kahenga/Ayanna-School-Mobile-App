import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const String _keyIsFirstLaunch = 'is_first_launch';
  static const String _keyCurrentSchoolYearId = 'current_school_year_id';
  static const String _keyIsConfigured = 'is_configured';

  // Vérifie si c'est le premier lancement de l'application
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsFirstLaunch) ?? true;
  }

  // Marque l'application comme ayant été lancée
  static Future<void> setFirstLaunchCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsFirstLaunch, false);
  }

  // Vérifie si l'application est configurée (année scolaire sélectionnée)
  static Future<bool> isConfigured() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsConfigured) ?? false;
  }

  // Marque l'application comme configurée
  static Future<void> setConfigured(bool configured) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsConfigured, configured);
  }

  // Sauvegarde l'ID de l'année scolaire en cours
  static Future<void> setCurrentSchoolYearId(int yearId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCurrentSchoolYearId, yearId);
    await setConfigured(true);
  }

  // Récupère l'ID de l'année scolaire en cours
  static Future<int?> getCurrentSchoolYearId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCurrentSchoolYearId);
  }

  // Remet à zéro les préférences (pour debugging ou réinitialisation)
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
