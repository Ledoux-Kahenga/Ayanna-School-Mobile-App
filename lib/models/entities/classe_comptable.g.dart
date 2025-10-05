// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classe_comptable.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClasseComptable _$ClasseComptableFromJson(Map<String, dynamic> json) =>
    ClasseComptable(
      id: (json['id'] as num?)?.toInt(),
      serverId: (json['id'] as num?)?.toInt(),
      code: json['code'] as String?,
      nom: json['nom'] as String,
      libelle: json['libelle'] as String,
      type: json['type'] as String,
      entrepriseId: (json['entreprise_id'] as num).toInt(),
      actif: parseBool(json['actif']),
      document: json['document'] as String?,
      dateCreation: DateTime.parse(json['date_creation'] as String),
      dateModification: DateTime.parse(json['date_modification'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ClasseComptableToJson(ClasseComptable instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.serverId);
  writeNotNull('code', instance.code);
  val['nom'] = instance.nom;
  val['libelle'] = instance.libelle;
  val['type'] = instance.type;
  val['entreprise_id'] = instance.entrepriseId;
  writeNotNull('actif', instance.actif);
  writeNotNull('document', instance.document);
  val['date_creation'] = instance.dateCreation.toIso8601String();
  val['date_modification'] = instance.dateModification.toIso8601String();
  val['updated_at'] = instance.updatedAt.toIso8601String();
  return val;
}
