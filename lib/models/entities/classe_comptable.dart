import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';
import 'entreprise.dart';
import '../helpers/parse_helper.dart';
part 'classe_comptable.g.dart';

@Entity(
  tableName: 'classes_comptables',
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
class ClasseComptable {
  @PrimaryKey(autoGenerate: false)
  @JsonKey(name: 'id', includeToJson: false, includeFromJson: true)
  final int? id;

  @ColumnInfo(name: 'server_id')
  @JsonKey(name: 'id', includeToJson: false, includeFromJson: true)
  int? serverId;

  @ColumnInfo(name: 'is_sync')
  @JsonKey(name: 'is_sync', includeFromJson: false, includeToJson: false)
  bool isSync;

  String? code;
  String nom;
  String libelle;
  String type;

  @ColumnInfo(name: 'entreprise_id')
  @JsonKey(name: 'entreprise_id')
  int entrepriseId;

  @JsonKey(name: 'actif', fromJson: parseBool)
  bool? actif;
  String? document;

  @ColumnInfo(name: 'date_creation')
  @JsonKey(name: 'date_creation')
  DateTime dateCreation;

  @ColumnInfo(name: 'date_modification')
  @JsonKey(name: 'date_modification')
  DateTime dateModification;

  @ColumnInfo(name: 'updated_at')
  @JsonKey(name: 'updated_at')
  DateTime updatedAt;

  ClasseComptable({
    this.id,
    this.serverId,
    this.isSync = true,
    this.code,
    required this.nom,
    required this.libelle,
    required this.type,
    required this.entrepriseId,
    this.actif,
    this.document,
    required this.dateCreation,
    required this.dateModification,
    required this.updatedAt,
  });

  factory ClasseComptable.fromJson(Map<String, dynamic> json) =>
      _$ClasseComptableFromJson(json);

  Map<String, dynamic> toJson() {
    final json = _$ClasseComptableToJson(this);
    // Logique conditionnelle: utiliser serverId si disponible, sinon id
    if (serverId != null) {
      json['id'] = serverId;
    } else {
      json['id'] = id;
    }
    return json;
  }

  /// Convertir une liste de JSON en liste d'objets ClasseComptable
  static List<ClasseComptable> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => ClasseComptable.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Convertir une liste d'objets ClasseComptable en liste de JSON
  static List<Map<String, dynamic>> toJsonList(
    List<ClasseComptable> classesComptables,
  ) {
    return classesComptables.map((classe) => classe.toJson()).toList();
  }

  ClasseComptable copyWith({
    int? id,
    int? serverId,
    bool? isSync,
    String? code,
    String? nom,
    String? libelle,
    String? type,
    int? entrepriseId,
    bool? actif,
    String? document,
    DateTime? dateCreation,
    DateTime? dateModification,
    DateTime? updatedAt,
  }) {
    return ClasseComptable(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      isSync: isSync ?? this.isSync,
      code: code ?? this.code,
      nom: nom ?? this.nom,
      libelle: libelle ?? this.libelle,
      type: type ?? this.type,
      entrepriseId: entrepriseId ?? this.entrepriseId,
      actif: actif ?? this.actif,
      document: document ?? this.document,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
