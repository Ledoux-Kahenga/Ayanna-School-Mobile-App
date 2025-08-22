import 'package:ayanna_school/models/classesComptables.dart';
import 'package:floor/floor.dart';

/// @Entity marks this class as a database table.
/// The tableName is explicitly set to "comptes_comptables" to match the SQL schema.
/// We also define a foreign key to relate this entity to the 'ClassesComptablesModel'.
@Entity(
  tableName: "comptes_comptables",
  foreignKeys: [
    ForeignKey(
      childColumns: ['classe_comptable_id'],
      parentColumns: ['id'],
      entity: ClassesComptablesModel, // Assuming 'ClassesComptablesModel' is the name of your entity class
      onDelete: ForeignKeyAction.cascade,
    ),
  ],
)
class ComptesComptablesModel {
  /// @PrimaryKey marks this field as the primary key.
  /// The id is of type int and is not-nullable.
  @PrimaryKey()
  final int id;

  /// These fields correspond to the SQL columns that are defined as NOT NULL.
  final String numero;
  final String nom;
  final String libelle;
  final int classe_comptable_id;
  final DateTime date_creation;
  final DateTime date_modification;

  /// The 'actif' column is of type BOOLEAN and is nullable.
  final bool? actif;

  /// The constructor for the ComptesComptablesModel class.
  ComptesComptablesModel({
    required this.id,
    required this.numero,
    required this.nom,
    required this.libelle,
    required this.classe_comptable_id,
    required this.date_creation,
    required this.date_modification,
    this.actif,
  });

  /// A factory constructor to create a ComptesComptablesModel from a JSON Map.
  factory ComptesComptablesModel.fromJson(Map<String, dynamic> json) {
    return ComptesComptablesModel(
      id: json['id'] as int,
      numero: json['numero'] as String,
      nom: json['nom'] as String,
      libelle: json['libelle'] as String,
      classe_comptable_id: json['classe_comptable_id'] as int,
      date_creation: DateTime.parse(json['date_creation'] as String),
      date_modification: DateTime.parse(json['date_modification'] as String),
      actif: json['actif'] as bool?,
    );
  }

  /// Converts the ComptesComptablesModel object into a JSON Map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numero': numero,
      'nom': nom,
      'libelle': libelle,
      'classe_comptable_id': classe_comptable_id,
      'date_creation': date_creation.toIso8601String(),
      'date_modification': date_modification.toIso8601String(),
      'actif': actif,
    };
  }
}
