import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';
import 'annee_scolaire.dart';

part 'periode.g.dart';

@Entity(
  tableName: 'periodes',
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
  ],
)
@JsonSerializable()
class Periode {
  @PrimaryKey(autoGenerate: true)
  @JsonKey(includeFromJson: false, includeToJson: false)
  final int? id;

  @ColumnInfo(name: 'server_id')
  @JsonKey(name: 'id')
  int? serverId;

  @ColumnInfo(name: 'is_sync')
  @JsonKey(name: 'is_sync', includeFromJson: false, includeToJson: false)
  bool isSync;

  String? code;
  String nom;
  int semestre;
  int? poids;

  @ColumnInfo(name: 'date_debut')
  @JsonKey(name: 'date_debut')
  DateTime? dateDebut;

  @ColumnInfo(name: 'date_fin')
  @JsonKey(name: 'date_fin')
  DateTime? dateFin;

  @ColumnInfo(name: 'annee_scolaire_id')
  @JsonKey(name: 'annee_scolaire_id')
  int? anneeScolaireId;

  @ColumnInfo(name: 'date_creation')
  @JsonKey(name: 'date_creation')
  DateTime dateCreation;

  @ColumnInfo(name: 'date_modification')
  @JsonKey(name: 'date_modification')
  DateTime dateModification;

  @ColumnInfo(name: 'updated_at')
  @JsonKey(name: 'updated_at')
  DateTime updatedAt;

  Periode({
    this.id,
    this.serverId,
    this.isSync = true,
    this.code,
    required this.nom,
    required this.semestre,
    this.poids,
    this.dateDebut,
    this.dateFin,
    this.anneeScolaireId,
    required this.dateCreation,
    required this.dateModification,
    required this.updatedAt,
  });

  factory Periode.fromJson(Map<String, dynamic> json) =>
      _$PeriodeFromJson(json);
  Map<String, dynamic> toJson() => _$PeriodeToJson(this);

  /// Convertir une liste de JSON en liste d'objets Periode
  static List<Periode> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => Periode.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Convertir une liste d'objets Periode en liste de JSON
  static List<Map<String, dynamic>> toJsonList(List<Periode> periodes) {
    return periodes.map((periode) => periode.toJson()).toList();
  }

  Periode copyWith({
    final int? id,
    int? serverId,
    bool? isSync,
    String? code,
    String? nom,
    int? semestre,
    int? poids,
    DateTime? dateDebut,
    DateTime? dateFin,
    int? anneeScolaireId,
    DateTime? dateCreation,
    DateTime? dateModification,
    DateTime? updatedAt,
  }) {
    return Periode(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      isSync: isSync ?? this.isSync,
      code: code ?? this.code,
      nom: nom ?? this.nom,
      semestre: semestre ?? this.semestre,
      poids: poids ?? this.poids,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      anneeScolaireId: anneeScolaireId ?? this.anneeScolaireId,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
