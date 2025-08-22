import 'package:ayanna_school/models/classe.dart';
import 'package:ayanna_school/models/responsable.dart';
import 'package:floor/floor.dart';

/// @Entity marks this class as a database table.
/// The tableName is explicitly set to "eleves" to match the SQL schema.
/// We also define foreign keys to relate this entity to the 'ClassModel' and 'ResponsableModel'.
@Entity(
  tableName: "eleves",
  foreignKeys: [
    ForeignKey(
      childColumns: ['classe_id'],
      parentColumns: ['id'],
      entity: ClassModel,
      onDelete: ForeignKeyAction.setNull,
    ),
    ForeignKey(
      childColumns: ['responsable_id'],
      parentColumns: ['id'],
      entity: ResponsableModel,
      onDelete: ForeignKeyAction.setNull,
    ),
  ],
)
class EleveModel {
  /// @PrimaryKey marks this field as the primary key.
  /// The id is of type int and is not-nullable.
  @PrimaryKey()
  final int id;

  /// These fields correspond to the SQL columns that are defined as NOT NULL.
  final String nom;
  final String prenom;

  /// These fields correspond to nullable columns in the SQL schema.
  final String? postnom;
  final String? sexe;
  final String? statut;
  final String? date_naissance; // format ISO ou null
  final String? lieu_naissance;
  final String? matricule;
  final String? numero_permanent;

  /// These fields represent the foreign keys in the SQL table.
  final int? classe_id;
  final int? responsable_id;

  /// The constructor for the EleveModel class.
  EleveModel({
    required this.id,
    required this.nom,
    required this.prenom,
    this.postnom,
    this.sexe,
    this.statut,
    this.date_naissance,
    this.lieu_naissance,
    this.matricule,
    this.numero_permanent,
    this.classe_id,
    this.responsable_id,
  });

  /// A factory constructor to create an EleveModel from a JSON Map.
  factory EleveModel.fromJson(Map<String, dynamic> json) {
    return EleveModel(
      id: json['id'] as int,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      postnom: json['postnom'] as String?,
      sexe: json['sexe'] as String?,
      statut: json['statut'] as String?,
      date_naissance: json['date_naissance'] as String?,
      lieu_naissance: json['lieu_naissance'] as String?,
      matricule: json['matricule'] as String?,
      numero_permanent: json['numero_permanent'] as String?,
      classe_id: json['classe_id'] as int?,
      responsable_id: json['responsable_id'] as int?,
    );
  }

  /// Converts the EleveModel object into a JSON Map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'postnom': postnom,
      'sexe': sexe,
      'statut': statut,
      'date_naissance': date_naissance,
      'lieu_naissance': lieu_naissance,
      'matricule': matricule,
      'numero_permanent': numero_permanent,
      'classe_id': classe_id,
      'responsable_id': responsable_id,
    };
  }
}
