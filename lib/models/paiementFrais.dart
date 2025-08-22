import 'package:ayanna_school/models/Eleve.dart';
import 'package:ayanna_school/models/fraisScolaire.dart';
import 'package:ayanna_school/models/utilisateurs.dart';
import 'package:floor/floor.dart';

/// @Entity marks this class as a database table.
/// The tableName is explicitly set to "paiement_frais" to match the SQL.
/// We also define foreign keys to relate this entity to the 'EleveModel',
/// 'FraisScolaireModel', and 'UtilisateurModel'.
@Entity(
  tableName: "paiement_frais",
  foreignKeys: [
    ForeignKey(
      childColumns: ['eleve_id'],
      parentColumns: ['id'],
      entity: EleveModel, // Assuming 'EleveModel' exists
      onDelete: ForeignKeyAction.cascade,
    ),
    ForeignKey(
      childColumns: ['frais_scolaire_id'],
      parentColumns: ['id'],
      entity: FraisScolaireModel, // Assuming 'FraisScolaireModel' exists
      onDelete: ForeignKeyAction.cascade,
    ),
    ForeignKey(
      childColumns: ['user_id'],
      parentColumns: ['id'],
      entity: UtilisateurModel, // Assuming 'UtilisateurModel' exists
      onDelete: ForeignKeyAction.setNull,
    ),
  ],
)
class PaiementFraisModel {
  /// @PrimaryKey marks this field as the primary key.
  /// The id is of type int and is not-nullable.
  @PrimaryKey()
  final int id;

  /// These fields are NOT NULL in the SQL table, so they are required.
  final int eleve_id;
  final int frais_scolaire_id;
  final double montant_paye;
  final DateTime date_paiement;

  /// These fields correspond to the nullable columns in the SQL schema.
  final int? user_id;
  final double? reste_a_payer;
  final String? statut;

  /// The constructor for the PaiementFraisModel class.
  PaiementFraisModel({
    required this.id,
    required this.eleve_id,
    required this.frais_scolaire_id,
    required this.montant_paye,
    required this.date_paiement,
    this.user_id,
    this.reste_a_payer,
    this.statut,
  });

  /// A factory constructor to create a PaiementFraisModel from a JSON Map.
  /// This is essential for converting database results into a Dart object.
  factory PaiementFraisModel.fromJson(Map<String, dynamic> json) {
    return PaiementFraisModel(
      id: json['id'] as int,
      eleve_id: json['eleve_id'] as int,
      frais_scolaire_id: json['frais_scolaire_id'] as int,
      montant_paye: (json['montant_paye'] as num).toDouble(),
      date_paiement: DateTime.parse(json['date_paiement'] as String),
      user_id: json['user_id'] as int?,
      reste_a_payer: (json['reste_a_payer'] as num?)?.toDouble(),
      statut: json['statut'] as String?,
    );
  }

  /// Converts the PaiementFraisModel object into a JSON Map.
  /// This is useful for inserting or updating data in the database.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eleve_id': eleve_id,
      'frais_scolaire_id': frais_scolaire_id,
      'montant_paye': montant_paye,
      'date_paiement': date_paiement.toIso8601String(),
      'user_id': user_id,
      'reste_a_payer': reste_a_payer,
      'statut': statut,
    };
  }
}
