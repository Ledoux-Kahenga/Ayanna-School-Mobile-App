import 'package:floor/floor.dart';

/// @Entity marks this class as a database table.
/// The tableName is explicitly set to "responsables" to match the SQL.
@Entity(tableName: "responsables", indices: [
  Index(value: ['code'], unique: true),
])
class ResponsableModel {
  /// @PrimaryKey marks this field as the primary key.
  /// The id is of type int and is not-nullable.
  @PrimaryKey()
  final int id;

  /// These fields correspond to the VARCHAR columns that are
  /// nullable in the SQL schema.
  final String? nom;
  
  /// This field has a UNIQUE constraint in the SQL, so we can
  /// add the @unique annotation in Dart.

  final String? code;
  
  final String? telephone;
  
  /// This field corresponds to the TEXT column in SQL.
  final String? adresse;

  /// The constructor for the ResponsableModel class.
  /// Only the 'id' is required as per the SQL schema's NOT NULL constraint.
  ResponsableModel({
    required this.id,
    this.nom,
    this.code,
    this.telephone,
    this.adresse,
  });

  /// A factory constructor to create a ResponsableModel from a JSON Map.
  factory ResponsableModel.fromJson(Map<String, dynamic> json) {
    return ResponsableModel(
      id: json['id'] as int,
      nom: json['nom'] as String?,
      code: json['code'] as String?,
      telephone: json['telephone'] as String?,
      adresse: json['adresse'] as String?,
    );
  }

  /// Converts the ResponsableModel object into a JSON Map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'code': code,
      'telephone': telephone,
      'adresse': adresse,
    };
  }
}
