import 'package:chopper/chopper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import 'entreprise_service.dart';
import 'utilisateur_service.dart';
import 'annee_scolaire_service.dart';
import 'enseignant_service.dart';
import 'classe_service.dart';
import 'eleve_service.dart';
import 'responsable_service.dart';
import 'cours_service.dart';
import 'note_periode_service.dart';
import 'periode_service.dart';
import 'frais_scolaire_service.dart';
import 'paiement_frais_service.dart';
import 'creance_service.dart';
import 'classe_comptable_service.dart';
import 'compte_comptable_service.dart';
import 'journal_comptable_service.dart';
import 'ecriture_comptable_service.dart';
import 'depense_service.dart';
import 'licence_service.dart';
import 'config_ecole_service.dart';
import 'comptes_config_service.dart';
import 'periodes_classes_service.dart';

class ApiClient {
  static const String baseUrl = 'https://your-api-url.com/api';

  late final ChopperClient _client;

  // Services instances
  late final EntrepriseService _entrepriseService;
  late final UtilisateurService _utilisateurService;
  late final AnneeScolaireService _anneeScolaireService;
  late final EnseignantService _enseignantService;
  late final ClasseService _classeService;
  late final EleveService _eleveService;
  late final ResponsableService _responsableService;
  late final CoursService _coursService;
  late final NotePeriodeService _notePeriodeService;
  late final PeriodeService _periodeService;
  late final FraisScolaireService _fraisScolaireService;
  late final PaiementFraisService _paiementFraisService;
  late final CreanceService _creanceService;
  late final ClasseComptableService _classeComptableService;
  late final CompteComptableService _compteComptableService;
  late final JournalComptableService _journalComptableService;
  late final EcritureComptableService _ecritureComptableService;
  late final DepenseService _depenseService;
  late final LicenceService _licenceService;
  late final ConfigEcoleService _configEcoleService;
  late final ComptesConfigService _comptesConfigService;
  late final PeriodesClassesService _periodesClassesService;

  ApiClient() {
    _client = ChopperClient(
      baseUrl: Uri.parse(baseUrl),
      services: [
        EntrepriseService.create(),
        UtilisateurService.create(),
        AnneeScolaireService.create(),
        EnseignantService.create(),
        ClasseService.create(),
        EleveService.create(),
        ResponsableService.create(),
        CoursService.create(),
        NotePeriodeService.create(),
        PeriodeService.create(),
        FraisScolaireService.create(),
        PaiementFraisService.create(),
        CreanceService.create(),
        ClasseComptableService.create(),
        CompteComptableService.create(),
        JournalComptableService.create(),
        EcritureComptableService.create(),
        DepenseService.create(),
        LicenceService.create(),
        ConfigEcoleService.create(),
        ComptesConfigService.create(),
        PeriodesClassesService.create(),
      ],
      converter: const JsonConverter(),
      interceptors: [HttpLoggingInterceptor(), AuthInterceptor()],
    );

    // Initialize all services
    _entrepriseService = _client.getService<EntrepriseService>();
    _utilisateurService = _client.getService<UtilisateurService>();
    _anneeScolaireService = _client.getService<AnneeScolaireService>();
    _enseignantService = _client.getService<EnseignantService>();
    _classeService = _client.getService<ClasseService>();
    _eleveService = _client.getService<EleveService>();
    _responsableService = _client.getService<ResponsableService>();
    _coursService = _client.getService<CoursService>();
    _notePeriodeService = _client.getService<NotePeriodeService>();
    _periodeService = _client.getService<PeriodeService>();
    _fraisScolaireService = _client.getService<FraisScolaireService>();
    _paiementFraisService = _client.getService<PaiementFraisService>();
    _creanceService = _client.getService<CreanceService>();
    _classeComptableService = _client.getService<ClasseComptableService>();
    _compteComptableService = _client.getService<CompteComptableService>();
    _journalComptableService = _client.getService<JournalComptableService>();
    _ecritureComptableService = _client.getService<EcritureComptableService>();
    _depenseService = _client.getService<DepenseService>();
    _licenceService = _client.getService<LicenceService>();
    _configEcoleService = _client.getService<ConfigEcoleService>();
    _comptesConfigService = _client.getService<ComptesConfigService>();
    _periodesClassesService = _client.getService<PeriodesClassesService>();
  }

  // Getters for all services
  EntrepriseService get entrepriseService => _entrepriseService;
  UtilisateurService get utilisateurService => _utilisateurService;
  AnneeScolaireService get anneeScolaireService => _anneeScolaireService;
  EnseignantService get enseignantService => _enseignantService;
  ClasseService get classeService => _classeService;
  EleveService get eleveService => _eleveService;
  ResponsableService get responsableService => _responsableService;
  CoursService get coursService => _coursService;
  NotePeriodeService get notePeriodeService => _notePeriodeService;
  PeriodeService get periodeService => _periodeService;
  FraisScolaireService get fraisScolaireService => _fraisScolaireService;
  PaiementFraisService get paiementFraisService => _paiementFraisService;
  CreanceService get creanceService => _creanceService;
  ClasseComptableService get classeComptableService => _classeComptableService;
  CompteComptableService get compteComptableService => _compteComptableService;
  JournalComptableService get journalComptableService =>
      _journalComptableService;
  EcritureComptableService get ecritureComptableService =>
      _ecritureComptableService;
  DepenseService get depenseService => _depenseService;
  LicenceService get licenceService => _licenceService;
  ConfigEcoleService get configEcoleService => _configEcoleService;
  ComptesConfigService get comptesConfigService => _comptesConfigService;
  PeriodesClassesService get periodesClassesService => _periodesClassesService;

  void dispose() {
    _client.dispose();
  }
}

class AuthInterceptor implements Interceptor {
  static const String _tokenKey = 'auth_token';

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
    Chain<BodyType> chain,
  ) async {
    final request = chain.request;

    // Ajouter le token d'authentification si nécessaire
    String? token = await _getAuthToken();

    final newRequest =
        token != null
            ? request.copyWith(
              headers: {...request.headers, 'Authorization': 'Bearer $token'},
            )
            : request;

    return chain.proceed(newRequest);
  }

  Future<String?> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      print('Erreur lors de la récupération du token: $e');
      return null;
    }
  }

  /// Sauvegarder le token d'authentification
  static Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    } catch (e) {
      print('Erreur lors de la sauvegarde du token: $e');
    }
  }

  /// Supprimer le token d'authentification
  static Future<void> clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
    } catch (e) {
      print('Erreur lors de la suppression du token: $e');
    }
  }

  /// Vérifier si un token existe
  static Future<bool> hasToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      return token != null && token.isNotEmpty;
    } catch (e) {
      print('Erreur lors de la vérification du token: $e');
      return false;
    }
  }
}
