import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';
import 'frais_scolaire.dart';
import 'classe.dart';

part 'frais_classes.g.dart';

@Entity(
  tableName: 'frais_classes',
  indices: [
    // Contrainte d'unicité sur server_id pour éviter les doublons
    Index(value: ['server_id'], unique: true),
  ],
  foreignKeys: [
    ForeignKey(
      childColumns: ['frais_id'],
      parentColumns: ['id'],
      entity: FraisScolaire,
    ),
    ForeignKey(
      childColumns: ['classe_id'],
      parentColumns: ['id'],
      entity: Classe,
    ),
  ],
)
@JsonSerializable()
class FraisClasses {
  @PrimaryKey(autoGenerate: false)
  @JsonKey(name: 'id', includeToJson: false, includeFromJson: true)
  final int? id;
  @ColumnInfo(name: 'server_id')
  @JsonKey(name: 'id', includeToJson: false, includeFromJson: true)
  int? serverId;

  @ColumnInfo(name: 'is_sync')
  @JsonKey(name: 'is_sync', includeFromJson: false, includeToJson: false)
  bool isSync;

  @ColumnInfo(name: 'frais_id')
  @JsonKey(name: 'frais_id')
  int fraisId;

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

  FraisClasses({
    this.id,
    this.serverId,
    this.isSync = false,
    required this.fraisId,
    required this.classeId,
    required this.dateCreation,
    required this.dateModification,
    required this.updatedAt,
  });

  factory FraisClasses.fromJson(Map<String, dynamic> json) =>
      _$FraisClassesFromJson(json);
  
  Map<String, dynamic> toJson() {
    final json = _$FraisClassesToJson(this);
    // Logique conditionnelle: utiliser serverId si disponible, sinon id
    if (serverId != null) {
      json['id'] = serverId;
    } else {
      json['id'] = id;
    }
    return json;
  }

  FraisClasses copyWith({
    int? id,
    int? serverId,
    bool? isSync,
    int? fraisId,
    int? classeId,
    DateTime? dateCreation,
    DateTime? dateModification,
    DateTime? updatedAt,
  }) {
    return FraisClasses(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      isSync: isSync ?? this.isSync,
      fraisId: fraisId ?? this.fraisId,
      classeId: classeId ?? this.classeId,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'FraisClasses(id: $id, serverId: $serverId, fraisId: $fraisId, classeId: $classeId, isSync: $isSync)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FraisClasses &&
        other.id == id &&
        other.serverId == serverId &&
        other.fraisId == fraisId &&
        other.classeId == classeId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        serverId.hashCode ^
        fraisId.hashCode ^
        classeId.hashCode;
  }
}
