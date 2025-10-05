import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';
import 'journal_comptable.dart';
import 'compte_comptable.dart';

part 'ecriture_comptable.g.dart';

@Entity(
  tableName: 'ecritures_comptables',
  indices: [
    // Contrainte d'unicité sur server_id pour éviter les doublons
    // Permet la gestion automatique des conflits
    Index(value: ['server_id'], unique: true),
  ],
  foreignKeys: [
    ForeignKey(
      childColumns: ['journal_id'],
      parentColumns: ['id'],
      entity: JournalComptable,
    ),
    ForeignKey(
      childColumns: ['compte_comptable_id'],
      parentColumns: ['id'],
      entity: CompteComptable,
    ),
  ],
)
@JsonSerializable()
class EcritureComptable {
  @PrimaryKey(autoGenerate: false)
  @JsonKey(name: 'id', includeToJson: false, includeFromJson: true)
  final int? id;
  @ColumnInfo(name: 'server_id')
  @JsonKey(name: 'id', includeToJson: false, includeFromJson: true)
  int? serverId;

  @ColumnInfo(name: 'is_sync')
  @JsonKey(name: 'is_sync', includeFromJson: false, includeToJson: false)
  bool isSync;

  @ColumnInfo(name: 'journal_id')
  @JsonKey(name: 'journal_id')
  int journalId;

  @ColumnInfo(name: 'compte_comptable_id')
  @JsonKey(name: 'compte_comptable_id')
  int compteComptableId;

  double? debit;
  double? credit;
  int ordre;

  @ColumnInfo(name: 'date_ecriture')
  @JsonKey(name: 'date_ecriture')
  DateTime dateEcriture;

  String? libelle;
  String? reference;

  @ColumnInfo(name: 'date_creation')
  @JsonKey(name: 'date_creation')
  DateTime dateCreation;

  @ColumnInfo(name: 'date_modification')
  @JsonKey(name: 'date_modification')
  DateTime dateModification;

  @ColumnInfo(name: 'updated_at')
  @JsonKey(name: 'updated_at')
  DateTime updatedAt;

  EcritureComptable({
    this.id,
    this.serverId,
    this.isSync = true,
    required this.journalId,
    required this.compteComptableId,
    this.debit,
    this.credit,
    required this.ordre,
    required this.dateEcriture,
    this.libelle,
    this.reference,
    required this.dateCreation,
    required this.dateModification,
    required this.updatedAt,
  });

  factory EcritureComptable.fromJson(Map<String, dynamic> json) =>
      _$EcritureComptableFromJson(json);
  
  Map<String, dynamic> toJson() {
    final json = _$EcritureComptableToJson(this);
    // Logique conditionnelle: utiliser serverId si disponible, sinon id
    if (serverId != null) {
      json['id'] = serverId;
    } else {
      json['id'] = id;
    }
    return json;
  }

  /// Convertir une liste de JSON en liste d'objets EcritureComptable
  static List<EcritureComptable> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => EcritureComptable.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Convertir une liste d'objets EcritureComptable en liste de JSON
  static List<Map<String, dynamic>> toJsonList(
    List<EcritureComptable> ecritures,
  ) {
    return ecritures.map((ecriture) => ecriture.toJson()).toList();
  }

  EcritureComptable copyWith({
    int? id,
    int? serverId,
    bool? isSync,
    int? journalId,
    int? compteComptableId,
    double? debit,
    double? credit,
    int? ordre,
    DateTime? dateEcriture,
    String? libelle,
    String? reference,
    DateTime? dateCreation,
    DateTime? dateModification,
    DateTime? updatedAt,
  }) {
    return EcritureComptable(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      isSync: isSync ?? this.isSync,
      journalId: journalId ?? this.journalId,
      compteComptableId: compteComptableId ?? this.compteComptableId,
      debit: debit ?? this.debit,
      credit: credit ?? this.credit,
      ordre: ordre ?? this.ordre,
      dateEcriture: dateEcriture ?? this.dateEcriture,
      libelle: libelle ?? this.libelle,
      reference: reference ?? this.reference,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
