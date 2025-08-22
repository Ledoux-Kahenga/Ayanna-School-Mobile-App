import 'package:ayanna_school/models/entreprises.dart';
import 'package:floor/floor.dart';

/// @Entity marks this class as a database table.
/// The tableName is explicitly set to "frais" to match the SQL schema.
/// We also define a foreign key to relate this entity to the 'EntrepriseModel'.
@Entity(
  tableName: "frais",
  foreignKeys: [
    ForeignKey(
      childColumns: ['entreprise_id'],
      parentColumns: ['id'],
      entity: EntrepriseModel,
      onDelete: ForeignKeyAction.cascade,
    ),
  ],
  indices: [
    Index(value: ['code'], unique: true),
  ],
)
class FraisModel {
  /// @PrimaryKey marks this field as the primary key.
  /// The id is of type int and is not-nullable.
  @PrimaryKey()
  final int id;

  /// This field is NOT NULL in the SQL table, so it is required.
  final String nom;

  /// The 'montant' column is of type INTEGER and is nullable.
  final int? montant;

  /// This field has a UNIQUE constraint in the SQL, so we can
  /// add the @unique annotation in Dart.

  final String? code;

  /// This is the foreign key that links to the 'entreprises' table.
  /// It is defined as NOT NULL in your SQL, so it's a non-nullable int here.
  final int entreprise_id;

  /// The constructor for the FraisModel class.
  FraisModel({
    required this.id,
    required this.nom,
    required this.entreprise_id,
    this.montant,
    this.code,
  });

  /// A factory constructor to create a FraisModel from a JSON Map.
  factory FraisModel.fromJson(Map<String, dynamic> json) {
    return FraisModel(
      id: json['id'] as int,
      nom: json['nom'] as String,
      entreprise_id: json['entreprise_id'] as int,
      montant: json['montant'] as int?,
      code: json['code'] as String?,
    );
  }

  /// Converts the FraisModel object into a JSON Map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'entreprise_id': entreprise_id,
      'montant': montant,
      'code': code,
    };
  }
}
