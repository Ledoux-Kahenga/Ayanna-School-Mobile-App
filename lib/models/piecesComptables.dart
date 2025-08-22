import 'package:ayanna_school/models/entreprises.dart';
import 'package:floor/floor.dart';

/// @Entity marks this class as a database table.
/// The tableName is explicitly set to "pieces_comptables" to match the SQL schema.
/// We also define a foreign key to relate this entity to the 'EntrepriseModel'.
@Entity(
  tableName: "pieces_comptables",
  foreignKeys: [
    ForeignKey(
      childColumns: ['entreprise_id'],
      parentColumns: ['id'],
      entity: EntrepriseModel, // Assuming 'EntrepriseModel' is the name of your entity class
      onDelete: ForeignKeyAction.cascade,
    ),
  ],
)
class PiecesComptablesModel {
  /// @PrimaryKey marks this field as the primary key.
  /// The id is of type int and is not-nullable.
  @PrimaryKey()
  final int id;

  /// These fields correspond to the SQL columns that are defined as NOT NULL.
  final String numero;
  final DateTime date_piece;
  final String type_piece;
  
  /// The 'montant_total' column is NUMERIC(15, 2) in SQL, which maps to a double in Dart.
  final double montant_total;

  final int entreprise_id;
  final DateTime date_creation;
  final DateTime date_modification;

  /// These fields correspond to nullable columns in the SQL schema.
  final String? tiers;
  final String? reference_externe;
  final String? statut;

  /// The constructor for the PiecesComptablesModel class.
  PiecesComptablesModel({
    required this.id,
    required this.numero,
    required this.date_piece,
    required this.type_piece,
    required this.montant_total,
    required this.entreprise_id,
    required this.date_creation,
    required this.date_modification,
    this.tiers,
    this.reference_externe,
    this.statut,
  });

  /// A factory constructor to create a PiecesComptablesModel from a JSON Map.
  factory PiecesComptablesModel.fromJson(Map<String, dynamic> json) {
    return PiecesComptablesModel(
      id: json['id'] as int,
      numero: json['numero'] as String,
      date_piece: DateTime.parse(json['date_piece'] as String),
      type_piece: json['type_piece'] as String,
      montant_total: (json['montant_total'] as num).toDouble(),
      entreprise_id: json['entreprise_id'] as int,
      date_creation: DateTime.parse(json['date_creation'] as String),
      date_modification: DateTime.parse(json['date_modification'] as String),
      tiers: json['tiers'] as String?,
      reference_externe: json['reference_externe'] as String?,
      statut: json['statut'] as String?,
    );
  }

  /// Converts the PiecesComptablesModel object into a JSON Map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numero': numero,
      'date_piece': date_piece.toIso8601String(),
      'type_piece': type_piece,
      'montant_total': montant_total,
      'entreprise_id': entreprise_id,
      'date_creation': date_creation.toIso8601String(),
      'date_modification': date_modification.toIso8601String(),
      'tiers': tiers,
      'reference_externe': reference_externe,
      'statut': statut,
    };
  }
}
