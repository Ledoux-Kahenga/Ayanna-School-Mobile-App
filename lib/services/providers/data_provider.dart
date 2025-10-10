import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/entities/eleve.dart';
import '../../models/entities/classe.dart';
import '../../models/entities/enseignant.dart';
import '../../models/entities/responsable.dart';
import '../../models/entities/utilisateur.dart';
import '../../models/entities/annee_scolaire.dart';
import '../../models/entities/frais_scolaire.dart';
import '../../models/entities/paiement_frais.dart';
import '../../models/entities/note_periode.dart';
import '../../models/entities/cours.dart';
import '../../models/entities/creance.dart';
import '../../models/entities/entreprise.dart';
import '../../models/entities/licence.dart';
import '../../models/entities/config_ecole.dart';
import '../../models/entities/periodes_classes.dart';
import '../../models/entities/depense.dart';
import '../../models/entities/classe_comptable.dart';
import '../../models/entities/compte_comptable.dart';
import '../../models/entities/comptes_config.dart';
import '../../models/entities/ecriture_comptable.dart';
import '../../models/entities/journal_comptable.dart';
import '../../models/entities/periode.dart';
import '../../models/entities/frais_classes.dart';
import '../../models/frais_details.dart';
import 'database_provider.dart';
import 'connectivity_provider.dart';
import 'sync_provider_new.dart';
import 'auth_provider.dart';

part 'data_provider.g.dart';

/// Provider pour la liste des élèves
@riverpod
class ElevesNotifier extends _$ElevesNotifier {
  @override
  Future<List<Eleve>> build() async {
    final dao = ref.watch(eleveDaoProvider);
    return await dao.getAllEleves();
  }

  /// Rafraîchir les données depuis l'API
  Future<void> refresh(List<Eleve> eleves) async {
    final dao = ref.watch(eleveDaoProvider);

    try {
      // Mettre à jour la base de données locale
      await dao.insertEleves(eleves);
      // Rafraîchir le provider
      ref.invalidateSelf();
    } catch (e) {
      // En cas d'erreur API, garder les données locales
      print('Erreur lors du rafraîchissement des élèves: $e');
    }
  }

  /// Ajouter un nouvel élève
  Future<void> addEleve(Eleve eleve) async {
    final dao = ref.watch(eleveDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    // Toujours sauvegarder localement d'abord avec isSync = false
    eleve.isSync = false;
    await dao.insertEleve(eleve);
    ref.invalidateSelf();

    // Si connecté, essayer de synchroniser via l'API
    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          eleve,
          'eleves',
          'create',
          userEmail:
              'admin@testschool.com', // Remplacer par l'email de l'utilisateur connecté
        );
      } catch (e) {
        print('Erreur lors de l\'upload de l\'élève: $e');
        // L'entité reste avec isSync = false pour être synchronisée plus tard
      }
    }
  }

  /// Mettre à jour un élève
  Future<void> updateEleve(Eleve eleve) async {
    final dao = ref.watch(eleveDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    // Toujours sauvegarder localement d'abord avec isSync = false
    eleve.isSync = false;
    await dao.updateEleve(eleve);
    ref.invalidateSelf();

    // Si connecté, essayer de synchroniser via l'API
    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          eleve,
          'eleves',
          'update',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de la mise à jour de l\'élève: $e');
      }
    }
  }

  /// Supprimer un élève
  Future<void> deleteEleve(Eleve eleve) async {
    final dao = ref.watch(eleveDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    // Si connecté, essayer de supprimer via l'API d'abord
    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          eleve,
          'eleves',
          'delete',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de la suppression de l\'élève via API: $e');
      }
    }

    // Supprimer localement
    await dao.deleteEleve(eleve);
    ref.invalidateSelf();
  }
}

/// Provider pour la liste des classes
@riverpod
class ClassesNotifier extends _$ClassesNotifier {
  @override
  Future<List<Classe>> build() async {
    final dao = ref.watch(classeDaoProvider);
    return await dao.getAllClasses();
  }

  /// Rafraîchir les données depuis l'API
  Future<void> refresh(List<Classe> classes) async {
    final dao = ref.watch(classeDaoProvider);

    try {
      await dao.insertClasses(classes);
      ref.invalidateSelf();
    } catch (e) {
      print('Erreur lors du rafraîchissement des classes: $e');
    }
  }

  /// Ajouter une nouvelle classe
  Future<void> addClasse(Classe classe) async {
    final dao = ref.watch(classeDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    // Toujours sauvegarder localement d'abord avec isSync = false
    classe.isSync = false;
    await dao.insertClasse(classe);
    ref.invalidateSelf();

    // Si connecté, essayer de synchroniser via l'API
    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          classe,
          'classes',
          'create',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de l\'upload de la classe: $e');
      }
    }
  }

  /// Mettre à jour une classe
  Future<void> updateClasse(Classe classe) async {
    final dao = ref.watch(classeDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    // Toujours sauvegarder localement d'abord avec isSync = false
    classe.isSync = false;
    await dao.updateClasse(classe);
    ref.invalidateSelf();

    // Si connecté, essayer de synchroniser via l'API
    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          classe,
          'classes',
          'update',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de la mise à jour de la classe: $e');
      }
    }
  }

  /// Supprimer une classe
  Future<void> deleteClasse(Classe classe) async {
    final dao = ref.watch(classeDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    // Si connecté, essayer de supprimer via l'API d'abord
    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          classe,
          'classes',
          'delete',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de la suppression de la classe via API: $e');
      }
    }

    // Supprimer localement
    await dao.deleteClasse(classe);
    ref.invalidateSelf();
  }
}

/// Provider pour la liste des enseignants
@riverpod
class EnseignantsNotifier extends _$EnseignantsNotifier {
  @override
  Future<List<Enseignant>> build() async {
    final dao = ref.watch(enseignantDaoProvider);
    return await dao.getAllEnseignants();
  }

  /// Rafraîchir les données depuis l'API
  Future<void> refresh(List<Enseignant> enseignants) async {
    final dao = ref.watch(enseignantDaoProvider);

    try {
      await dao.insertEnseignants(enseignants);
      ref.invalidateSelf();
    } catch (e) {
      print('Erreur lors du rafraîchissement des enseignants: $e');
    }
  }

  /// Ajouter un nouvel enseignant
  Future<void> addEnseignant(Enseignant enseignant) async {
    final dao = ref.watch(enseignantDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    // Toujours sauvegarder localement d'abord avec isSync = false
    enseignant.isSync = false;
    await dao.insertEnseignant(enseignant);
    ref.invalidateSelf();

    // Si connecté, essayer de synchroniser via l'API
    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          enseignant,
          'enseignants',
          'create',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de l\'upload de l\'enseignant: $e');
      }
    }
  }

  /// Mettre à jour un enseignant
  Future<void> updateEnseignant(Enseignant enseignant) async {
    final dao = ref.watch(enseignantDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    // Toujours sauvegarder localement d'abord avec isSync = false
    enseignant.isSync = false;
    await dao.updateEnseignant(enseignant);
    ref.invalidateSelf();

    // Si connecté, essayer de synchroniser via l'API
    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          enseignant,
          'enseignants',
          'update',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de la mise à jour de l\'enseignant: $e');
      }
    }
  }

  /// Supprimer un enseignant
  Future<void> deleteEnseignant(Enseignant enseignant) async {
    final dao = ref.watch(enseignantDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    // Si connecté, essayer de supprimer via l'API d'abord
    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          enseignant,
          'enseignants',
          'delete',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de la suppression de l\'enseignant via API: $e');
      }
    }

    // Supprimer localement
    await dao.deleteEnseignant(enseignant);
    ref.invalidateSelf();
  }
}

