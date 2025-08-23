import 'package:ayanna_school/models/entreprises.dart';
import 'package:floor/floor.dart';

/// @Entity marks this class as a database table.
/// The tableName is explicitly set to "utilisateurs" to match the SQL schema.
/// We also define a foreign key to relate this entity to the 'EntrepriseModel'.
@Entity(
  tableName: "utilisateurs",
  foreignKeys: [
    ForeignKey(
      childColumns: ['entreprise_id'],
      parentColumns: ['id'],
      entity: EntrepriseModel,
      onDelete: ForeignKeyAction.cascade,
    ),
  ],
  indices: [
    Index(value: ['email'], unique: true), // Assuming email should be unique
  ],
)
class UtilisateurModel {
  /// @PrimaryKey marks this field as the primary key.
  /// The id is of type int and is not-nullable.
  @PrimaryKey()
  final int id;

  /// These fields are NOT NULL in the SQL table, so they are required.
  final String nom;
  final String prenom;

  /// The email has a UNIQUE constraint in the SQL, so we can add the @unique annotation in Dart.

  final String email;

  final String mot_de_passe_hash;
  final String role;
  final int entreprise_id;
  final String date_creation;
  final String date_modification;

  /// The 'actif' column is of type BOOLEAN and is nullable.
  final bool? actif;

  /// The constructor for the UtilisateurModel class.
  UtilisateurModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.mot_de_passe_hash,
    required this.role,
    required this.entreprise_id,
    required this.date_creation,
    required this.date_modification,
    this.actif,
  });

  /// A factory constructor to create a UtilisateurModel from a JSON Map.
  factory UtilisateurModel.fromJson(Map<String, dynamic> json) {
    return UtilisateurModel(
      id: json['id'] as int,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      email: json['email'] as String,
      mot_de_passe_hash: json['mot_de_passe_hash'] as String,
      role: json['role'] as String,
      entreprise_id: json['entreprise_id'] as int,
      date_creation: json['date_creation'] as String,
      date_modification: json['date_modification'] as String,
      actif: (json['actif'] is bool)
          ? json['actif']
          : (json['actif'] is int)
          ? json['actif'] == 1
          : null,
    );
  }

  /// Converts the UtilisateurModel object into a JSON Map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'mot_de_passe_hash': mot_de_passe_hash,
      'role': role,
      'entreprise_id': entreprise_id,
      'date_creation': date_creation,
      'date_modification': date_modification,
      'actif': actif,
    };
  }
}
