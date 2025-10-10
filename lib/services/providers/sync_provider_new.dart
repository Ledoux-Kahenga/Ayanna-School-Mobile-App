import 'package:ayanna_school/models/entities/classe.dart';
import 'package:ayanna_school/models/entities/eleve.dart';
import 'package:ayanna_school/models/entities/enseignant.dart';
import 'package:ayanna_school/models/entities/frais_scolaire.dart';
import 'package:ayanna_school/models/entities/frais_classes.dart';
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
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:ayanna_school/services/providers/data_provider.dart';
import 'package:ayanna_school/services/providers/shared_preferences_provider.dart';
import 'package:ayanna_school/services/providers/database_provider.dart';
import 'api_client_provider.dart';
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
    print(
      '📥 [SYNC-MANAGER] Démarrage téléchargement changements pour $userEmail',
    );
    try {
      final sinceString =
          since?.toIso8601String() ?? '1970-01-01T00:00:00.000Z';
      print('📅 [SYNC-MANAGER] Depuis: $sinceString');

      final response = await _syncService.downloadChanges(
        since: sinceString,
        clientId: 'flutter-client',
        userEmail: userEmail,
      );

      return response.body;
    } catch (e) {
      print('❌ [SYNC-MANAGER] Erreur téléchargement: $e');
      rethrow;
    }
  }

  /// Upload les changements locaux avec la nouvelle structure
  Future<SyncUploadResponse?> uploadChanges(
    SyncUploadRequest uploadRequest,
  ) async {
    print('📤 [SYNC-MANAGER] Démarrage upload changements');
    try {
      print(
        '📊 [SYNC-MANAGER] Nombre de changements: ${uploadRequest.changes.length}',
      );

      final response = await _syncService.uploadChanges(uploadRequest);

      if (response.isSuccessful && response.body != null) {
        // response.body est déjà de type SyncUploadResponse
        final uploadResponse = response.body!;
        print('✅ [SYNC-MANAGER] Upload réussi: ${uploadResponse.message}');
        if (uploadResponse.idMapping != null &&
            uploadResponse.idMapping!.isNotEmpty) {
          print(
            '🔄 [SYNC-MANAGER] Mapping IDs détecté: ${uploadResponse.idMapping!.length} mappings',
          );
        }
        return uploadResponse;
      }
      print('❌ [SYNC-MANAGER] Upload échoué: ${response.statusCode}');
      return null;
    } catch (e) {
      print('❌ [SYNC-MANAGER] Erreur upload: $e ${StackTrace.current}');
      rethrow;
    }
  }

  /// Upload les changements locaux (version legacy)
  Future<SyncUploadResponse?> uploadChangesLegacy(
    Map<String, dynamic> changes,
  ) async {
    print('📤 [SYNC-MANAGER] Démarrage upload legacy');
    try {
      // Convertir le Map en SyncUploadRequest pour compatibilité
      final builder = SyncUploadRequestBuilder(
        clientId: changes['client_id'] ?? 'flutter-client',
      );

      final changesList = changes['changes'] as List<dynamic>? ?? [];
      print(
        '📊 [SYNC-MANAGER] Conversion ${changesList.length} changements legacy',
      );

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
        print('✅ [SYNC-MANAGER] Upload legacy réussi');
        return response.body;
      }
      print('❌ [SYNC-MANAGER] Upload legacy échoué');
      return null;
    } catch (e) {
      print('❌ [SYNC-MANAGER] Erreur upload legacy: $e');
      rethrow;
    }
  }

  /// Marque les changements comme synchronisés
  Future<bool> acknowledgeChanges(List<String> changeIds) async {
    print('✅ [SYNC-MANAGER] Acquittement ${changeIds.length} changements');
    try {
      final response = await _syncService.acknowledgeChanges({
        'change_ids': changeIds,
      });

      final success = response.isSuccessful;
      print('📋 [SYNC-MANAGER] Acquittement ${success ? 'réussi' : 'échoué'}');
      return success;
    } catch (e) {
      print('❌ [SYNC-MANAGER] Erreur acquittement: $e');
      return false;
    }
  }

  /// Vérifie la connectivité avec le serveur
  Future<bool> ping() async {
    print('🏓 [SYNC-MANAGER] Ping du serveur');
    try {
      final response = await _syncService.ping();
      final success = response.isSuccessful;
      print('🏓 [SYNC-MANAGER] Ping ${success ? 'réussi' : 'échoué'}');
      return success;
    } catch (e) {
      print('❌ [SYNC-MANAGER] Erreur ping: $e');
      return false;
    }
  }

  /// Obtient le statut de synchronisation
  Future<Map<String, dynamic>?> getSyncStatus(String userEmail) async {
    print('📊 [SYNC-MANAGER] Récupération statut sync pour $userEmail');
    try {
      final response = await _syncService.getSyncStatus(userEmail: userEmail);

      if (response.isSuccessful && response.body != null) {
        print('✅ [SYNC-MANAGER] Statut sync récupéré');
        return response.body;
      }
      print('❌ [SYNC-MANAGER] Échec récupération statut sync');
      return null;
    } catch (e) {
      print('❌ [SYNC-MANAGER] Erreur statut sync: $e');
      return null;
    }
  }
}

