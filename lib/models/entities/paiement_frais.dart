import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';
import 'eleve.dart';
import 'frais_scolaire.dart';
import 'utilisateur.dart';

part 'paiement_frais.g.dart';

@Entity(
  tableName: 'paiement_frais',
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
      childColumns: ['frais_scolaire_id'],
      parentColumns: ['id'],
      entity: FraisScolaire,
    ),
    ForeignKey(
      childColumns: ['user_id'],
      parentColumns: ['id'],
      entity: Utilisateur,
    ),
  ],
)
@JsonSerializable()
class PaiementFrais {
  @PrimaryKey(autoGenerate: false)
  @JsonKey(name: 'id', includeToJson: false, includeFromJson: true)
  final int? id;
  @ColumnInfo(name: 'server_id')
  @JsonKey(name: 'id', includeToJson: false, includeFromJson: true)
  int? serverId;

  @ColumnInfo(name: 'is_sync')
  @JsonKey(name: 'is_sync', includeFromJson: false, includeToJson: false)
  bool isSync;

  @ColumnInfo(name: 'eleve_id')
  @JsonKey(name: 'eleve_id')
  int eleveId;

  @ColumnInfo(name: 'frais_scolaire_id')
  @JsonKey(name: 'frais_scolaire_id')
  int fraisScolaireId;

  @ColumnInfo(name: 'montant_paye')
  @JsonKey(name: 'montant_paye')
  double montantPaye;

  @ColumnInfo(name: 'date_paiement')
  @JsonKey(name: 'date_paiement')
  DateTime datePaiement;

  @ColumnInfo(name: 'user_id')
  @JsonKey(name: 'user_id')
  int? userId;

  @ColumnInfo(name: 'reste_a_payer')
  @JsonKey(name: 'reste_a_payer')
  double? resteAPayer;

  String? statut;

  @ColumnInfo(name: 'date_creation')
  @JsonKey(name: 'date_creation')
  DateTime dateCreation;

  @ColumnInfo(name: 'date_modification')
  @JsonKey(name: 'date_modification')
  DateTime dateModification;

  @ColumnInfo(name: 'updated_at')
  @JsonKey(name: 'updated_at')
  DateTime updatedAt;

  PaiementFrais({
    this.id,
    this.serverId,
    this.isSync = true,
    required this.eleveId,
    required this.fraisScolaireId,
    required this.montantPaye,
    required this.datePaiement,
    this.userId,
    this.resteAPayer,
    this.statut,
    required this.dateCreation,
    required this.dateModification,
    required this.updatedAt,
  });

  factory PaiementFrais.fromJson(Map<String, dynamic> json) =>
      _$PaiementFraisFromJson(json);

  Map<String, dynamic> toJson() {
    final json = _$PaiementFraisToJson(this);
    // Logique conditionnelle: utiliser serverId si disponible, sinon id
    if (serverId != null) {
      json['id'] = serverId;
    } else {
      json['id'] = id;
    }
    return json;
  }

  /// Convertir une liste de JSON en liste d'objets PaiementFrais
  static List<PaiementFrais> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => PaiementFrais.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Convertir une liste d'objets PaiementFrais en liste de JSON
  static List<Map<String, dynamic>> toJsonList(List<PaiementFrais> paiements) {
    return paiements.map((paiement) => paiement.toJson()).toList();
  }

  PaiementFrais copyWith({
    final int? id,
    int? serverId,
    bool? isSync,
    int? eleveId,
    int? fraisScolaireId,
    double? montantPaye,
    DateTime? datePaiement,
    int? userId,
    double? resteAPayer,
    String? statut,
    DateTime? dateCreation,
    DateTime? dateModification,
    DateTime? updatedAt,
  }) {
    return PaiementFrais(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      isSync: isSync ?? this.isSync,
      eleveId: eleveId ?? this.eleveId,
      fraisScolaireId: fraisScolaireId ?? this.fraisScolaireId,
      montantPaye: montantPaye ?? this.montantPaye,
      datePaiement: datePaiement ?? this.datePaiement,
      userId: userId ?? this.userId,
      resteAPayer: resteAPayer ?? this.resteAPayer,
      statut: statut ?? this.statut,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