/// Provider pour la liste des responsables
@riverpod
class ResponsablesNotifier extends _$ResponsablesNotifier {
  @override
  Future<List<Responsable>> build() async {
    final dao = ref.watch(responsableDaoProvider);
    return await dao.getAllResponsables();
  }

  Future<void> refresh(List<Responsable> responsables) async {
    final dao = ref.watch(responsableDaoProvider);
    try {
      await dao.insertResponsables(responsables);
      ref.invalidateSelf();
    } catch (e) {
      print('Erreur lors du rafraîchissement des responsables: $e');
    }
  }

  Future<void> addResponsable(Responsable responsable) async {
    final dao = ref.watch(responsableDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    responsable.isSync = false;
    await dao.insertResponsable(responsable);
    ref.invalidateSelf();

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          responsable,
          'responsables',
          'create',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de l\'upload du responsable: $e');
      }
    }
  }

  Future<void> updateResponsable(Responsable responsable) async {
    final dao = ref.watch(responsableDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    responsable.isSync = false;
    await dao.updateResponsable(responsable);
    ref.invalidateSelf();

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          responsable,
          'responsables',
          'update',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de la mise à jour du responsable: $e');
      }
    }
  }

  Future<void> deleteResponsable(Responsable responsable) async {
    final dao = ref.watch(responsableDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          responsable,
          'responsables',
          'delete',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de la suppression du responsable via API: $e');
      }
    }

    await dao.deleteResponsable(responsable);
    ref.invalidateSelf();
  }
}

/// Provider pour la liste des utilisateurs
@riverpod
class UtilisateursNotifier extends _$UtilisateursNotifier {
  @override
  Future<List<Utilisateur>> build() async {
    final dao = ref.watch(utilisateurDaoProvider);
    return await dao.getAllUtilisateurs();
  }

  Future<void> refresh(List<Utilisateur> utilisateurs) async {
    final dao = ref.watch(utilisateurDaoProvider);
    try {
      await dao.insertUtilisateurs(utilisateurs);
      ref.invalidateSelf();
    } catch (e) {
      print('Erreur lors du rafraîchissement des utilisateurs: $e');
    }
  }

  Future<void> addUtilisateur(Utilisateur utilisateur) async {
    final dao = ref.watch(utilisateurDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    utilisateur.isSync = false;
    await dao.insertUtilisateur(utilisateur);
    ref.invalidateSelf();

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          utilisateur,
          'utilisateurs',
          'create',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de l\'upload de l\'utilisateur: $e');
      }
    }
  }

  Future<void> updateUtilisateur(Utilisateur utilisateur) async {
    final dao = ref.watch(utilisateurDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    utilisateur.isSync = false;
    await dao.updateUtilisateur(utilisateur);
    ref.invalidateSelf();

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          utilisateur,
          'utilisateurs',
          'update',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de la mise à jour de l\'utilisateur: $e');
      }
    }
  }

  Future<void> deleteUtilisateur(Utilisateur utilisateur) async {
    final dao = ref.watch(utilisateurDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          utilisateur,
          'utilisateurs',
          'delete',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de la suppression de l\'utilisateur via API: $e');
      }
    }

    await dao.deleteUtilisateur(utilisateur);
    ref.invalidateSelf();
  }
}

/// Provider pour la liste des années scolaires
@riverpod
class AnneesScolairesNotifier extends _$AnneesScolairesNotifier {
  @override
  Future<List<AnneeScolaire>> build() async {
    final dao = ref.watch(anneeScolaireDaoProvider);
    return await dao.getAllAnneesScolaires();
  }

  Future<void> refresh(List<AnneeScolaire> annees) async {
    final dao = ref.watch(anneeScolaireDaoProvider);
    try {
      await dao.insertAnneesScolaires(annees);
      ref.invalidateSelf();
    } catch (e) {
      print('Erreur lors du rafraîchissement des années scolaires: $e');
    }
  }

  Future<void> addAnneeScolaire(AnneeScolaire annee) async {
    final dao = ref.watch(anneeScolaireDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    annee.isSync = false;
    await dao.insertAnneeScolaire(annee);
    ref.invalidateSelf();

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          annee,
          'annees_scolaires',
          'create',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de l\'upload de l\'année scolaire: $e');
      }
    }
  }

  Future<void> updateAnneeScolaire(AnneeScolaire annee) async {
    final dao = ref.watch(anneeScolaireDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    annee.isSync = false;
    await dao.updateAnneeScolaire(annee);
    ref.invalidateSelf();

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          annee,
          'annees_scolaires',
          'update',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de la mise à jour de l\'année scolaire: $e');
      }
    }
  }

  Future<void> deleteAnneeScolaire(AnneeScolaire annee) async {
    final dao = ref.watch(anneeScolaireDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          annee,
          'annees_scolaires',
          'delete',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de la suppression de l\'année scolaire via API: $e');
      }
    }

    await dao.deleteAnneeScolaire(annee);
    ref.invalidateSelf();
  }
}

/// Provider pour la liste des frais scolaires
@riverpod
class FraisScolairesNotifier extends _$FraisScolairesNotifier {
  @override
  Future<List<FraisScolaire>> build() async {
    final dao = ref.watch(fraisScolaireDaoProvider);
    return await dao.getAllFraisScolaires();
  }

  Future<void> refresh(List<FraisScolaire> frais) async {
    final dao = ref.watch(fraisScolaireDaoProvider);
    try {
      await dao.insertFraisScolaires(frais);
      ref.invalidateSelf();
    } catch (e) {
      print('Erreur lors du rafraîchissement des frais scolaires: $e');
    }
  }

  Future<void> addFraisScolaire(FraisScolaire frais) async {
    final dao = ref.watch(fraisScolaireDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    frais.isSync = false;
    await dao.insertFraisScolaire(frais);
    ref.invalidateSelf();

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          frais,
          'frais_scolaires',
          'create',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de l\'upload du frais scolaire: $e');
      }
    }
  }

  Future<void> updateFraisScolaire(FraisScolaire frais) async {
    final dao = ref.watch(fraisScolaireDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    frais.isSync = false;
    await dao.updateFraisScolaire(frais);
    ref.invalidateSelf();

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          frais,
          'frais_scolaires',
          'update',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de la mise à jour du frais scolaire: $e');
      }
    }
  }

  Future<void> deleteFraisScolaire(FraisScolaire frais) async {
    final dao = ref.watch(fraisScolaireDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          frais,
          'frais_scolaires',
          'delete',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de la suppression du frais scolaire via API: $e');
      }
    }

    await dao.deleteFraisScolaire(frais);
    ref.invalidateSelf();
  }
}

