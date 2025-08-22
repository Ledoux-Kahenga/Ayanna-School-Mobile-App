class JournalComptable {
  final int id;
  final DateTime date;
  final String libelle;
  final double montant;
  final String type; // 'Entrée' ou 'Sortie'

  JournalComptable({
    required this.id,
    required this.date,
    required this.libelle,
    required this.montant,
    required this.type,
  });

  factory JournalComptable.fromMap(Map<String, dynamic> map) {
    return JournalComptable(
      id: map['id'],
      date: DateTime.parse(map['date_operation'] ?? map['date'] ?? ''),
      libelle: map['libelle'],
      montant: map['montant'] is int
          ? (map['montant'] as int).toDouble()
          : map['montant'],
      type: map['type_operation'] ?? map['type'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date_operation': date.toIso8601String(),
      'libelle': libelle,
      'montant': montant,
      'type_operation': type,
    };
  }
}
