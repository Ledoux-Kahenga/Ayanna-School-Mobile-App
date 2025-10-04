// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cours.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Cours _$CoursFromJson(Map<String, dynamic> json) => Cours(
      serverId: (json['id'] as num?)?.toInt(),
      code: json['code'] as String?,
      nom: json['nom'] as String,
      coefficient: (json['coefficient'] as num?)?.toInt(),
      enseignantId: (json['enseignant_id'] as num).toInt(),
      classeId: (json['classe_id'] as num).toInt(),
      dateCreation: DateTime.parse(json['date_creation'] as String),
      dateModification: DateTime.parse(json['date_modification'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$CoursToJson(Cours instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.serverId);
  writeNotNull('code', instance.code);
  val['nom'] = instance.nom;
  writeNotNull('coefficient', instance.coefficient);
  val['enseignant_id'] = instance.enseignantId;
  val['classe_id'] = instance.classeId;
  val['date_creation'] = instance.dateCreation.toIso8601String();
  val['date_modification'] = instance.dateModification.toIso8601String();
  val['updated_at'] = instance.updatedAt.toIso8601String();
  return val;
}
