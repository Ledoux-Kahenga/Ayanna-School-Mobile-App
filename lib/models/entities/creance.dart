import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';
import 'eleve.dart';
import 'frais_scolaire.dart';
import '../helpers/parse_helper.dart';

part 'creance.g.dart';

@Entity(
  tableName: 'creances',
  indices: [
    // Contrainte d'unicité sur server_id pour éviter les doublons
    // Permet la gestion automatique des conflits
    Index(value: ['server_id'], unique: true),
  ],
  foreignKeys: [
    ForeignKey(
      childColumns: ['eleve_id'],
      parentColumns: ['id'],
      entity: Eleve,
    ),
    ForeignKey(
      childColumns: ['frais_scolaire_id'],
      parentColumns: ['id'],
      entity: FraisScolaire,
    ),
  ],
)
@JsonSerializable()
class Creance {
  @PrimaryKey(autoGenerate: false)
  @JsonKey(includeToJson: false)
  final int? id;


  @ColumnInfo(name: 'server_id')
  @JsonKey(name: 'id')
  int? serverId;

  @ColumnInfo(name: 'is_sync')
  @JsonKey(name: 'is_sync', includeFromJson: false, includeToJson: false)
  bool isSync;

  @ColumnInfo(name: 'eleve_id')
  @JsonKey(name: 'eleve_id')
  int eleveId;

  @ColumnInfo(name: 'frais_scolaire_id')
  @JsonKey(name: 'frais_scolaire_id')
  int fraisScolaireId;

  double montant;

  @ColumnInfo(name: 'date_echeance')
  @JsonKey(name: 'date_echeance')
  DateTime dateEcheance;

  @JsonKey(name: 'actif', fromJson: parseBool)
  bool? active;

  @ColumnInfo(name: 'date_creation')
  @JsonKey(name: 'date_creation')
  DateTime dateCreation;

  @ColumnInfo(name: 'date_modification')
  @JsonKey(name: 'date_modification')
  DateTime dateModification;

  @ColumnInfo(name: 'updated_at')
  @JsonKey(name: 'updated_at')
  DateTime updatedAt;

  Creance({
    this.id,
    this.serverId,
    this.isSync = true,
    required this.eleveId,
    required this.fraisScolaireId,
    required this.montant,
    required this.dateEcheance,
    this.active,
    required this.dateCreation,
    required this.dateModification,
    required this.updatedAt,
  });

  factory Creance.fromJson(Map<String, dynamic> json) =>
      _$CreanceFromJson(json);
  Map<String, dynamic> toJson() => _$CreanceToJson(this);

  /// Convertir une liste de JSON en liste d'objets Creance
  static List<Creance> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => Creance.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Convertir une liste d'objets Creance en liste de JSON
  static List<Map<String, dynamic>> toJsonList(List<Creance> creances) {
    return creances.map((creance) => creance.toJson()).toList();
  }
}
