class Utilisateur {
  final int id;
  final String nom;
  final String motDePasse;

  Utilisateur({required this.id, required this.nom, required this.motDePasse});

  factory Utilisateur.fromMap(Map<String, dynamic> map) {
    return Utilisateur(
      id: map['id'],
      nom: map['nom'],
      motDePasse: map['mot_de_passe'],
    );
  }
}

class AnneeScolaire {
  final int id;
  final String nom;
  final String dateDebut;
  final String dateFin;
  final int entrepriseId;
  final int enCours;

  AnneeScolaire({
    required this.id,
    required this.nom,
    required this.dateDebut,
    required this.dateFin,
    required this.entrepriseId,
    required this.enCours,
  });

  factory AnneeScolaire.fromMap(Map<String, dynamic> map) {
    return AnneeScolaire(
      id: map['id'],
      nom: map['nom'],
      dateDebut: map['date_debut'],
      dateFin: map['date_fin'],
      entrepriseId: map['entreprise_id'],
      enCours: map['en_cours'],
    );
  }
}

class Classe {
  final int id;
  final String nom;
  final int anneeScolaireId;
  final int? enseignantId;
  final String? niveau;
  final int? effectif;
  final String? code;

  Classe({
    required this.id,
    required this.nom,
    required this.anneeScolaireId,
    this.enseignantId,
    this.niveau,
    this.effectif,
    this.code,
  });

  factory Classe.fromMap(Map<String, dynamic> map) {
    return Classe(
      id: map['id'],
      nom: map['nom'],
      anneeScolaireId: map['annee_scolaire_id'],
      enseignantId: map['enseignant_id'],
      niveau: map['niveau'],
      effectif: map['effectif'],
      code: map['code'],
    );
  }
}

class Eleve {
  final int id;
  final String nom;
  final String prenom;
  final String? sexe;
  final String? dateNaissance;
  final String? lieuNaissance;
  final String? numeroPermanent;
  final int? classeId;
  final int? responsableId;
  final String? matricule;
  final String? postnom;
  final String? statut;

  Eleve({
    required this.id,
    required this.nom,
    required this.prenom,
    this.sexe,
    this.dateNaissance,
    this.lieuNaissance,
    this.numeroPermanent,
    this.classeId,
    this.responsableId,
    this.matricule,
    this.postnom,
    this.statut,
  });

  factory Eleve.fromMap(Map<String, dynamic> map) {
    return Eleve(
      id: map['id'],
      nom: map['nom'],
      prenom: map['prenom'],
      sexe: map['sexe'],
      dateNaissance: map['date_naissance'],
      lieuNaissance: map['lieu_naissance'],
      numeroPermanent: map['numero_permanent'],
      classeId: map['classe_id'],
      responsableId: map['responsable_id'],
      matricule: map['matricule'],
      postnom: map['postnom'],
      statut: map['statut'],
    );
  }
}

class FraisScolaire {
  final int id;
  final String nom;
  final double montant;
  final String? dateLimite;
  final int entrepriseId;
  final int anneeScolaireId;
  final String? code;

  FraisScolaire({
    required this.id,
    required this.nom,
    required this.montant,
    this.dateLimite,
    required this.entrepriseId,
    required this.anneeScolaireId,
    this.code,
  });

  factory FraisScolaire.fromMap(Map<String, dynamic> map) {
    return FraisScolaire(
      id: map['id'],
      nom: map['nom'],
      montant: map['montant'] is int
          ? (map['montant'] as int).toDouble()
          : map['montant'],
      dateLimite: map['date_limite'],
      entrepriseId: map['entreprise_id'],
      anneeScolaireId: map['annee_scolaire_id'],
      code: map['code'],
    );
  }
}

class PaiementFrais {
  final int id;
  final int eleveId;
  final int fraisScolaireId;
  final double montantPaye;
  final String datePaiement;
  final double? resteAPayer;
  final String? statut;
  final int? userId;

  PaiementFrais({
    required this.id,
    required this.eleveId,
    required this.fraisScolaireId,
    required this.montantPaye,
    required this.datePaiement,
    this.resteAPayer,
    this.statut,
    this.userId,
  });

  factory PaiementFrais.fromMap(Map<String, dynamic> map) {
    return PaiementFrais(
      id: map['id'],
      eleveId: map['eleve_id'],
      fraisScolaireId: map['frais_scolaire_id'],
      montantPaye: map['montant_paye'] is int
          ? (map['montant_paye'] as int).toDouble()
          : map['montant_paye'],
      datePaiement: map['date_paiement'],
      resteAPayer: map['reste_a_payer'] == null
          ? null
          : (map['reste_a_payer'] is int
                ? (map['reste_a_payer'] as int).toDouble()
                : map['reste_a_payer']),
      statut: map['statut'],
      userId: map['user_id'],
    );
  }
}
