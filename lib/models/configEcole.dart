import 'package:ayanna_school/models/anneescolaire.dart';
import 'package:ayanna_school/models/entreprises.dart';
import 'package:floor/floor.dart';

/// @Entity marks this class as a database table.
/// The tableName is explicitly set to "config_ecole" to match the SQL schema.
/// We also define foreign keys to relate this entity to the 'AnneeScolaireModel' and 'EntrepriseModel'.
@Entity(
  tableName: "config_ecole",
  foreignKeys: [
    ForeignKey(
      childColumns: ['annee_scolaire_en_cours_id'],
      parentColumns: ['id'],
      entity: AnneeScolaireModel, // Assuming 'AnneeScolaireModel' is the name of your entity class
      onDelete: ForeignKeyAction.setNull,
    ),
    ForeignKey(
      childColumns: ['entreprise_id'],
      parentColumns: ['id'],
      entity: EntrepriseModel, // Assuming 'EntrepriseModel' is the name of your entity class
      onDelete: ForeignKeyAction.cascade,
    ),
  ],
)
class ConfigEcoleModel {
  /// @PrimaryKey marks this field as the primary key.
  /// The id is of type int and is not-nullable.
  @PrimaryKey()
  final int id;

  /// The 'entreprise_id' is NOT NULL in the SQL table, so it is required.
  final int entreprise_id;

  /// The 'annee_scolaire_en_cours_id' is a nullable foreign key.
  final int? annee_scolaire_en_cours_id;

  /// The constructor for the ConfigEcoleModel class.
  ConfigEcoleModel({
    required this.id,
    required this.entreprise_id,
    this.annee_scolaire_en_cours_id,
  });

  /// A factory constructor to create a ConfigEcoleModel from a JSON Map.
  factory ConfigEcoleModel.fromJson(Map<String, dynamic> json) {
    return ConfigEcoleModel(
      id: json['id'] as int,
      entreprise_id: json['entreprise_id'] as int,
      annee_scolaire_en_cours_id: json['annee_scolaire_en_cours_id'] as int?,
    );
  }

  /// Converts the ConfigEcoleModel object into a JSON Map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entreprise_id': entreprise_id,
      'annee_scolaire_en_cours_id': annee_scolaire_en_cours_id,
    };
  }
}
