// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'creance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Creance _$CreanceFromJson(Map<String, dynamic> json) => Creance(
      serverId: (json['id'] as num?)?.toInt(),
      eleveId: (json['eleve_id'] as num).toInt(),
      fraisScolaireId: (json['frais_scolaire_id'] as num).toInt(),
      montant: (json['montant'] as num).toDouble(),
      dateEcheance: DateTime.parse(json['date_echeance'] as String),
      active: json['active'] as bool?,
      dateCreation: DateTime.parse(json['date_creation'] as String),
      dateModification: DateTime.parse(json['date_modification'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$CreanceToJson(Creance instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.serverId);
  val['eleve_id'] = instance.eleveId;
  val['frais_scolaire_id'] = instance.fraisScolaireId;
  val['montant'] = instance.montant;
  val['date_echeance'] = instance.dateEcheance.toIso8601String();
  writeNotNull('active', instance.active);
  val['date_creation'] = instance.dateCreation.toIso8601String();
  val['date_modification'] = instance.dateModification.toIso8601String();
  val['updated_at'] = instance.updatedAt.toIso8601String();
  return val;
}
