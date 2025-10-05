// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'frais_scolaire.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FraisScolaire _$FraisScolaireFromJson(Map<String, dynamic> json) =>
    FraisScolaire(
      id: (json['id'] as num?)?.toInt(),
      serverId: (json['id'] as num?)?.toInt(),
      nom: json['nom'] as String,
      montant: (json['montant'] as num).toDouble(),
      dateLimite: json['date_limite'] == null
          ? null
          : DateTime.parse(json['date_limite'] as String),
      entrepriseId: (json['entreprise_id'] as num).toInt(),
      anneeScolaireId: (json['annee_scolaire_id'] as num).toInt(),
      dateCreation: DateTime.parse(json['date_creation'] as String),
      dateModification: DateTime.parse(json['date_modification'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$FraisScolaireToJson(FraisScolaire instance) {
  final val = <String, dynamic>{
    'nom': instance.nom,
    'montant': instance.montant,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('date_limite', instance.dateLimite?.toIso8601String());
  val['entreprise_id'] = instance.entrepriseId;
  val['annee_scolaire_id'] = instance.anneeScolaireId;
  val['date_creation'] = instance.dateCreation.toIso8601String();
  val['date_modification'] = instance.dateModification.toIso8601String();
  val['updated_at'] = instance.updatedAt.toIso8601String();
  return val;
}
