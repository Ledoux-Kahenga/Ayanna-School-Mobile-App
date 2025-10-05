// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'licence.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Licence _$LicenceFromJson(Map<String, dynamic> json) => Licence(
      id: (json['id'] as num?)?.toInt(),
      serverId: (json['id'] as num?)?.toInt(),
      cle: json['cle'] as String,
      type: json['type'] as String,
      dateActivation: DateTime.parse(json['date_activation'] as String),
      dateExpiration: DateTime.parse(json['date_expiration'] as String),
      signature: json['signature'] as String,
      active: parseBool(json['actif']),
      entrepriseId: (json['entreprise_id'] as num?)?.toInt(),
      dateCreation: DateTime.parse(json['date_creation'] as String),
      dateModification: DateTime.parse(json['date_modification'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$LicenceToJson(Licence instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.serverId);
  val['cle'] = instance.cle;
  val['type'] = instance.type;
  val['date_activation'] = instance.dateActivation.toIso8601String();
  val['date_expiration'] = instance.dateExpiration.toIso8601String();
  val['signature'] = instance.signature;
  writeNotNull('actif', instance.active);
  writeNotNull('entreprise_id', instance.entrepriseId);
  val['date_creation'] = instance.dateCreation.toIso8601String();
  val['date_modification'] = instance.dateModification.toIso8601String();
  val['updated_at'] = instance.updatedAt.toIso8601String();
  return val;
}