/// Provider pour la liste des paiements de frais
@riverpod
class PaiementsFraisNotifier extends _$PaiementsFraisNotifier {
  @override
  Future<List<PaiementFrais>> build() async {
    final dao = ref.watch(paiementFraisDaoProvider);
    return await dao.getAllPaiementsFrais();
  }

  Future<void> refresh(List<PaiementFrais> paiements) async {
    final dao = ref.watch(paiementFraisDaoProvider);
    try {
      await dao.insertPaiementsFrais(paiements);
      ref.invalidateSelf();
    } catch (e) {
      print('Erreur lors du rafraîchissement des paiements: $e');
    }
  }

  Future<void> addPaiementFrais(PaiementFrais paiement) async {
    final dao = ref.watch(paiementFraisDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    paiement.isSync = false;
    await dao.insertPaiementFrais(paiement);
    ref.invalidateSelf();

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          paiement,
          'paiement_frais',
          'create',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de l\'upload du paiement: $e');
      }
    }
  }

  Future<void> updatePaiementFrais(PaiementFrais paiement) async {
    final dao = ref.watch(paiementFraisDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    paiement.isSync = false;
    await dao.updatePaiementFrais(paiement);
    ref.invalidateSelf();

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          paiement,
          'paiement_frais',
          'update',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de la mise à jour du paiement: $e');
      }
    }
  }

  Future<void> deletePaiementFrais(PaiementFrais paiement) async {
    final dao = ref.watch(paiementFraisDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          paiement,
          'paiement_frais',
          'delete',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de la suppression du paiement via API: $e');
      }
    }

    await dao.deletePaiementFrais(paiement);
    ref.invalidateSelf();
  }

  /// Récupère les détails des frais pour un élève donné
  Future<List<FraisDetails>> getEleveFraisDetails(int eleveId) async {
    final paiementDao = ref.watch(paiementFraisDaoProvider);
    final fraisDao = ref.watch(fraisScolaireDaoProvider);
    final fraisClassesDao = ref.watch(fraisClassesDaoProvider);
    final eleveDao = ref.watch(eleveDaoProvider);

    try {
      // Récupérer l'élève pour connaître sa classe
      final eleve = await eleveDao.getEleveById(eleveId);
      if (eleve == null) {
        return [];
      }

      final classeId = eleve.classeId;
      if (classeId == null) {
        return [];
      }

      // Récupérer tous les frais de la classe
      final fraisClassesList = await fraisClassesDao.getFraisClassesByClasse(
        classeId,
      );

      // Pour chaque frais de la classe, récupérer les détails
      final List<FraisDetails> fraisDetails = [];

      for (final fraisClasse in fraisClassesList) {
        final frais = await fraisDao.getFraisScolaireById(fraisClasse.fraisId);
        if (frais == null) continue;

        // Récupérer tous les paiements pour ce frais et cet élève
        final paiements = await paiementDao.getPaiementsFraisByEleve(eleveId);
        final paiementsPourCeFrais = paiements
            .where((p) => p.fraisScolaireId == frais.id)
            .toList();

        // Calculer le total payé
        double totalPaye = 0;
        for (final p in paiementsPourCeFrais) {
          totalPaye += p.montantPaye;
        }

        // Calculer le reste à payer
        final montantFrais = frais.montant;
        final resteAPayer = montantFrais - totalPaye;

        // Déterminer le statut
        String statut;
        if (resteAPayer <= 0) {
          statut = 'en_ordre';
        } else if (totalPaye > 0) {
          statut = 'partiellement_paye';
        } else {
          statut = 'pas_en_ordre';
        }

        fraisDetails.add(
          FraisDetails(
            fraisId: frais.id!,
            nomFrais: frais.nom,
            montant: montantFrais,
            totalPaye: totalPaye,
            restePayer: resteAPayer,
            statut: statut,
            historiquePaiements: paiementsPourCeFrais,
          ),
        );
      }

      return fraisDetails;
    } catch (e) {
      print('Erreur lors de la récupération des détails des frais: $e');
      return [];
    }
  }

  /// Enregistre un nouveau paiement de frais
  Future<void> enregistrerPaiement({
    required int eleveId,
    required int fraisId,
    required double montant,
  }) async {
    final paiementDao = ref.watch(paiementFraisDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    try {
      final now = DateTime.now();

      final nouveauPaiement = PaiementFrais(
        eleveId: eleveId,
        fraisScolaireId: fraisId,
        montantPaye: montant,
        datePaiement: now,
        statut: 'validé',
        isSync: false,
        dateCreation: now,
        dateModification: now,
        updatedAt: now,
      );

      await paiementDao.insertPaiementFrais(nouveauPaiement);
      ref.invalidateSelf();

      if (isConnected) {
        try {
          await syncNotifier.uploadSingleEntity(
            nouveauPaiement,
            'paiement_frais',
            'create',
            userEmail: 'admin@testschool.com',
          );
        } catch (e) {
          print('Erreur lors de l\'upload du paiement: $e');
        }
      }
    } catch (e) {
      print('Erreur lors de l\'enregistrement du paiement: $e');
      rethrow;
    }
  }

  /// Enregistre un nouveau paiement avec écritures comptables automatiques
  Future<void> enregistrerPaiementAvecEcritures({
    required int eleveId,
    required int fraisId,
    required double montant,
    required int entrepriseId,
    int? userId,
  }) async {
    final paiementDao = ref.watch(paiementFraisDaoProvider);
    final journalDao = ref.watch(journalComptableDaoProvider);
    final ecritureDao = ref.watch(ecritureComptableDaoProvider);
    final comptesConfigDao = ref.watch(comptesConfigDaoProvider);
    final eleveDao = ref.watch(eleveDaoProvider);
    final fraisDao = ref.watch(fraisScolaireDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    try {
      final now = DateTime.now();

      // 1. Récupérer les informations de l'élève et du frais
      final eleve = await eleveDao.getEleveById(eleveId);
      final frais = await fraisDao.getFraisScolaireById(fraisId);

      if (eleve == null) throw Exception("Élève introuvable.");
      if (frais == null) throw Exception("Frais scolaire introuvable.");

      // 2. Calculer le reste à payer
      print('💰 Calcul du reste à payer:');
      print('  - Montant du frais: ${frais.montant}');

      double montantDejaPaye = 0.0;
      try {
        final result = await paiementDao.getTotalPaiementsByEleveAndFrais(
          eleveId,
          fraisId,
        );
        // Avec COALESCE, result ne devrait jamais être null, mais on garde la sécurité
        montantDejaPaye = result ?? 0.0;
        print('  - Montant déjà payé (succès): $montantDejaPaye');
      } catch (e) {
        print('  - Erreur lors du calcul du montant déjà payé: $e');
        print('  - Utilisation de la valeur par défaut: 0.0');
        montantDejaPaye = 0.0;
      }

      print('  - Montant déjà payé final: $montantDejaPaye');
      print('  - Nouveau paiement: $montant');

      final resteAPayer = frais.montant - montantDejaPaye - montant;
      print('  - Reste à payer calculé: $resteAPayer');

      // 3. Créer le paiement
      print('📝 Création du paiement:');
      final resteAPayerFinal = resteAPayer > 0 ? resteAPayer : 0.0;
      final statutFinal = resteAPayer <= 0 ? 'complet' : 'partiel';

      print('  - Reste à payer final: $resteAPayerFinal');
      print('  - Statut: $statutFinal');

      final nouveauPaiement = PaiementFrais(
        eleveId: eleveId,
        fraisScolaireId: fraisId,
        montantPaye: montant,
        datePaiement: now,
        userId: userId,
        resteAPayer: resteAPayerFinal,
        statut: statutFinal,
        isSync: false,
        dateCreation: now,
        dateModification: now,
        updatedAt: now,
      );

      print('🗃️ Insertion du paiement en base...');
      final paiementId = await paiementDao.insertPaiementFrais(nouveauPaiement);
      print('✅ Paiement inséré avec ID: $paiementId');

      // 4. Créer le libellé pour le journal
      final nomEleve = '${eleve.nom} ${eleve.postnom ?? ''} ${eleve.prenom}';
      final libelle = 'Paiement : ${frais.nom} ${nomEleve.trim()}';

      print('📓 Création du journal comptable...');
      print('  - Libellé: $libelle');

      // 5. Créer l'entrée dans le journal comptable
      final journalEntry = JournalComptable(
        dateOperation: now,
        libelle: libelle,
        montant: montant,
        typeOperation: 'Entrée',
        paiementFraisId: paiementId,
        entrepriseId: entrepriseId,
        isSync: false,
        dateCreation: now,
        dateModification: now,
        updatedAt: now,
      );

      final journalId = await journalDao.insertJournalComptable(journalEntry);
      print('✅ Journal créé avec ID: $journalId');

      // 6. Récupérer la configuration comptable
      final config = await comptesConfigDao.getComptesConfigByEntreprise(
        entrepriseId,
      );
      if (config == null) {
        throw Exception(
          "Configuration comptable introuvable pour entreprise_id $entrepriseId",
        );
      }

      // 7. Créer les écritures comptables (Partie Double)
      print('📊 Création des écritures comptables (débit/crédit):');
      print('  - Compte Caisse ID: ${config.compteCaisseId}');
      print('  - Compte Frais ID: ${config.compteFraisId}');

      // Écriture DÉBIT : Compte Caisse (Actif augmente)
      final ecritureDebit = EcritureComptable(
        journalId: journalId,
        compteComptableId: config.compteCaisseId,
        debit: montant,
        credit: 0,
        ordre: 1,
        dateEcriture: now,
        isSync: false,
        dateCreation: now,
        dateModification: now,
        updatedAt: now,
      );

      // Écriture CRÉDIT : Compte Frais (Produit augmente)
      final ecritureCredit = EcritureComptable(
        journalId: journalId,
        compteComptableId: config.compteFraisId,
        debit: 0,
        credit: montant,
        ordre: 2,
        dateEcriture: now,
        isSync: false,
        dateCreation: now,
        dateModification: now,
        updatedAt: now,
      );

      print('  - Écriture DÉBIT : Caisse = ${montant} CDF');
      print('  - Écriture CRÉDIT : Frais = ${montant} CDF');
      print(
        '  - Équilibre comptable : ${ecritureDebit.debit} = ${ecritureCredit.credit} ✓',
      );

      await ecritureDao.insertEcritureComptable(ecritureDebit);
      print('✅ Écriture DÉBIT insérée');

      await ecritureDao.insertEcritureComptable(ecritureCredit);
      print('✅ Écriture CRÉDIT insérée');

      print(
        '💼 Écritures comptables créées avec succès (partie double respectée)',
      );

      // 8. Invalider le cache pour rafraîchir les données
      ref.invalidateSelf();

      // 9. Synchronisation si connecté
      if (isConnected) {
        try {
          await syncNotifier.uploadSingleEntity(
            nouveauPaiement,
            'paiement_frais',
            'create',
            userEmail: 'admin@testschool.com',
          );

          await syncNotifier.uploadSingleEntity(
            journalEntry,
            'journaux_comptables',
            'create',
            userEmail: 'admin@testschool.com',
          );

          await syncNotifier.uploadSingleEntity(
            ecritureDebit,
            'ecritures_comptables',
            'create',
            userEmail: 'admin@testschool.com',
          );

          await syncNotifier.uploadSingleEntity(
            ecritureCredit,
            'ecritures_comptables',
            'create',
            userEmail: 'admin@testschool.com',
          );
        } catch (e) {
          print('Erreur lors de la synchronisation: $e');
        }
      }

      print(
        '✅ Paiement enregistré avec écritures comptables - Montant: $montant',
      );
    } catch (e) {
      print('❌ Erreur lors de l\'enregistrement du paiement complet: $e');
      rethrow;
    }
  }
}

/// Provider pour la liste des notes par période
@riverpod
class NotesPeriodesNotifier extends _$NotesPeriodesNotifier {
  @override
  Future<List<NotePeriode>> build() async {
    final dao = ref.watch(notePeriodeDaoProvider);
    return await dao.getAllNotesPeriode();
  }

  Future<void> refresh(List<NotePeriode> notes) async {
    final dao = ref.watch(notePeriodeDaoProvider);
    try {
      await dao.insertMultipleNotePeriode(notes);
      ref.invalidateSelf();
    } catch (e) {
      print('Erreur lors du rafraîchissement des notes: $e');
    }
  }

  Future<void> addNotePeriode(NotePeriode note) async {
    final dao = ref.watch(notePeriodeDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    note.isSync = false;
    await dao.insertNotePeriode(note);
    ref.invalidateSelf();

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          note,
          'notes_periode',
          'create',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de l\'upload de la note: $e');
      }
    }
  }

  Future<void> updateNotePeriode(NotePeriode note) async {
    final dao = ref.watch(notePeriodeDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    note.isSync = false;
    await dao.updateNotePeriode(note);
    ref.invalidateSelf();

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          note,
          'notes_periode',
          'update',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de la mise à jour de la note: $e');
      }
    }
  }

  Future<void> deleteNotePeriode(NotePeriode note) async {
    final dao = ref.watch(notePeriodeDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          note,
          'notes_periode',
          'delete',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de la suppression de la note via API: $e');
      }
    }

    await dao.deleteNotePeriode(note);
    ref.invalidateSelf();
  }
}

