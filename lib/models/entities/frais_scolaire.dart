import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';
import 'entreprise.dart';
import 'annee_scolaire.dart';

part 'frais_scolaire.g.dart';

@Entity(
  tableName: 'frais_scolaires',
  indices: [
    // Contrainte d'unicité sur server_id pour éviter les doublons
    // Permet la gestion automatique des conflits
    Index(value: ['server_id'], unique: true),
  ],
  foreignKeys: [
    ForeignKey(
      childColumns: ['entreprise_id'],
      parentColumns: ['id'],
      entity: Entreprise,
    ),
    ForeignKey(
      childColumns: ['annee_scolaire_id'],
      parentColumns: ['id'],
      entity: AnneeScolaire,
    ),
  ],
)
@JsonSerializable()
class FraisScolaire {
  @PrimaryKey(autoGenerate: false)
  @JsonKey(includeToJson: false)
  final int? id;
  @ColumnInfo(name: 'server_id')
  @JsonKey(name: 'id')
  int? serverId;

  @ColumnInfo(name: 'is_sync')
  @JsonKey(name: 'is_sync', includeFromJson: false, includeToJson: false)
  bool isSync;

  String nom;
  double montant;

  @ColumnInfo(name: 'date_limite')
  @JsonKey(name: 'date_limite')
  DateTime? dateLimite;

  @ColumnInfo(name: 'entreprise_id')
  @JsonKey(name: 'entreprise_id')
  int entrepriseId;

  @ColumnInfo(name: 'annee_scolaire_id')
  @JsonKey(name: 'annee_scolaire_id')
  int anneeScolaireId;

  @ColumnInfo(name: 'date_creation')
  @JsonKey(name: 'date_creation')
  DateTime dateCreation;

  @ColumnInfo(name: 'date_modification')
  @JsonKey(name: 'date_modification')
  DateTime dateModification;

  @ColumnInfo(name: 'updated_at')
  @JsonKey(name: 'updated_at')
  DateTime updatedAt;

  FraisScolaire({
    this.id,
    this.serverId,
    this.isSync = true,
    required this.nom,
    required this.montant,
    this.dateLimite,
    required this.entrepriseId,
    required this.anneeScolaireId,
    required this.dateCreation,
    required this.dateModification,
    required this.updatedAt,
  });

  factory FraisScolaire.fromJson(Map<String, dynamic> json) =>
      _$FraisScolaireFromJson(json);
  Map<String, dynamic> toJson() => _$FraisScolaireToJson(this);

  /// Convertir une liste de JSON en liste d'objets FraisScolaire
  static List<FraisScolaire> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => FraisScolaire.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Convertir une liste d'objets FraisScolaire en liste de JSON
  static List<Map<String, dynamic>> toJsonList(
    List<FraisScolaire> fraisScolaires,
  ) {
    return fraisScolaires.map((frais) => frais.toJson()).toList();
  }

  FraisScolaire copyWith({
    int? id,
    int? serverId,
    bool? isSync,
    String? nom,
    double? montant,
    DateTime? dateLimite,
    int? entrepriseId,
    int? anneeScolaireId,
    DateTime? dateCreation,
    DateTime? dateModification,
    DateTime? updatedAt,
  }) {
    return FraisScolaire(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      isSync: isSync ?? this.isSync,
      nom: nom ?? this.nom,
      montant: montant ?? this.montant,
      dateLimite: dateLimite ?? this.dateLimite,
      entrepriseId: entrepriseId ?? this.entrepriseId,
      anneeScolaireId: anneeScolaireId ?? this.anneeScolaireId,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
