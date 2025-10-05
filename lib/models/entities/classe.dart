import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';
import 'annee_scolaire.dart';
import 'enseignant.dart';

part 'classe.g.dart';

@Entity(
  tableName: 'classes',
  indices: [
    // Contrainte d'unicité sur server_id pour éviter les doublons
    // Permet la gestion automatique des conflits
    Index(value: ['server_id'], unique: true),
  ],
  foreignKeys: [
    ForeignKey(
      childColumns: ['annee_scolaire_id'],
      parentColumns: ['id'],
      entity: AnneeScolaire,
    ),
    ForeignKey(
      childColumns: ['enseignant_id'],
      parentColumns: ['id'],
      entity: Enseignant,
    ),
  ],
)
@JsonSerializable()
class Classe {
  @PrimaryKey(autoGenerate: false)
  @JsonKey(includeToJson: false)
  final int? id;
  

  @ColumnInfo(name: 'server_id')
  @JsonKey(name: 'id')
  int? serverId;

  @ColumnInfo(name: 'is_sync')
  @JsonKey(name: 'is_sync', includeFromJson: false, includeToJson: false)
  bool isSync;

  String? code;
  String nom;
  String? niveau;
  int? effectif;

  @ColumnInfo(name: 'annee_scolaire_id')
  @JsonKey(name: 'annee_scolaire_id')
  int anneeScolaireId;

  @ColumnInfo(name: 'enseignant_id')
  @JsonKey(name: 'enseignant_id')
  int? enseignantId;

  @ColumnInfo(name: 'date_creation')
  @JsonKey(name: 'date_creation')
  DateTime dateCreation;

  @ColumnInfo(name: 'date_modification')
  @JsonKey(name: 'date_modification')
  DateTime dateModification;

  @ColumnInfo(name: 'updated_at')
  @JsonKey(name: 'updated_at')
  DateTime updatedAt;

  Classe({
    this.id,
    this.serverId,
    this.isSync = true,
    this.code,
    required this.nom,
    this.niveau,
    this.effectif,
    required this.anneeScolaireId,
    this.enseignantId,
    required this.dateCreation,
    required this.dateModification,
    required this.updatedAt,
  });

  factory Classe.fromJson(Map<String, dynamic> json) => _$ClasseFromJson(json);
  Map<String, dynamic> toJson() => _$ClasseToJson(this);

  /// Convertir une liste de JSON en liste d'objets Classe
  static List<Classe> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => Classe.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Convertir une liste d'objets Classe en liste de JSON
  static List<Map<String, dynamic>> toJsonList(List<Classe> classes) {
    return classes.map((classe) => classe.toJson()).toList();
  }

  Classe copyWith({
    int? id,
    int? serverId,
    bool? isSync,
    String? code,
    String? nom,
    String? niveau,
    int? effectif,
    int? anneeScolaireId,
    int? enseignantId,
    DateTime? dateCreation,
    DateTime? dateModification,
    DateTime? updatedAt,
  }) {
    return Classe(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      isSync: isSync ?? this.isSync,
      code: code ?? this.code,
      nom: nom ?? this.nom,
      niveau: niveau ?? this.niveau,
      effectif: effectif ?? this.effectif,
      anneeScolaireId: anneeScolaireId ?? this.anneeScolaireId,
      enseignantId: enseignantId ?? this.enseignantId,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