/// Provider pour la liste des configurations d'école
@riverpod
class ConfigEcolesNotifier extends _$ConfigEcolesNotifier {
  @override
  Future<List<ConfigEcole>> build() async {
    final dao = ref.watch(configEcoleDaoProvider);
    return await dao.getAllConfigsEcole();
  }

  Future<void> refresh(List<ConfigEcole> configs) async {
    final dao = ref.watch(configEcoleDaoProvider);
    try {
      await dao.insertConfigsEcole(configs);
      ref.invalidateSelf();
    } catch (e) {
      print('Erreur lors du rafraîchissement des configurations: $e');
    }
  }

  Future<void> addConfigEcole(ConfigEcole config) async {
    final dao = ref.watch(configEcoleDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    config.isSync = false;
    await dao.insertConfigEcole(config);
    ref.invalidateSelf();

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          config,
          'config_ecoles',
          'create',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de l\'upload de la configuration: $e');
      }
    }
  }

  Future<void> updateConfigEcole(ConfigEcole config) async {
    final dao = ref.watch(configEcoleDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    config.isSync = false;
    await dao.updateConfigEcole(config);
    ref.invalidateSelf();

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          config,
          'config_ecoles',
          'update',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de la mise à jour de la configuration: $e');
      }
    }
  }

  Future<void> deleteConfigEcole(ConfigEcole config) async {
    final dao = ref.watch(configEcoleDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          config,
          'config_ecoles',
          'delete',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de la suppression de la configuration via API: $e');
      }
    }

    await dao.deleteConfigEcole(config);
    ref.invalidateSelf();
  }

  /// Met à jour l'année scolaire en cours dans la configuration
  Future<void> updateCurrentAnneeScolaire(int anneeScolaireId) async {
    final dao = ref.watch(configEcoleDaoProvider);
    final authState = await ref.read(authNotifierProvider.future);

    if (authState.entrepriseId == null) {
      throw Exception('Entreprise non définie');
    }

    try {
      await dao.updateAnneeScolaireEnCours(
        authState.entrepriseId!,
        anneeScolaireId,
      );

      // Invalider le provider pour recharger la configuration
      ref.invalidateSelf();
      ref.invalidate(currentAnneeScolaireProvider);
    } catch (e) {
      print('Erreur lors de la mise à jour de l\'année scolaire en cours: $e');
      rethrow;
    }
  }
}

