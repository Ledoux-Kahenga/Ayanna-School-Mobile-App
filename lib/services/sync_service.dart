import '../models/app_database.dart';
import '../models/entities/entreprise.dart';
import 'api/api_client.dart';

class SyncService {
  final AppDatabase _database;
  final ApiClient _apiClient;

  SyncService(this._database, this._apiClient);

  // Synchronisation des entreprises
  Future<void> syncEntreprises() async {
    try {
      // 1. Envoyer les entreprises non synchronisées vers le serveur
      await _uploadUnsyncedEntreprises();

      // 2. Récupérer les entreprises depuis le serveur
      await _downloadEntreprises();
    } catch (e) {
      print('Erreur lors de la synchronisation des entreprises: $e');
      rethrow;
    }
  }

  Future<void> _uploadUnsyncedEntreprises() async {
    final unsyncedEntreprises =
        await _database.entrepriseDao.getUnsyncedEntreprises();

    for (final entreprise in unsyncedEntreprises) {
      try {
        if (entreprise.serverId == null) {
          // Créer une nouvelle entreprise sur le serveur
          final response = await _apiClient.entrepriseService.createEntreprise(
            entreprise.toJson(),
          );

          if (response.isSuccessful && response.body != null) {
            final serverData = response.body!;
            final serverId = serverData['id'] as int;

            // Mettre à jour l'ID serveur et marquer comme synchronisé
            await _database.entrepriseDao.updateServerIdAndSync(
              entreprise.id!,
              serverId,
            );
          }
        } else {
          // Mettre à jour l'entreprise existante sur le serveur
          final response = await _apiClient.entrepriseService.updateEntreprise(
            entreprise.serverId!,
            entreprise.toJson(),
          );

          if (response.isSuccessful) {
            // Marquer comme synchronisé
            await _database.entrepriseDao.markAsSynced(entreprise.id!);
          }
        }
      } catch (e) {
        print('Erreur lors de l\'upload de l\'entreprise ${entreprise.id}: $e');
        // Continuer avec les autres entreprises
      }
    }
  }

  Future<void> _downloadEntreprises() async {
    try {
      final response = await _apiClient.entrepriseService.getEntreprises();

      if (response.isSuccessful && response.body != null) {
        final List<Map<String, dynamic>> enterprisesData = response.body!;
        final List<Entreprise> enterprises =
            enterprisesData.map((data) => Entreprise.fromJson(data)).toList();

        // Mettre à jour ou insérer les entreprises dans la base locale
        for (final enterprise in enterprises) {
          final existingEnterprise = await _database.entrepriseDao
              .getEntrepriseByServerId(enterprise.serverId!);

          if (existingEnterprise != null) {
            // Mettre à jour l'entreprise existante
            final updatedEnterprise = enterprise.copyWith(
              id: existingEnterprise.id,
              isSync: true,
            );
            await _database.entrepriseDao.updateEntreprise(updatedEnterprise);
          } else {
            // Insérer la nouvelle entreprise
            final newEnterprise = enterprise.copyWith(isSync: true);
            await _database.entrepriseDao.insertEntreprise(newEnterprise);
          }
        }
      }
    } catch (e) {
      print('Erreur lors du téléchargement des entreprises: $e');
      rethrow;
    }
  }

  // Méthode générique pour la synchronisation complète
  Future<void> fullSync() async {
    await syncEntreprises();
    // Ajouter d'autres synchronisations ici (utilisateurs, classes, etc.)
  }

  // Vérifier la connectivité avant la synchronisation
  Future<bool> canSync() async {
    try {
      // Faire un ping simple vers le serveur
      final response = await _apiClient.entrepriseService.getEntreprises();
      return response.isSuccessful;
    } catch (e) {
      return false;
    }
  }
}
