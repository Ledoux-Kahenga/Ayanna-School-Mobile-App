import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';
import 'classe_comptable.dart';
import '../helpers/parse_helper.dart';

part 'compte_comptable.g.dart';

@Entity(
  tableName: 'comptes_comptables',
  indices: [
    // Contrainte d'unicité sur server_id pour éviter les doublons
    // Permet la gestion automatique des conflits
    Index(value: ['server_id'], unique: true),
  ],
  foreignKeys: [
    ForeignKey(
      childColumns: ['classe_comptable_id'],
      parentColumns: ['id'],
      entity: ClasseComptable,
    ),
  ],
)
@JsonSerializable()
class CompteComptable {
  @PrimaryKey(autoGenerate: false)
  @JsonKey(name: 'id', includeToJson: false, includeFromJson: true)
  final int? id;

  @ColumnInfo(name: 'server_id')
  @JsonKey(name: 'id', includeToJson: false, includeFromJson: true)
  int? serverId;

  @ColumnInfo(name: 'is_sync')
  @JsonKey(name: 'is_sync', includeFromJson: false, includeToJson: false)
  bool isSync;

  String numero;
  String nom;
  String libelle;
  @JsonKey(name: 'actif', fromJson: parseBool)
  bool? actif;

  @ColumnInfo(name: 'classe_comptable_id')
  @JsonKey(name: 'classe_comptable_id')
  int classeComptableId;

  @ColumnInfo(name: 'date_creation')
  @JsonKey(name: 'date_creation')
  DateTime dateCreation;

  @ColumnInfo(name: 'date_modification')
  @JsonKey(name: 'date_modification')
  DateTime dateModification;

  @ColumnInfo(name: 'updated_at')
  @JsonKey(name: 'updated_at')
  DateTime updatedAt;

  CompteComptable({
    this.id,
    this.serverId,
    this.isSync = true,
    required this.numero,
    required this.nom,
    required this.libelle,
    this.actif,
    required this.classeComptableId,
    required this.dateCreation,
    required this.dateModification,
    required this.updatedAt,
  });

  factory CompteComptable.fromJson(Map<String, dynamic> json) =>
      _$CompteComptableFromJson(json);

  Map<String, dynamic> toJson() {
    final json = _$CompteComptableToJson(this);
    // Logique conditionnelle: utiliser serverId si disponible, sinon id
    if (serverId != null) {
      json['id'] = serverId;
    } else {
      json['id'] = id;
    }
    return json;
  }

  /// Convertir une liste de JSON en liste d'objets CompteComptable
  static List<CompteComptable> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => CompteComptable.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Convertir une liste d'objets CompteComptable en liste de JSON
  static List<Map<String, dynamic>> toJsonList(
    List<CompteComptable> comptesComptables,
  ) {
    return comptesComptables.map((compte) => compte.toJson()).toList();
  }

  CompteComptable copyWith({
    int? id,
    int? serverId,
    bool? isSync,
    String? numero,
    String? nom,
    String? libelle,
    bool? actif,
    int? classeComptableId,
    DateTime? dateCreation,
    DateTime? dateModification,
    DateTime? updatedAt,
  }) {
    return CompteComptable(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      isSync: isSync ?? this.isSync,
      numero: numero ?? this.numero,
      nom: nom ?? this.nom,
      libelle: libelle ?? this.libelle,
      actif: actif ?? this.actif,
      classeComptableId: classeComptableId ?? this.classeComptableId,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
