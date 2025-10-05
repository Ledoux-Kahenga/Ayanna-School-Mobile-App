import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';
import 'entreprise.dart';
import 'annee_scolaire.dart';

part 'config_ecole.g.dart';

@Entity(
  tableName: 'config_ecole',
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
      childColumns: ['annee_scolaire_en_cours_id'],
      parentColumns: ['id'],
      entity: AnneeScolaire,
    ),
  ],
)
@JsonSerializable()
class ConfigEcole {
  @PrimaryKey(autoGenerate: false)
  @JsonKey(name: 'id', includeToJson: false, includeFromJson: true)
  final int? id;

  @ColumnInfo(name: 'server_id')
  @JsonKey(name: 'id', includeToJson: false, includeFromJson: true)
  int? serverId;

  @ColumnInfo(name: 'is_sync')
  @JsonKey(name: 'is_sync', includeFromJson: false, includeToJson: false)
  bool isSync;

  @ColumnInfo(name: 'entreprise_id')
  @JsonKey(name: 'entreprise_id')
  int entrepriseId;

  @ColumnInfo(name: 'annee_scolaire_en_cours_id')
  @JsonKey(name: 'annee_scolaire_en_cours_id')
  int? anneeScolaireEnCoursId;

  @ColumnInfo(name: 'date_creation')
  @JsonKey(name: 'date_creation')
  DateTime dateCreation;

  @ColumnInfo(name: 'date_modification')
  @JsonKey(name: 'date_modification')
  DateTime dateModification;

  @ColumnInfo(name: 'updated_at')
  @JsonKey(name: 'updated_at')
  DateTime updatedAt;

  ConfigEcole({
    this.id,
    this.serverId,
    this.isSync = true,
    required this.entrepriseId,
    this.anneeScolaireEnCoursId,
    required this.dateCreation,
    required this.dateModification,
    required this.updatedAt,
  });

  factory ConfigEcole.fromJson(Map<String, dynamic> json) =>
      _$ConfigEcoleFromJson(json);

  Map<String, dynamic> toJson() {
    final json = _$ConfigEcoleToJson(this);
    // Logique conditionnelle: utiliser serverId si disponible, sinon id
    if (serverId != null) {
      json['id'] = serverId;
    } else {
      json['id'] = id;
    }
    return json;
  }
  /// Convertir une liste de JSON en liste d'objets ConfigEcole
  static List<ConfigEcole> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => ConfigEcole.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Convertir une liste d'objets ConfigEcole en liste de JSON
  static List<Map<String, dynamic>> toJsonList(List<ConfigEcole> configs) {
    return configs.map((config) => config.toJson()).toList();
  }

  ConfigEcole copyWith({
    int? id,
    int? serverId,
    bool? isSync,
    int? entrepriseId,
    int? anneeScolaireEnCoursId,
    DateTime? dateCreation,
    DateTime? dateModification,
    DateTime? updatedAt,
  }) {
    return ConfigEcole(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      isSync: isSync ?? this.isSync,
      entrepriseId: entrepriseId ?? this.entrepriseId,
      anneeScolaireEnCoursId:
          anneeScolaireEnCoursId ?? this.anneeScolaireEnCoursId,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
