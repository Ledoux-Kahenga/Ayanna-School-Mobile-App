import 'package:flutter/material.dart';
import '../models/app_database.dart';
import '../models/entities/entreprise.dart';
import '../services/api/api_client.dart';
import '../services/sync_service.dart';

class EntrepriseService extends ChangeNotifier {
  late final AppDatabase _database;
  late final ApiClient _apiClient;
  late final SyncService _syncService;

  List<Entreprise> _entreprises = [];
  bool _isLoading = false;
  String? _error;

  List<Entreprise> get entreprises => _entreprises;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> initialize() async {
    _database = await AppDatabase.create();
    _apiClient = ApiClient();
    _syncService = SyncService(_database, _apiClient);
    await loadEntreprises();
  }

  Future<void> loadEntreprises() async {
    _setLoading(true);
    try {
      _entreprises = await _database.entrepriseDao.getAllEntreprises();
      _setError(null);
    } catch (e) {
      _setError('Erreur lors du chargement des entreprises: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createEntreprise(Entreprise entreprise) async {
    _setLoading(true);
    try {
      final now = DateTime.now();
      final newEntreprise = entreprise.copyWith(
        dateCreation: now,
        dateModification: now,
        updatedAt: now,
        isSync: false, // Marquer comme non synchronisé
      );

      await _database.entrepriseDao.insertEntreprise(newEntreprise);
      await loadEntreprises();
      _setError(null);
    } catch (e) {
      _setError('Erreur lors de la création de l\'entreprise: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateEntreprise(Entreprise entreprise) async {
    _setLoading(true);
    try {
      final updatedEntreprise = entreprise.copyWith(
        dateModification: DateTime.now(),
        updatedAt: DateTime.now(),
        isSync: false, // Marquer comme non synchronisé
      );

      await _database.entrepriseDao.updateEntreprise(updatedEntreprise);
      await loadEntreprises();
      _setError(null);
    } catch (e) {
      _setError('Erreur lors de la mise à jour de l\'entreprise: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteEntreprise(Entreprise entreprise) async {
    _setLoading(true);
    try {
      await _database.entrepriseDao.deleteEntreprise(entreprise);
      await loadEntreprises();
      _setError(null);
    } catch (e) {
      _setError('Erreur lors de la suppression de l\'entreprise: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> syncWithServer() async {
    _setLoading(true);
    try {
      final canSync = await _syncService.canSync();
      if (!canSync) {
        throw Exception('Pas de connexion au serveur');
      }

      await _syncService.syncEntreprises();
      await loadEntreprises();
      _setError(null);
    } catch (e) {
      _setError('Erreur lors de la synchronisation: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  @override
  void dispose() {
    _apiClient.dispose();
    super.dispose();
  }
}
