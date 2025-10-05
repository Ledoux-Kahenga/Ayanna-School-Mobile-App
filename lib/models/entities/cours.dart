import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';
import 'enseignant.dart';
import 'classe.dart';

part 'cours.g.dart';

@Entity(
  tableName: 'cours',
  indices: [
    // Contrainte d'unicité sur server_id pour éviter les doublons
    // Permet la gestion automatique des conflits
    Index(value: ['server_id'], unique: true),
  ],
  foreignKeys: [
    ForeignKey(
      childColumns: ['enseignant_id'],
      parentColumns: ['id'],
      entity: Enseignant,
    ),
    ForeignKey(
      childColumns: ['classe_id'],
      parentColumns: ['id'],
      entity: Classe,
    ),
  ],
)
@JsonSerializable()
class Cours {
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
  int? coefficient;

  @ColumnInfo(name: 'enseignant_id')
  @JsonKey(name: 'enseignant_id')
  int enseignantId;

  @ColumnInfo(name: 'classe_id')
  @JsonKey(name: 'classe_id')
  int classeId;

  @ColumnInfo(name: 'date_creation')
  @JsonKey(name: 'date_creation')
  DateTime dateCreation;

  @ColumnInfo(name: 'date_modification')
  @JsonKey(name: 'date_modification')
  DateTime dateModification;

  @ColumnInfo(name: 'updated_at')
  @JsonKey(name: 'updated_at')
  DateTime updatedAt;

  Cours({
    this.id,
    this.serverId,
    this.isSync = true,
    this.code,
    required this.nom,
    this.coefficient,
    required this.enseignantId,
    required this.classeId,
    required this.dateCreation,
    required this.dateModification,
    required this.updatedAt,
  });

  factory Cours.fromJson(Map<String, dynamic> json) => _$CoursFromJson(json);
  Map<String, dynamic> toJson() => _$CoursToJson(this);

  /// Convertir une liste de JSON en liste d'objets Cours
  static List<Cours> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => Cours.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Convertir une liste d'objets Cours en liste de JSON
  static List<Map<String, dynamic>> toJsonList(List<Cours> coursList) {
    return coursList.map((cours) => cours.toJson()).toList();
  }

  Cours copyWith({
    int? id,
    int? serverId,
    bool? isSync,
    String? code,
    String? nom,
    int? coefficient,
    int? enseignantId,
    int? classeId,
    DateTime? dateCreation,
    DateTime? dateModification,
    DateTime? updatedAt,
  }) {
    return Cours(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      isSync: isSync ?? this.isSync,
      code: code ?? this.code,
      nom: nom ?? this.nom,
      coefficient: coefficient ?? this.coefficient,
      enseignantId: enseignantId ?? this.enseignantId,
      classeId: classeId ?? this.classeId,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
