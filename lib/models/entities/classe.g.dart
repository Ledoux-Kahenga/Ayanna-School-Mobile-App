// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classe.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Classe _$ClasseFromJson(Map<String, dynamic> json) => Classe(
      id: (json['id'] as num?)?.toInt(),
      serverId: (json['id'] as num?)?.toInt(),
      code: json['code'] as String?,
      nom: json['nom'] as String,
      niveau: json['niveau'] as String?,
      effectif: (json['effectif'] as num?)?.toInt(),
      anneeScolaireId: (json['annee_scolaire_id'] as num).toInt(),
      enseignantId: (json['enseignant_id'] as num?)?.toInt(),
      dateCreation: DateTime.parse(json['date_creation'] as String),
      dateModification: DateTime.parse(json['date_modification'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ClasseToJson(Classe instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.serverId);
  writeNotNull('code', instance.code);
  val['nom'] = instance.nom;
  writeNotNull('niveau', instance.niveau);
  writeNotNull('effectif', instance.effectif);
  val['annee_scolaire_id'] = instance.anneeScolaireId;
  writeNotNull('enseignant_id', instance.enseignantId);
  val['date_creation'] = instance.dateCreation.toIso8601String();
  val['date_modification'] = instance.dateModification.toIso8601String();
  val['updated_at'] = instance.updatedAt.toIso8601String();
  return val;
}
