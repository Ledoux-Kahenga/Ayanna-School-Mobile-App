// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comptes_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ComptesConfig _$ComptesConfigFromJson(Map<String, dynamic> json) =>
    ComptesConfig(
      id: (json['id'] as num?)?.toInt(),
      serverId: (json['id'] as num?)?.toInt(),
      entrepriseId: (json['entreprise_id'] as num).toInt(),
      compteCaisseId: (json['compte_caisse_id'] as num).toInt(),
      compteFraisId: (json['compte_frais_id'] as num).toInt(),
      compteClientId: (json['compte_client_id'] as num).toInt(),
      dateCreation: DateTime.parse(json['date_creation'] as String),
      dateModification: DateTime.parse(json['date_modification'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ComptesConfigToJson(ComptesConfig instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.serverId);
  val['entreprise_id'] = instance.entrepriseId;
  val['compte_caisse_id'] = instance.compteCaisseId;
  val['compte_frais_id'] = instance.compteFraisId;
  val['compte_client_id'] = instance.compteClientId;
  val['date_creation'] = instance.dateCreation.toIso8601String();
  val['date_modification'] = instance.dateModification.toIso8601String();
  val['updated_at'] = instance.updatedAt.toIso8601String();
  return val;
}
