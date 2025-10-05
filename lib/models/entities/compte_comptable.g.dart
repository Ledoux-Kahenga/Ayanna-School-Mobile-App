// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compte_comptable.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompteComptable _$CompteComptableFromJson(Map<String, dynamic> json) =>
    CompteComptable(
      id: (json['id'] as num?)?.toInt(),
      serverId: (json['id'] as num?)?.toInt(),
      numero: json['numero'] as String,
      nom: json['nom'] as String,
      libelle: json['libelle'] as String,
      actif: parseBool(json['actif']),
      classeComptableId: (json['classe_comptable_id'] as num).toInt(),
      dateCreation: DateTime.parse(json['date_creation'] as String),
      dateModification: DateTime.parse(json['date_modification'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$CompteComptableToJson(CompteComptable instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.serverId);
  val['numero'] = instance.numero;
  val['nom'] = instance.nom;
  val['libelle'] = instance.libelle;
  writeNotNull('actif', instance.actif);
  val['classe_comptable_id'] = instance.classeComptableId;
  val['date_creation'] = instance.dateCreation.toIso8601String();
  val['date_modification'] = instance.dateModification.toIso8601String();
  val['updated_at'] = instance.updatedAt.toIso8601String();
  return val;
}
