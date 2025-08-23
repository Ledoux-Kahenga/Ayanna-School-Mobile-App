import 'package:ayanna_school/models/entreprises.dart';
import 'package:floor/floor.dart';

/// @Entity marks this class as a database table.
/// The tableName is explicitly set to "enseignants" to match the SQL schema.
/// We also define a foreign key to relate this entity to the 'EntrepriseModel'.
@Entity(
  tableName: "enseignants",
  foreignKeys: [
    ForeignKey(
      childColumns: ['entreprise_id'],
      parentColumns: ['id'],
      entity: EntrepriseModel, // Assuming 'EntrepriseModel' is the name of your entity class
      onDelete: ForeignKeyAction.cascade,
    ),
  ], 
)
class EnseignantModel {
  /// @PrimaryKey marks this field as the primary key.
  /// The id is of type int and is not-nullable.
  @PrimaryKey()
  final int id;

  /// These fields correspond to the SQL columns that are defined as NOT NULL.
  final String nom;
  final String prenom;
  final int entreprise_id;

  /// These fields correspond to nullable columns in the SQL schema.
  /// We use nullable types (`String?`, `int?`) in Dart.
  final String? matricule;
  final String? sexe;
  final String? niveau;
  final String? discipline;
  final String? email;
  final String? telephone;

  /// The constructor for the EnseignantModel class.
  /// 'id', 'nom', 'prenom', and 'entreprise_id' are required as per the SQL schema.
  EnseignantModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.entreprise_id,
    this.matricule,
    this.sexe,
    this.niveau,
    this.discipline,
    this.email,
    this.telephone,
  });

  /// A factory constructor to create an EnseignantModel from a JSON Map.
  factory EnseignantModel.fromJson(Map<String, dynamic> json) {
    return EnseignantModel(
      id: json['id'] as int,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      entreprise_id: json['entreprise_id'] as int,
      matricule: json['matricule'] as String?,
      sexe: json['sexe'] as String?,
      niveau: json['niveau'] as String?,
      discipline: json['discipline'] as String?,
      email: json['email'] as String?,
      telephone: json['telephone'] as String?,
    );
  }

  /// Converts the EnseignantModel object into a JSON Map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'entreprise_id': entreprise_id,
      'matricule': matricule,
      'sexe': sexe,
      'niveau': niveau,
      'discipline': discipline,
      'email': email,
      'telephone': telephone,
    };
  }
}
