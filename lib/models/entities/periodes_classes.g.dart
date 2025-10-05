// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'periodes_classes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PeriodesClasses _$PeriodesClassesFromJson(Map<String, dynamic> json) =>
    PeriodesClasses(
      id: (json['id'] as num?)?.toInt(),
      serverId: (json['id'] as num?)?.toInt(),
      classeId: (json['classe_id'] as num).toInt(),
      periodeId: (json['periode_id'] as num).toInt(),
      dateCreation: DateTime.parse(json['date_creation'] as String),
      dateModification: DateTime.parse(json['date_modification'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$PeriodesClassesToJson(PeriodesClasses instance) =>
    <String, dynamic>{
      'classe_id': instance.classeId,
      'periode_id': instance.periodeId,
      'date_creation': instance.dateCreation.toIso8601String(),
      'date_modification': instance.dateModification.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
