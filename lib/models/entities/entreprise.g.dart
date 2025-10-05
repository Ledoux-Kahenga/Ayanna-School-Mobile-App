// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entreprise.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Entreprise _$EntrepriseFromJson(Map<String, dynamic> json) => Entreprise(
      id: (json['id'] as num?)?.toInt(),
      serverId: (json['id'] as num?)?.toInt(),
      nom: json['nom'] as String,
      adresse: json['adresse'] as String?,
      numeroId: json['numero_id'] as String?,
      devise: json['devise'] as String?,
      telephone: json['telephone'] as String?,
      email: json['email'] as String?,
      logo: json['logo'] as String?,
      timezone: json['timezone'] as String,
      dateCreation: DateTime.parse(json['date_creation'] as String),
      dateModification: DateTime.parse(json['date_modification'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$EntrepriseToJson(Entreprise instance) {
  final val = <String, dynamic>{
    'nom': instance.nom,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('adresse', instance.adresse);
  writeNotNull('numero_id', instance.numeroId);
  writeNotNull('devise', instance.devise);
  writeNotNull('telephone', instance.telephone);
  writeNotNull('email', instance.email);
  writeNotNull('logo', instance.logo);
  val['timezone'] = instance.timezone;
  val['date_creation'] = instance.dateCreation.toIso8601String();
  val['date_modification'] = instance.dateModification.toIso8601String();
  val['updated_at'] = instance.updatedAt.toIso8601String();
  return val;
}
