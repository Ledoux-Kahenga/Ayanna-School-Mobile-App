import 'package:ayanna_school/models/comptesComptables.dart';
import 'package:ayanna_school/models/journauxComptables.dart';
import 'package:ayanna_school/models/piecesComptables.dart';
import 'package:floor/floor.dart';

/// @Entity marks this class as a database table.
/// The tableName is explicitly set to "ecritures_comptables" to match the SQL schema.
/// We also define foreign keys to relate this entity to the 'JournauxComptablesModel',
/// 'ComptesComptablesModel', and 'PiecesComptablesModel'.
@Entity(
  tableName: "ecritures_comptables",
  foreignKeys: [
    ForeignKey(
      childColumns: ['journal_id'],
      parentColumns: ['id'],
      entity: JournauxComptablesModel, // Assuming 'JournauxComptablesModel' is the name of your entity class
      onDelete: ForeignKeyAction.cascade,
    ),
    ForeignKey(
      childColumns: ['compte_comptable_id'],
      parentColumns: ['id'],
      entity: ComptesComptablesModel, // Assuming 'ComptesComptablesModel' is the name of your entity class
      onDelete: ForeignKeyAction.cascade,
    ),
    ForeignKey(
      childColumns: ['piece_id'],
      parentColumns: ['id'],
      entity: PiecesComptablesModel, // Assuming 'PiecesComptablesModel' is the name of your entity class
      onDelete: ForeignKeyAction.setNull,
    ),
  ],
)
class EcrituresComptablesModel {
  /// @PrimaryKey marks this field as the primary key.
  /// The id is of type int and is not-nullable.
  @PrimaryKey()
  final int id;

  /// These fields are NOT NULL in the SQL table, so they are required.
  final int journal_id;
  final int compte_comptable_id;
  final double? debit; // NUMERIC maps to double in Dart, can be null
  final double? credit; // NUMERIC maps to double in Dart, can be null
  final int ordre;
  final DateTime created_at;
  final DateTime date_creation;
  final DateTime date_modification;

  /// This field corresponds to the nullable foreign key column in the SQL schema.
  final int? piece_id;

  /// The constructor for the EcrituresComptablesModel class.
  EcrituresComptablesModel({
    required this.id,
    required this.journal_id,
    required this.compte_comptable_id,
    required this.ordre,
    required this.created_at,
    required this.date_creation,
    required this.date_modification,
    this.piece_id,
    this.debit,
    this.credit,
  });

  /// A factory constructor to create an EcrituresComptablesModel from a JSON Map.
  factory EcrituresComptablesModel.fromJson(Map<String, dynamic> json) {
    return EcrituresComptablesModel(
      id: json['id'] as int,
      journal_id: json['journal_id'] as int,
      compte_comptable_id: json['compte_comptable_id'] as int,
      ordre: json['ordre'] as int,
      created_at: DateTime.parse(json['created_at'] as String),
      date_creation: DateTime.parse(json['date_creation'] as String),
      date_modification: DateTime.parse(json['date_modification'] as String),
      piece_id: json['piece_id'] as int?,
      debit: (json['debit'] as num?)?.toDouble(),
      credit: (json['credit'] as num?)?.toDouble(),
    );
  }

  /// Converts the EcrituresComptablesModel object into a JSON Map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'journal_id': journal_id,
      'compte_comptable_id': compte_comptable_id,
      'ordre': ordre,
      'created_at': created_at.toIso8601String(),
      'date_creation': date_creation.toIso8601String(),
      'date_modification': date_modification.toIso8601String(),
      'piece_id': piece_id,
      'debit': debit,
      'credit': credit,
    };
  }
}
