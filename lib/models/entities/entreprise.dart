import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';
import '../converters/datetime_converter.dart';

part 'entreprise.g.dart';

@Entity(
  tableName: 'entreprises',
  indices: [
    // Contrainte d'unicité sur server_id pour éviter les doublons
    // Permet la gestion automatique des conflits
    Index(value: ['server_id'], unique: true),
  ],
)
@JsonSerializable()
class Entreprise {
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
  String? adresse;

  @ColumnInfo(name: 'numero_id')
  @JsonKey(name: 'numero_id')
  String? numeroId;

  String? devise;
  String? telephone;
  String? email;
  String? logo; // Changed from BLOB to String for base64
  String timezone;

  @ColumnInfo(name: 'date_creation')
  @JsonKey(name: 'date_creation')
  @TypeConverters([DateTimeConverter])
  DateTime dateCreation;

  @ColumnInfo(name: 'date_modification')
  @JsonKey(name: 'date_modification')
  @TypeConverters([DateTimeConverter])
  DateTime dateModification;

  @ColumnInfo(name: 'updated_at')
  @JsonKey(name: 'updated_at')
  @TypeConverters([DateTimeConverter])
  DateTime updatedAt;

  Entreprise({
    this.id,
    this.serverId,
    this.isSync = true,
    required this.nom,
    this.adresse,
    this.numeroId,
    this.devise,
    this.telephone,
    this.email,
    this.logo,
    required this.timezone,
    required this.dateCreation,
    required this.dateModification,
    required this.updatedAt,
  });

  factory Entreprise.fromJson(Map<String, dynamic> json) =>
      _$EntrepriseFromJson(json);

  Map<String, dynamic> toJson() {
    final json = _$EntrepriseToJson(this);
    // Logique conditionnelle: utiliser serverId si disponible, sinon id
    if (serverId != null) {
      json['id'] = serverId;
    } else {
      json['id'] = id;
    }
    return json;
  }

  /// Convertir une liste de JSON en liste d'objets Entreprise
  static List<Entreprise> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => Entreprise.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Convertir une liste d'objets Entreprise en liste de JSON
  static List<Map<String, dynamic>> toJsonList(List<Entreprise> entreprises) {
    return entreprises.map((entreprise) => entreprise.toJson()).toList();
  }

  Entreprise copyWith({
    int? id,
    int? serverId,
    bool? isSync,
    String? nom,
    String? adresse,
    String? numeroId,
    String? devise,
    String? telephone,
    String? email,
    String? logo,
    String? timezone,
    DateTime? dateCreation,
    DateTime? dateModification,
    DateTime? updatedAt,
  }) {
    return Entreprise(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      isSync: isSync ?? this.isSync,
      nom: nom ?? this.nom,
      adresse: adresse ?? this.adresse,
      numeroId: numeroId ?? this.numeroId,
      devise: devise ?? this.devise,
      telephone: telephone ?? this.telephone,
      email: email ?? this.email,
      logo: logo ?? this.logo,
      timezone: timezone ?? this.timezone,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
