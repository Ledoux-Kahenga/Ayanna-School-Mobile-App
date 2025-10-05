import 'package:floor/floor.dart';
import 'package:json_annotation/json_annotation.dart';
import 'entreprise.dart';
import 'journal_comptable.dart';
import 'utilisateur.dart';

part 'depense.g.dart';

@Entity(
  tableName: 'depenses',
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
    ForeignKey(
      childColumns: ['journal_id'],
      parentColumns: ['id'],
      entity: JournalComptable,
    ),
    ForeignKey(
      childColumns: ['user_id'],
      parentColumns: ['id'],
      entity: Utilisateur,
    ),
  ],
)
@JsonSerializable()
class Depense {
  @PrimaryKey(autoGenerate: false)
  @JsonKey(includeToJson: false)
  final int? id;
  @ColumnInfo(name: 'server_id')
  @JsonKey(name: 'id')
  int? serverId;

  @ColumnInfo(name: 'is_sync')
  @JsonKey(name: 'is_sync', includeFromJson: false, includeToJson: false)
  bool isSync;

  String libelle;
  double montant;

  @ColumnInfo(name: 'date_depense')
  @JsonKey(name: 'date_depense')
  DateTime dateDepense;

  @ColumnInfo(name: 'entreprise_id')
  @JsonKey(name: 'entreprise_id')
  int entrepriseId;

  String? observation;

  @ColumnInfo(name: 'journal_id')
  @JsonKey(name: 'journal_id')
  int? journalId;

  @ColumnInfo(name: 'user_id')
  @JsonKey(name: 'user_id')
  int? userId;

  @ColumnInfo(name: 'date_creation')
  @JsonKey(name: 'date_creation')
  DateTime dateCreation;

  @ColumnInfo(name: 'date_modification')
  @JsonKey(name: 'date_modification')
  DateTime dateModification;

  @ColumnInfo(name: 'updated_at')
  @JsonKey(name: 'updated_at')
  DateTime updatedAt;

  Depense({
    this.id,
    this.serverId,
    this.isSync = true,
    required this.libelle,
    required this.montant,
    required this.dateDepense,
    required this.entrepriseId,
    this.observation,
    this.journalId,
    this.userId,
    required this.dateCreation,
    required this.dateModification,
    required this.updatedAt,
  });

  factory Depense.fromJson(Map<String, dynamic> json) =>
      _$DepenseFromJson(json);
  Map<String, dynamic> toJson() => _$DepenseToJson(this);

  /// Convertir une liste de JSON en liste d'objets Depense
  static List<Depense> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => Depense.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Convertir une liste d'objets Depense en liste de JSON
  static List<Map<String, dynamic>> toJsonList(List<Depense> depenses) {
    return depenses.map((depense) => depense.toJson()).toList();
  }

  Depense copyWith({
    int? id,
    int? serverId,
    bool? isSync,
    String? libelle,
    double? montant,
    DateTime? dateDepense,
    int? entrepriseId,
    String? observation,
    int? journalId,
    int? userId,
    DateTime? dateCreation,
    DateTime? dateModification,
    DateTime? updatedAt,
  }) {
    return Depense(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      isSync: isSync ?? this.isSync,
      libelle: libelle ?? this.libelle,
      montant: montant ?? this.montant,
      dateDepense: dateDepense ?? this.dateDepense,
      entrepriseId: entrepriseId ?? this.entrepriseId,
      observation: observation ?? this.observation,
      journalId: journalId ?? this.journalId,
      userId: userId ?? this.userId,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
