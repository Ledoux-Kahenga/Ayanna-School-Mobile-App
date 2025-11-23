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
      dateActivation: parseDateTime(json['date_activation']),
      dateExpiration: parseDateTime(json['date_expiration']),
      signature: json['signature'] as String,
      active: parseBool(json['actif']),
      entrepriseId: (json['entreprise_id'] as num?)?.toInt(),
      dateCreation: parseDateTime(json['date_creation']),
      dateModification: parseDateTime(json['date_modification']),
      updatedAt: parseDateTime(json['updated_at']),
    );

Map<String, dynamic> _$LicenceToJson(Licence instance) {
  final val = <String, dynamic>{
    'cle': instance.cle,
    'type': instance.type,
    'date_activation': instance.dateActivation.toIso8601String(),
    'date_expiration': instance.dateExpiration.toIso8601String(),
    'signature': instance.signature,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('actif', instance.active);
  writeNotNull('entreprise_id', instance.entrepriseId);
  val['date_creation'] = instance.dateCreation.toIso8601String();
  val['date_modification'] = instance.dateModification.toIso8601String();
  val['updated_at'] = instance.updatedAt.toIso8601String();
  return val;
}