/// Provider pour obtenir l'année scolaire en cours
/// Ce provider récupère la configuration de l'école et retourne l'année scolaire active
@riverpod
Future<AnneeScolaire?> currentAnneeScolaire(Ref ref) async {
  // Get current entreprise ID from auth
  final authState = await ref.watch(authNotifierProvider.future);
  final entrepriseId = authState.entrepriseId;

  if (entrepriseId == null) {
    return null;
  }

  // Get config ecole for this entreprise
  final configDao = ref.watch(configEcoleDaoProvider);
  final configEcole = await configDao.getConfigEcoleByEntreprise(entrepriseId);

  if (configEcole == null || configEcole.anneeScolaireEnCoursId == null) {
    // Fallback: return the first annee scolaire if no config
    final anneesScolaires = await ref.watch(
      anneesScolairesNotifierProvider.future,
    );
    return anneesScolaires.isNotEmpty ? anneesScolaires.first : null;
  }

  // Get the annee scolaire by its ID
  final anneeScolaireDao = ref.watch(anneeScolaireDaoProvider);
  return await anneeScolaireDao.getAnneeScolaireById(
    configEcole.anneeScolaireEnCoursId!,
  );
}

/// Provider pour la liste des cours
@riverpod
class CoursNotifier extends _$CoursNotifier {
  @override
  Future<List<Cours>> build() async {
    final dao = ref.watch(coursDaoProvider);
    return await dao.getAllCours();
  }

  Future<void> refresh(List<Cours> cours) async {
    final dao = ref.watch(coursDaoProvider);
    try {
      await dao.insertMultipleCours(cours);
      ref.invalidateSelf();
    } catch (e) {
      print('Erreur lors du rafraîchissement des cours: $e');
    }
  }

  Future<void> addCours(Cours cours) async {
    final dao = ref.watch(coursDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    cours.isSync = false;
    await dao.insertCours(cours);
    ref.invalidateSelf();

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          cours,
          'cours',
          'create',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de l\'upload du cours: $e');
      }
    }
  }

  Future<void> updateCours(Cours cours) async {
    final dao = ref.watch(coursDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    cours.isSync = false;
    await dao.updateCours(cours);
    ref.invalidateSelf();

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          cours,
          'cours',
          'update',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de la mise à jour du cours: $e');
      }
    }
  }

  Future<void> deleteCours(Cours cours) async {
    final dao = ref.watch(coursDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          cours,
          'cours',
          'delete',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de la suppression du cours via API: $e');
      }
    }

    await dao.deleteCours(cours);
    ref.invalidateSelf();
  }
}

/// Provider pour la liste des entreprises
@riverpod
class EntreprisesNotifier extends _$EntreprisesNotifier {
  @override
  Future<List<Entreprise>> build() async {
    final dao = ref.watch(entrepriseDaoProvider);
    return await dao.getAllEntreprises();
  }

  Future<void> refresh(List<Entreprise> entreprises) async {
    final dao = ref.watch(entrepriseDaoProvider);
    try {
      await dao.insertEntreprises(entreprises);
      ref.invalidateSelf();
    } catch (e) {
      print('Erreur lors du rafraîchissement des entreprises: $e');
    }
  }

  Future<void> addEntreprise(Entreprise entreprise) async {
    final dao = ref.watch(entrepriseDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    entreprise.isSync = false;
    await dao.insertEntreprise(entreprise);
    ref.invalidateSelf();

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          entreprise,
          'entreprises',
          'create',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de l\'upload de l\'entreprise: $e');
      }
    }
  }

  Future<void> updateEntreprise(Entreprise entreprise) async {
    final dao = ref.watch(entrepriseDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    entreprise.isSync = false;
    await dao.updateEntreprise(entreprise);
    ref.invalidateSelf();

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          entreprise,
          'entreprises',
          'update',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de la mise à jour de l\'entreprise: $e');
      }
    }
  }

  Future<void> deleteEntreprise(Entreprise entreprise) async {
    final dao = ref.watch(entrepriseDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          entreprise,
          'entreprises',
          'delete',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de la suppression de l\'entreprise via API: $e');
      }
    }

    await dao.deleteEntreprise(entreprise);
    ref.invalidateSelf();
  }
}

/// Provider pour la liste des licences
@riverpod
class LicencesNotifier extends _$LicencesNotifier {
  @override
  Future<List<Licence>> build() async {
    final dao = ref.watch(licenceDaoProvider);
    return await dao.getAllLicences();
  }

  Future<void> refresh(List<Licence> licences) async {
    final dao = ref.watch(licenceDaoProvider);
    try {
      await dao.insertLicences(licences);
      ref.invalidateSelf();
    } catch (e) {
      print('Erreur lors du rafraîchissement des licences: $e');
    }
  }

