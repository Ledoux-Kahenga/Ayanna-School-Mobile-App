import 'package:ayanna_school/models/anneescolaire.dart';
import 'package:ayanna_school/models/entreprises.dart';
import 'package:floor/floor.dart';

/// @Entity marks this class as a database table.
/// The tableName is explicitly set to "frais_scolaires" to match the SQL schema.
/// We also define foreign keys to relate this entity to the 'AnneeScolaireModel'
/// and 'EntrepriseModel'.
@Entity(
  tableName: "frais_scolaires",
  foreignKeys: [
    ForeignKey(
      childColumns: ['annee_scolaire_id'],
      parentColumns: ['id'],
      entity: AnneeScolaireModel,
      onDelete: ForeignKeyAction.cascade,
    ),
    ForeignKey(
      childColumns: ['entreprise_id'],
      parentColumns: ['id'],
      entity: EntrepriseModel,
      onDelete: ForeignKeyAction.cascade,
    ),
  ],
)
class FraisScolaireModel {
  /// @PrimaryKey marks this field as the primary key.
  /// The id is of type int and is not-nullable.
  @PrimaryKey()
  final int id;

  /// These fields are NOT NULL in the SQL table, so they are required.
  final String nom;
  final double montant;
  final int annee_scolaire_id;
  final int entreprise_id;

  /// The 'date_limite' column is of type DATE and is nullable.
  final DateTime? date_limite;

  /// The constructor for the FraisScolaireModel class.
  FraisScolaireModel({
    required this.id,
    required this.nom,
    required this.montant,
    required this.annee_scolaire_id,
    required this.entreprise_id,
    this.date_limite,
  });

  /// A factory constructor to create a FraisScolaireModel from a JSON Map.
  factory FraisScolaireModel.fromJson(Map<String, dynamic> json) {
    return FraisScolaireModel(
      id: json['id'] as int,
      nom: json['nom'] as String,
      montant: (json['montant'] as num).toDouble(),
      annee_scolaire_id: json['annee_scolaire_id'] as int,
      entreprise_id: json['entreprise_id'] as int,
      date_limite: json['date_limite'] != null
          ? DateTime.parse(json['date_limite'] as String)
          : null,
    );
  }

  /// Converts the FraisScolaireModel object into a JSON Map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'montant': montant,
      'annee_scolaire_id': annee_scolaire_id,
      'entreprise_id': entreprise_id,
      'date_limite': date_limite?.toIso8601String(),
    };
  }
}
