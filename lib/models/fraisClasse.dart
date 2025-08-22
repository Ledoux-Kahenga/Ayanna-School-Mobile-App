import 'package:ayanna_school/models/classe.dart';
import 'package:ayanna_school/models/fraisScolaire.dart';
import 'package:floor/floor.dart';

/// @Entity marks this class as a database table.
/// The tableName is explicitly set to "frais_classes" to match the SQL schema.
/// We also define foreign keys to relate this entity to the 'ClassModel' and 'FraisScolaireModel'.
@Entity(
  tableName: "frais_classes",
  foreignKeys: [
    ForeignKey(
      childColumns: ['classe_id'],
      parentColumns: ['id'],
      entity: ClassModel, // Assuming 'ClassModel' is the name of your entity class
      onDelete: ForeignKeyAction.cascade,
    ),
    ForeignKey(
      childColumns: ['frais_id'],
      parentColumns: ['id'],
      entity: FraisScolaireModel, // Assuming 'FraisScolaireModel' is the name of your entity class
      onDelete: ForeignKeyAction.cascade,
    ),
  ],
)
class FraisClassesModel {
  /// @PrimaryKey marks this field as the primary key.
  /// The id is of type int and is not-nullable.
  @PrimaryKey()
  final int id;

  /// These fields are NOT NULL in the SQL table, so they are required.
  /// They represent the foreign keys that link to other tables.
  final int frais_id;
  final int classe_id;

  /// The constructor for the FraisClassesModel class.
  FraisClassesModel({
    required this.id,
    required this.frais_id,
    required this.classe_id,
  });

  /// A factory constructor to create a FraisClassesModel from a JSON Map.
  factory FraisClassesModel.fromJson(Map<String, dynamic> json) {
    return FraisClassesModel(
      id: json['id'] as int,
      frais_id: json['frais_id'] as int,
      classe_id: json['classe_id'] as int,
    );
  }

  /// Converts the FraisClassesModel object into a JSON Map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'frais_id': frais_id,
      'classe_id': classe_id,
    };
  }
}