/// Provider pour le service de synchronisation
@riverpod
SyncService syncService(SyncServiceRef ref) {
  return ref.watch(apiClientProvider).syncService;
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
    print(
      '📤 [SYNC] Upload entité individuelle: $tableName, opération: $operation, utilisateur: $userEmail',
    );
    final helper = SyncUploadHelper(clientId: 'flutter-client');

    try {
      // Ajouter l'entité selon l'opération
      switch (operation.toLowerCase()) {
        case 'create':
          print('➕ [SYNC] Ajout création entité $tableName');
          helper.addEntity(
            entity,
            tableName,
            SyncOperation.insert,
            toJson: (e) => (e as dynamic).toJson(),
            getServerId: (e) => (e as dynamic).serverId,
          );
          break;
        case 'update':
          print('🔄 [SYNC] Ajout mise à jour entité $tableName');
          helper.addEntity(
            entity,
            tableName,
            SyncOperation.update,
            toJson: (e) => (e as dynamic).toJson(),
            getServerId: (e) => (e as dynamic).serverId,
          );
          break;
        case 'delete':
          print('🗑️ [SYNC] Ajout suppression entité $tableName');
          helper.addEntity(
            entity,
            tableName,
            SyncOperation.delete,
            toJson: (e) => (e as dynamic).toJson(),
            getServerId: (e) => (e as dynamic).serverId,
          );
          break;
        default:
          print('❌ [SYNC] Opération non supportée: $operation');
          throw ArgumentError('Opération non supportée: $operation');
      }

      if (helper.hasChanges) {
        print('📤 [SYNC] Envoi de l\'entité au serveur');
        final uploadRequest = helper.build();
        final response = await _syncManager.uploadChanges(uploadRequest);

        if (response != null && response.success) {
          print('✅ [SYNC] Upload réussi');
          // Traitement du mapping des IDs si nécessaire
          if (response.hasIdMapping) {
            print('🔄 [SYNC] Traitement mapping IDs');
            final idMappingHelper = IdMappingHelper(ref);
            await idMappingHelper.processIdMapping(response);
          }

          // Marquer l'entité comme synchronisée
          print('✅ [SYNC] Marquage entité comme synchronisée');
          await _markSingleEntityAsSynced(entity, tableName);
        } else {
          print('❌ [SYNC] Échec upload entité');
        }
      } else {
        print('⚠️ [SYNC] Aucune modification à uploader');
      }
    } catch (e) {
      print('❌ [SYNC] Erreur upload entité $tableName: $e');
      rethrow;
    }
  }

  /// Marquer une entité individuelle comme synchronisée
  Future<void> _markSingleEntityAsSynced<T>(T entity, String tableName) async {
    print('✅ [SYNC] Marquage entité individuelle synchronisée: $tableName');
    final database = ref.read(databaseProvider);

    try {
      // Mettre à jour isSync = true pour l'entité
      final entityWithSync = entity as dynamic;
      entityWithSync.isSync = true;

      switch (tableName) {
        case 'eleves':
          print('👨‍🎓 [SYNC] Marquage élève synchronisé');
          await database.eleveDao.updateEleve(entityWithSync as Eleve);
          break;
        case 'enseignants':
          print('👨‍🏫 [SYNC] Marquage enseignant synchronisé');
          await database.enseignantDao.updateEnseignant(
            entityWithSync as Enseignant,
          );
          break;
        case 'classes':
          print('🏫 [SYNC] Marquage classe synchronisée');
          await database.classeDao.updateClasse(entityWithSync as Classe);
          break;
        // Ajouter d'autres cas selon les besoins
        default:
          print(
            '⚠️ [SYNC] Table non supportée pour le marquage sync: $tableName',
          );
      }
    } catch (e) {
      print('❌ [SYNC] Erreur marquage synchronisation pour $tableName: $e');
    }
  }

  /// Lance une synchronisation complète
  Future<void> performFullSync(String userEmail) async {
    print('🔄 [SYNC] Démarrage synchronisation complète pour $userEmail');
    try {
      state = state.copyWith(
        status: SyncStatus.downloading,
        message: 'Téléchargement des changements...',
        error: null,
      );
      print('📥 [SYNC] État changé: downloading');

      // Récupérer la dernière date de synchronisation depuis SharedPreferences
      final syncPrefs = ref.read(syncPreferencesNotifierProvider.notifier);
      final lastSyncDate = await syncPrefs.getLastSyncDate();
      print('📅 [SYNC] Dernière sync: $lastSyncDate');

      // Télécharger les changements depuis la dernière synchronisation
      final syncResponse = await _syncManager.downloadChanges(
        userEmail: userEmail,
        since: lastSyncDate,
      );

      if (syncResponse == null) {
        print('❌ [SYNC] Réponse de téléchargement nulle');
        state = state.copyWith(
          status: SyncStatus.error,
          error: 'Échec du téléchargement des changements',
        );
        return;
      }

      print('📊 [SYNC] ${syncResponse.total} changements à traiter');
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
      print('💾 [SYNC] Dates sauvegardées: $now pour $userEmail');

      state = state.copyWith(
        status: SyncStatus.idle,
        message: 'Synchronisation terminée',
        lastSync: now,
        processedChanges: syncResponse.total,
      );
      print('✅ [SYNC] Synchronisation complète terminée');
    } catch (e) {
      print('❌ [SYNC] Erreur synchronisation complète: $e');
      state = state.copyWith(
        status: SyncStatus.error,
        error: 'Erreur de synchronisation: $e',
      );
    }
  }

  /// Traite une liste de changements
  Future<void> _processChanges(List<SyncChange> changes) async {
    print('⚙️ [SYNC] Démarrage traitement ${changes.length} changements');
    int processed = 0;

    // Debug: Afficher la distribution des changements par table
    Map<String, int> tableCounts = {};
    for (final change in changes) {
      tableCounts[change.table] = (tableCounts[change.table] ?? 0) + 1;
    }
    print('🔍 [SYNC] DEBUG - Distribution des changements: $tableCounts');

    List<Eleve> eleves = [];
    List<Classe> classes = [];
    List<Enseignant> enseignants = [];
    List<NotePeriode> notes = [];
    List<PaiementFrais> paiements = [];
    List<Utilisateur> utilisateurs = [];
    List<FraisScolaire> fraisScolaires = [];
    List<FraisClasses> fraisClasses = [];
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
        case 'frais_classes':
          fraisClasses.add(FraisClasses.fromJson(change.data));
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
          print('⚠️ [SYNC] Table non gérée: ${change.table}');
      }
      processed++;

      state = state.copyWith(
        processedChanges: processed,
        message: 'Traitement ${change.table}...',
      );
    }

    print('💾 [SYNC] Enregistrement des changements en base locale');

    // Debug: Afficher le nombre d'entités collectées par type
    print('🔍 [SYNC] DEBUG - Entités collectées:');
    print('  - entreprises: ${entreprises.length}');
    print('  - anneesScolaires: ${anneesScolaires.length}');
    print('  - utilisateurs: ${utilisateurs.length}');
    print('  - enseignants: ${enseignants.length}');
    print('  - responsables: ${responsables.length}');
    print('  - classes: ${classes.length}');
    print('  - eleves: ${eleves.length}');
    print('  - fraisScolaires: ${fraisScolaires.length}');
    print('  - fraisClasses: ${fraisClasses.length}');

    state = state.copyWith(
      status: SyncStatus.idle,
      message: 'Enregistrement des changements en cours...',
      processedChanges: processed,
    );

    // Appel des méthodes refresh pour toutes les entités collectées
    // ORDRE IMPORTANT : Les entités parentes doivent être synchronisées avant les enfants

    // 1. Entités de base (sans dépendances)
    print(
      '🔍 [SYNC] DEBUG - Nombre d\'entreprises collectées: ${entreprises.length}',
    );
    if (entreprises.isNotEmpty) {
      print('🏢 [SYNC] Refresh ${entreprises.length} entreprises');
      await ref.read(entreprisesNotifierProvider.notifier).refresh(entreprises);
    } else {
      print(
        '⚠️ [SYNC] Aucune entreprise à synchroniser - vérification base locale...',
      );
      // Vérifier si des entreprises existent déjà en base
      final existingEntreprises = await ref.read(
        entreprisesNotifierProvider.future,
      );
      print(
        '📊 [SYNC] Entreprises existantes en base: ${existingEntreprises.length}',
      );
      if (existingEntreprises.isNotEmpty) {
        print(
          '🏢 [SYNC] Entreprises en base: ${existingEntreprises.map((e) => '${e.id}:${e.nom}').join(', ')}',
        );
      }
    }

    if (anneesScolaires.isNotEmpty) {
      print('� [SYNC] Refresh ${anneesScolaires.length} années scolaires');
      await ref
          .read(anneesScolairesNotifierProvider.notifier)
          .refresh(anneesScolaires);
    }

    if (utilisateurs.isNotEmpty) {
      print('👤 [SYNC] Refresh ${utilisateurs.length} utilisateurs');
      await ref
          .read(utilisateursNotifierProvider.notifier)
          .refresh(utilisateurs);
    }

    if (enseignants.isNotEmpty) {
      print('�‍🏫 [SYNC] Refresh ${enseignants.length} enseignants');
      await ref.read(enseignantsNotifierProvider.notifier).refresh(enseignants);
    }

    if (responsables.isNotEmpty) {
      print('�‍👩‍👧‍👦 [SYNC] Refresh ${responsables.length} responsables');
      await ref
          .read(responsablesNotifierProvider.notifier)
          .refresh(responsables);
    }

    // 2. Entités dépendant des entités de base
    if (classes.isNotEmpty) {
      print('🏫 [SYNC] Refresh ${classes.length} classes');
      await ref.read(classesNotifierProvider.notifier).refresh(classes);
    }

    if (eleves.isNotEmpty) {
      print('�‍🎓 [SYNC] Refresh ${eleves.length} élèves');
      await ref.read(elevesNotifierProvider.notifier).refresh(eleves);
    }

    if (fraisScolaires.isNotEmpty) {
      print('📋 [SYNC] Refresh ${fraisScolaires.length} frais scolaires');
      await ref
          .read(fraisScolairesNotifierProvider.notifier)
          .refresh(fraisScolaires);
    }

    if (fraisClasses.isNotEmpty) {
      print('� [SYNC] Refresh ${fraisClasses.length} frais classes');
      await ref
          .read(fraisClassesNotifierProvider.notifier)
          .refresh(fraisClasses);
    }

    // 3. Entités comptables
    if (classesComptables.isNotEmpty) {
      print('📊 [SYNC] Refresh ${classesComptables.length} classes comptables');
      await ref
          .read(classesComptablesNotifierProvider.notifier)
          .refresh(classesComptables);
    }

    if (comptesComptables.isNotEmpty) {
      print('💼 [SYNC] Refresh ${comptesComptables.length} comptes comptables');
      await ref
          .read(comptesComptablesNotifierProvider.notifier)
          .refresh(comptesComptables);
    }

    // 4. Autres entités
    if (licences.isNotEmpty) {
      print('📜 [SYNC] Refresh ${licences.length} licences');
      await ref.read(licencesNotifierProvider.notifier).refresh(licences);
    }

    if (periodes.isNotEmpty) {
      print('⏰ [SYNC] Refresh ${periodes.length} périodes');
      await ref.read(periodesNotifierProvider.notifier).refresh(periodes);
    }

    if (configsEcole.isNotEmpty) {
      print('⚙️ [SYNC] Refresh ${configsEcole.length} configs école');
      await ref
          .read(configEcolesNotifierProvider.notifier)
          .refresh(configsEcole);
    }

    if (comptesConfigs.isNotEmpty) {
      print('🔧 [SYNC] Refresh ${comptesConfigs.length} configs comptes');
      await ref
          .read(comptesConfigsNotifierProvider.notifier)
          .refresh(comptesConfigs);
    }

    if (periodesClasses.isNotEmpty) {
      print('📚 [SYNC] Refresh ${periodesClasses.length} périodes-classes');
      await ref
          .read(periodesClassesNotifierProvider.notifier)
          .refresh(periodesClasses);
    }
    if (cours.isNotEmpty) {
      print('📖 [SYNC] Refresh ${cours.length} cours');
      await ref.read(coursNotifierProvider.notifier).refresh(cours);
    }
    if (creances.isNotEmpty) {
      print('💳 [SYNC] Refresh ${creances.length} créances');
      await ref.read(creancesNotifierProvider.notifier).refresh(creances);
    }
    if (journauxComptables.isNotEmpty) {
      print(
        '📓 [SYNC] Refresh ${journauxComptables.length} journaux comptables',
      );
      await ref
          .read(journauxComptablesNotifierProvider.notifier)
          .refresh(journauxComptables);
    }
    if (depenses.isNotEmpty) {
      print('💸 [SYNC] Refresh ${depenses.length} dépenses');
      await ref.read(depensesNotifierProvider.notifier).refresh(depenses);
    }
    if (ecrituresComptables.isNotEmpty) {
      print(
        '📝 [SYNC] Refresh ${ecrituresComptables.length} écritures comptables',
      );
      await ref
          .read(ecrituresComptablesNotifierProvider.notifier)
          .refresh(ecrituresComptables);
    }

    // 5. Entités restantes (notes, paiements, etc.)
    if (notes.isNotEmpty) {
      print('📚 [SYNC] Refresh ${notes.length} notes');
      await ref.read(notesPeriodesNotifierProvider.notifier).refresh(notes);
    }

    if (paiements.isNotEmpty) {
      print('💰 [SYNC] Refresh ${paiements.length} paiements');
      await ref
          .read(paiementsFraisNotifierProvider.notifier)
          .refresh(paiements);
    }

    state = state.copyWith(
      status: SyncStatus.idle,
      message: 'Tous les changements ont été enregistrés',
      processedChanges: processed,
    );
    print('✅ [SYNC] Traitement des changements terminé');
  }

  /// Traite un changement individuel

  /// Vérifie la connectivité
  Future<bool> checkConnectivity() async {
    try {
      print('🌐 [CONNECTIVITY] Vérification directe de la connectivité...');
      final results = await Connectivity().checkConnectivity();
      final isConnected =
          results.contains(ConnectivityResult.wifi) ||
          results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.ethernet);
      print(
        '🌐 [CONNECTIVITY] Résultats directs: $results, isConnected: $isConnected',
      );
      return isConnected;
    } catch (e) {
      print(
        '❌ [CONNECTIVITY] Erreur lors de la vérification directe de connectivité: $e',
      );
      return false;
    }
  }

  /*   /// Vérifie si une synchronisation est nécessaire
  Future<bool> isSyncNeeded({int muniteThreshold = 1}) async {
    print(
      '⏰ [SYNC] Vérification si synchronisation nécessaire (seuil: ${muniteThreshold}h)',
    );
    final syncPrefs = ref.read(syncPreferencesNotifierProvider.notifier);
    final needed = await syncPrefs.isSyncNeeded(muniteThreshold: muniteThreshold);
    print(
      '⏰ [SYNC] Synchronisation ${needed ? 'nécessaire' : 'non nécessaire'}',
    );
    return needed;
  } */

  /// Obtient la dernière date de synchronisation
  Future<DateTime?> getLastSyncDate() async {
    print('📅 [SYNC] Récupération dernière date de synchronisation');
    final syncPrefs = ref.read(syncPreferencesNotifierProvider.notifier);
    final date = await syncPrefs.getLastSyncDate();
    print('📅 [SYNC] Dernière date: $date');
    return date;
  }

  /// Obtient l'email du dernier utilisateur synchronisé
  Future<String?> getLastSyncUserEmail() async {
    print('👤 [SYNC] Récupération dernier email utilisateur synchronisé');
    final syncPrefs = ref.read(syncPreferencesNotifierProvider.notifier);
    final email = await syncPrefs.getLastSyncUserEmail();
    print('👤 [SYNC] Dernier email: $email');
    return email;
  }

  /// Collecte et upload les changements locaux non synchronisés
  Future<void> uploadLocalChanges(String userEmail) async {
    print('📤 [SYNC] Démarrage upload changements locaux pour $userEmail');
    state = state.copyWith(
      status: SyncStatus.uploading,
      message: 'Collecte des changements locaux...',
    );

    try {
      final helper = SyncUploadHelper(clientId: 'flutter-client');
      print('🔍 [SYNC] Collecte des changements non synchronisés');

      // Collecter tous les changements non synchronisés
      await _collectUnsyncedChanges(helper);

      if (!helper.hasChanges) {
        print('ℹ️ [SYNC] Aucun changement local à synchroniser');
        state = state.copyWith(
          status: SyncStatus.idle,
          message: 'Aucun changement local à synchroniser',
        );
        return;
      }

      print('📊 [SYNC] ${helper.changeCount} changements à uploader');
      state = state.copyWith(
        message: 'Upload de ${helper.changeCount} changements...',
        totalChanges: helper.changeCount,
        processedChanges: 0,
      );

      // Construire et envoyer la requête
      final uploadRequest = helper.build();
      final response = await _syncManager.uploadChanges(uploadRequest);

      if (response != null) {
        print('✅ [SYNC] Upload réussi: ${response.message}');
        // Traiter le mapping des IDs si présent
        if (response.hasIdMapping) {
          print('🔄 [SYNC] Traitement du mapping des IDs');
          final idMappingHelper = IdMappingHelper(ref);
          await idMappingHelper.processIdMapping(response);

          final mappingSummary = idMappingHelper.getIdMappingSummary(response);
          print('📋 [SYNC] Mapping IDs: $mappingSummary');
          state = state.copyWith(
            status: SyncStatus.idle,
            message: 'Upload terminé avec succès. $mappingSummary',
            processedChanges: helper.changeCount,
          );
        } else {
          // Marquer les éléments comme synchronisés (ancienne méthode)
          print('✅ [SYNC] Marquage des changements comme synchronisés');
          await _markChangesAsSynced(helper);

          state = state.copyWith(
            status: SyncStatus.idle,
            message: 'Upload terminé avec succès',
            processedChanges: helper.changeCount,
          );
        }
      } else {
        print('❌ [SYNC] Échec de l\'upload: réponse nulle');
        throw Exception('Échec de l\'upload');
      }
    } catch (e) {
      print('❌ [SYNC] Erreur upload changements locaux: $e');
      state = state.copyWith(
        status: SyncStatus.error,
        error: 'Erreur upload: $e',
      );
      rethrow;
    }
  }

  /// Collecte tous les changements non synchronisés
  Future<void> _collectUnsyncedChanges(SyncUploadHelper helper) async {
    print('🔍 [SYNC] Démarrage collecte changements non synchronisés');
    final database = ref.read(databaseProvider);

    // Collecter les élèves non synchronisés
    try {
      final unsyncedEleves = await database.eleveDao.getUnsyncedEleves();
      print(
        '👨‍🎓 [SYNC] ${unsyncedEleves.length} élèves non synchronisés trouvés',
      );
      for (final eleve in unsyncedEleves) {
        if (eleve.serverId != null) {
          helper.addEleve(eleve, operation: SyncOperation.update);
        } else {
          helper.addEleve(eleve, operation: SyncOperation.insert);
        }
      }
    } catch (e) {
      print('❌ [SYNC] Erreur collecte élèves: $e');
    }

    // Collecter les enseignants non synchronisés
    try {
      final unsyncedEnseignants = await database.enseignantDao
          .getUnsyncedEnseignants();
      print(
        '👨‍🏫 [SYNC] ${unsyncedEnseignants.length} enseignants non synchronisés trouvés',
      );
      for (final enseignant in unsyncedEnseignants) {
        if (enseignant.serverId != null) {
          helper.addEnseignant(enseignant, operation: SyncOperation.update);
        } else {
          helper.addEnseignant(enseignant, operation: SyncOperation.insert);
        }
      }
    } catch (e) {
      print('❌ [SYNC] Erreur collecte enseignants: $e');
    }

    // Collecter les classes non synchronisées
    try {
      final unsyncedClasses = await database.classeDao.getUnsyncedClasses();
      print(
        '🏫 [SYNC] ${unsyncedClasses.length} classes non synchronisées trouvées',
      );
      for (final classe in unsyncedClasses) {
        if (classe.serverId != null) {
          helper.addClasse(classe, operation: SyncOperation.update);
        } else {
          helper.addClasse(classe, operation: SyncOperation.insert);
        }
      }
    } catch (e) {
      print('❌ [SYNC] Erreur collecte classes: $e');
    }

    // Collecter les années scolaires non synchronisées
    try {
      final unsyncedAnnees = await database.anneeScolaireDao
          .getUnsyncedAnneesScolaires();
      print(
        '📅 [SYNC] ${unsyncedAnnees.length} années scolaires non synchronisées trouvées',
      );
      for (final annee in unsyncedAnnees) {
        if (annee.serverId != null) {
          helper.addAnneeScolaire(annee, operation: SyncOperation.update);
        } else {
          helper.addAnneeScolaire(annee, operation: SyncOperation.insert);
        }
      }
    } catch (e) {
      print('❌ [SYNC] Erreur collecte années scolaires: $e');
    }

    // Collecter les responsables non synchronisés
    try {
      final unsyncedResponsables = await database.responsableDao
          .getUnsyncedResponsables();
      print(
        '👨‍👩‍👧‍👦 [SYNC] ${unsyncedResponsables.length} responsables non synchronisés trouvés',
      );
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
      print('❌ [SYNC] Erreur collecte responsables: $e');
    }

    // Collecter les cours non synchronisés
    try {
      final unsyncedCours = await database.coursDao.getUnsyncedCours();
      print('📖 [SYNC] ${unsyncedCours.length} cours non synchronisés trouvés');
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
      print('❌ [SYNC] Erreur collecte cours: $e');
    }

    // Collecter les frais scolaires non synchronisés
    try {
      final unsyncedFrais = await database.fraisScolaireDao
          .getUnsyncedFraisScolaires();
      print(
        '📋 [SYNC] ${unsyncedFrais.length} frais scolaires non synchronisés trouvés',
      );
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
      print('❌ [SYNC] Erreur collecte frais scolaires: $e');
    }

    // Collecter les frais classes non synchronisés
    try {
      final unsyncedFraisClasses = await database.fraisClassesDao
          .getUnsyncedFraisClasses();
      print(
        '📋 [SYNC] ${unsyncedFraisClasses.length} frais classes non synchronisés trouvés',
      );
      for (final fraisClasse in unsyncedFraisClasses) {
        helper.addEntity(
          fraisClasse,
          'frais_classes',
          fraisClasse.serverId != null
              ? SyncOperation.update
              : SyncOperation.insert,
          toJson: (f) => f.toJson(),
          getServerId: (f) => f.serverId,
        );
      }
    } catch (e) {
      print('❌ [SYNC] Erreur collecte frais classes: $e');
    }

    // Collecter les notes de période non synchronisées
    try {
      final unsyncedNotes = await database.notePeriodeDao
          .getUnsyncedNotesPeriode();
      print(
        '📚 [SYNC] ${unsyncedNotes.length} notes de période non synchronisées trouvées',
      );
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
      print('❌ [SYNC] Erreur collecte notes période: $e');
    }

    // Collecter les paiements de frais non synchronisés
    try {
      final unsyncedPaiements = await database.paiementFraisDao
          .getUnsyncedPaiementsFrais();
      print(
        '💰 [SYNC] ${unsyncedPaiements.length} paiements de frais non synchronisés trouvés',
      );
      for (final paiement in unsyncedPaiements) {
        helper.addEntity(
          paiement,
          'paiement_frais',
          paiement.serverId != null
              ? SyncOperation.update
              : SyncOperation.insert,
          toJson: (p) => p.toJson(),
          getServerId: (p) => p.serverId,
        );
      }
    } catch (e) {
      print('❌ [SYNC] Erreur collecte paiements frais: $e');
    }

    // Collecter les périodes non synchronisées
    try {
      final unsyncedPeriodes = await database.periodeDao.getUnsyncedPeriodes();
      print(
        '⏰ [SYNC] ${unsyncedPeriodes.length} périodes non synchronisées trouvées',
      );
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
      print('❌ [SYNC] Erreur collecte périodes: $e');
    }

    // Collecter les créances non synchronisées
    try {
      final unsyncedCreances = await database.creanceDao.getUnsyncedCreances();
      print(
        '💳 [SYNC] ${unsyncedCreances.length} créances non synchronisées trouvées',
      );
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
      print('❌ [SYNC] Erreur collecte créances: $e');
    }

    // Collecter les utilisateurs non synchronisés
    try {
      final unsyncedUtilisateurs = await database.utilisateurDao
          .getUnsyncedUtilisateurs();
      print(
        '👤 [SYNC] ${unsyncedUtilisateurs.length} utilisateurs non synchronisés trouvés',
      );
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
      print('❌ [SYNC] Erreur collecte utilisateurs: $e');
    }

    // Collecter les configurations d'école non synchronisées
    try {
      final unsyncedConfigs = await database.configEcoleDao
          .getUnsyncedConfigsEcole();
      print(
        '⚙️ [SYNC] ${unsyncedConfigs.length} configurations d\'école non synchronisées trouvées',
      );
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
      print('❌ [SYNC] Erreur collecte configs école: $e');
    }

    // Collecter les périodes-classes non synchronisées
    try {
      final unsyncedPeriodesClasses = await database.periodesClassesDao
          .getUnsyncedPeriodesClasses();
      print(
        '📚 [SYNC] ${unsyncedPeriodesClasses.length} périodes-classes non synchronisées trouvées',
      );
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
      print('❌ [SYNC] Erreur collecte périodes-classes: $e');
    }

    // Tables comptables
    // Collecter les comptes comptables non synchronisés
    try {
      final unsyncedComptes = await database.compteComptableDao
          .getUnsyncedComptesComptables();
      print(
        '💼 [SYNC] ${unsyncedComptes.length} comptes comptables non synchronisés trouvés',
      );
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
      print('❌ [SYNC] Erreur collecte comptes comptables: $e');
    }

    // Collecter les classes comptables non synchronisées
    try {
      final unsyncedClassesComptables = await database.classeComptableDao
          .getUnsyncedClassesComptables();
      print(
        '📊 [SYNC] ${unsyncedClassesComptables.length} classes comptables non synchronisées trouvées',
      );
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
      print('❌ [SYNC] Erreur collecte classes comptables: $e');
    }

    // Collecter les journaux comptables non synchronisés
    try {
      final unsyncedJournaux = await database.journalComptableDao
          .getUnsyncedJournauxComptables();
      print(
        '📓 [SYNC] ${unsyncedJournaux.length} journaux comptables non synchronisés trouvés',
      );
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
      print('❌ [SYNC] Erreur collecte journaux comptables: $e');
    }

    // Collecter les écritures comptables non synchronisées
    try {
      final unsyncedEcritures = await database.ecritureComptableDao
          .getUnsyncedEcrituresComptables();
      print(
        '📝 [SYNC] ${unsyncedEcritures.length} écritures comptables non synchronisées trouvées',
      );
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
      print('❌ [SYNC] Erreur collecte écritures comptables: $e');
    }

    // Collecter les dépenses non synchronisées
    try {
      final unsyncedDepenses = await database.depenseDao.getUnsyncedDepenses();
      print(
        '💸 [SYNC] ${unsyncedDepenses.length} dépenses non synchronisées trouvées',
      );
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
      print('❌ [SYNC] Erreur collecte dépenses: $e');
    }

    // Collecter les licences non synchronisées
    try {
      final unsyncedLicences = await database.licenceDao.getUnsyncedLicences();
      print(
        '📜 [SYNC] ${unsyncedLicences.length} licences non synchronisées trouvées',
      );
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
      print('❌ [SYNC] Erreur collecte licences: $e');
    }

    // Collecter les entreprises non synchronisées
    try {
      final unsyncedEntreprises = await database.entrepriseDao
          .getUnsyncedEntreprises();
      print(
        '🏢 [SYNC] ${unsyncedEntreprises.length} entreprises non synchronisées trouvées',
      );
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
      print('❌ [SYNC] Erreur collecte entreprises: $e');
    }

    // Collecter les configurations de comptes non synchronisées
    try {
      final unsyncedComptesConfigs = await database.comptesConfigDao
          .getUnsyncedComptesConfigs();
      print(
        '🔧 [SYNC] ${unsyncedComptesConfigs.length} configurations de comptes non synchronisées trouvées',
      );
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
      print('❌ [SYNC] Erreur collecte configurations comptes: $e');
    }

    print('✅ [SYNC] Collecte des changements terminée');
  }

  /// Marque les changements comme synchronisés après upload réussi
  Future<void> _markChangesAsSynced(SyncUploadHelper helper) async {
    print('✅ [SYNC] Démarrage marquage changements synchronisés');
    final database = ref.read(databaseProvider);
    final changesByTable = helper.changesByTable;

    // Marquer les élèves comme synchronisés
    if (changesByTable.containsKey('eleves')) {
      try {
        final eleveChanges = changesByTable['eleves']!;
        print(
          '👨‍🎓 [SYNC] Marquage ${eleveChanges.length} élèves comme synchronisés',
        );
        for (final change in eleveChanges) {
          final eleveId = change.data['id'] as int?;
          if (eleveId != null) {
            await database.eleveDao.markAsSynced(eleveId);
          }
        }
      } catch (e) {
        print('❌ [SYNC] Erreur marquage élèves: $e');
      }
    }

    // Marquer les enseignants comme synchronisés
    if (changesByTable.containsKey('enseignants')) {
      try {
        final enseignantChanges = changesByTable['enseignants']!;
        print(
          '👨‍🏫 [SYNC] Marquage ${enseignantChanges.length} enseignants comme synchronisés',
        );
        for (final change in enseignantChanges) {
          final enseignantId = change.data['id'] as int?;
          if (enseignantId != null) {
            await database.enseignantDao.markAsSynced(enseignantId);
          }
        }
      } catch (e) {
        print('❌ [SYNC] Erreur marquage enseignants: $e');
      }
    }

    // Marquer les paiements de frais comme synchronisés
    if (changesByTable.containsKey('paiement_frais')) {
      try {
        final paiementChanges = changesByTable['paiement_frais']!;
        print(
          '💳 [SYNC] Marquage ${paiementChanges.length} paiements comme synchronisés',
        );
        for (final change in paiementChanges) {
          final paiementId = change.data['id'] as int?;
          if (paiementId != null) {
            await database.paiementFraisDao.markAsSynced(paiementId);
          }
        }
      } catch (e) {
        print('❌ [SYNC] Erreur marquage paiements: $e');
      }
    }

    // Marquer les responsables comme synchronisés
    if (changesByTable.containsKey('responsables')) {
      try {
        final responsableChanges = changesByTable['responsables']!;
        print(
          '👨‍👩‍👧‍👦 [SYNC] Marquage ${responsableChanges.length} responsables comme synchronisés',
        );
        for (final change in responsableChanges) {
          final responsableId = change.data['id'] as int?;
          if (responsableId != null) {
            await database.responsableDao.markAsSynced(responsableId);
          }
        }
      } catch (e) {
        print('❌ [SYNC] Erreur marquage responsables: $e');
      }
    }

    // Marquer les dépenses comme synchronisées
    if (changesByTable.containsKey('depenses')) {
      try {
        final depenseChanges = changesByTable['depenses']!;
        print(
          '💰 [SYNC] Marquage ${depenseChanges.length} dépenses comme synchronisées',
        );
        for (final change in depenseChanges) {
          final depenseId = change.data['id'] as int?;
          if (depenseId != null) {
            await database.depenseDao.markAsSynced(depenseId);
          }
        }
      } catch (e) {
        print('❌ [SYNC] Erreur marquage dépenses: $e');
      }
    }

    // Marquer les créances comme synchronisées
    if (changesByTable.containsKey('creances')) {
      try {
        final creanceChanges = changesByTable['creances']!;
        print(
          '📋 [SYNC] Marquage ${creanceChanges.length} créances comme synchronisées',
        );
        for (final change in creanceChanges) {
          final creanceId = change.data['id'] as int?;
          if (creanceId != null) {
            await database.creanceDao.markAsSynced(creanceId);
          }
        }
      } catch (e) {
        print('❌ [SYNC] Erreur marquage créances: $e');
      }
    }

    print('✅ [SYNC] Marquage synchronisation terminé');
  }

  /// Synchronisation bidirectionnelle complète
  Future<void> performBidirectionalSync(String userEmail) async {
    print(
      '🔄 [SYNC] Démarrage synchronisation bidirectionnelle pour $userEmail',
    );
    try {
      // 1. Upload des changements locaux d'abord
      print('📤 [SYNC] Étape 1: Upload des changements locaux');
      await uploadLocalChanges(userEmail);

      // 2. Download des changements du serveur
      print('📥 [SYNC] Étape 2: Download des changements serveur');
      await performFullSync(userEmail);

      print('✅ [SYNC] Synchronisation bidirectionnelle terminée');
    } catch (e) {
      print('❌ [SYNC] Erreur synchronisation bidirectionnelle: $e');
      state = state.copyWith(
        status: SyncStatus.error,
        error: 'Erreur sync bidirectionnelle: $e',
      );
      rethrow;
    }
  }

  /// Force une synchronisation (ignore la dernière date)
  Future<void> performForcedSync(String userEmail) async {
    print('🔄 [SYNC] Démarrage synchronisation forcée pour $userEmail');
    final syncPrefs = ref.read(syncPreferencesNotifierProvider.notifier);
    print('🗑️ [SYNC] Réinitialisation des données de synchronisation');
    await syncPrefs.clearSyncData();
    await performFullSync(userEmail);
    print('✅ [SYNC] Synchronisation forcée terminée');
  }

  /// Remet à zéro l'état de synchronisation
  void resetState() {
    print('🔄 [SYNC] Réinitialisation de l\'état de synchronisation');
    state = const SyncState();
  }
}
