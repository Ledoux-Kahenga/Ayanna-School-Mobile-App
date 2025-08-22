import 'package:ayanna_school/models/entreprises.dart';
import 'package:floor/floor.dart';

/// @Entity marks this class as a database table.
/// The tableName is explicitly set to "classes_comptables" to match the SQL schema.
/// We also define a foreign key to relate this entity to the 'EntrepriseModel'.
@Entity(
  tableName: "classes_comptables",
  foreignKeys: [
    ForeignKey(
      childColumns: ['entreprise_id'],
      parentColumns: ['id'],
      entity: EntrepriseModel, // Assuming 'EntrepriseModel' is the name of your entity class
      onDelete: ForeignKeyAction.cascade,
    ),
  ],
)
class ClassesComptablesModel {
  /// @PrimaryKey marks this field as the primary key.
  /// The id is of type int and is not-nullable.
  @PrimaryKey()
  final int id;

  /// These fields correspond to the SQL columns that are defined as NOT NULL.
  final String nom;
  final String libelle;
  final String type;
  final int entreprise_id;
  final DateTime date_creation;
  final DateTime date_modification;

  /// These fields correspond to nullable columns in the SQL schema.
  final String? code;
  final bool? actif;
  final String? document;

  /// The constructor for the ClassesComptablesModel class.
  ClassesComptablesModel({
    required this.id,
    required this.nom,
    required this.libelle,
    required this.type,
    required this.entreprise_id,
    required this.date_creation,
    required this.date_modification,
    this.code,
    this.actif,
    this.document,
  });

  /// A factory constructor to create a ClassesComptablesModel from a JSON Map.
  factory ClassesComptablesModel.fromJson(Map<String, dynamic> json) {
    return ClassesComptablesModel(
      id: json['id'] as int,
      nom: json['nom'] as String,
      libelle: json['libelle'] as String,
      type: json['type'] as String,
      entreprise_id: json['entreprise_id'] as int,
      date_creation: DateTime.parse(json['date_creation'] as String),
      date_modification: DateTime.parse(json['date_modification'] as String),
      code: json['code'] as String?,
      actif: json['actif'] as bool?,
      document: json['document'] as String?,
    );
  }

  /// Converts the ClassesComptablesModel object into a JSON Map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'libelle': libelle,
      'type': type,
      'entreprise_id': entreprise_id,
      'date_creation': date_creation.toIso8601String(),
      'date_modification': date_modification.toIso8601String(),
      'code': code,
      'actif': actif,
      'document': document,
    };
  }
}