  Future<void> addLicence(Licence licence) async {
    final dao = ref.watch(licenceDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    licence.isSync = false;
    await dao.insertLicence(licence);
    ref.invalidateSelf();

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          licence,
          'licences',
          'create',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de l\'upload de la licence: $e');
      }
    }
  }

  Future<void> updateLicence(Licence licence) async {
    final dao = ref.watch(licenceDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    licence.isSync = false;
    await dao.updateLicence(licence);
    ref.invalidateSelf();

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          licence,
          'licences',
          'update',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de la mise à jour de la licence: $e');
      }
    }
  }

  Future<void> deleteLicence(Licence licence) async {
    final dao = ref.watch(licenceDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          licence,
          'licences',
          'delete',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de la suppression de la licence via API: $e');
      }
    }

    await dao.deleteLicence(licence);
    ref.invalidateSelf();
  }
}

/// Provider pour la liste des périodes classes
@riverpod
class PeriodesClassesNotifier extends _$PeriodesClassesNotifier {
  @override
  Future<List<PeriodesClasses>> build() async {
    final dao = ref.watch(periodesClassesDaoProvider);
    return await dao.getAllPeriodesClasses();
  }

  Future<void> refresh(List<PeriodesClasses> periodesClasses) async {
    final dao = ref.watch(periodesClassesDaoProvider);
    try {
      await dao.insertPeriodesClasses(periodesClasses);
      ref.invalidateSelf();
    } catch (e) {
      print('Erreur lors du rafraîchissement des périodes classes: $e');
    }
  }

  Future<void> addPeriodesClasses(PeriodesClasses periodesClasses) async {
    final dao = ref.watch(periodesClassesDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    periodesClasses.isSync = false;
    await dao.insertPeriodeClasse(periodesClasses);
    ref.invalidateSelf();

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          periodesClasses,
          'periodes_classes',
          'create',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de l\'upload des périodes classes: $e');
      }
    }
  }

  Future<void> updatePeriodesClasses(PeriodesClasses periodesClasses) async {
    final dao = ref.watch(periodesClassesDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    periodesClasses.isSync = false;
    await dao.updatePeriodeClasse(periodesClasses);
    ref.invalidateSelf();

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          periodesClasses,
          'periodes_classes',
          'update',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de la mise à jour des périodes classes: $e');
      }
    }
  }

  Future<void> deletePeriodesClasses(PeriodesClasses periodesClasses) async {
    final dao = ref.watch(periodesClassesDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          periodesClasses,
          'periodes_classes',
          'delete',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de la suppression des périodes classes via API: $e');
      }
    }

    await dao.deletePeriodeClasse(periodesClasses);
    ref.invalidateSelf();
  }
}

/// Provider pour la liste des créances
@riverpod
class CreancesNotifier extends _$CreancesNotifier {
  @override
  Future<List<Creance>> build() async {
    final dao = ref.watch(creanceDaoProvider);
    return await dao.getAllCreances();
  }

  Future<void> refresh(List<Creance> creances) async {
    final dao = ref.watch(creanceDaoProvider);
    try {
      await dao.insertCreances(creances);
      ref.invalidateSelf();
    } catch (e) {
      print('Erreur lors du rafraîchissement des créances: $e');
    }
  }

  Future<void> addCreance(Creance creance) async {
    final dao = ref.watch(creanceDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    creance.isSync = false;
    await dao.insertCreance(creance);
    ref.invalidateSelf();

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          creance,
          'creances',
          'create',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de l\'upload de la créance: $e');
      }
    }
  }

  Future<void> updateCreance(Creance creance) async {
    final dao = ref.watch(creanceDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    creance.isSync = false;
    await dao.updateCreance(creance);
    ref.invalidateSelf();

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          creance,
          'creances',
          'update',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de la mise à jour de la créance: $e');
      }
    }
  }

  Future<void> deleteCreance(Creance creance) async {
    final dao = ref.watch(creanceDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          creance,
          'creances',
          'delete',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de la suppression de la créance via API: $e');
      }
    }

    await dao.deleteCreance(creance);
    ref.invalidateSelf();
  }
}

/// Provider pour la liste des dépenses
@riverpod
class DepensesNotifier extends _$DepensesNotifier {
  @override
  Future<List<Depense>> build() async {
    final dao = ref.watch(depenseDaoProvider);
    return await dao.getAllDepenses();
  }

  Future<void> refresh(List<Depense> depenses) async {
    final dao = ref.watch(depenseDaoProvider);
    try {
      await dao.insertDepenses(depenses);
      ref.invalidateSelf();
    } catch (e) {
      print('Erreur lors du rafraîchissement des dépenses: $e');
    }
  }

  Future<void> addDepense(Depense depense) async {
    final dao = ref.watch(depenseDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    depense.isSync = false;
    await dao.insertDepense(depense);
    ref.invalidateSelf();

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          depense,
          'depenses',
          'create',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de l\'upload de la dépense: $e');
      }
    }
  }

  Future<void> updateDepense(Depense depense) async {
    final dao = ref.watch(depenseDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    depense.isSync = false;
    await dao.updateDepense(depense);
    ref.invalidateSelf();

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          depense,
          'depenses',
          'update',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de la mise à jour de la dépense: $e');
      }
    }
  }

  Future<void> deleteDepense(Depense depense) async {
    final dao = ref.watch(depenseDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          depense,
          'depenses',
          'delete',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de la suppression de la dépense via API: $e');
      }
    }

    await dao.deleteDepense(depense);
    ref.invalidateSelf();
  }
}

/// Provider pour la liste des classes comptables
@riverpod
class ClassesComptablesNotifier extends _$ClassesComptablesNotifier {
  @override
  Future<List<ClasseComptable>> build() async {
    final dao = ref.watch(classeComptableDaoProvider);
    return await dao.getAllClassesComptables();
  }

  Future<void> refresh(List<ClasseComptable> classes) async {
    final dao = ref.watch(classeComptableDaoProvider);
    try {
      await dao.insertClassesComptables(classes);
      ref.invalidateSelf();
    } catch (e) {
      print('Erreur lors du rafraîchissement des classes comptables: $e');
    }
  }

  Future<void> addClasseComptable(ClasseComptable classe) async {
    final dao = ref.watch(classeComptableDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    classe.isSync = false;
    await dao.insertClasseComptable(classe);
    ref.invalidateSelf();

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          classe,
          'classes_comptables',
          'create',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de l\'upload de la classe comptable: $e');
      }
    }
  }

  Future<void> updateClasseComptable(ClasseComptable classe) async {
    final dao = ref.watch(classeComptableDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    classe.isSync = false;
    await dao.updateClasseComptable(classe);
    ref.invalidateSelf();

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          classe,
          'classes_comptables',
          'update',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de la mise à jour de la classe comptable: $e');
      }
    }
  }

  Future<void> deleteClasseComptable(ClasseComptable classe) async {
    final dao = ref.watch(classeComptableDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          classe,
          'classes_comptables',
          'delete',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print(
          'Erreur lors de la suppression de la classe comptable via API: $e',
        );
      }
    }

    await dao.deleteClasseComptable(classe);
    ref.invalidateSelf();
  }
}

/// Provider pour la liste des comptes comptables
@riverpod
class ComptesComptablesNotifier extends _$ComptesComptablesNotifier {
  @override
  Future<List<CompteComptable>> build() async {
    final dao = ref.watch(compteComptableDaoProvider);
    return await dao.getAllComptesComptables();
  }

