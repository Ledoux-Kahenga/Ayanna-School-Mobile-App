// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_periode.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotePeriode _$NotePeriodeFromJson(Map<String, dynamic> json) => NotePeriode(
      id: (json['id'] as num?)?.toInt(),
      serverId: (json['id'] as num?)?.toInt(),
      eleveId: (json['eleve_id'] as num).toInt(),
      coursId: (json['cours_id'] as num).toInt(),
      periodeId: (json['periode_id'] as num).toInt(),
      valeur: (json['valeur'] as num?)?.toDouble(),
      dateCreation: DateTime.parse(json['date_creation'] as String),
      dateModification: DateTime.parse(json['date_modification'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$NotePeriodeToJson(NotePeriode instance) {
  final val = <String, dynamic>{
    'eleve_id': instance.eleveId,
    'cours_id': instance.coursId,
    'periode_id': instance.periodeId,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('valeur', instance.valeur);
  val['date_creation'] = instance.dateCreation.toIso8601String();
  val['date_modification'] = instance.dateModification.toIso8601String();
  val['updated_at'] = instance.updatedAt.toIso8601String();
  return val;
}
