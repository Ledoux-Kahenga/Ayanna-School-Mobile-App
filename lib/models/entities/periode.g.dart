// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'periode.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Periode _$PeriodeFromJson(Map<String, dynamic> json) => Periode(
      id: (json['id'] as num?)?.toInt(),
      serverId: (json['id'] as num?)?.toInt(),
      code: json['code'] as String?,
      nom: json['nom'] as String,
      semestre: (json['semestre'] as num).toInt(),
      poids: (json['poids'] as num?)?.toInt(),
      dateDebut: json['date_debut'] == null
          ? null
          : DateTime.parse(json['date_debut'] as String),
      dateFin: json['date_fin'] == null
          ? null
          : DateTime.parse(json['date_fin'] as String),
      anneeScolaireId: (json['annee_scolaire_id'] as num?)?.toInt(),
      dateCreation: DateTime.parse(json['date_creation'] as String),
      dateModification: DateTime.parse(json['date_modification'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$PeriodeToJson(Periode instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('code', instance.code);
  val['nom'] = instance.nom;
  val['semestre'] = instance.semestre;
  writeNotNull('poids', instance.poids);
  writeNotNull('date_debut', instance.dateDebut?.toIso8601String());
  writeNotNull('date_fin', instance.dateFin?.toIso8601String());
  writeNotNull('annee_scolaire_id', instance.anneeScolaireId);
  val['date_creation'] = instance.dateCreation.toIso8601String();
  val['date_modification'] = instance.dateModification.toIso8601String();
  val['updated_at'] = instance.updatedAt.toIso8601String();
  return val;
}
