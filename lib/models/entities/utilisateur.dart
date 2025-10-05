import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';
import 'entreprise.dart';
import '../helpers/parse_helper.dart';

part 'utilisateur.g.dart';

@Entity(
  tableName: 'utilisateurs',
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
class Utilisateur {
  @PrimaryKey(autoGenerate: false)
  @JsonKey(includeToJson: false)
  final int? id;
  @ColumnInfo(name: 'server_id')
  @JsonKey(name: 'id')
  int? serverId;

  @ColumnInfo(name: 'is_sync')
  @JsonKey(name: 'is_sync', includeFromJson: false, includeToJson: false)
  bool isSync;

  String nom;
  String prenom;
  String email;

  @ColumnInfo(name: 'mot_de_passe_hash')
  @JsonKey(name: 'mot_de_passe_hash')
  String motDePasseHash;

  String role;
  @JsonKey(name: 'actif', fromJson: parseBool)
  bool? actif;

  @ColumnInfo(name: 'entreprise_id')
  @JsonKey(name: 'entreprise_id')
  int entrepriseId;

  @ColumnInfo(name: 'date_creation')
  @JsonKey(name: 'date_creation')
  DateTime dateCreation;

  @ColumnInfo(name: 'date_modification')
  @JsonKey(name: 'date_modification')
  DateTime dateModification;

  @ColumnInfo(name: 'updated_at')
  @JsonKey(name: 'updated_at')
  DateTime updatedAt;

  Utilisateur({
    this.id,
    this.serverId,
    this.isSync = true,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.motDePasseHash,
    required this.role,
    this.actif,
    required this.entrepriseId,
    required this.dateCreation,
    required this.dateModification,
    required this.updatedAt,
  });

  factory Utilisateur.fromJson(Map<String, dynamic> json) =>
      _$UtilisateurFromJson(json);
  Map<String, dynamic> toJson() => _$UtilisateurToJson(this);

  /// Convertir une liste de JSON en liste d'objets Utilisateur
  static List<Utilisateur> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => Utilisateur.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Convertir une liste d'objets Utilisateur en liste de JSON
  static List<Map<String, dynamic>> toJsonList(List<Utilisateur> utilisateurs) {
    return utilisateurs.map((utilisateur) => utilisateur.toJson()).toList();
  }

  Utilisateur copyWith({
    final int? id,
    int? serverId,
    bool? isSync,
    String? nom,
    String? prenom,
    String? email,
    String? motDePasseHash,
    String? role,
    bool? actif,
    int? entrepriseId,
    DateTime? dateCreation,
    DateTime? dateModification,
    DateTime? updatedAt,
  }) {
    return Utilisateur(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      isSync: isSync ?? this.isSync,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      motDePasseHash: motDePasseHash ?? this.motDePasseHash,
      role: role ?? this.role,
      actif: actif ?? this.actif,
      entrepriseId: entrepriseId ?? this.entrepriseId,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
