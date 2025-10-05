import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';
import 'entreprise.dart';

part 'enseignant.g.dart';

@Entity(
  tableName: 'enseignants',
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
class Enseignant {
  @PrimaryKey(autoGenerate: false)
  @JsonKey(includeToJson: false)
  final int? id;
  @ColumnInfo(name: 'server_id')
  @JsonKey(name: 'id')
  int? serverId;

  @ColumnInfo(name: 'is_sync')
  @JsonKey(name: 'is_sync', includeFromJson: false, includeToJson: false)
  bool isSync;

  String? matricule;
  String nom;
  String prenom;
  String? sexe;
  String? niveau;
  String? discipline;
  String? email;
  String? telephone;

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

  Enseignant({
    this.id,
    this.serverId,
    this.isSync = true,
    this.matricule,
    required this.nom,
    required this.prenom,
    this.sexe,
    this.niveau,
    this.discipline,
    this.email,
    this.telephone,
    required this.entrepriseId,
    required this.dateCreation,
    required this.dateModification,
    required this.updatedAt,
  });

  factory Enseignant.fromJson(Map<String, dynamic> json) =>
      _$EnseignantFromJson(json);
  Map<String, dynamic> toJson() => _$EnseignantToJson(this);

  /// Convertir une liste de JSON en liste d'objets Enseignant
  static List<Enseignant> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => Enseignant.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Convertir une liste d'objets Enseignant en liste de JSON
  static List<Map<String, dynamic>> toJsonList(List<Enseignant> enseignants) {
    return enseignants.map((enseignant) => enseignant.toJson()).toList();
  }

  Enseignant copyWith({
    int? id,
    int? serverId,
    bool? isSync,
    String? matricule,
    String? nom,
    String? prenom,
    String? sexe,
    String? niveau,
    String? discipline,
    String? email,
    String? telephone,
    int? entrepriseId,
    DateTime? dateCreation,
    DateTime? dateModification,
    DateTime? updatedAt,
  }) {
    return Enseignant(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      isSync: isSync ?? this.isSync,
      matricule: matricule ?? this.matricule,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      sexe: sexe ?? this.sexe,
      niveau: niveau ?? this.niveau,
      discipline: discipline ?? this.discipline,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      entrepriseId: entrepriseId ?? this.entrepriseId,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
