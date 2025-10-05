import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';
import 'classe.dart';
import 'responsable.dart';

part 'eleve.g.dart';

@Entity(
  tableName: 'eleves',
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
      childColumns: ['responsable_id'],
      parentColumns: ['id'],
      entity: Responsable,
    ),
  ],
)
@JsonSerializable()
class Eleve {
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
  String? postnom;
  String prenom;
  String? sexe;
  String? statut;

  @ColumnInfo(name: 'date_naissance')
  @JsonKey(name: 'date_naissance')
  DateTime? dateNaissance;

  @ColumnInfo(name: 'lieu_naissance')
  @JsonKey(name: 'lieu_naissance')
  String? lieuNaissance;

  String? matricule;

  @ColumnInfo(name: 'numero_permanent')
  @JsonKey(name: 'numero_permanent')
  String? numeroPermanent;

  @ColumnInfo(name: 'classe_id')
  @JsonKey(name: 'classe_id')
  int? classeId;

  @ColumnInfo(name: 'responsable_id')
  @JsonKey(name: 'responsable_id')
  int? responsableId;

  @ColumnInfo(name: 'date_creation')
  @JsonKey(name: 'date_creation')
  DateTime dateCreation;

  @ColumnInfo(name: 'date_modification')
  @JsonKey(name: 'date_modification')
  DateTime dateModification;

  @ColumnInfo(name: 'updated_at')
  @JsonKey(name: 'updated_at')
  DateTime updatedAt;

  Eleve({
    this.id,
    this.serverId,
    this.isSync = true,
    required this.nom,
    this.postnom,
    required this.prenom,
    this.sexe,
    this.statut,
    this.dateNaissance,
    this.lieuNaissance,
    this.matricule,
    this.numeroPermanent,
    this.classeId,
    this.responsableId,
    required this.dateCreation,
    required this.dateModification,
    required this.updatedAt,
  });

  factory Eleve.fromJson(Map<String, dynamic> json) => _$EleveFromJson(json);
  Map<String, dynamic> toJson() => _$EleveToJson(this);

  /// Convertir une liste de JSON en liste d'objets Eleve
  static List<Eleve> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => Eleve.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Convertir une liste d'objets Eleve en liste de JSON
  static List<Map<String, dynamic>> toJsonList(List<Eleve> eleves) {
    return eleves.map((eleve) => eleve.toJson()).toList();
  }

  /// Méthodes utilitaires pour l'affichage
  String get prenomCapitalized => prenom.isEmpty
      ? ''
      : prenom[0].toUpperCase() + prenom.substring(1).toLowerCase();

  String get nomPostnomMaj {
    String result = nom.toUpperCase();
    if (postnom != null && postnom!.isNotEmpty) {
      result += ' ${postnom!.toUpperCase()}';
    }
    return result;
  }

  /// Nom de classe temporaire (sera remplacé par une jointure avec Classe)
  String? get classeNom => null; // À implémenter avec jointure

  /// Nom complet formaté
  String get nomComplet => '$prenomCapitalized $nomPostnomMaj';

  Eleve copyWith({
    int? id,
    int? serverId,
    bool? isSync,
    String? nom,
    String? postnom,
    String? prenom,
    String? sexe,
    String? statut,
    DateTime? dateNaissance,
    String? lieuNaissance,
    String? matricule,
    String? numeroPermanent,
    int? classeId,
    int? responsableId,
    DateTime? dateCreation,
    DateTime? dateModification,
    DateTime? updatedAt,
  }) {
    return Eleve(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      isSync: isSync ?? this.isSync,
      nom: nom ?? this.nom,
      postnom: postnom ?? this.postnom,
      prenom: prenom ?? this.prenom,
      sexe: sexe ?? this.sexe,
      statut: statut ?? this.statut,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      lieuNaissance: lieuNaissance ?? this.lieuNaissance,
      matricule: matricule ?? this.matricule,
      numeroPermanent: numeroPermanent ?? this.numeroPermanent,
      classeId: classeId ?? this.classeId,
      responsableId: responsableId ?? this.responsableId,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
