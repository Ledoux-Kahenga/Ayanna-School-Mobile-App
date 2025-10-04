import 'package:ayanna_school/models/entities/classe.dart';
import 'package:ayanna_school/models/entities/eleve.dart';
import 'package:ayanna_school/models/entities/enseignant.dart';
import 'package:ayanna_school/models/entities/frais_scolaire.dart';
import 'package:ayanna_school/models/entities/note_periode.dart';
import 'package:ayanna_school/models/entities/paiement_frais.dart';
import 'package:ayanna_school/models/entities/utilisateur.dart';
import 'package:ayanna_school/models/entities/entreprise.dart';
import 'package:ayanna_school/models/entities/responsable.dart';
import 'package:ayanna_school/models/entities/classe_comptable.dart';
import 'package:ayanna_school/models/entities/compte_comptable.dart';
import 'package:ayanna_school/models/entities/licence.dart';
import 'package:ayanna_school/models/entities/annee_scolaire.dart';
import 'package:ayanna_school/models/entities/periode.dart';
import 'package:ayanna_school/models/entities/config_ecole.dart';
import 'package:ayanna_school/models/entities/comptes_config.dart';
import 'package:ayanna_school/models/entities/periodes_classes.dart';
import 'package:ayanna_school/models/entities/cours.dart';
import 'package:ayanna_school/models/entities/creance.dart';
import 'package:ayanna_school/models/entities/journal_comptable.dart';
import 'package:ayanna_school/models/entities/depense.dart';
import 'package:ayanna_school/models/entities/ecriture_comptable.dart';

import 'package:ayanna_school/services/providers/data_provider.dart';
import 'package:ayanna_school/services/providers/shared_preferences_provider.dart';
import 'package:ayanna_school/services/providers/database_provider.dart';
import 'package:ayanna_school/services/helpers/sync_upload_helper.dart';
import 'package:ayanna_school/services/helpers/id_mapping_helper.dart';
import 'package:ayanna_school/models/sync_upload_request.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../api/sync_service.dart';
import '../../models/sync_response.dart';

part 'sync_provider_new.g.dart';

/// États de synchronisation
enum SyncStatus { idle, downloading, uploading, processing, error }

class SyncState {
  final SyncStatus status;
  final String? message;
  final DateTime? lastSync;
  final int? totalChanges;
  final int? processedChanges;
  final String? error;

  const SyncState({
    this.status = SyncStatus.idle,
    this.message,
    this.lastSync,
    this.totalChanges,
    this.processedChanges,
    this.error,
  });

  SyncState copyWith({
    SyncStatus? status,
    String? message,
    DateTime? lastSync,
    int? totalChanges,
    int? processedChanges,
    String? error,
  }) {
    return SyncState(
      status: status ?? this.status,
      message: message ?? this.message,
      lastSync: lastSync ?? this.lastSync,
      totalChanges: totalChanges ?? this.totalChanges,
      processedChanges: processedChanges ?? this.processedChanges,
      error: error ?? this.error,
    );
  }

  double get progress {
    if (totalChanges == null || processedChanges == null || totalChanges == 0) {
      return 0.0;
    }
    return processedChanges! / totalChanges!;
  }
}

/// Gestionnaire de synchronisation
class SyncManager {
  final SyncService _syncService;

  SyncManager(this._syncService);

  /// Synchronise les données depuis le serveur
  Future<SyncResponse?> downloadChanges({
    required String userEmail,
    DateTime? since,
  }) async {
    try {
      final sinceString =
          since?.toIso8601String() ?? '1970-01-01T00:00:00.000Z';

      final response = await _syncService.downloadChanges(
        since: sinceString,
        clientId: 'flutter-client',
        userEmail: userEmail,
      );

      return response.body!;
    } catch (e) {
      rethrow;
    }
  }

