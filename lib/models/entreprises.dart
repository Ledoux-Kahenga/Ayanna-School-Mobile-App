import 'package:floor/floor.dart';
import 'dart:typed_data';

/// @Entity marks this class as a database table.
/// The tableName is explicitly set to "entreprises" to match the SQL.
@Entity(tableName: "entreprises")
class EntrepriseModel {
  /// @PrimaryKey marks this field as the primary key.
  /// According to your SQL schema, the ID is NOT NULL but does not have an
  /// auto-increment flag. Therefore, we use a non-nullable `final int`
  /// and `autoGenerate: false` is the default behavior.
  @PrimaryKey()
  final int id;

  /// These fields correspond to the VARCHAR columns that are
  /// defined as NOT NULL in the table schema.
  final String nom;
  final DateTime date_creation;
  final DateTime date_modification;

  /// These fields correspond to nullable columns in the SQL schema.
  /// We use nullable types (`String?`, `Uint8List?`) in Dart.
  final String? adresse;
  final String? numero_id;
  final String? devise;
  final String? telephone;
  final String? email;

  /// The 'logo' column is of type BLOB in SQL, which is typically used for
  /// storing binary data like images. In Dart, this maps to Uint8List?.
  final Uint8List? logo;

  /// The constructor for the EntrepriseModel class.
  /// 'id', 'nom', 'date_creation', and 'date_modification' are required because
  /// they are NOT NULL in the table.
  EntrepriseModel({
    required this.id,
    required this.nom,
    required this.date_creation,
    required this.date_modification,
    this.adresse,
    this.numero_id,
    this.devise,
    this.telephone,
    this.email,
    this.logo,
  });

  /// A factory constructor to create an EntrepriseModel from a JSON Map.
  /// This is useful for data serialization.
  factory EntrepriseModel.fromJson(Map<String, dynamic> json) {
    return EntrepriseModel(
      id: json['id'] as int,
      nom: json['nom'] as String,
      adresse: json['adresse'] as String?,
      numero_id: json['numero_id'] as String?,
      devise: json['devise'] as String?,
      telephone: json['telephone'] as String?,
      email: json['email'] as String?,
      logo: json['logo'] is List<int>
          ? Uint8List.fromList(json['logo'] as List<int>)
          : null,
      date_creation: DateTime.parse(json['date_creation'] as String),
      date_modification: DateTime.parse(json['date_modification'] as String),
    );
  }

  /// Converts the EntrepriseModel object into a JSON Map.
  /// This is useful for sending data over a network or saving it to a file.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'adresse': adresse,
      'numero_id': numero_id,
      'devise': devise,
      'telephone': telephone,
      'email': email,
      'logo': logo,
      'date_creation': date_creation.toIso8601String(),
      'date_modification': date_modification.toIso8601String(),
    };
  }
}
