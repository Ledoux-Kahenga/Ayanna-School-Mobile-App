// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_comptable.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JournalComptable _$JournalComptableFromJson(Map<String, dynamic> json) =>
    JournalComptable(
      serverId: (json['id'] as num?)?.toInt(),
      dateOperation: DateTime.parse(json['date_operation'] as String),
      libelle: json['libelle'] as String,
      montant: (json['montant'] as num).toDouble(),
      typeOperation: json['type_operation'] as String,
      paiementFraisId: (json['paiement_frais_id'] as num?)?.toInt(),
      entrepriseId: (json['entreprise_id'] as num).toInt(),
      dateCreation: DateTime.parse(json['date_creation'] as String),
      dateModification: DateTime.parse(json['date_modification'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$JournalComptableToJson(JournalComptable instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.serverId);
  val['date_operation'] = instance.dateOperation.toIso8601String();
  val['libelle'] = instance.libelle;
  val['montant'] = instance.montant;
  val['type_operation'] = instance.typeOperation;
  writeNotNull('paiement_frais_id', instance.paiementFraisId);
  val['entreprise_id'] = instance.entrepriseId;
  val['date_creation'] = instance.dateCreation.toIso8601String();
  val['date_modification'] = instance.dateModification.toIso8601String();
  val['updated_at'] = instance.updatedAt.toIso8601String();
  return val;
}
