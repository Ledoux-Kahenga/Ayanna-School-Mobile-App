// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config_ecole.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConfigEcole _$ConfigEcoleFromJson(Map<String, dynamic> json) => ConfigEcole(
      serverId: (json['id'] as num?)?.toInt(),
      entrepriseId: (json['entreprise_id'] as num).toInt(),
      anneeScolaireEnCoursId:
          (json['annee_scolaire_en_cours_id'] as num?)?.toInt(),
      dateCreation: DateTime.parse(json['date_creation'] as String),
      dateModification: DateTime.parse(json['date_modification'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ConfigEcoleToJson(ConfigEcole instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.serverId);
  val['entreprise_id'] = instance.entrepriseId;
  writeNotNull('annee_scolaire_en_cours_id', instance.anneeScolaireEnCoursId);
  val['date_creation'] = instance.dateCreation.toIso8601String();
  val['date_modification'] = instance.dateModification.toIso8601String();
  val['updated_at'] = instance.updatedAt.toIso8601String();
  return val;
}
