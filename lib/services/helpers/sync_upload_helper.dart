import '../../models/sync_upload_request.dart';
import '../../models/entities/eleve.dart';
import '../../models/entities/enseignant.dart';
import '../../models/entities/classe.dart';
import '../../models/entities/annee_scolaire.dart';
// Ajoutez d'autres imports d'entités selon vos besoins

/// Helper pour créer facilement les requêtes d'upload de synchronisation
class SyncUploadHelper {
  final SyncUploadRequestBuilder _builder;

  SyncUploadHelper({String clientId = 'flutter-client'})
    : _builder = SyncUploadRequestBuilder(clientId: clientId);

  /// Ajouter un élève modifié/créé
  void addEleve(Eleve eleve, {required SyncOperation operation}) {
    final data = eleve.toJson();
    // Retirer les champs locaux qui ne doivent pas être envoyés
    // Statut de sync local

    switch (operation) {
      case SyncOperation.insert:
        _builder.addInsert('eleves', data);
        break;
      case SyncOperation.update:
        _builder.addUpdate('eleves', data);
        break;
      case SyncOperation.delete:
        _builder.addDelete('eleves', {'id': eleve.serverId});
        break;
    }
  }

  /// Ajouter un enseignant modifié/créé
  void addEnseignant(
    Enseignant enseignant, {
    required SyncOperation operation,
  }) {
    final data = enseignant.toJson();
   

    switch (operation) {
      case SyncOperation.insert:
        _builder.addInsert('enseignants', data);
        break;
      case SyncOperation.update:
        _builder.addUpdate('enseignants', data);
        break;
      case SyncOperation.delete:
        _builder.addDelete('enseignants', {'id': enseignant.serverId});
        break;
    }
  }

  /// Ajouter une classe modifiée/créée
  void addClasse(Classe classe, {required SyncOperation operation}) {
    final data = classe.toJson();
    

    switch (operation) {
      case SyncOperation.insert:
        _builder.addInsert('classes', data);
        break;
      case SyncOperation.update:
        _builder.addUpdate('classes', data);
        break;
      case SyncOperation.delete:
        _builder.addDelete('classes', {'id': classe.serverId});
        break;
    }
  }

  /// Ajouter une année scolaire modifiée/créée
  void addAnneeScolaire(
    AnneeScolaire anneeScolaire, {
    required SyncOperation operation,
  }) {
    final data = anneeScolaire.toJson();

  

    switch (operation) {
      case SyncOperation.insert:
        _builder.addInsert('annees_scolaires', data);
        break;
      case SyncOperation.update:
        _builder.addUpdate('annees_scolaires', data);
        break;
      case SyncOperation.delete:
        _builder.addDelete('annees_scolaires', {'id': anneeScolaire.serverId});
        break;
    }
  }

  /// Méthode générique pour ajouter n'importe quelle entité
  void addEntity<T>(
    T entity,
    String tableName,
    SyncOperation operation, {
    required Map<String, dynamic> Function(T) toJson,
    required dynamic Function(T) getServerId,
  }) {
    final data = toJson(entity);
   

    switch (operation) {
      case SyncOperation.insert:
        _builder.addInsert(tableName, data);
        break;
      case SyncOperation.update:
        _builder.addUpdate(tableName, data);
        break;
      case SyncOperation.delete:
        _builder.addDelete(tableName, {'id': getServerId(entity)});
        break;
    }
  }

  /// Construire la requête finale
  SyncUploadRequest build() => _builder.build();

  /// Vider les changements
  void clear() => _builder.clear();

  /// Statistiques des changements
  Map<String, int> get stats => _builder.changeStats;

  /// Nombre de changements
  int get changeCount => _builder.changeCount;

  /// Vérifier s'il y a des changements
  bool get hasChanges => _builder.hasChanges;

  /// Changements groupés par table
  Map<String, List<SyncChangeUpload>> get changesByTable =>
      _builder.changesByTable;
}

/// Extension pour faciliter l'ajout d'entités
extension SyncUploadHelperExtensions on SyncUploadHelper {
  /// Ajouter plusieurs élèves
  void addEleves(List<Eleve> eleves, {required SyncOperation operation}) {
    for (final eleve in eleves) {
      addEleve(eleve, operation: operation);
    }
  }

  /// Ajouter plusieurs enseignants
  void addEnseignants(
    List<Enseignant> enseignants, {
    required SyncOperation operation,
  }) {
    for (final enseignant in enseignants) {
      addEnseignant(enseignant, operation: operation);
    }
  }

  /// Ajouter plusieurs classes
  void addClasses(List<Classe> classes, {required SyncOperation operation}) {
    for (final classe in classes) {
      addClasse(classe, operation: operation);
    }
  }

  /// Ajouter plusieurs années scolaires
  void addAnneesScolaires(
    List<AnneeScolaire> anneesScolaires, {
    required SyncOperation operation,
  }) {
    for (final anneeScolaire in anneesScolaires) {
      addAnneeScolaire(anneeScolaire, operation: operation);
    }
  }
}

/// Exemple d'utilisation
class SyncUploadExample {
  static Future<void> exempleUpload() async {
    final helper = SyncUploadHelper(clientId: 'flutter-client');

    // Exemple d'ajout d'un élève modifié
    final eleve = Eleve(
      serverId: 71,
      nom: 'Kalombo',
      postnom: 'Kante',
      prenom: 'Elvis',
      sexe: 'Masculin',
      statut: 'actif',
      dateNaissance: DateTime.parse('2015-09-12'),
      matricule: 'EKAKAEL469',
      classeId: 38,
      responsableId: 99,
      dateCreation: DateTime.parse('2025-09-12T16:28:53.000000+00:00'),
      dateModification: DateTime.parse('2025-09-12T16:28:53.000000+00:00'),
      updatedAt: DateTime.parse('2025-09-12T16:31:24.000000+00:00'),
    );

    // Ajouter l'élève comme modification
    helper.addEleve(eleve, operation: SyncOperation.update);

    // Construire la requête
    final uploadRequest = helper.build();

    print('Requête d\'upload construite:');
    print('- Client ID: ${uploadRequest.clientId}');
    print('- Nombre de changements: ${uploadRequest.changes.length}');
    print('- Timestamp: ${uploadRequest.timestamp}');

    // La requête peut maintenant être envoyée via le SyncService
    // await syncService.uploadChanges(uploadRequest);
  }
}
