import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';

part 'responsable.g.dart';

@Entity(
  tableName: 'responsables',
  indices: [
    // Contrainte d'unicité sur server_id pour éviter les doublons
    // Permet la gestion automatique des conflits
    Index(value: ['server_id'], unique: true),
  ],
)
@JsonSerializable()
class Responsable {
  @PrimaryKey(autoGenerate: false)
  @JsonKey(includeToJson: false)
  final int? id;
  @ColumnInfo(name: 'server_id')
  @JsonKey(name: 'id')
  int? serverId;

  @ColumnInfo(name: 'is_sync')
  @JsonKey(name: 'is_sync', includeFromJson: false, includeToJson: false)
  bool isSync;

  String? nom;
  String? code;
  String? telephone;
  String? adresse;

  @ColumnInfo(name: 'date_creation')
  @JsonKey(name: 'date_creation')
  DateTime dateCreation;

  @ColumnInfo(name: 'date_modification')
  @JsonKey(name: 'date_modification')
  DateTime dateModification;

  @ColumnInfo(name: 'updated_at')
  @JsonKey(name: 'updated_at')
  DateTime updatedAt;

  Responsable({
    this.id,
    this.serverId,
    this.isSync = true,
    this.nom,
    this.code,
    this.telephone,
    this.adresse,
    required this.dateCreation,
    required this.dateModification,
    required this.updatedAt,
  });

  factory Responsable.fromJson(Map<String, dynamic> json) =>
      _$ResponsableFromJson(json);
  Map<String, dynamic> toJson() => _$ResponsableToJson(this);

  /// Convertir une liste de JSON en liste d'objets Responsable
  static List<Responsable> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => Responsable.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Convertir une liste d'objets Responsable en liste de JSON
  static List<Map<String, dynamic>> toJsonList(List<Responsable> responsables) {
    return responsables.map((responsable) => responsable.toJson()).toList();
  }

  Responsable copyWith({
    final int? id,
    int? serverId,
    bool? isSync,
    String? nom,
    String? code,
    String? telephone,
    String? adresse,
    DateTime? dateCreation,
    DateTime? dateModification,
    DateTime? updatedAt,
  }) {
    return Responsable(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      isSync: isSync ?? this.isSync,
      nom: nom ?? this.nom,
      code: code ?? this.code,
      telephone: telephone ?? this.telephone,
      adresse: adresse ?? this.adresse,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
