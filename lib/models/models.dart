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
  final DateTime? updatedAt;

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
    this.updatedAt,
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
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }
}

class Utilisateur {
  final int id;
  final String nom;
  final String motDePasse;
  final DateTime? dateCreation;
  final DateTime? updatedAt;

  Utilisateur({
    required this.id,
    required this.nom,
    required this.motDePasse,
    this.dateCreation,
    this.updatedAt,
  });

  factory Utilisateur.fromMap(Map<String, dynamic> map) {
    return Utilisateur(
      id: map['id'],
      nom: map['nom'],
      motDePasse: map['mot_de_passe'],
      dateCreation: map['date_creation'] != null
          ? DateTime.parse(map['date_creation'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
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
  final DateTime? dateCreation;
  final DateTime? updatedAt;

  AnneeScolaire({
    required this.id,
    required this.nom,
    required this.dateDebut,
    required this.dateFin,
    required this.entrepriseId,
    required this.enCours,
    this.dateCreation,
    this.updatedAt,
  });

  factory AnneeScolaire.fromMap(Map<String, dynamic> map) {
    return AnneeScolaire(
      id: map['id'],
      nom: map['nom'],
      dateDebut: map['date_debut'],
      dateFin: map['date_fin'],
      entrepriseId: map['entreprise_id'],
      enCours: map['en_cours'],
      dateCreation: map['date_creation'] != null
          ? DateTime.parse(map['date_creation'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
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
  final DateTime? dateCreation;
  final DateTime? updatedAt;

  Classe({
    required this.id,
    required this.nom,
    required this.anneeScolaireId,
    this.enseignantId,
    this.niveau,
    this.effectif,
    this.code,
    this.dateCreation,
    this.updatedAt,
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
      dateCreation: map['date_creation'] != null
          ? DateTime.parse(map['date_creation'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
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
  final String? responsableAdresse;
  final DateTime? dateCreation;
  final DateTime? updatedAt;

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
    this.responsableAdresse,
    this.dateCreation,
    this.updatedAt,
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
      responsableAdresse: map['responsable_adresse'],
      dateCreation: map['date_creation'] != null
          ? DateTime.parse(map['date_creation'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }
}

class Responsable {
  final int id;
  final String nom;
  final String? telephone;
  final String? code;
  final String? adresse;
  final DateTime? dateCreation;
  final DateTime? updatedAt;

  Responsable({
    required this.id,
    required this.nom,
    this.telephone,
    this.code,
    this.adresse,
    this.dateCreation,
    this.updatedAt,
  });

  factory Responsable.fromMap(Map<String, dynamic> map) {
    return Responsable(
      id: map['id'],
      nom: map['nom'] ?? '', // Ajout de la valeur par défaut ''
      telephone: map['telephone'],
      code: map['code'],
      adresse: map['adresse'],
      dateCreation: map['date_creation'] != null
          ? DateTime.parse(map['date_creation'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
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
  final DateTime? dateCreation;
  final DateTime? updatedAt;

  FraisScolaire({
    required this.id,
    required this.nom,
    required this.montant,
    this.dateLimite,
    required this.entrepriseId,
    required this.anneeScolaireId,
    this.code,
    this.dateCreation,
    this.updatedAt,
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
      dateCreation: map['date_creation'] != null
          ? DateTime.parse(map['date_creation'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
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
  final DateTime? dateCreation;
  final DateTime? updatedAt;

  PaiementFrais({
    required this.id,
    required this.eleveId,
    required this.fraisScolaireId,
    required this.montantPaye,
    required this.datePaiement,
    this.resteAPayer,
    this.statut,
    this.userId,
    this.dateCreation,
    this.updatedAt,
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
      dateCreation: map['date_creation'] != null
          ? DateTime.parse(map['date_creation'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
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

class JournalComptable {
  final int id;
  final DateTime dateOperation;
  final String libelle;
  final double montant;
  final String typeOperation; // 'Entrée' or 'Sortie'
  final int? paiementFraisId;
  final int entrepriseId;
  final DateTime? dateCreation;
  final DateTime? updatedAt;

  JournalComptable({
    required this.id,
    required this.dateOperation,
    required this.libelle,
    required this.montant,
    required this.typeOperation,
    this.paiementFraisId,
    required this.entrepriseId,
    this.dateCreation,
    this.updatedAt,
  });

  factory JournalComptable.fromMap(Map<String, dynamic> map) {
    return JournalComptable(
      id: map['id'],
      dateOperation: DateTime.parse(map['date_operation']),
      libelle: map['libelle'],
      montant: map['montant'] is int
          ? (map['montant'] as int).toDouble()
          : map['montant'],
      typeOperation: map['type_operation'],
      paiementFraisId: map['paiement_frais_id'],
      entrepriseId: map['entreprise_id'],
      dateCreation: map['date_creation'] != null
          ? DateTime.parse(map['date_creation'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }
}

class ComptesConfig {
  final int id;
  final int entrepriseId;
  final int compteCaisseId;
  final int compteFraisId;
  final int compteClientId;
  final DateTime? dateCreation;
  final DateTime? updatedAt;

  ComptesConfig({
    required this.id,
    required this.entrepriseId,
    required this.compteCaisseId,
    required this.compteFraisId,
    required this.compteClientId,
    this.dateCreation,
    this.updatedAt,
  });

  factory ComptesConfig.fromMap(Map<String, dynamic> map) {
    return ComptesConfig(
      id: map['id'],
      entrepriseId: map['entreprise_id'],
      compteCaisseId: map['compte_caisse_id'],
      compteFraisId: map['compte_frais_id'],
      compteClientId: map['compte_client_id'],
      dateCreation: map['date_creation'] != null
          ? DateTime.parse(map['date_creation'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }
}

// [NOUVEAU] Modèle pour les comptes comptables
class CompteComptable {
  final int id;
  final String numero;
  final String nom;
  final String libelle;
  final int classeComptableId;
  final DateTime? dateCreation;
  final DateTime? updatedAt;

  CompteComptable({
    required this.id,
    required this.numero,
    required this.nom,
    required this.libelle,
    required this.classeComptableId,
    this.dateCreation,
    this.updatedAt,
  });

  factory CompteComptable.fromMap(Map<String, dynamic> map) {
    return CompteComptable(
      id: map['id'],
      numero: map['numero'],
      nom: map['nom'],
      libelle: map['libelle'],
      classeComptableId: map['classe_comptable_id'],
      dateCreation: map['date_creation'] != null
          ? DateTime.parse(map['date_creation'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }
}

// [NOUVEAU] Modèle pour les dépenses
class Depense {
  final int id;
  final String libelle;
  final double montant;
  final DateTime dateDepense;
  final int entrepriseId;
  final String? piece;
  final String? observation;
  final int? journalId;
  final int? userId;
  final DateTime? dateCreation;
  final DateTime? updatedAt;

  Depense({
    required this.id,
    required this.libelle,
    required this.montant,
    required this.dateDepense,
    required this.entrepriseId,
    this.piece,
    this.observation,
    this.journalId,
    this.userId,
    this.dateCreation,
    this.updatedAt,
  });

  factory Depense.fromMap(Map<String, dynamic> map) {
    return Depense(
      id: map['id'],
      libelle: map['libelle'],
      montant: (map['montant'] as num).toDouble(),
      dateDepense: DateTime.parse(map['date_depense']),
      entrepriseId: map['entreprise_id'],
      piece: map['piece'],
      observation: map['observation'],
      journalId: map['journal_id'],
      userId: map['user_id'],
      dateCreation: map['date_creation'] != null
          ? DateTime.parse(map['date_creation'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }
}

// [NOUVEAU] Modèle pour les écritures comptables
class EcritureComptable {
  final int id;
  final int journalId;
  final int compteComptableId;
  final double? debit;
  final double? credit;
  final int ordre;
  final DateTime dateEcriture;
  final String? libelle;
  final String? reference;
  final DateTime? dateCreation;
  final DateTime? dateModification;
  final DateTime? updatedAt;

  EcritureComptable({
    required this.id,
    required this.journalId,
    required this.compteComptableId,
    this.debit,
    this.credit,
    required this.ordre,
    required this.dateEcriture,
    this.libelle,
    this.reference,
    this.dateCreation,
    this.dateModification,
    this.updatedAt,
  });

  factory EcritureComptable.fromMap(Map<String, dynamic> map) {
    return EcritureComptable(
      id: map['id'],
      journalId: map['journal_id'],
      compteComptableId: map['compte_comptable_id'],
      debit: map['debit'] != null ? (map['debit'] as num).toDouble() : null,
      credit: map['credit'] != null ? (map['credit'] as num).toDouble() : null,
      ordre: map['ordre'],
      dateEcriture: DateTime.parse(map['date_ecriture']),
      libelle: map['libelle'],
      reference: map['reference'],
      dateCreation: map['date_creation'] != null
          ? DateTime.parse(map['date_creation'])
          : null,
      dateModification: map['date_modification'] != null
          ? DateTime.parse(map['date_modification'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'journal_id': journalId,
      'compte_comptable_id': compteComptableId,
      'debit': debit,
      'credit': credit,
      'ordre': ordre,
      'date_ecriture': dateEcriture.toIso8601String(),
      'libelle': libelle,
      'reference': reference,
      'date_creation': dateCreation?.toIso8601String(),
      'date_modification': dateModification?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

// Modèles pour la synchronisation
class SyncMetadata {
  final int id;
  final String key;
  final String? value;
  final DateTime? updatedAt;

  SyncMetadata({
    required this.id,
    required this.key,
    this.value,
    this.updatedAt,
  });

  factory SyncMetadata.fromMap(Map<String, dynamic> map) {
    return SyncMetadata(
      id: map['id'] as int,
      key: map['key'] as String,
      value: map['value'] as String?,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'key': key,
      'value': value,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class LocalAction {
  final int id;
  final String tableName;
  final int recordId;
  final String actionType; // 'CREATE', 'UPDATE', 'DELETE'
  final DateTime updatedAt;
  final Map<String, dynamic>? data;

  LocalAction({
    required this.id,
    required this.tableName,
    required this.recordId,
    required this.actionType,
    required this.updatedAt,
    this.data,
  });

  factory LocalAction.fromMap(Map<String, dynamic> map) {
    return LocalAction(
      id: map['id'] as int,
      tableName: map['table_name'] as String,
      recordId: map['record_id'] as int,
      actionType: map['action_type'] as String,
      updatedAt: DateTime.parse(map['updated_at'] as String),
      data: map['data'] != null
          ? Map<String, dynamic>.from(map['data'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'table_name': tableName,
      'record_id': recordId,
      'action_type': actionType,
      'updated_at': updatedAt.toIso8601String(),
      'data': data,
    };
  }
}
