// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'responsable.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Responsable _$ResponsableFromJson(Map<String, dynamic> json) => Responsable(
      id: (json['id'] as num?)?.toInt(),
      serverId: (json['id'] as num?)?.toInt(),
      nom: json['nom'] as String?,
      code: json['code'] as String?,
      telephone: json['telephone'] as String?,
      adresse: json['adresse'] as String?,
      dateCreation: DateTime.parse(json['date_creation'] as String),
      dateModification: DateTime.parse(json['date_modification'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ResponsableToJson(Responsable instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.serverId);
  writeNotNull('nom', instance.nom);
  writeNotNull('code', instance.code);
  writeNotNull('telephone', instance.telephone);
  writeNotNull('adresse', instance.adresse);
  val['date_creation'] = instance.dateCreation.toIso8601String();
  val['date_modification'] = instance.dateModification.toIso8601String();
  val['updated_at'] = instance.updatedAt.toIso8601String();
  return val;
}
