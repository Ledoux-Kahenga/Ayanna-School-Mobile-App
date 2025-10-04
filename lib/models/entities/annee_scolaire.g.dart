// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'annee_scolaire.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnneeScolaire _$AnneeScolaireFromJson(Map<String, dynamic> json) =>
    AnneeScolaire(
      serverId: (json['id'] as num?)?.toInt(),
      nom: json['nom'] as String,
      dateDebut: DateTime.parse(json['date_debut'] as String),
      dateFin: DateTime.parse(json['date_fin'] as String),
      entrepriseId: (json['entreprise_id'] as num).toInt(),
      enCours: (json['en_cours'] as num?)?.toInt(),
      dateCreation: DateTime.parse(json['date_creation'] as String),
      dateModification: DateTime.parse(json['date_modification'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$AnneeScolaireToJson(AnneeScolaire instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.serverId);
  val['nom'] = instance.nom;
  val['date_debut'] = instance.dateDebut.toIso8601String();
  val['date_fin'] = instance.dateFin.toIso8601String();
  val['entreprise_id'] = instance.entrepriseId;
  writeNotNull('en_cours', instance.enCours);
  val['date_creation'] = instance.dateCreation.toIso8601String();
  val['date_modification'] = instance.dateModification.toIso8601String();
  val['updated_at'] = instance.updatedAt.toIso8601String();
  return val;
}
