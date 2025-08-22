import 'package:ayanna_school/models/anneeScolaire.dart';
import 'package:ayanna_school/models/enseignant.dart';
import 'package:floor/floor.dart';

/// @Entity marks this class as a database table.
/// The tableName is explicitly set to "classes" to match the SQL schema.
/// We also define the foreign keys to relate this entity to
/// 'AnneeScolaireModel' and 'EnseignantModel'.
@Entity(
  tableName: "classes",
  foreignKeys: [
    ForeignKey(
      childColumns: ['annee_scolaire_id'],
      parentColumns: ['id'],
      entity: AnneeScolaireModel,
      onDelete: ForeignKeyAction.cascade,
    ),
    ForeignKey(
      childColumns: ['enseignant_id'],
      parentColumns: ['id'],
      entity: EnseignantModel,
      onDelete: ForeignKeyAction.setNull, // Or another appropriate action
    ),
  ],
)
class ClassModel {
  /// @PrimaryKey marks this field as the primary key.
  /// The id is of type int and is not-nullable.
  @PrimaryKey()
  final int id;

  /// These fields correspond to the SQL columns that are
  /// defined as NOT NULL in the table schema.
  final String nom;
  final int annee_scolaire_id;

  /// These fields correspond to nullable columns in the SQL schema.
  final String? code;
  final String? niveau;
  final int? effectif;
  final int? enseignant_id;

  /// The constructor for the ClassModel class.
  /// 'id', 'nom', and 'annee_scolaire_id' are required as per the SQL schema.
  ClassModel({
    required this.id,
    required this.nom,
    required this.annee_scolaire_id,
    this.code,
    this.niveau,
    this.effectif,
    this.enseignant_id,
  });

  /// A factory constructor to create a ClassModel from a JSON Map.
  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'] as int,
      nom: json['nom'] as String,
      annee_scolaire_id: json['annee_scolaire_id'] as int,
      code: json['code'] as String?,
      niveau: json['niveau'] as String?,
      effectif: json['effectif'] as int?,
      enseignant_id: json['enseignant_id'] as int?,
    );
  }

  /// Converts the ClassModel object into a JSON Map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'annee_scolaire_id': annee_scolaire_id,
      'code': code,
      'niveau': niveau,
      'effectif': effectif,
      'enseignant_id': enseignant_id,
    };
  }
}
