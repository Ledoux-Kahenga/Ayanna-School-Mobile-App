import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';
import 'classe.dart';
import 'periode.dart';

part 'periodes_classes.g.dart';

@Entity(
  tableName: 'periodes_classes',
  indices: [
    // Contrainte d'unicité sur server_id pour éviter les doublons
    // Permet la gestion automatique des conflits
    Index(value: ['server_id'], unique: true),
  ],
  foreignKeys: [
    ForeignKey(
      childColumns: ['classe_id'],
      parentColumns: ['id'],
      entity: Classe,
    ),
    ForeignKey(
      childColumns: ['periode_id'],
      parentColumns: ['id'],
      entity: Periode,
    ),
  ],
)
@JsonSerializable()
class PeriodesClasses {
  @PrimaryKey(autoGenerate: false)
  @JsonKey(name: 'id', includeToJson: false, includeFromJson: true)
  final int? id;
  @ColumnInfo(name: 'server_id')
  @JsonKey(name: 'id', includeToJson: false, includeFromJson: true)
  int? serverId;

  @ColumnInfo(name: 'is_sync')
  @JsonKey(name: 'is_sync', includeFromJson: false, includeToJson: false)
  bool isSync;

  @ColumnInfo(name: 'classe_id')
  @JsonKey(name: 'classe_id')
  int classeId;

  @ColumnInfo(name: 'periode_id')
  @JsonKey(name: 'periode_id')
  int periodeId;

  @ColumnInfo(name: 'date_creation')
  @JsonKey(name: 'date_creation')
  DateTime dateCreation;

  @ColumnInfo(name: 'date_modification')
  @JsonKey(name: 'date_modification')
  DateTime dateModification;

  @ColumnInfo(name: 'updated_at')
  @JsonKey(name: 'updated_at')
  DateTime updatedAt;

  PeriodesClasses({
    this.id,
    this.serverId,
    this.isSync = true,
    required this.classeId,
    required this.periodeId,
    required this.dateCreation,
    required this.dateModification,
    required this.updatedAt,
  });

  factory PeriodesClasses.fromJson(Map<String, dynamic> json) =>
      _$PeriodesClassesFromJson(json);
 
  Map<String, dynamic> toJson() {
    final json = _$PeriodesClassesToJson(this);
    // Logique conditionnelle: utiliser serverId si disponible, sinon id
    if (serverId != null) {
      json['id'] = serverId;
    } else {
      json['id'] = id;
    }
    return json;
  }

  /// Convertir une liste de JSON en liste d'objets PeriodesClasses
  static List<PeriodesClasses> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => PeriodesClasses.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Convertir une liste d'objets PeriodesClasses en liste de JSON
  static List<Map<String, dynamic>> toJsonList(
    List<PeriodesClasses> periodesClasses,
  ) {
    return periodesClasses.map((pc) => pc.toJson()).toList();
  }

  PeriodesClasses copyWith({
    final int? id,
    int? serverId,
    bool? isSync,
    int? classeId,
    int? periodeId,
    DateTime? dateCreation,
    DateTime? dateModification,
    DateTime? updatedAt,
  }) {
    return PeriodesClasses(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      isSync: isSync ?? this.isSync,
      classeId: classeId ?? this.classeId,
      periodeId: periodeId ?? this.periodeId,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
