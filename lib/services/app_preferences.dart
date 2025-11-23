import 'package:ayanna_school/services/providers/database_provider.dart';
import 'package:ayanna_school/models/entities/entreprise.dart';

class AppPreferences {
  static final AppPreferences _instance = AppPreferences._internal();

  factory AppPreferences() {
    return _instance;
  }

  AppPreferences._internal();

  /// Devise utilisée dans l'application (synchronous fallback)
  String get devise => 'CDF';

  /// Récupère la devise en lisant la table `entreprises`.
  ///
  /// Retourne la valeur de la colonne `devise` de la première entreprise
  /// si disponible, sinon renvoie la valeur de `devise` (fallback).
  Future<String> getDevise() async {
    try {
      // `floorDb` est initialisé par le provider database; utiliser directement
      // le DAO partagé pour éviter de dépendre d'un Ref ici.
      final List<Entreprise> entreprises = await floorDb.entrepriseDao
          .getAllEntreprises();
      if (entreprises.isNotEmpty) {
        final String? d = entreprises.first.devise;
        if (d != null && d.isNotEmpty) return d;
      }
    } catch (_) {
      // ignore and fallback
    }
    return devise;
  }

  /// Initialisation des préférences
  Future<void> init() async {
    // Pour l'instant, pas besoin d'initialisation spéciale
    // À implémenter si nécessaire avec shared_preferences
  }
}
