// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_upload_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncUploadRequest _$SyncUploadRequestFromJson(Map<String, dynamic> json) =>
    SyncUploadRequest(
      clientId: json['client_id'] as String,
      changes: (json['changes'] as List<dynamic>)
          .map((e) => SyncChangeUpload.fromJson(e as Map<String, dynamic>))
          .toList(),
      timestamp: json['timestamp'] as String,
    );

Map<String, dynamic> _$SyncUploadRequestToJson(SyncUploadRequest instance) =>
    <String, dynamic>{
      'client_id': instance.clientId,
      'changes': instance.changes.map((e) => e.toJson()).toList(),
      'timestamp': instance.timestamp,
    };

SyncChangeUpload _$SyncChangeUploadFromJson(Map<String, dynamic> json) =>
    SyncChangeUpload(
      table: json['table'] as String,
      operation: json['operation'] as String,
      action: json['action'] as String,
      data: json['data'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$SyncChangeUploadToJson(SyncChangeUpload instance) =>
    <String, dynamic>{
      'table': instance.table,
      'operation': instance.operation,
      'action': instance.action,
      'data': instance.data,
    };
