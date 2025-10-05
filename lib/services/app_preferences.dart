/// Service pour gérer les préférences de l'application
class AppPreferences {
  static final AppPreferences _instance = AppPreferences._internal();

  factory AppPreferences() {
    return _instance;
  }

  AppPreferences._internal();

  /// Devise utilisée dans l'application
  String get devise => 'CDF';

  /// Initialisation des préférences
  Future<void> init() async {
    // Pour l'instant, pas besoin d'initialisation spéciale
    // À implémenter si nécessaire avec shared_preferences
  }
}
