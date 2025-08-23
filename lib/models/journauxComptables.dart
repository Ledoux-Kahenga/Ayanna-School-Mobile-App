import 'package:ayanna_school/models/entreprises.dart';
import 'package:ayanna_school/models/paiementFrais.dart';
import 'package:floor/floor.dart';

/// @Entity marks this class as a database table.
/// The tableName is explicitly set to "journaux_comptables" to match the SQL schema.
/// We also define foreign keys to relate this entity to the 'EntrepriseModel' and 'PaiementFraisModel'.
@Entity(
  tableName: "journaux_comptables",
  foreignKeys: [
    ForeignKey(
      childColumns: ['entreprise_id'],
      parentColumns: ['id'],
      entity: EntrepriseModel, // Assuming 'EntrepriseModel' is the name of your entity class
      onDelete: ForeignKeyAction.cascade,
    ),
    ForeignKey(
      childColumns: ['paiement_frais_id'],
      parentColumns: ['id'],
      entity: PaiementFraisModel, // Assuming 'PaiementFraisModel' is the name of your entity class
      onDelete: ForeignKeyAction.setNull,
    ),
  ],
)
class JournauxComptablesModel {
  /// @PrimaryKey marks this field as the primary key.
  /// The id is of type int and is not-nullable.
  @PrimaryKey()
  final int id;

  /// These fields correspond to the SQL columns that are defined as NOT NULL.
  final String date_operation;
  final String libelle;
  
  /// The 'montant' column is NUMERIC(15, 2) in SQL, which maps to a double in Dart.
  final double montant;
  
  final String type_operation;
  final int entreprise_id;
  final String created_at;
  final String date_creation;
  final String date_modification;

  /// This field corresponds to the nullable foreign key column in the SQL schema.
  final int? paiement_frais_id;

  /// The constructor for the JournauxComptablesModel class.
  JournauxComptablesModel({
    required this.id,
    required this.date_operation,
    required this.libelle,
    required this.montant,
    required this.type_operation,
    required this.entreprise_id,
    required this.created_at,
    required this.date_creation,
    required this.date_modification,
    this.paiement_frais_id,
  });

  /// A factory constructor to create a JournauxComptablesModel from a JSON Map.
  factory JournauxComptablesModel.fromJson(Map<String, dynamic> json) {
    return JournauxComptablesModel(
      id: json['id'] as int,
      date_operation: json['date_operation'] as String,
      libelle: json['libelle'] as String,
      montant: (json['montant'] as num).toDouble(),
      type_operation: json['type_operation'] as String,
      entreprise_id: json['entreprise_id'] as int,
      created_at: json['created_at'] as String,
      date_creation: json['date_creation'] as String,
      date_modification: json['date_modification'] as String,
      paiement_frais_id: json['paiement_frais_id'] as int?,
    );
  }

  /// Converts the JournauxComptablesModel object into a JSON Map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date_operation': date_operation,
      'libelle': libelle,
      'montant': montant,
      'type_operation': type_operation,
      'entreprise_id': entreprise_id,
      'created_at': created_at,
      'date_creation': date_creation,
      'date_modification': date_modification,
      'paiement_frais_id': paiement_frais_id,
    };
  }
}
