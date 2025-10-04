import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';
import 'eleve.dart';
import 'cours.dart';
import 'periode.dart';

part 'note_periode.g.dart';

@Entity(
  tableName: 'notes_periode',
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
      childColumns: ['cours_id'],
      parentColumns: ['id'],
      entity: Cours,
    ),
    ForeignKey(
      childColumns: ['periode_id'],
      parentColumns: ['id'],
      entity: Periode,
    ),
  ],
)
@JsonSerializable()
class NotePeriode {
  @PrimaryKey(autoGenerate: true)
  @JsonKey(includeFromJson: false, includeToJson: false)
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

  @ColumnInfo(name: 'cours_id')
  @JsonKey(name: 'cours_id')
  int coursId;

  @ColumnInfo(name: 'periode_id')
  @JsonKey(name: 'periode_id')
  int periodeId;

  double? valeur;

  @ColumnInfo(name: 'date_creation')
  @JsonKey(name: 'date_creation')
  DateTime dateCreation;

  @ColumnInfo(name: 'date_modification')
  @JsonKey(name: 'date_modification')
  DateTime dateModification;

  @ColumnInfo(name: 'updated_at')
  @JsonKey(name: 'updated_at')
  DateTime updatedAt;

  NotePeriode({
    this.id,
    this.serverId,
    this.isSync = true,
    required this.eleveId,
    required this.coursId,
    required this.periodeId,
    this.valeur,
    required this.dateCreation,
    required this.dateModification,
    required this.updatedAt,
  });

  factory NotePeriode.fromJson(Map<String, dynamic> json) =>
      _$NotePeriodeFromJson(json);
  Map<String, dynamic> toJson() => _$NotePeriodeToJson(this);

  /// Convertir une liste de JSON en liste d'objets NotePeriode
  static List<NotePeriode> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => NotePeriode.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Convertir une liste d'objets NotePeriode en liste de JSON
  static List<Map<String, dynamic>> toJsonList(List<NotePeriode> notes) {
    return notes.map((note) => note.toJson()).toList();
  }

  NotePeriode copyWith({
    final int? id,
    int? serverId,
    bool? isSync,
    int? eleveId,
    int? coursId,
    int? periodeId,
    double? valeur,
    DateTime? dateCreation,
    DateTime? dateModification,
    DateTime? updatedAt,
  }) {
    return NotePeriode(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      isSync: isSync ?? this.isSync,
      eleveId: eleveId ?? this.eleveId,
      coursId: coursId ?? this.coursId,
      periodeId: periodeId ?? this.periodeId,
      valeur: valeur ?? this.valeur,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