  /// Upload les changements locaux avec la nouvelle structure
  Future<SyncUploadResponse?> uploadChanges(
    SyncUploadRequest uploadRequest,
  ) async {
    try {
      final response = await _syncService.uploadChanges(uploadRequest);

      if (response.isSuccessful && response.body != null) {
        return response.body;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Upload les changements locaux (version legacy)
  Future<SyncUploadResponse?> uploadChangesLegacy(
    Map<String, dynamic> changes,
  ) async {
    try {
      // Convertir le Map en SyncUploadRequest pour compatibilité
      final builder = SyncUploadRequestBuilder(
        clientId: changes['client_id'] ?? 'flutter-client',
      );

      final changesList = changes['changes'] as List<dynamic>? ?? [];
      for (final change in changesList) {
        final changeMap = change as Map<String, dynamic>;
        builder.addChange(
          SyncChangeUpload(
            table: changeMap['table'],
            operation: changeMap['operation'],
            action: changeMap['action'],
            data: changeMap['data'],
          ),
        );
      }

      final uploadRequest = builder.build();
      final response = await _syncService.uploadChanges(uploadRequest);

      if (response.isSuccessful && response.body != null) {
        return response.body;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Marque les changements comme synchronisés
  Future<bool> acknowledgeChanges(List<String> changeIds) async {
    try {
      final response = await _syncService.acknowledgeChanges({
        'change_ids': changeIds,
      });

      return response.isSuccessful;
    } catch (e) {
      return false;
    }
  }

  /// Vérifie la connectivité avec le serveur
  Future<bool> ping() async {
    try {
      final response = await _syncService.ping();
      return response.isSuccessful;
    } catch (e) {
      return false;
    }
  }

  /// Obtient le statut de synchronisation
  Future<Map<String, dynamic>?> getSyncStatus(String userEmail) async {
    try {
      final response = await _syncService.getSyncStatus(userEmail: userEmail);

      if (response.isSuccessful && response.body != null) {
        return response.body;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

/// Provider pour le service de synchronisation
@riverpod
SyncService syncService(SyncServiceRef ref) {
  return SyncService.create();
}

/// Provider pour gérer la synchronisation bidirectionnelle
@riverpod
SyncManager syncManager(SyncManagerRef ref) {
  final syncService = ref.watch(syncServiceProvider);
  return SyncManager(syncService);
}

/// Provider pour l'état de synchronisation
@riverpod
class SyncStateNotifier extends _$SyncStateNotifier {
  late final SyncManager _syncManager;

  @override
  SyncState build() {
    _syncManager = ref.watch(syncManagerProvider);
    return const SyncState();
  }

  /// Upload une seule entité (pour les opérations CRUD individuelles)
  Future<void> uploadSingleEntity<T>(
    T entity,
    String tableName,
    String operation, { // 'create', 'update', 'delete'
    required String userEmail,
  }) async {
    final helper = SyncUploadHelper(clientId: 'flutter-client');

    try {
      // Ajouter l'entité selon l'opération
      switch (operation.toLowerCase()) {
        case 'create':
          helper.addEntity(
            entity,
            tableName,
            SyncOperation.insert,
            toJson: (e) => (e as dynamic).toJson(),
            getServerId: (e) => (e as dynamic).serverId,
          );
          break;
        case 'update':
          helper.addEntity(
            entity,
            tableName,
            SyncOperation.update,
            toJson: (e) => (e as dynamic).toJson(),
            getServerId: (e) => (e as dynamic).serverId,
          );
          break;
        case 'delete':
          helper.addEntity(
            entity,
            tableName,
            SyncOperation.delete,
            toJson: (e) => (e as dynamic).toJson(),
            getServerId: (e) => (e as dynamic).serverId,
          );
          break;
        default:
          throw ArgumentError('Opération non supportée: $operation');
      }

      if (helper.hasChanges) {
        final uploadRequest = helper.build();
        final response = await _syncManager.uploadChanges(uploadRequest);

        if (response != null && response.success) {
          // Traitement du mapping des IDs si nécessaire
          if (response.hasIdMapping) {
            final idMappingHelper = IdMappingHelper(ref);
            await idMappingHelper.processIdMapping(response);
          }

          // Marquer l'entité comme synchronisée
          await _markSingleEntityAsSynced(entity, tableName);
        }
      }
    } catch (e) {
      print('Erreur lors de l\'upload de l\'entité $tableName: $e');
      rethrow;
    }
  }

  /// Marquer une entité individuelle comme synchronisée
  Future<void> _markSingleEntityAsSynced<T>(T entity, String tableName) async {
    final database = ref.read(databaseProvider);

    try {
      // Mettre à jour isSync = true pour l'entité
      final entityWithSync = entity as dynamic;
      entityWithSync.isSync = true;

      switch (tableName) {
        case 'eleves':
          await database.eleveDao.updateEleve(entityWithSync as Eleve);
          break;
        case 'enseignants':
          await database.enseignantDao.updateEnseignant(
            entityWithSync as Enseignant,
          );
          break;
        case 'classes':
          await database.classeDao.updateClasse(entityWithSync as Classe);
          break;
        // Ajouter d'autres cas selon les besoins
        default:
          print('Table non supportée pour le marquage sync: $tableName');
      }
    } catch (e) {
      print('Erreur lors du marquage de synchronisation pour $tableName: $e');
    }
  }

  /// Lance une synchronisation complète
  Future<void> performFullSync(String userEmail) async {
    try {
      state = state.copyWith(
        status: SyncStatus.downloading,
        message: 'Téléchargement des changements...',
        error: null,
      );

      // Récupérer la dernière date de synchronisation depuis SharedPreferences
      final syncPrefs = ref.read(syncPreferencesNotifierProvider.notifier);
      final lastSyncDate = await syncPrefs.getLastSyncDate();

      // Télécharger les changements depuis la dernière synchronisation
      final syncResponse = await _syncManager.downloadChanges(
        userEmail: userEmail,
        since: lastSyncDate,
      );

      if (syncResponse == null) {
        state = state.copyWith(
          status: SyncStatus.error,
          error: 'Échec du téléchargement des changements',
        );
        return;
      }

      state = state.copyWith(
        status: SyncStatus.processing,
        message: 'Traitement des changements...',
        totalChanges: syncResponse.total,
        processedChanges: 0,
        lastSync: lastSyncDate,
      );

      // Traiter les changements
      await _processChanges(syncResponse.changes);

      // Sauvegarder la nouvelle date de synchronisation
      final now = DateTime.now();
      await syncPrefs.saveLastSyncDate(now);
      await syncPrefs.saveLastSyncUserEmail(userEmail);

      state = state.copyWith(
        status: SyncStatus.idle,
        message: 'Synchronisation terminée',
        lastSync: now,
        processedChanges: syncResponse.total,
      );
    } catch (e) {
      state = state.copyWith(
        status: SyncStatus.error,
        error: 'Erreur de synchronisation: $e',
      );
    }
  }

  /// Traite une liste de changements
  Future<void> _processChanges(List<SyncChange> changes) async {
    int processed = 0;
    List<Eleve> eleves = [];
    List<Classe> classes = [];
    List<Enseignant> enseignants = [];
    List<NotePeriode> notes = [];
    List<PaiementFrais> paiements = [];
    List<Utilisateur> utilisateurs = [];
    List<FraisScolaire> fraisScolaires = [];
    List<Entreprise> entreprises = [];
    List<Responsable> responsables = [];
    List<ClasseComptable> classesComptables = [];
    List<CompteComptable> comptesComptables = [];
    List<Licence> licences = [];
    List<AnneeScolaire> anneesScolaires = [];
    List<Periode> periodes = [];
    List<ConfigEcole> configsEcole = [];
    List<ComptesConfig> comptesConfigs = [];
    List<PeriodesClasses> periodesClasses = [];
    List<Cours> cours = [];
    List<Creance> creances = [];
    List<JournalComptable> journauxComptables = [];
    List<Depense> depenses = [];
    List<EcritureComptable> ecrituresComptables = [];

    for (final change in changes) {
      final table = change.table;
      switch (table) {
        case 'eleves':
          eleves.add(Eleve.fromJson(change.data));
          break;
        case 'classes':
          classes.add(Classe.fromJson(change.data));
          break;
        case 'enseignants':
          enseignants.add(Enseignant.fromJson(change.data));
          break;
        case 'notes_periode':
          notes.add(NotePeriode.fromJson(change.data));
          break;
        case 'paiement_frais':
          paiements.add(PaiementFrais.fromJson(change.data));
          break;
        case 'utilisateurs':
          utilisateurs.add(Utilisateur.fromJson(change.data));
          break;
        case 'frais_scolaires':
          fraisScolaires.add(FraisScolaire.fromJson(change.data));
          break;
        case 'entreprises':
          entreprises.add(Entreprise.fromJson(change.data));
          break;
        case 'responsables':
          responsables.add(Responsable.fromJson(change.data));
          break;
        case 'classes_comptables':
          classesComptables.add(ClasseComptable.fromJson(change.data));
          break;
        case 'comptes_comptables':
          comptesComptables.add(CompteComptable.fromJson(change.data));
          break;
        case 'licence':
          licences.add(Licence.fromJson(change.data));
          break;
        case 'annees_scolaires':
          anneesScolaires.add(AnneeScolaire.fromJson(change.data));
          break;
        case 'periodes':
          periodes.add(Periode.fromJson(change.data));
          break;
        case 'config_ecole':
          configsEcole.add(ConfigEcole.fromJson(change.data));
          break;
        case 'comptes_config':
          comptesConfigs.add(ComptesConfig.fromJson(change.data));
          break;
        case 'periodes_classes':
          periodesClasses.add(PeriodesClasses.fromJson(change.data));
          break;
        case 'cours':
          cours.add(Cours.fromJson(change.data));
          break;
        case 'creances':
          creances.add(Creance.fromJson(change.data));
          break;
        case 'journaux_comptables':
          journauxComptables.add(JournalComptable.fromJson(change.data));
          break;
        case 'depenses':
          depenses.add(Depense.fromJson(change.data));
          break;
        case 'ecritures_comptables':
          ecrituresComptables.add(EcritureComptable.fromJson(change.data));
          break;
        default:
          print('Table non gérée: ${change.table}');
      }
      processed++;

      state = state.copyWith(
        processedChanges: processed,
        message: 'Traitement ${change.table}...',
      );
    }
    state = state.copyWith(
      status: SyncStatus.idle,
      message: 'Enregistrement des changements en cours...',
      processedChanges: processed,
    );

    // Appel des méthodes refresh pour toutes les entités collectées
    if (notes.isNotEmpty) {
      await ref.read(notesPeriodesNotifierProvider.notifier).refresh(notes);
    }
    if (enseignants.isNotEmpty) {
      await ref.read(enseignantsNotifierProvider.notifier).refresh(enseignants);
    }
    if (eleves.isNotEmpty) {
      await ref.read(elevesNotifierProvider.notifier).refresh(eleves);
    }
    if (classes.isNotEmpty) {
      await ref.read(classesNotifierProvider.notifier).refresh(classes);
    }
    if (paiements.isNotEmpty) {
      await ref.read(paiementsFraisNotifierProvider.notifier).refresh(paiements);
    }
    if (utilisateurs.isNotEmpty) {
      await ref
          .read(utilisateursNotifierProvider.notifier)
          .refresh(utilisateurs);
    }
    if (fraisScolaires.isNotEmpty) {
      await ref
          .read(fraisScolairesNotifierProvider.notifier)
          .refresh(fraisScolaires);
    }

    // TODO: Ajouter les providers manquants pour les nouvelles entités
    // Une fois que les providers seront créés, décommenter ces lignes :

    if (entreprises.isNotEmpty) {
      await ref.read(entreprisesNotifierProvider.notifier).refresh(entreprises);
    }
    if (responsables.isNotEmpty) {
      await ref
          .read(responsablesNotifierProvider.notifier)
          .refresh(responsables);
    }
    if (classesComptables.isNotEmpty) {
      await ref
          .read(classesComptablesNotifierProvider.notifier)
          .refresh(classesComptables);
    }
    if (comptesComptables.isNotEmpty) {
      await ref
          .read(comptesComptablesNotifierProvider.notifier)
          .refresh(comptesComptables);
    }
    if (licences.isNotEmpty) {
      await ref.read(licencesNotifierProvider.notifier).refresh(licences);
    }
    if (anneesScolaires.isNotEmpty) {
      await ref
          .read(anneesScolairesNotifierProvider.notifier)
          .refresh(anneesScolaires);
    }
    if (periodes.isNotEmpty) {
      await ref.read(periodesNotifierProvider.notifier).refresh(periodes);
    }
    if (configsEcole.isNotEmpty) {
      await ref
          .read(configEcolesNotifierProvider.notifier)
          .refresh(configsEcole);
    }
    if (comptesConfigs.isNotEmpty) {
      await ref
          .read(comptesConfigsNotifierProvider.notifier)
          .refresh(comptesConfigs);
    }
    if (periodesClasses.isNotEmpty) {
      await ref
          .read(periodesClassesNotifierProvider.notifier)
          .refresh(periodesClasses);
    }
    if (cours.isNotEmpty) {
      await ref.read(coursNotifierProvider.notifier).refresh(cours);
    }
    if (creances.isNotEmpty) {
      await ref.read(creancesNotifierProvider.notifier).refresh(creances);
    }
    if (journauxComptables.isNotEmpty) {
      await ref
          .read(journauxComptablesNotifierProvider.notifier)
          .refresh(journauxComptables);
    }
    if (depenses.isNotEmpty) {
      await ref.read(depensesNotifierProvider.notifier).refresh(depenses);
    }
    if (ecrituresComptables.isNotEmpty) {
      await ref
          .read(ecrituresComptablesNotifierProvider.notifier)
          .refresh(ecrituresComptables);
    }
    state = state.copyWith(
      status: SyncStatus.idle,
      message: 'Tous les changements ont été enregistrés',
      processedChanges: processed,
    );
  }

  /// Traite un changement individuel

  /// Vérifie la connectivité
  Future<bool> checkConnectivity() async {
    return await _syncManager.ping();
  }

  /// Vérifie si une synchronisation est nécessaire
  Future<bool> isSyncNeeded({int hoursThreshold = 1}) async {
    final syncPrefs = ref.read(syncPreferencesNotifierProvider.notifier);
    return await syncPrefs.isSyncNeeded(hoursThreshold: hoursThreshold);
  }

  /// Obtient la dernière date de synchronisation
  Future<DateTime?> getLastSyncDate() async {
    final syncPrefs = ref.read(syncPreferencesNotifierProvider.notifier);
    return await syncPrefs.getLastSyncDate();
  }

  /// Obtient l'email du dernier utilisateur synchronisé
  Future<String?> getLastSyncUserEmail() async {
    final syncPrefs = ref.read(syncPreferencesNotifierProvider.notifier);
    return await syncPrefs.getLastSyncUserEmail();
  }

  /// Collecte et upload les changements locaux non synchronisés
  Future<void> uploadLocalChanges(String userEmail) async {
    state = state.copyWith(
      status: SyncStatus.uploading,
      message: 'Collecte des changements locaux...',
    );

    try {
      final helper = SyncUploadHelper(clientId: 'flutter-client');

      // Collecter tous les changements non synchronisés
      await _collectUnsyncedChanges(helper);

      if (!helper.hasChanges) {
        state = state.copyWith(
          status: SyncStatus.idle,
          message: 'Aucun changement local à synchroniser',
        );
        return;
      }

      state = state.copyWith(
        message: 'Upload de ${helper.changeCount} changements...',
        totalChanges: helper.changeCount,
        processedChanges: 0,
      );

      // Construire et envoyer la requête
      final uploadRequest = helper.build();
      final response = await _syncManager.uploadChanges(uploadRequest);

      if (response != null) {
        // Traiter le mapping des IDs si présent
        if (response.hasIdMapping) {
          final idMappingHelper = IdMappingHelper(ref);
          await idMappingHelper.processIdMapping(response);

          final mappingSummary = idMappingHelper.getIdMappingSummary(response);
          state = state.copyWith(
            status: SyncStatus.idle,
            message: 'Upload terminé avec succès. $mappingSummary',
            processedChanges: helper.changeCount,
          );
        } else {
          // Marquer les éléments comme synchronisés (ancienne méthode)
          await _markChangesAsSynced(helper);

          state = state.copyWith(
            status: SyncStatus.idle,
            message: 'Upload terminé avec succès',
            processedChanges: helper.changeCount,
          );
        }
      } else {
        throw Exception('Échec de l\'upload');
      }
    } catch (e) {
      state = state.copyWith(
        status: SyncStatus.error,
        error: 'Erreur upload: $e',
      );
      rethrow;
    }
  }

  /// Collecte tous les changements non synchronisés
  Future<void> _collectUnsyncedChanges(SyncUploadHelper helper) async {
    final database = ref.read(databaseProvider);

    // Collecter les élèves non synchronisés
    try {
      final unsyncedEleves = await database.eleveDao.getUnsyncedEleves();
      for (final eleve in unsyncedEleves) {
        if (eleve.serverId != null) {
          helper.addEleve(eleve, operation: SyncOperation.update);
        } else {
          helper.addEleve(eleve, operation: SyncOperation.insert);
        }
      }
    } catch (e) {
      print('Erreur collecte élèves: $e');
    }

    // Collecter les enseignants non synchronisés
    try {
      final unsyncedEnseignants =
          await database.enseignantDao.getUnsyncedEnseignants();
      for (final enseignant in unsyncedEnseignants) {
        if (enseignant.serverId != null) {
          helper.addEnseignant(enseignant, operation: SyncOperation.update);
        } else {
          helper.addEnseignant(enseignant, operation: SyncOperation.insert);
        }
      }
    } catch (e) {
      print('Erreur collecte enseignants: $e');
    }

    // Collecter les classes non synchronisées
    try {
      final unsyncedClasses = await database.classeDao.getUnsyncedClasses();
      for (final classe in unsyncedClasses) {
        if (classe.serverId != null) {
          helper.addClasse(classe, operation: SyncOperation.update);
        } else {
          helper.addClasse(classe, operation: SyncOperation.insert);
        }
      }
    } catch (e) {
      print('Erreur collecte classes: $e');
    }

    // Collecter les années scolaires non synchronisées
    try {
      final unsyncedAnnees =
          await database.anneeScolaireDao.getUnsyncedAnneesScolaires();
      for (final annee in unsyncedAnnees) {
        if (annee.serverId != null) {
          helper.addAnneeScolaire(annee, operation: SyncOperation.update);
        } else {
          helper.addAnneeScolaire(annee, operation: SyncOperation.insert);
        }
      }
    } catch (e) {
      print('Erreur collecte années scolaires: $e');
    }

    // Collecter les responsables non synchronisés
    try {
      final unsyncedResponsables =
          await database.responsableDao.getUnsyncedResponsables();
      for (final responsable in unsyncedResponsables) {
        helper.addEntity(
          responsable,
          'responsables',
          responsable.serverId != null
              ? SyncOperation.update
              : SyncOperation.insert,
          toJson: (r) => r.toJson(),
          getServerId: (r) => r.serverId,
        );
      }
    } catch (e) {
      print('Erreur collecte responsables: $e');
    }

    // Collecter les cours non synchronisés
    try {
      final unsyncedCours = await database.coursDao.getUnsyncedCours();
      for (final cours in unsyncedCours) {
        helper.addEntity(
          cours,
          'cours',
          cours.serverId != null ? SyncOperation.update : SyncOperation.insert,
          toJson: (c) => c.toJson(),
          getServerId: (c) => c.serverId,
        );
      }
    } catch (e) {
      print('Erreur collecte cours: $e');
    }

    // Collecter les frais scolaires non synchronisés
    try {
      final unsyncedFrais =
          await database.fraisScolaireDao.getUnsyncedFraisScolaires();
      for (final frais in unsyncedFrais) {
        helper.addEntity(
          frais,
          'frais_scolaires',
          frais.serverId != null ? SyncOperation.update : SyncOperation.insert,
          toJson: (f) => f.toJson(),
          getServerId: (f) => f.serverId,
        );
      }
    } catch (e) {
      print('Erreur collecte frais scolaires: $e');
    }

    // Collecter les notes de période non synchronisées
    try {
      final unsyncedNotes =
          await database.notePeriodeDao.getUnsyncedNotesPeriode();
      for (final note in unsyncedNotes) {
        helper.addEntity(
          note,
          'notes_periode',
          note.serverId != null ? SyncOperation.update : SyncOperation.insert,
          toJson: (n) => n.toJson(),
          getServerId: (n) => n.serverId,
        );
      }
    } catch (e) {
      print('Erreur collecte notes période: $e');
    }

    // Collecter les paiements de frais non synchronisés
    try {
      final unsyncedPaiements =
          await database.paiementFraisDao.getUnsyncedPaiementsFrais();
      for (final paiement in unsyncedPaiements) {
        helper.addEntity(
          paiement,
          'paiements_frais',
          paiement.serverId != null
              ? SyncOperation.update
              : SyncOperation.insert,
          toJson: (p) => p.toJson(),
          getServerId: (p) => p.serverId,
        );
      }
    } catch (e) {
      print('Erreur collecte paiements frais: $e');
    }

    // Collecter les périodes non synchronisées
    try {
      final unsyncedPeriodes = await database.periodeDao.getUnsyncedPeriodes();
      for (final periode in unsyncedPeriodes) {
        helper.addEntity(
          periode,
          'periodes',
          periode.serverId != null
              ? SyncOperation.update
              : SyncOperation.insert,
          toJson: (p) => p.toJson(),
          getServerId: (p) => p.serverId,
        );
      }
    } catch (e) {
      print('Erreur collecte périodes: $e');
    }

    // Collecter les créances non synchronisées
    try {
      final unsyncedCreances = await database.creanceDao.getUnsyncedCreances();
      for (final creance in unsyncedCreances) {
        helper.addEntity(
          creance,
          'creances',
          creance.serverId != null
              ? SyncOperation.update
              : SyncOperation.insert,
          toJson: (c) => c.toJson(),
          getServerId: (c) => c.serverId,
        );
      }
    } catch (e) {
      print('Erreur collecte créances: $e');
    }

    // Collecter les utilisateurs non synchronisés
    try {
      final unsyncedUtilisateurs =
          await database.utilisateurDao.getUnsyncedUtilisateurs();
      for (final utilisateur in unsyncedUtilisateurs) {
        helper.addEntity(
          utilisateur,
          'utilisateurs',
          utilisateur.serverId != null
              ? SyncOperation.update
              : SyncOperation.insert,
          toJson: (u) => u.toJson(),
          getServerId: (u) => u.serverId,
        );
      }
    } catch (e) {
      print('Erreur collecte utilisateurs: $e');
    }

    // Collecter les configurations d'école non synchronisées
    try {
      final unsyncedConfigs =
          await database.configEcoleDao.getUnsyncedConfigsEcole();
      for (final config in unsyncedConfigs) {
        helper.addEntity(
          config,
          'configs_ecole',
          config.serverId != null ? SyncOperation.update : SyncOperation.insert,
          toJson: (c) => c.toJson(),
          getServerId: (c) => c.serverId,
        );
      }
    } catch (e) {
      print('Erreur collecte configs école: $e');
    }

    // Collecter les périodes-classes non synchronisées
    try {
      final unsyncedPeriodesClasses =
          await database.periodesClassesDao.getUnsyncedPeriodesClasses();
      for (final pc in unsyncedPeriodesClasses) {
        helper.addEntity(
          pc,
          'periodes_classes',
          pc.serverId != null ? SyncOperation.update : SyncOperation.insert,
          toJson: (pc) => pc.toJson(),
          getServerId: (pc) => pc.serverId,
        );
      }
    } catch (e) {
      print('Erreur collecte périodes-classes: $e');
    }

    // Tables comptables
    // Collecter les comptes comptables non synchronisés
    try {
      final unsyncedComptes =
          await database.compteComptableDao.getUnsyncedComptesComptables();
      for (final compte in unsyncedComptes) {
        helper.addEntity(
          compte,
          'comptes_comptables',
          compte.serverId != null ? SyncOperation.update : SyncOperation.insert,
          toJson: (c) => c.toJson(),
          getServerId: (c) => c.serverId,
        );
      }
    } catch (e) {
      print('Erreur collecte comptes comptables: $e');
    }

    // Collecter les classes comptables non synchronisées
    try {
      final unsyncedClassesComptables =
          await database.classeComptableDao.getUnsyncedClassesComptables();
      for (final classe in unsyncedClassesComptables) {
        helper.addEntity(
          classe,
          'classes_comptables',
          classe.serverId != null ? SyncOperation.update : SyncOperation.insert,
          toJson: (c) => c.toJson(),
          getServerId: (c) => c.serverId,
        );
      }
    } catch (e) {
      print('Erreur collecte classes comptables: $e');
    }

    // Collecter les journaux comptables non synchronisés
    try {
      final unsyncedJournaux =
          await database.journalComptableDao.getUnsyncedJournauxComptables();
      for (final journal in unsyncedJournaux) {
        helper.addEntity(
          journal,
          'journaux_comptables',
          journal.serverId != null
              ? SyncOperation.update
              : SyncOperation.insert,
          toJson: (j) => j.toJson(),
          getServerId: (j) => j.serverId,
        );
      }
    } catch (e) {
      print('Erreur collecte journaux comptables: $e');
    }

    // Collecter les écritures comptables non synchronisées
    try {
      final unsyncedEcritures =
          await database.ecritureComptableDao.getUnsyncedEcrituresComptables();
      for (final ecriture in unsyncedEcritures) {
        helper.addEntity(
          ecriture,
          'ecritures_comptables',
          ecriture.serverId != null
              ? SyncOperation.update
              : SyncOperation.insert,
          toJson: (e) => e.toJson(),
          getServerId: (e) => e.serverId,
        );
      }
    } catch (e) {
      print('Erreur collecte écritures comptables: $e');
    }

    // Collecter les dépenses non synchronisées
    try {
      final unsyncedDepenses = await database.depenseDao.getUnsyncedDepenses();
      for (final depense in unsyncedDepenses) {
        helper.addEntity(
          depense,
          'depenses',
          depense.serverId != null
              ? SyncOperation.update
              : SyncOperation.insert,
          toJson: (d) => d.toJson(),
          getServerId: (d) => d.serverId,
        );
      }
    } catch (e) {
      print('Erreur collecte dépenses: $e');
    }

    // Collecter les licences non synchronisées
    try {
      final unsyncedLicences = await database.licenceDao.getUnsyncedLicences();
      for (final licence in unsyncedLicences) {
        helper.addEntity(
          licence,
          'licences',
          licence.serverId != null
              ? SyncOperation.update
              : SyncOperation.insert,
          toJson: (l) => l.toJson(),
          getServerId: (l) => l.serverId,
        );
      }
    } catch (e) {
      print('Erreur collecte licences: $e');
    }

    // Collecter les entreprises non synchronisées
    try {
      final unsyncedEntreprises =
          await database.entrepriseDao.getUnsyncedEntreprises();
      for (final entreprise in unsyncedEntreprises) {
        helper.addEntity(
          entreprise,
          'entreprises',
          entreprise.serverId != null
              ? SyncOperation.update
              : SyncOperation.insert,
          toJson: (e) => e.toJson(),
          getServerId: (e) => e.serverId,
        );
      }
    } catch (e) {
      print('Erreur collecte entreprises: $e');
    }

    // Collecter les configurations de comptes non synchronisées
    try {
      final unsyncedComptesConfigs =
          await database.comptesConfigDao.getUnsyncedComptesConfigs();
      for (final config in unsyncedComptesConfigs) {
        helper.addEntity(
          config,
          'comptes_configs',
          config.serverId != null ? SyncOperation.update : SyncOperation.insert,
          toJson: (c) => c.toJson(),
          getServerId: (c) => c.serverId,
        );
      }
    } catch (e) {
      print('Erreur collecte configurations comptes: $e');
    }
  }

  /// Marque les changements comme synchronisés après upload réussi
  Future<void> _markChangesAsSynced(SyncUploadHelper helper) async {
    final database = ref.read(databaseProvider);
    final changesByTable = helper.changesByTable;

    // Marquer les élèves comme synchronisés
    if (changesByTable.containsKey('eleves')) {
      try {
        final eleveChanges = changesByTable['eleves']!;
        for (final change in eleveChanges) {
          final eleveId = change.data['id'] as int?;
          if (eleveId != null) {
            await database.eleveDao.markAsSynced(eleveId);
          }
        }
      } catch (e) {
        print('Erreur marquage élèves: $e');
      }
    }

    // Marquer les enseignants comme synchronisés
    if (changesByTable.containsKey('enseignants')) {
      try {
        final enseignantChanges = changesByTable['enseignants']!;
        for (final change in enseignantChanges) {
          final enseignantId = change.data['id'] as int?;
          if (enseignantId != null) {
            await database.enseignantDao.markAsSynced(enseignantId);
          }
        }
      } catch (e) {
        print('Erreur marquage enseignants: $e');
      }
    }

    // Ajouter le marquage pour les autres entités...
  }

  /// Synchronisation bidirectionnelle complète
  Future<void> performBidirectionalSync(String userEmail) async {
    try {
      // 1. Upload des changements locaux d'abord
      await uploadLocalChanges(userEmail);

      // 2. Download des changements du serveur
      await performFullSync(userEmail);
    } catch (e) {
      state = state.copyWith(
        status: SyncStatus.error,
        error: 'Erreur sync bidirectionnelle: $e',
      );
      rethrow;
    }
  }

  /// Force une synchronisation (ignore la dernière date)
  Future<void> performForcedSync(String userEmail) async {
    final syncPrefs = ref.read(syncPreferencesNotifierProvider.notifier);
    await syncPrefs.clearSyncData();
    await performFullSync(userEmail);
  }

  /// Remet à zéro l'état de synchronisation
  void resetState() {
    state = const SyncState();
  }
}
