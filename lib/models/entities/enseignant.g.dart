// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enseignant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Enseignant _$EnseignantFromJson(Map<String, dynamic> json) => Enseignant(
      serverId: (json['id'] as num?)?.toInt(),
      matricule: json['matricule'] as String?,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      sexe: json['sexe'] as String?,
      niveau: json['niveau'] as String?,
      discipline: json['discipline'] as String?,
      email: json['email'] as String?,
      telephone: json['telephone'] as String?,
      entrepriseId: (json['entreprise_id'] as num).toInt(),
      dateCreation: DateTime.parse(json['date_creation'] as String),
      dateModification: DateTime.parse(json['date_modification'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$EnseignantToJson(Enseignant instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.serverId);
  writeNotNull('matricule', instance.matricule);
  val['nom'] = instance.nom;
  val['prenom'] = instance.prenom;
  writeNotNull('sexe', instance.sexe);
  writeNotNull('niveau', instance.niveau);
  writeNotNull('discipline', instance.discipline);
  writeNotNull('email', instance.email);
  writeNotNull('telephone', instance.telephone);
  val['entreprise_id'] = instance.entrepriseId;
  val['date_creation'] = instance.dateCreation.toIso8601String();
  val['date_modification'] = instance.dateModification.toIso8601String();
  val['updated_at'] = instance.updatedAt.toIso8601String();
  return val;
}
