// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncResponse _$SyncResponseFromJson(Map<String, dynamic> json) => SyncResponse(
      success: json['success'] as bool,
      changes: (json['changes'] as List<dynamic>)
          .map((e) => SyncChange.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
    );

Map<String, dynamic> _$SyncResponseToJson(SyncResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'changes': instance.changes.map((e) => e.toJson()).toList(),
      'total': instance.total,
    };

SyncChange _$SyncChangeFromJson(Map<String, dynamic> json) => SyncChange(
      table: json['table'] as String,
      operation: json['operation'] as String,
      action: json['action'] as String,
      data: json['data'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$SyncChangeToJson(SyncChange instance) =>
    <String, dynamic>{
      'table': instance.table,
      'operation': instance.operation,
      'action': instance.action,
      'data': instance.data,
    };

SyncUploadResponse _$SyncUploadResponseFromJson(Map<String, dynamic> json) =>
    SyncUploadResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      errors:
          (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList(),
      processed: (json['processed'] as num?)?.toInt(),
      idMapping: (json['id_mapping'] as List<dynamic>?)
          ?.map((e) => IdMapping.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SyncUploadResponseToJson(SyncUploadResponse instance) {
  final val = <String, dynamic>{
    'success': instance.success,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('message', instance.message);
  writeNotNull('errors', instance.errors);
  writeNotNull('processed', instance.processed);
  writeNotNull(
      'id_mapping', instance.idMapping?.map((e) => e.toJson()).toList());
  return val;
}

IdMapping _$IdMappingFromJson(Map<String, dynamic> json) => IdMapping(
      table: json['table'] as String,
      idLocal: (json['id_local'] as num).toInt(),
      idServeur: (json['id_serveur'] as num).toInt(),
    );

Map<String, dynamic> _$IdMappingToJson(IdMapping instance) => <String, dynamic>{
      'table': instance.table,
      'id_local': instance.idLocal,
      'id_serveur': instance.idServeur,
    };
