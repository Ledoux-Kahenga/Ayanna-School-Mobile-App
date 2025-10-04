// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'eleve.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Eleve _$EleveFromJson(Map<String, dynamic> json) => Eleve(
      serverId: (json['id'] as num?)?.toInt(),
      nom: json['nom'] as String,
      postnom: json['postnom'] as String?,
      prenom: json['prenom'] as String,
      sexe: json['sexe'] as String?,
      statut: json['statut'] as String?,
      dateNaissance: json['date_naissance'] == null
          ? null
          : DateTime.parse(json['date_naissance'] as String),
      lieuNaissance: json['lieu_naissance'] as String?,
      matricule: json['matricule'] as String?,
      numeroPermanent: json['numero_permanent'] as String?,
      classeId: (json['classe_id'] as num?)?.toInt(),
      responsableId: (json['responsable_id'] as num?)?.toInt(),
      dateCreation: DateTime.parse(json['date_creation'] as String),
      dateModification: DateTime.parse(json['date_modification'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$EleveToJson(Eleve instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.serverId);
  val['nom'] = instance.nom;
  writeNotNull('postnom', instance.postnom);
  val['prenom'] = instance.prenom;
  writeNotNull('sexe', instance.sexe);
  writeNotNull('statut', instance.statut);
  writeNotNull('date_naissance', instance.dateNaissance?.toIso8601String());
  writeNotNull('lieu_naissance', instance.lieuNaissance);
  writeNotNull('matricule', instance.matricule);
  writeNotNull('numero_permanent', instance.numeroPermanent);
  writeNotNull('classe_id', instance.classeId);
  writeNotNull('responsable_id', instance.responsableId);
  val['date_creation'] = instance.dateCreation.toIso8601String();
  val['date_modification'] = instance.dateModification.toIso8601String();
  val['updated_at'] = instance.updatedAt.toIso8601String();
  return val;
}