  Future<void> refresh(List<CompteComptable> comptes) async {
    final dao = ref.watch(compteComptableDaoProvider);
    try {
      await dao.insertComptesComptables(comptes);
      ref.invalidateSelf();
    } catch (e) {
      print('Erreur lors du rafraîchissement des comptes comptables: $e');
    }
  }

  Future<void> addCompteComptable(CompteComptable compte) async {
    final dao = ref.watch(compteComptableDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    compte.isSync = false;
    await dao.insertCompteComptable(compte);
    ref.invalidateSelf();

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          compte,
          'comptes_comptables',
          'create',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de l\'upload du compte comptable: $e');
      }
    }
  }

  Future<void> updateCompteComptable(CompteComptable compte) async {
    final dao = ref.watch(compteComptableDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    compte.isSync = false;
    await dao.updateCompteComptable(compte);
    ref.invalidateSelf();

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          compte,
          'comptes_comptables',
          'update',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de la mise à jour du compte comptable: $e');
      }
    }
  }

  Future<void> deleteCompteComptable(CompteComptable compte) async {
    final dao = ref.watch(compteComptableDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          compte,
          'comptes_comptables',
          'delete',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de la suppression du compte comptable via API: $e');
      }
    }

    await dao.deleteCompteComptable(compte);
    ref.invalidateSelf();
  }
}

/// Provider pour la liste des configurations de comptes
@riverpod
class ComptesConfigsNotifier extends _$ComptesConfigsNotifier {
  @override
  Future<List<ComptesConfig>> build() async {
    final dao = ref.watch(comptesConfigDaoProvider);
    return await dao.getAllComptesConfigs();
  }

  Future<void> refresh(List<ComptesConfig> configs) async {
    final dao = ref.watch(comptesConfigDaoProvider);
    try {
      await dao.insertComptesConfigs(configs);
      ref.invalidateSelf();
    } catch (e) {
      print(
        'Erreur lors du rafraîchissement des configurations de comptes: $e',
      );
    }
  }

  Future<void> addComptesConfig(ComptesConfig config) async {
    final dao = ref.watch(comptesConfigDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    config.isSync = false;
    await dao.insertComptesConfig(config);
    ref.invalidateSelf();

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          config,
          'comptes_configs',
          'create',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de l\'upload de la configuration de comptes: $e');
      }
    }
  }

  Future<void> updateComptesConfig(ComptesConfig config) async {
    final dao = ref.watch(comptesConfigDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    config.isSync = false;
    await dao.updateComptesConfig(config);
    ref.invalidateSelf();

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          config,
          'comptes_configs',
          'update',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print(
          'Erreur lors de la mise à jour de la configuration de comptes: $e',
        );
      }
    }
  }

  Future<void> deleteComptesConfig(ComptesConfig config) async {
    final dao = ref.watch(comptesConfigDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          config,
          'comptes_configs',
          'delete',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print(
          'Erreur lors de la suppression de la configuration de comptes via API: $e',
        );
      }
    }

    await dao.deleteComptesConfig(config);
    ref.invalidateSelf();
  }
}

/// Provider pour la liste des écritures comptables
@riverpod
class EcrituresComptablesNotifier extends _$EcrituresComptablesNotifier {
  @override
  Future<List<EcritureComptable>> build() async {
    final dao = ref.watch(ecritureComptableDaoProvider);
    return await dao.getAllEcrituresComptables();
  }

  Future<void> refresh(List<EcritureComptable> ecritures) async {
    final dao = ref.watch(ecritureComptableDaoProvider);
    try {
      await dao.insertEcrituresComptables(ecritures);
      ref.invalidateSelf();
    } catch (e) {
      print('Erreur lors du rafraîchissement des écritures comptables: $e');
    }
  }

  Future<void> addEcritureComptable(EcritureComptable ecriture) async {
    final dao = ref.watch(ecritureComptableDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    ecriture.isSync = false;
    await dao.insertEcritureComptable(ecriture);
    ref.invalidateSelf();

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          ecriture,
          'ecritures_comptables',
          'create',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de l\'upload de l\'écriture comptable: $e');
      }
    }
  }

  Future<void> updateEcritureComptable(EcritureComptable ecriture) async {
    final dao = ref.watch(ecritureComptableDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    ecriture.isSync = false;
    await dao.updateEcritureComptable(ecriture);
    ref.invalidateSelf();

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          ecriture,
          'ecritures_comptables',
          'update',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de la mise à jour de l\'écriture comptable: $e');
      }
    }
  }

  Future<void> deleteEcritureComptable(EcritureComptable ecriture) async {
    final dao = ref.watch(ecritureComptableDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          ecriture,
          'ecritures_comptables',
          'delete',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print(
          'Erreur lors de la suppression de l\'écriture comptable via API: $e',
        );
      }
    }

    await dao.deleteEcritureComptable(ecriture);
    ref.invalidateSelf();
  }
}

/// Provider pour la liste des journaux comptables
@riverpod
class JournauxComptablesNotifier extends _$JournauxComptablesNotifier {
  @override
  Future<List<JournalComptable>> build() async {
    final dao = ref.watch(journalComptableDaoProvider);
    return await dao.getAllJournauxComptables();
  }

  Future<void> refresh(List<JournalComptable> journaux) async {
    final dao = ref.watch(journalComptableDaoProvider);
    try {
      await dao.insertJournauxComptables(journaux);
      ref.invalidateSelf();
    } catch (e) {
      print('Erreur lors du rafraîchissement des journaux comptables: $e');
    }
  }

