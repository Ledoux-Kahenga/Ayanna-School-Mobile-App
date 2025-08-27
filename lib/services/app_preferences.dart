// lib/services/app_preferences.dart

import '../models/models.dart';
import 'school_queries.dart';

class AppPreferences {
  // Singleton pour une instance unique
  static final AppPreferences _instance = AppPreferences._internal();
  factory AppPreferences() => _instance;
  AppPreferences._internal();

  Entreprise? _currentEntreprise;

  Future<void> init() async {
    // Supposons que l'entreprise avec l'ID 2 est l'entreprise active
    // Idéalement, cet ID devrait être stocké après la connexion de l'utilisateur
    _currentEntreprise = await SchoolQueries.getEntrepriseById(2);
  }

  String get devise {
    // Retourne la devise de l'entreprise ou '$' par défaut
    return _currentEntreprise?.devise ?? '\$';
  }

  Entreprise? get entreprise {
    return _currentEntreprise;
  }
}