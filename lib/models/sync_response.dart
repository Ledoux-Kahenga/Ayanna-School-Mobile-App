import 'package:json_annotation/json_annotation.dart';

part 'sync_response.g.dart';

/// Fonction utilitaire pour convertir int/bool en bool
bool _parseBool(dynamic value) {
  if (value is bool) return value;
  if (value is int) return value != 0;
  if (value is String) return value.toLowerCase() == 'true';
  return false;
}

@JsonSerializable()
class SyncResponse {
  final bool success;
  final List<SyncChange> changes;
  final int total;

  const SyncResponse({
    required this.success,
    required this.changes,
    required this.total,
  });

  factory SyncResponse.fromJson(Map<String, dynamic> json) =>
      _$SyncResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SyncResponseToJson(this);

  /// Convertir une liste de JSON en liste d'objets SyncResponse
  static List<SyncResponse> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => SyncResponse.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Convertir une liste d'objets SyncResponse en liste de JSON
  static List<Map<String, dynamic>> toJsonList(List<SyncResponse> responses) {
    return responses.map((response) => response.toJson()).toList();
  }
}

@JsonSerializable()
class SyncChange {
  final String table;
  final String operation;
  final String action;
  final Map<String, dynamic> data;

  const SyncChange({
    required this.table,
    required this.operation,
    required this.action,
    required this.data,
  });

  factory SyncChange.fromJson(Map<String, dynamic> json) =>
      _$SyncChangeFromJson(json);
  Map<String, dynamic> toJson() => _$SyncChangeToJson(this);

  /// Convertir une liste de JSON en liste d'objets SyncChange
  static List<SyncChange> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => SyncChange.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Convertir une liste d'objets SyncChange en liste de JSON
  static List<Map<String, dynamic>> toJsonList(List<SyncChange> changes) {
    return changes.map((change) => change.toJson()).toList();
  }
}

@JsonSerializable()
class SyncUploadResponse {
  final bool success;
  final String? message;
  final List<String>? errors;
  final int? processed;
  @JsonKey(name: 'id_mapping')
  final List<IdMapping>? idMapping;

  const SyncUploadResponse({
    required this.success,
    this.message,
    this.errors,
    this.processed,
    this.idMapping,
  });

  factory SyncUploadResponse.fromJson(Map<String, dynamic> json) =>
      _$SyncUploadResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SyncUploadResponseToJson(this);

  /// Convertir une liste de JSON en liste d'objets SyncUploadResponse
  static List<SyncUploadResponse> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map(
          (json) => SyncUploadResponse.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  /// Convertir une liste d'objets SyncUploadResponse en liste de JSON
  static List<Map<String, dynamic>> toJsonList(
    List<SyncUploadResponse> responses,
  ) {
    return responses.map((response) => response.toJson()).toList();
  }
}

@JsonSerializable()
class IdMapping {
  final String table;
  @JsonKey(name: 'id_local')
  final int? idLocal;
  @JsonKey(name: 'id_serveur')
  final int? idServeur;

  const IdMapping({
    required this.table,
     this.idLocal,
     this.idServeur,
  });

  factory IdMapping.fromJson(Map<String, dynamic> json) =>
      _$IdMappingFromJson(json);
  Map<String, dynamic> toJson() => _$IdMappingToJson(this);

  /// Convertir une liste de JSON en liste d'objets IdMapping
  static List<IdMapping> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => IdMapping.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Convertir une liste d'objets IdMapping en liste de JSON
  static List<Map<String, dynamic>> toJsonList(List<IdMapping> mappings) {
    return mappings.map((mapping) => mapping.toJson()).toList();
  }
}

/// Extensions pour SyncUploadResponse
extension SyncUploadResponseExtensions on SyncUploadResponse {
  /// Vérifie si la réponse contient des mappings d'IDs
  bool get hasIdMapping => idMapping != null && idMapping!.isNotEmpty;

  /// Retourne le nombre total d'IDs mappés
  int get totalMappedIds => idMapping?.length ?? 0;

  /// Retourne la liste des tables affectées par le mapping
  List<String> get affectedTables {
    if (idMapping == null) return [];
    return idMapping!.map((m) => m.table).toSet().toList();
  }

  /// Retourne tous les mappings pour une table donnée
  List<IdMapping> getMappingsForTable(String tableName) {
    if (idMapping == null) return [];
    return idMapping!.where((m) => m.table == tableName).toList();
  }

  /// Retourne l'ID serveur pour un ID local donné dans une table
  int? getServerIdForLocal(String tableName, int localId) {
    if (idMapping == null) return null;

    try {
      final mapping = idMapping!.firstWhere(
        (m) => m.table == tableName && m.idLocal == localId,
      );
      return mapping.idServeur;
    } catch (e) {
      return null;
    }
  }
}
