import 'entities/paiement_frais.dart';

/// Classe pour stocker les détails des frais d'un élève
class FraisDetails {
  final int fraisId;
  final String nomFrais;
  final double montant;
  final double totalPaye;
  final double restePayer;
  final String statut;
  final List<PaiementFrais> historiquePaiements;
  bool showRecu;

  FraisDetails({
    required this.fraisId,
    required this.nomFrais,
    required this.montant,
    required this.totalPaye,
    required this.restePayer,
    required this.statut,
    this.historiquePaiements = const [],
    this.showRecu = false,
  });

  // Getters pour compatibilité avec l'ancien code
  double get montantPaye => totalPaye;
  double get resteAPayer => restePayer;

  // Propriété frais pour compatibilité
  FraisInfo get frais => FraisInfo(id: fraisId, nom: nomFrais);

  // Getters pour déterminer le statut
  bool get isEnOrdre => restePayer <= 0;
  bool get isPartiellementPaye => totalPaye > 0 && restePayer > 0;

  factory FraisDetails.fromMap(Map<String, dynamic> map) {
    return FraisDetails(
      fraisId: map['frais_id'] ?? 0,
      nomFrais: map['nom_frais'] ?? '',
      montant: (map['montant'] ?? 0.0).toDouble(),
      totalPaye: (map['total_paye'] ?? 0.0).toDouble(),
      restePayer: (map['reste_payer'] ?? 0.0).toDouble(),
      statut: map['statut'] ?? '',
      historiquePaiements: const [],
    );
  }
}

/// Classe simple pour la compatibilité avec l'ancien code
class FraisInfo {
  final int id;
  final String nom;

  FraisInfo({required this.id, required this.nom});

  // Getter pour compatibilité - retourne 0 par défaut car nous n'avons pas cette info
  double get montant => 0.0;
}
