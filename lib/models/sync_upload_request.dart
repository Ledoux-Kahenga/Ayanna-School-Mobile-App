import 'package:json_annotation/json_annotation.dart';

part 'sync_upload_request.g.dart';

/// Modèle pour la requête d'upload de synchronisation
@JsonSerializable()
class SyncUploadRequest {
  @JsonKey(name: 'client_id')
  final String clientId;

  final List<SyncChangeUpload> changes;

  final String timestamp;

  SyncUploadRequest({
    required this.clientId,
    required this.changes,
    required this.timestamp,
  });

  factory SyncUploadRequest.fromJson(Map<String, dynamic> json) =>
      _$SyncUploadRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SyncUploadRequestToJson(this);
}

/// Modèle pour un changement individual à uploader
@JsonSerializable()
class SyncChangeUpload {
  final String table;
  final String operation; // "insert", "update", "delete"
  final String action; // "ajout", "modifié", "supprimé"
  final Map<String, dynamic> data;

  SyncChangeUpload({
    required this.table,
    required this.operation,
    required this.action,
    required this.data,
  });

  factory SyncChangeUpload.fromJson(Map<String, dynamic> json) =>
      _$SyncChangeUploadFromJson(json);

  Map<String, dynamic> toJson() => _$SyncChangeUploadToJson(this);
}

/// Enum pour les types d'opérations
enum SyncOperation {
  @JsonValue('insert')
  insert,
  @JsonValue('update')
  update,
  @JsonValue('delete')
  delete,
}

/// Enum pour les actions
enum SyncAction {
  @JsonValue('ajout')
  ajout,
  @JsonValue('modifié')
  modifie,
  @JsonValue('supprimé')
  supprime,
}

/// Extension pour faciliter la conversion des enums
extension SyncOperationExtension on SyncOperation {
  String get value {
    switch (this) {
      case SyncOperation.insert:
        return 'insert';
      case SyncOperation.update:
        return 'update';
      case SyncOperation.delete:
        return 'delete';
    }
  }

  SyncAction get correspondingAction {
    switch (this) {
      case SyncOperation.insert:
        return SyncAction.ajout;
      case SyncOperation.update:
        return SyncAction.modifie;
      case SyncOperation.delete:
        return SyncAction.supprime;
    }
  }
}

extension SyncActionExtension on SyncAction {
  String get value {
    switch (this) {
      case SyncAction.ajout:
        return 'ajout';
      case SyncAction.modifie:
        return 'modifié';
      case SyncAction.supprime:
        return 'supprimé';
    }
  }
}

/// Builder pour construire facilement les requêtes d'upload
class SyncUploadRequestBuilder {
  final String clientId;
  final List<SyncChangeUpload> _changes = [];

  SyncUploadRequestBuilder({this.clientId = 'flutter-client'});

  /// Ajouter un changement d'insertion
  void addInsert(String table, Map<String, dynamic> data) {
    _changes.add(
      SyncChangeUpload(
        table: table,
        operation: SyncOperation.insert.value,
        action: SyncAction.ajout.value,
        data: data,
      ),
    );
  }

  /// Ajouter un changement de mise à jour
  void addUpdate(String table, Map<String, dynamic> data) {
    _changes.add(
      SyncChangeUpload(
        table: table,
        operation: SyncOperation.update.value,
        action: SyncAction.modifie.value,
        data: data,
      ),
    );
  }

  /// Ajouter un changement de suppression
  void addDelete(String table, Map<String, dynamic> data) {
    _changes.add(
      SyncChangeUpload(
        table: table,
        operation: SyncOperation.delete.value,
        action: SyncAction.supprime.value,
        data: data,
      ),
    );
  }

  /// Ajouter un changement personnalisé
  void addChange(SyncChangeUpload change) {
    _changes.add(change);
  }

  /// Construire la requête finale
  SyncUploadRequest build() {
    return SyncUploadRequest(
      clientId: clientId,
      changes: List.from(_changes),
      timestamp: DateTime.now().toIso8601String(),
    );
  }

  /// Vider la liste des changements
  void clear() {
    _changes.clear();
  }

  /// Obtenir le nombre de changements
  int get changeCount => _changes.length;

  /// Vérifier si des changements sont en attente
  bool get hasChanges => _changes.isNotEmpty;

  /// Grouper les changements par table
  Map<String, List<SyncChangeUpload>> get changesByTable {
    final grouped = <String, List<SyncChangeUpload>>{};
    for (final change in _changes) {
      grouped.putIfAbsent(change.table, () => []).add(change);
    }
    return grouped;
  }

  /// Statistiques des changements
  Map<String, int> get changeStats {
    final stats = <String, int>{'insert': 0, 'update': 0, 'delete': 0};
    for (final change in _changes) {
      stats[change.operation] = (stats[change.operation] ?? 0) + 1;
    }
    return stats;
  }
}
