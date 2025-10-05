// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ecriture_comptable.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EcritureComptable _$EcritureComptableFromJson(Map<String, dynamic> json) =>
    EcritureComptable(
      id: (json['id'] as num?)?.toInt(),
      serverId: (json['id'] as num?)?.toInt(),
      journalId: (json['journal_id'] as num).toInt(),
      compteComptableId: (json['compte_comptable_id'] as num).toInt(),
      debit: (json['debit'] as num?)?.toDouble(),
      credit: (json['credit'] as num?)?.toDouble(),
      ordre: (json['ordre'] as num).toInt(),
      dateEcriture: DateTime.parse(json['date_ecriture'] as String),
      libelle: json['libelle'] as String?,
      reference: json['reference'] as String?,
      dateCreation: DateTime.parse(json['date_creation'] as String),
      dateModification: DateTime.parse(json['date_modification'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$EcritureComptableToJson(EcritureComptable instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.serverId);
  val['journal_id'] = instance.journalId;
  val['compte_comptable_id'] = instance.compteComptableId;
  writeNotNull('debit', instance.debit);
  writeNotNull('credit', instance.credit);
  val['ordre'] = instance.ordre;
  val['date_ecriture'] = instance.dateEcriture.toIso8601String();
  writeNotNull('libelle', instance.libelle);
  writeNotNull('reference', instance.reference);
  val['date_creation'] = instance.dateCreation.toIso8601String();
  val['date_modification'] = instance.dateModification.toIso8601String();
  val['updated_at'] = instance.updatedAt.toIso8601String();
  return val;
}
