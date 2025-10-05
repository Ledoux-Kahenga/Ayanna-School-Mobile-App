import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';
import 'entreprise.dart';
import '../helpers/parse_helper.dart';

part 'licence.g.dart';

@Entity(
  tableName: 'licence',
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
class Licence {
  @PrimaryKey(autoGenerate: false)
  @JsonKey(includeToJson: false)
  final int? id;
  @ColumnInfo(name: 'server_id')
  @JsonKey(name: 'id')
  int? serverId;

  @ColumnInfo(name: 'is_sync')
  @JsonKey(name: 'is_sync', includeFromJson: false, includeToJson: false)
  bool isSync;

  String cle;
  String type;

  @ColumnInfo(name: 'date_activation')
  @JsonKey(name: 'date_activation')
  DateTime dateActivation;

  @ColumnInfo(name: 'date_expiration')
  @JsonKey(name: 'date_expiration')
  DateTime dateExpiration;

  String signature;

  @JsonKey(name: 'actif', fromJson: parseBool)
  bool? active;

  @ColumnInfo(name: 'entreprise_id')
  @JsonKey(name: 'entreprise_id')
  int? entrepriseId;

  @ColumnInfo(name: 'date_creation')
  @JsonKey(name: 'date_creation')
  DateTime dateCreation;

  @ColumnInfo(name: 'date_modification')
  @JsonKey(name: 'date_modification')
  DateTime dateModification;

  @ColumnInfo(name: 'updated_at')
  @JsonKey(name: 'updated_at')
  DateTime updatedAt;

  Licence({
    this.id,
    this.serverId,
    this.isSync = true,
    required this.cle,
    required this.type,
    required this.dateActivation,
    required this.dateExpiration,
    required this.signature,
    this.active,
    this.entrepriseId,
    required this.dateCreation,
    required this.dateModification,
    required this.updatedAt,
  });

  factory Licence.fromJson(Map<String, dynamic> json) =>
      _$LicenceFromJson(json);
  Map<String, dynamic> toJson() => _$LicenceToJson(this);

  /// Convertir une liste de JSON en liste d'objets Licence
  static List<Licence> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => Licence.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Convertir une liste d'objets Licence en liste de JSON
  static List<Map<String, dynamic>> toJsonList(List<Licence> licences) {
    return licences.map((licence) => licence.toJson()).toList();
  }

  Licence copyWith({
    final int? id,
    int? serverId,
    bool? isSync,
    String? cle,
    String? type,
    DateTime? dateActivation,
    DateTime? dateExpiration,
    String? signature,
    bool? active,
    int? entrepriseId,
    DateTime? dateCreation,
    DateTime? dateModification,
    DateTime? updatedAt,
  }) {
    return Licence(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      isSync: isSync ?? this.isSync,
      cle: cle ?? this.cle,
      type: type ?? this.type,
      dateActivation: dateActivation ?? this.dateActivation,
      dateExpiration: dateExpiration ?? this.dateExpiration,
      signature: signature ?? this.signature,
      active: active ?? this.active,
      entrepriseId: entrepriseId ?? this.entrepriseId,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
