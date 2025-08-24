import 'dart:typed_data';

class Entreprise {
  final int id;
  final String nom;
  final String? adresse;
  final String? numeroId;
  final String? devise;
  final String? telephone;
  final String? email;
  final Uint8List? logo; // Pour les données binaires (BLOB)
  final DateTime dateCreation;
  final DateTime dateModification;

  Entreprise({
    required this.id,
    required this.nom,
    this.adresse,
    this.numeroId,
    this.devise,
    this.telephone,
    this.email,
    this.logo,
    required this.dateCreation,
    required this.dateModification,
  });

  // Constructeur pour créer une instance à partir d'une Map (résultat de la base de données)
  factory Entreprise.fromMap(Map<String, dynamic> map) {
    return Entreprise(
      id: map['id'],
      nom: map['nom'],
      adresse: map['adresse'],
      numeroId: map['numero_id'],
      devise: map['devise'],
      telephone: map['telephone'],
      email: map['email'],
      logo: map['logo'],
      dateCreation: DateTime.parse(map['date_creation']),
      dateModification: DateTime.parse(map['date_modification']),
    );
  }
}

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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnneeScolaire && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
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
  /// Returns prenom with first letter uppercase, rest lowercase
  String get prenomCapitalized {
    if (prenom.isEmpty) return '';
    return prenom[0].toUpperCase() + prenom.substring(1).toLowerCase();
  }

  /// Returns NOM and POSTNOM in uppercase, separated by a space
  String get nomPostnomMaj {
    final nomMaj = nom.toUpperCase();
    final postnomMaj = (postnom ?? '').toUpperCase();
    return postnomMaj.isNotEmpty ? '$nomMaj $postnomMaj' : nomMaj;
  }

  /// Returns the formatted name: NOM (uppercase) + Prenom (first letter uppercase, rest lowercase)
  String get formattedNomPrenom {
    final nomMaj = nom.toUpperCase();
    final prenomFormatted = prenom.isNotEmpty
        ? prenom[0].toUpperCase() + prenom.substring(1).toLowerCase()
        : '';
    return '$nomMaj $prenomFormatted';
  }

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
  final String? classeNom;
  // Ajout des champs responsable
  final String? responsableNom;
  final String? responsableTelephone;
  // final String? responsableEmail; // Removed: not present in DB schema
  final String? responsableAdresse;

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
    this.classeNom,
    this.responsableNom,
    this.responsableTelephone,
    // this.responsableEmail, // Removed: not present in DB schema
    this.responsableAdresse,
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
      classeNom: map['classe_nom'],
      responsableNom: map['responsable_nom'],
      responsableTelephone: map['responsable_telephone'],
      // responsableEmail: map['responsable_email'], // Removed: not present in DB schema
      responsableAdresse: map['responsable_adresse'],
    );
  }
}

// NOUVEAU : Le modèle Responsable que vous avez fourni
class Responsable {
  final int id;
  final String nom;
  final String? telephone;
  final String? code;
  final String? adresse;

  Responsable({
    required this.id,
    required this.nom,
    this.telephone,
    this.code,
    this.adresse,
  });

  factory Responsable.fromMap(Map<String, dynamic> map) {
    return Responsable(
      id: map['id'],
      nom: map['nom'],
      telephone: map['telephone'],
      code: map['code'],
      adresse: map['adresse'],
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

class EleveFraisDetails {
  final Eleve eleve;
  final List<FraisDetails> fraisDetails;

  EleveFraisDetails({required this.eleve, required this.fraisDetails});
}

class FraisDetails {
  final FraisScolaire frais;
  final double montantPaye;
  final double resteAPayer;
  final List<PaiementFrais> historiquePaiements;
  final String statut; // 'en_ordre', 'pas_en_ordre', 'partiellement_paye'

  bool showRecu = false;

  FraisDetails({
    required this.frais,
    required this.montantPaye,
    required this.resteAPayer,
    required this.historiquePaiements,
    required this.statut,
    this.showRecu = false,
  });

  bool get isEnOrdre => resteAPayer <= 0;
  bool get isPartiellementPaye => montantPaye > 0 && resteAPayer > 0;
}

// [MODIFICATION START] - ADDED a new class for the cash journal

class JournalComptable {
  final int id;
  final DateTime dateOperation;
  final String libelle;
  final double montant;
  final String typeOperation; // 'Entrée' or 'Sortie'
  final int? paiementFraisId;
  final int entrepriseId;

  JournalComptable({
    required this.id,
    required this.dateOperation,
    required this.libelle,
    required this.montant,
    required this.typeOperation,
    this.paiementFraisId,
    required this.entrepriseId,
  });

  factory JournalComptable.fromMap(Map<String, dynamic> map) {
    return JournalComptable(
      id: map['id'],
      // SQLite stores DATETIME as TEXT, so it needs to be parsed.
      dateOperation: DateTime.parse(map['date_operation']),
      libelle: map['libelle'],
      montant: map['montant'] is int
          ? (map['montant'] as int).toDouble()
          : map['montant'],
      typeOperation: map['type_operation'],
      paiementFraisId: map['paiement_frais_id'],
      entrepriseId: map['entreprise_id'],
    );
  }
}
// [MODIFICATION END]
