// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'depense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Depense _$DepenseFromJson(Map<String, dynamic> json) => Depense(
      id: (json['id'] as num?)?.toInt(),
      serverId: (json['id'] as num?)?.toInt(),
      libelle: json['libelle'] as String,
      montant: (json['montant'] as num).toDouble(),
      dateDepense: DateTime.parse(json['date_depense'] as String),
      entrepriseId: (json['entreprise_id'] as num).toInt(),
      observation: json['observation'] as String?,
      journalId: (json['journal_id'] as num?)?.toInt(),
      userId: (json['user_id'] as num?)?.toInt(),
      dateCreation: DateTime.parse(json['date_creation'] as String),
      dateModification: DateTime.parse(json['date_modification'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$DepenseToJson(Depense instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.serverId);
  val['libelle'] = instance.libelle;
  val['montant'] = instance.montant;
  val['date_depense'] = instance.dateDepense.toIso8601String();
  val['entreprise_id'] = instance.entrepriseId;
  writeNotNull('observation', instance.observation);
  writeNotNull('journal_id', instance.journalId);
  writeNotNull('user_id', instance.userId);
  val['date_creation'] = instance.dateCreation.toIso8601String();
  val['date_modification'] = instance.dateModification.toIso8601String();
  val['updated_at'] = instance.updatedAt.toIso8601String();
  return val;
}
