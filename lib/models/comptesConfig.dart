import 'package:ayanna_school/models/comptesComptables.dart';
import 'package:floor/floor.dart';

/// @Entity marks this class as a database table.
/// The tableName is explicitly set to "comptes_config" to match the SQL schema.
/// We also define foreign keys to relate this entity to the 'ComptesComptablesModel'.
@Entity(
  tableName: "comptes_config",
  foreignKeys: [
    ForeignKey(
      childColumns: ['compte_caisse_id'],
      parentColumns: ['id'],
      entity: ComptesComptablesModel, // Assuming 'ComptesComptablesModel' is the name of your entity class
      onDelete: ForeignKeyAction.cascade,
    ),
    ForeignKey(
      childColumns: ['compte_frais_id'],
      parentColumns: ['id'],
      entity: ComptesComptablesModel,
      onDelete: ForeignKeyAction.cascade,
    ),
    ForeignKey(
      childColumns: ['compte_client_id'],
      parentColumns: ['id'],
      entity: ComptesComptablesModel,
      onDelete: ForeignKeyAction.cascade,
    ),
  ],
)
class ComptesConfigModel {
  /// @PrimaryKey marks this field as the primary key.
  /// The id is of type int and is not-nullable.
  @PrimaryKey()
  final int id;

  /// These fields are NOT NULL in the SQL table, so they are required.
  final int entreprise_id;
  final int compte_caisse_id;
  final int compte_frais_id;
  final int compte_client_id;
  final DateTime date_creation;
  final DateTime date_modification;

  /// The constructor for the ComptesConfigModel class.
  ComptesConfigModel({
    required this.id,
    required this.entreprise_id,
    required this.compte_caisse_id,
    required this.compte_frais_id,
    required this.compte_client_id,
    required this.date_creation,
    required this.date_modification,
  });

  /// A factory constructor to create a ComptesConfigModel from a JSON Map.
  factory ComptesConfigModel.fromJson(Map<String, dynamic> json) {
    return ComptesConfigModel(
      id: json['id'] as int,
      entreprise_id: json['entreprise_id'] as int,
      compte_caisse_id: json['compte_caisse_id'] as int,
      compte_frais_id: json['compte_frais_id'] as int,
      compte_client_id: json['compte_client_id'] as int,
      date_creation: DateTime.parse(json['date_creation'] as String),
      date_modification: DateTime.parse(json['date_modification'] as String),
    );
  }

  /// Converts the ComptesConfigModel object into a JSON Map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entreprise_id': entreprise_id,
      'compte_caisse_id': compte_caisse_id,
      'compte_frais_id': compte_frais_id,
      'compte_client_id': compte_client_id,
      'date_creation': date_creation.toIso8601String(),
      'date_modification': date_modification.toIso8601String(),
    };
  }
}
