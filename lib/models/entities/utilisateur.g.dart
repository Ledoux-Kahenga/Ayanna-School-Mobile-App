// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'utilisateur.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Utilisateur _$UtilisateurFromJson(Map<String, dynamic> json) => Utilisateur(
      serverId: (json['id'] as num?)?.toInt(),
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      email: json['email'] as String,
      motDePasseHash: json['mot_de_passe_hash'] as String,
      role: json['role'] as String,
      actif: json['actif'] as bool?,
      entrepriseId: (json['entreprise_id'] as num).toInt(),
      dateCreation: DateTime.parse(json['date_creation'] as String),
      dateModification: DateTime.parse(json['date_modification'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$UtilisateurToJson(Utilisateur instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.serverId);
  val['nom'] = instance.nom;
  val['prenom'] = instance.prenom;
  val['email'] = instance.email;
  val['mot_de_passe_hash'] = instance.motDePasseHash;
  val['role'] = instance.role;
  writeNotNull('actif', instance.actif);
  val['entreprise_id'] = instance.entrepriseId;
  val['date_creation'] = instance.dateCreation.toIso8601String();
  val['date_modification'] = instance.dateModification.toIso8601String();
  val['updated_at'] = instance.updatedAt.toIso8601String();
  return val;
}