  Future<void> addJournalComptable(JournalComptable journal) async {
    final dao = ref.watch(journalComptableDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    journal.isSync = false;
    await dao.insertJournalComptable(journal);
    ref.invalidateSelf();

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          journal,
          'journaux_comptables',
          'create',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de l\'upload du journal comptable: $e');
      }
    }
  }

  Future<void> updateJournalComptable(JournalComptable journal) async {
    final dao = ref.watch(journalComptableDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    journal.isSync = false;
    await dao.updateJournalComptable(journal);
    ref.invalidateSelf();

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          journal,
          'journaux_comptables',
          'update',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de la mise à jour du journal comptable: $e');
      }
    }
  }

  Future<void> deleteJournalComptable(JournalComptable journal) async {
    final dao = ref.watch(journalComptableDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          journal,
          'journaux_comptables',
          'delete',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de la suppression du journal comptable via API: $e');
      }
    }

    await dao.deleteJournalComptable(journal);
    ref.invalidateSelf();
  }

  /// Récupère les entrées du journal pour une date donnée avec filtre optionnel
  Future<List<JournalComptable>> getJournalEntries(
    DateTime date, {
    String filter = 'Tous',
  }) async {
    final dao = ref.watch(journalComptableDaoProvider);
    final authState = await ref.read(authNotifierProvider.future);

    print('🔍 getJournalEntries - Debug:');
    print('  - Date demandée: $date');
    print('  - Filtre: $filter');
    print('  - Entreprise ID: ${authState.entrepriseId}');

    if (authState.entrepriseId == null) {
      print('❌ Aucune entreprise connectée - retour liste vide');
      return [];
    }

    try {
      // Définir le début et la fin du jour sélectionné
      final dateDebut = DateTime(date.year, date.month, date.day, 0, 0, 0);
      final dateFin = DateTime(date.year, date.month, date.day, 23, 59, 59);

      // Récupérer toutes les entrées de la période
      final entries = await dao.getJournauxComptablesByPeriode(
        dateDebut,
        dateFin,
        authState.entrepriseId!,
      );

      print('  - Période: $dateDebut à $dateFin');
      print('  - Entrées trouvées: ${entries.length}');

      // Appliquer le filtre si nécessaire
      if (filter == 'Tous') {
        return entries;
      } else if (filter == 'Entrée' || filter == 'Entrées') {
        return entries
            .where((e) => e.typeOperation.toLowerCase() == 'entrée')
            .toList();
      } else if (filter == 'Sortie' || filter == 'Sorties') {
        return entries
            .where((e) => e.typeOperation.toLowerCase() == 'sortie')
            .toList();
      }

      return entries;
    } catch (e) {
      print('Erreur lors de la récupération des entrées du journal: $e');
      return [];
    }
  }

  /// Calcule le solde actuel de la caisse
  Future<double> getSoldeCaisse() async {
    final dao = ref.watch(journalComptableDaoProvider);
    final authState = await ref.read(authNotifierProvider.future);

    if (authState.entrepriseId == null) {
      return 0.0;
    }

    try {
      // Récupérer toutes les entrées
      final totalEntrees =
          await dao.getTotalByTypeOperation(
            'Entrée',
            authState.entrepriseId!,
          ) ??
          0.0;

      // Récupérer toutes les sorties
      final totalSorties =
          await dao.getTotalByTypeOperation(
            'Sortie',
            authState.entrepriseId!,
          ) ??
          0.0;

      return totalEntrees - totalSorties;
    } catch (e) {
      print('Erreur lors du calcul du solde de caisse: $e');
      return 0.0;
    }
  }

  /// Enregistre une sortie de caisse (dépense)
  Future<void> insertSortieCaisse({
    required int entrepriseId,
    required double montant,
    required String libelle,
    required int compteDestinationId,
    String? pieceJustification,
    String? observation,
    required int userId,
  }) async {
    final dao = ref.watch(journalComptableDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    try {
      final now = DateTime.now();

      // Construire le libellé complet avec les informations additionnelles
      String libelleComplet = libelle;
      if (pieceJustification != null && pieceJustification.isNotEmpty) {
        libelleComplet += ' (Ref: $pieceJustification)';
      }
      if (observation != null && observation.isNotEmpty) {
        libelleComplet += ' - $observation';
      }

      final nouveauJournal = JournalComptable(
        entrepriseId: entrepriseId,
        typeOperation: 'Sortie',
        montant: montant,
        libelle: libelleComplet,
        dateOperation: now,
        isSync: false,
        dateCreation: now,
        dateModification: now,
        updatedAt: now,
      );

      await dao.insertJournalComptable(nouveauJournal);
      ref.invalidateSelf();

      if (isConnected) {
        try {
          await syncNotifier.uploadSingleEntity(
            nouveauJournal,
            'journaux_comptables',
            'create',
            userEmail: 'admin@testschool.com',
          );
        } catch (e) {
          print('Erreur lors de l\'upload de la sortie de caisse: $e');
        }
      }
    } catch (e) {
      print('Erreur lors de l\'enregistrement de la sortie de caisse: $e');
      rethrow;
    }
  }
}

/// Provider pour la liste des périodes
@riverpod
class PeriodesNotifier extends _$PeriodesNotifier {
  @override
  Future<List<Periode>> build() async {
    final dao = ref.watch(periodeDaoProvider);
    return await dao.getAllPeriodes();
  }

  Future<void> refresh(List<Periode> periodes) async {
    final dao = ref.watch(periodeDaoProvider);
    try {
      await dao.insertPeriodes(periodes);
      ref.invalidateSelf();
    } catch (e) {
      print('Erreur lors du rafraîchissement des périodes: $e');
    }
  }

  Future<void> addPeriode(Periode periode) async {
    final dao = ref.watch(periodeDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    periode.isSync = false;
    await dao.insertPeriode(periode);
    ref.invalidateSelf();

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          periode,
          'periodes',
          'create',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de l\'upload de la période: $e');
      }
    }
  }

  Future<void> updatePeriode(Periode periode) async {
    final dao = ref.watch(periodeDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    periode.isSync = false;
    await dao.updatePeriode(periode);
    ref.invalidateSelf();

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          periode,
          'periodes',
          'update',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de la mise à jour de la période: $e');
      }
    }
  }

  Future<void> deletePeriode(Periode periode) async {
    final dao = ref.watch(periodeDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          periode,
          'periodes',
          'delete',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de la suppression de la période via API: $e');
      }
    }

    await dao.deletePeriode(periode);
    ref.invalidateSelf();
  }
}

@riverpod
class FraisClassesNotifier extends _$FraisClassesNotifier {
  @override
  Future<List<FraisClasses>> build() async {
    final dao = ref.watch(fraisClassesDaoProvider);
    return await dao.getAllFraisClasses();
  }

  Future<void> refresh(List<FraisClasses> fraisClasses) async {
    final dao = ref.watch(fraisClassesDaoProvider);
    try {
      await dao.insertFraisClasses(fraisClasses);
      ref.invalidateSelf();
    } catch (e) {
      print('Erreur lors du rafraîchissement des frais classes: $e');
    }
  }

  Future<void> addFraisClasse(FraisClasses fraisClasse) async {
    final dao = ref.watch(fraisClassesDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    fraisClasse.isSync = false;
    await dao.insertFraisClasse(fraisClasse);
    ref.invalidateSelf();

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          fraisClasse,
          'frais_classes',
          'create',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de l\'upload du frais classe: $e');
      }
    }
  }

  Future<void> updateFraisClasse(FraisClasses fraisClasse) async {
    final dao = ref.watch(fraisClassesDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    fraisClasse.isSync = false;
    await dao.updateFraisClasse(fraisClasse);
    ref.invalidateSelf();

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          fraisClasse,
          'frais_classes',
          'update',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de l\'upload du frais classe: $e');
      }
    }
  }

  Future<void> deleteFraisClasse(FraisClasses fraisClasse) async {
    final dao = ref.watch(fraisClassesDaoProvider);
    final isConnected = ref.read(isConnectedProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    if (isConnected) {
      try {
        await syncNotifier.uploadSingleEntity(
          fraisClasse,
          'frais_classes',
          'delete',
          userEmail: 'admin@testschool.com',
        );
      } catch (e) {
        print('Erreur lors de la suppression du frais classe via API: $e');
      }
    }

    await dao.deleteFraisClasse(fraisClasse);
    ref.invalidateSelf();
  }
}
