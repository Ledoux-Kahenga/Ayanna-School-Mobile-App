// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'frais_classes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FraisClasses _$FraisClassesFromJson(Map<String, dynamic> json) => FraisClasses(
      id: (json['id'] as num?)?.toInt(),
      serverId: (json['id'] as num?)?.toInt(),
      fraisId: (json['frais_id'] as num).toInt(),
      classeId: (json['classe_id'] as num).toInt(),
      dateCreation: DateTime.parse(json['date_creation'] as String),
      dateModification: DateTime.parse(json['date_modification'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$FraisClassesToJson(FraisClasses instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.serverId);
  val['frais_id'] = instance.fraisId;
  val['classe_id'] = instance.classeId;
  val['date_creation'] = instance.dateCreation.toIso8601String();
  val['date_modification'] = instance.dateModification.toIso8601String();
  val['updated_at'] = instance.updatedAt.toIso8601String();
  return val;
}
