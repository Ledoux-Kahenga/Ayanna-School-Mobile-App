import 'package:ayanna_school/models/entreprises.dart';
import 'package:floor/floor.dart';

/// @Entity marks this class as a database table.
/// The tableName is explicitly set to "exercices_comptables" to match the SQL schema.
/// We also define a foreign key to relate this entity to the 'EntrepriseModel'.
@Entity(
  tableName: "exercices_comptables",
  foreignKeys: [
    ForeignKey(
      childColumns: ['entreprise_id'],
      parentColumns: ['id'],
      entity: EntrepriseModel, // Assuming 'EntrepriseModel' is the name of your entity class
      onDelete: ForeignKeyAction.cascade,
    ),
  ],
)
class ExercicesComptablesModel {
  /// @PrimaryKey marks this field as the primary key.
  /// The id is of type int and is not-nullable.
  @PrimaryKey()
  final int id;

  /// These fields correspond to the SQL columns that are defined as NOT NULL.
  final String libelle;
  final DateTime date_debut;
  final DateTime date_fin;
  final int entreprise_id;
  final DateTime date_creation;
  final DateTime date_modification;

  /// These fields correspond to nullable columns in the SQL schema.
  final bool? est_cloture;
  final DateTime? date_cloture;

  /// The constructor for the ExercicesComptablesModel class.
  ExercicesComptablesModel({
    required this.id,
    required this.libelle,
    required this.date_debut,
    required this.date_fin,
    required this.entreprise_id,
    required this.date_creation,
    required this.date_modification,
    this.est_cloture,
    this.date_cloture,
  });

  /// A factory constructor to create an ExercicesComptablesModel from a JSON Map.
  factory ExercicesComptablesModel.fromJson(Map<String, dynamic> json) {
    return ExercicesComptablesModel(
      id: json['id'] as int,
      libelle: json['libelle'] as String,
      date_debut: DateTime.parse(json['date_debut'] as String),
      date_fin: DateTime.parse(json['date_fin'] as String),
      entreprise_id: json['entreprise_id'] as int,
      date_creation: DateTime.parse(json['date_creation'] as String),
      date_modification: DateTime.parse(json['date_modification'] as String),
      est_cloture: json['est_cloture'] as bool?,
      date_cloture: json['date_cloture'] != null
          ? DateTime.parse(json['date_cloture'] as String)
          : null,
    );
  }

  /// Converts the ExercicesComptablesModel object into a JSON Map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'libelle': libelle,
      'date_debut': date_debut.toIso8601String(),
      'date_fin': date_fin.toIso8601String(),
      'entreprise_id': entreprise_id,
      'date_creation': date_creation.toIso8601String(),
      'date_modification': date_modification.toIso8601String(),
      'est_cloture': est_cloture,
      'date_cloture': date_cloture?.toIso8601String(),
    };
  }
}
