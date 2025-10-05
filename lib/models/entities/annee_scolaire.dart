import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';
import 'entreprise.dart';

part 'annee_scolaire.g.dart';

@Entity(
  tableName: 'annees_scolaires',
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
  ],
)
@JsonSerializable()
class AnneeScolaire {
  @PrimaryKey(autoGenerate: false)
  @JsonKey(name: 'id', includeToJson: false, includeFromJson: true)
  final int? id;

  @ColumnInfo(name: 'server_id')
  @JsonKey(name: 'id', includeToJson: false, includeFromJson: true)
  int? serverId;

  @ColumnInfo(name: 'is_sync')
  @JsonKey(name: 'is_sync', includeFromJson: false, includeToJson: false)
  bool isSync;

  String nom;

  @ColumnInfo(name: 'date_debut')
  @JsonKey(name: 'date_debut')
  DateTime dateDebut;

  @ColumnInfo(name: 'date_fin')
  @JsonKey(name: 'date_fin')
  DateTime dateFin;

  @ColumnInfo(name: 'entreprise_id')
  @JsonKey(name: 'entreprise_id')
  int entrepriseId;

  @ColumnInfo(name: 'en_cours')
  @JsonKey(name: 'en_cours')
  int? enCours;

  @ColumnInfo(name: 'date_creation')
  @JsonKey(name: 'date_creation')
  DateTime dateCreation;

  @ColumnInfo(name: 'date_modification')
  @JsonKey(name: 'date_modification')
  DateTime dateModification;

  @ColumnInfo(name: 'updated_at')
  @JsonKey(name: 'updated_at')
  DateTime updatedAt;

  AnneeScolaire({
    this.id,
    this.serverId,
    this.isSync = true,
    required this.nom,
    required this.dateDebut,
    required this.dateFin,
    required this.entrepriseId,
    this.enCours,
    required this.dateCreation,
    required this.dateModification,
    required this.updatedAt,
  });

  factory AnneeScolaire.fromJson(Map<String, dynamic> json) =>
      _$AnneeScolaireFromJson(json);

  Map<String, dynamic> toJson() {
    final json = _$AnneeScolaireToJson(this);
    // Logique conditionnelle: utiliser serverId si disponible, sinon id
    if (serverId != null) {
      json['id'] = serverId;
    } else {
      json['id'] = id;
    }
    return json;
  }

  /// Convertir une liste de JSON en liste d'objets AnneeScolaire
  static List<AnneeScolaire> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => AnneeScolaire.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Convertir une liste d'objets AnneeScolaire en liste de JSON
  static List<Map<String, dynamic>> toJsonList(
    List<AnneeScolaire> anneesScolaires,
  ) {
    return anneesScolaires
        .map((anneeScolaire) => anneeScolaire.toJson())
        .toList();
  }

  AnneeScolaire copyWith({
    int? id,
    int? serverId,
    bool? isSync,
    String? nom,
    DateTime? dateDebut,
    DateTime? dateFin,
    int? entrepriseId,
    int? enCours,
    DateTime? dateCreation,
    DateTime? dateModification,
    DateTime? updatedAt,
  }) {
    return AnneeScolaire(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      isSync: isSync ?? this.isSync,
      nom: nom ?? this.nom,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      entrepriseId: entrepriseId ?? this.entrepriseId,
      enCours: enCours ?? this.enCours,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
