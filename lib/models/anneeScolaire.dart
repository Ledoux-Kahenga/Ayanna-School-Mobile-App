import 'package:ayanna_school/models/entreprises.dart';
import 'package:floor/floor.dart';

/// @Entity marks this class as a database table.
/// The tableName is explicitly set to "annees_scolaires" to match the SQL.
/// We also define a foreign key to relate this entity to the 'EntrepriseModel'.
@Entity(
  tableName: "annees_scolaires",
  foreignKeys: [
    ForeignKey(
      childColumns: ['entreprise_id'],
      parentColumns: ['id'],
      entity: EntrepriseModel,
      onDelete: ForeignKeyAction.cascade,
    ),
  ],
)
class AnneeScolaireModel {
  /// @PrimaryKey marks this field as the primary key.
  /// The id is of type int and is not-nullable according to the SQL.
  @PrimaryKey()
  final int id;

  /// These fields correspond to the VARCHAR columns that are
  /// defined as NOT NULL in the table schema.
  final String nom;
  final String date_debut; // format ISO yyyy-MM-dd
  final String date_fin; // format ISO yyyy-MM-dd

  /// This is the foreign key that links to the 'entreprises' table.
  /// It is defined as NOT NULL in your SQL, so it's a non-nullable int here.
  final int entreprise_id;

  /// The 'en_cours' column is an INTEGER and is nullable. In Dart, this
  /// maps to a nullable int.
  final int? en_cours;

  /// The constructor for the AnneeScolaireModel class.
  /// All fields are required as per the SQL schema, except 'en_cours'.
  AnneeScolaireModel({
    required this.id,
    required this.nom,
    required this.date_debut,
    required this.date_fin,
    required this.entreprise_id,
    this.en_cours,
  });

  /// A factory constructor to create an AnneeScolaireModel from a JSON Map.
  factory AnneeScolaireModel.fromJson(Map<String, dynamic> json) {
    return AnneeScolaireModel(
      id: json['id'] as int,
      nom: json['nom'] as String,
      date_debut: json['date_debut'] as String,
      date_fin: json['date_fin'] as String,
      entreprise_id: json['entreprise_id'] as int,
      en_cours: json['en_cours'] as int?,
    );
  }

  /// Converts the AnneeScolaireModel object into a JSON Map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'date_debut': date_debut,
      'date_fin': date_fin,
      'entreprise_id': entreprise_id,
      'en_cours': en_cours,
    };
  }
}
