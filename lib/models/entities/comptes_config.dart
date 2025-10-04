import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';
import 'compte_comptable.dart';

part 'comptes_config.g.dart';

@Entity(
  tableName: 'comptes_config',
    indices: [
    // Contrainte d'unicité sur server_id pour éviter les doublons
    // Permet la gestion automatique des conflits
    Index(value: ['server_id'], unique: true),
  ],
  foreignKeys: [
    ForeignKey(
      childColumns: ['compte_caisse_id'],
      parentColumns: ['id'],
      entity: CompteComptable,
    ),
    ForeignKey(
      childColumns: ['compte_frais_id'],
      parentColumns: ['id'],
      entity: CompteComptable,
    ),
    ForeignKey(
      childColumns: ['compte_client_id'],
      parentColumns: ['id'],
      entity: CompteComptable,
    ),
  ],
)
@JsonSerializable()
class ComptesConfig {
  @PrimaryKey(autoGenerate: true)
  @JsonKey(includeFromJson: false, includeToJson: false)
  final int? id;

  @ColumnInfo(name: 'server_id')
  @JsonKey(name: 'id')
  int? serverId;

  @ColumnInfo(name: 'is_sync')
  @JsonKey(name: 'is_sync', includeFromJson: false, includeToJson: false)
  bool isSync;

  @ColumnInfo(name: 'entreprise_id')
  @JsonKey(name: 'entreprise_id')
  int entrepriseId;

  @ColumnInfo(name: 'compte_caisse_id')
  @JsonKey(name: 'compte_caisse_id')
  int compteCaisseId;

  @ColumnInfo(name: 'compte_frais_id')
  @JsonKey(name: 'compte_frais_id')
  int compteFraisId;

  @ColumnInfo(name: 'compte_client_id')
  @JsonKey(name: 'compte_client_id')
  int compteClientId;

  @ColumnInfo(name: 'date_creation')
  @JsonKey(name: 'date_creation')
  DateTime dateCreation;

  @ColumnInfo(name: 'date_modification')
  @JsonKey(name: 'date_modification')
  DateTime dateModification;

  @ColumnInfo(name: 'updated_at')
  @JsonKey(name: 'updated_at')
  DateTime updatedAt;

  ComptesConfig({
    this.id,
    this.serverId,
    this.isSync = true,
    required this.entrepriseId,
    required this.compteCaisseId,
    required this.compteFraisId,
    required this.compteClientId,
    required this.dateCreation,
    required this.dateModification,
    required this.updatedAt,
  });

  factory ComptesConfig.fromJson(Map<String, dynamic> json) =>
      _$ComptesConfigFromJson(json);
  Map<String, dynamic> toJson() => _$ComptesConfigToJson(this);

  /// Convertir une liste de JSON en liste d'objets ComptesConfig
  static List<ComptesConfig> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => ComptesConfig.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Convertir une liste d'objets ComptesConfig en liste de JSON
  static List<Map<String, dynamic>> toJsonList(List<ComptesConfig> configs) {
    return configs.map((config) => config.toJson()).toList();
  }

  ComptesConfig copyWith({
    int? id,
    int? serverId,
    bool? isSync,
    int? entrepriseId,
    int? compteCaisseId,
    int? compteFraisId,
    int? compteClientId,
    DateTime? dateCreation,
    DateTime? dateModification,
    DateTime? updatedAt,
  }) {
    return ComptesConfig(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      isSync: isSync ?? this.isSync,
      entrepriseId: entrepriseId ?? this.entrepriseId,
      compteCaisseId: compteCaisseId ?? this.compteCaisseId,
      compteFraisId: compteFraisId ?? this.compteFraisId,
      compteClientId: compteClientId ?? this.compteClientId,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
