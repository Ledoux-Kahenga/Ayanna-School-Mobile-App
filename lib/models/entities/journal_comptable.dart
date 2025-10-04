import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';
import 'paiement_frais.dart';
import 'entreprise.dart';

part 'journal_comptable.g.dart';

@Entity(
  tableName: 'journaux_comptables',
    indices: [
    // Contrainte d'unicité sur server_id pour éviter les doublons
    // Permet la gestion automatique des conflits
    Index(value: ['server_id'], unique: true),
  ],
  foreignKeys: [
    ForeignKey(
      childColumns: ['paiement_frais_id'],
      parentColumns: ['id'],
      entity: PaiementFrais,
    ),
    ForeignKey(
      childColumns: ['entreprise_id'],
      parentColumns: ['id'],
      entity: Entreprise,
    ),
  ],
)
@JsonSerializable()
class JournalComptable {
  @PrimaryKey(autoGenerate: true)
  @JsonKey(includeFromJson: false, includeToJson: false)
  final int? id;

  @ColumnInfo(name: 'server_id')
  @JsonKey(name: 'id')
  int? serverId;

  @ColumnInfo(name: 'is_sync')
  @JsonKey(name: 'is_sync', includeFromJson: false, includeToJson: false)
  bool isSync;

  @ColumnInfo(name: 'date_operation')
  @JsonKey(name: 'date_operation')
  DateTime dateOperation;

  String libelle;
  double montant;

  @ColumnInfo(name: 'type_operation')
  @JsonKey(name: 'type_operation')
  String typeOperation;

  @ColumnInfo(name: 'paiement_frais_id')
  @JsonKey(name: 'paiement_frais_id')
  int? paiementFraisId;

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

  JournalComptable({
    this.id,
    this.serverId,
    this.isSync = true,
    required this.dateOperation,
    required this.libelle,
    required this.montant,
    required this.typeOperation,
    this.paiementFraisId,
    required this.entrepriseId,
    required this.dateCreation,
    required this.dateModification,
    required this.updatedAt,
  });

  factory JournalComptable.fromJson(Map<String, dynamic> json) =>
      _$JournalComptableFromJson(json);
  Map<String, dynamic> toJson() => _$JournalComptableToJson(this);

  /// Convertir une liste de JSON en liste d'objets JournalComptable
  static List<JournalComptable> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => JournalComptable.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Convertir une liste d'objets JournalComptable en liste de JSON
  static List<Map<String, dynamic>> toJsonList(
    List<JournalComptable> journaux,
  ) {
    return journaux.map((journal) => journal.toJson()).toList();
  }

  JournalComptable copyWith({
    final int? id,
    int? serverId,
    bool? isSync,
    DateTime? dateOperation,
    String? libelle,
    double? montant,
    String? typeOperation,
    int? paiementFraisId,
    int? entrepriseId,
    DateTime? dateCreation,
    DateTime? dateModification,
    DateTime? updatedAt,
  }) {
    return JournalComptable(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      isSync: isSync ?? this.isSync,
      dateOperation: dateOperation ?? this.dateOperation,
      libelle: libelle ?? this.libelle,
      montant: montant ?? this.montant,
      typeOperation: typeOperation ?? this.typeOperation,
      paiementFraisId: paiementFraisId ?? this.paiementFraisId,
      entrepriseId: entrepriseId ?? this.entrepriseId,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
