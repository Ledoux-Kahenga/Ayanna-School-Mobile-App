// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paiement_frais.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaiementFrais _$PaiementFraisFromJson(Map<String, dynamic> json) =>
    PaiementFrais(
      id: (json['id'] as num?)?.toInt(),
      serverId: (json['id'] as num?)?.toInt(),
      eleveId: (json['eleve_id'] as num).toInt(),
      fraisScolaireId: (json['frais_scolaire_id'] as num).toInt(),
      montantPaye: (json['montant_paye'] as num).toDouble(),
      datePaiement: DateTime.parse(json['date_paiement'] as String),
      userId: (json['user_id'] as num?)?.toInt(),
      resteAPayer: (json['reste_a_payer'] as num?)?.toDouble(),
      statut: json['statut'] as String?,
      dateCreation: DateTime.parse(json['date_creation'] as String),
      dateModification: DateTime.parse(json['date_modification'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$PaiementFraisToJson(PaiementFrais instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.serverId);
  val['eleve_id'] = instance.eleveId;
  val['frais_scolaire_id'] = instance.fraisScolaireId;
  val['montant_paye'] = instance.montantPaye;
  val['date_paiement'] = instance.datePaiement.toIso8601String();
  writeNotNull('user_id', instance.userId);
  writeNotNull('reste_a_payer', instance.resteAPayer);
  writeNotNull('statut', instance.statut);
  val['date_creation'] = instance.dateCreation.toIso8601String();
  val['date_modification'] = instance.dateModification.toIso8601String();
  val['updated_at'] = instance.updatedAt.toIso8601String();
  return val;
}
