import 'package:sqflite/sqflite.dart';

import '../services/database_service.dart';
import '../models/models.dart';
  
class SchoolQueries {

  // [########### REQUÊTES POUR LES ENTREPRISES [###########]
  static Future<List<Entreprise>> getAllEntreprises() async {
    final db = await DatabaseService.database;
    final result = await db.query('entreprises');
    return result.map((e) => Entreprise.fromMap(e)).toList();
  } 

  static Future<Entreprise?> getEntrepriseById(int id) async {
  final db = await DatabaseService.database;
  final result = await db.query(
    'entreprises',
    where: 'id = ?',
    whereArgs: [id],
    limit: 1,
  );
  if (result.isNotEmpty) {
    return Entreprise.fromMap(result.first);
  }
  return null;
}

  // [########### REQUÊTES POUR LES UTILISATEURS [###########]
  static Future<Utilisateur?> authenticateUser(
    String username,
    String password,
  ) async {
    final db = await DatabaseService.database;
    final result = await db.query(
      'utilisateurs',
      where: 'nom = ? AND mot_de_passe = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty ? Utilisateur.fromMap(result.first) : null;
  }

     // [########### REQUÊTES POUR LES ANNEES SCOLAIRES [###########]
  static Future<List<AnneeScolaire>> getAllAnneesScolaires() async {
    final db = await DatabaseService.database;
    final result = await db.query('annees_scolaires');
    return result.map((e) => AnneeScolaire.fromMap(e)).toList();
  }

  
  static Future<AnneeScolaire?> getCurrentAnneeScolaire() async {
    final db = await DatabaseService.database;
    final result = await db.query(
      'annees_scolaires',
      where: 'en_cours = ?',
      whereArgs: [1],
      limit: 1, 
    );
    return result.isNotEmpty ? AnneeScolaire.fromMap(result.first) : null;
  }

  static Future<void> setCurrentSchoolYear(int yearId) async {
    final db = await DatabaseService.database;
    await db.update('annees_scolaires', {'en_cours': 0});
    await db.update(
      'annees_scolaires',
      {'en_cours': 1},
      where: 'id = ?',
      whereArgs: [yearId],
    );
  }

 // [########### REQUÊTES POUR LES ELEVES [###########]
  static Future<List<Eleve>> getEleves() async {
    final db = await DatabaseService.database;
    final result = await db.rawQuery('''
      SELECT e.*, c.nom as classe_nom
      FROM eleves e
      LEFT JOIN classes c ON e.classe_id = c.id
    ''');
    return result.map((e) => Eleve.fromMap(e)).toList();
  }

  static Future<List<Eleve>> getElevesByAnnee(int anneeScolaireId) async {
    final db = await DatabaseService.database;
    final result = await db.rawQuery(
      '''
      SELECT e.*, c.nom AS classe_nom
      FROM eleves AS e
      JOIN classes AS c ON e.classe_id = c.id
      WHERE c.annee_scolaire_id = ?
    ''',
      [anneeScolaireId],
    );
    return result.map((e) => Eleve.fromMap(e)).toList();
  }

  static Future<List<Eleve>> getElevesByClasse(int classeId) async {
    final db = await DatabaseService.database;
    final result = await db.query(
      'eleves',
      where: 'classe_id = ?',
      whereArgs: [classeId],
    );
    return result.map((e) => Eleve.fromMap(e)).toList();
  }

  static Future<Eleve?> getEleveById(int id) async {
    final db = await DatabaseService.database;
    final result = await db.query(
      'eleves',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return Eleve.fromMap(result.first);
    }
    return null;
  }

  static Future<int> insertEleve(Map<String, dynamic> eleveData) async {
    final db = await DatabaseService.database;
    return await db.insert('eleves', eleveData);
  }

  static Future<int> updateEleve(
    int eleveId,
    Map<String, dynamic> eleveData,
  ) async {
    final db = await DatabaseService.database;
    return await db.update(
      'eleves',
      eleveData,
      where: 'id = ?',
      whereArgs: [eleveId],
    );
  }

  // [########### REQUÊTES POUR LES RESPONSABLES [###########]
  static Future<Responsable?> getResponsableById(int id) async {
    final db = await DatabaseService.database;
    final result = await db.query('responsables_old', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? Responsable.fromMap(result.first) : null;
  }

  static Future<int> updateResponsable(int id, Map<String, dynamic> data) async {
    final db = await DatabaseService.database;
    return await db.update('responsables_old', data, where: 'id = ?', whereArgs: [id]);
  }

  // [########### REQUÊTES POUR LES CLASSES [###########]
  static Future<List<Classe>> getClassesByAnnee(int anneeScolaireId) async {
    final db = await DatabaseService.database;
    final result = await db.query(
      'classes',
      where: 'annee_scolaire_id = ?',
      whereArgs: [anneeScolaireId],
    );
    return result.map((e) => Classe.fromMap(e)).toList();
  }

  // [########### REQUÊTES POUR LES FRAIS SCOLAIRES [###########]
  static Future<List<FraisScolaire>> getAllFraisByClasse(int classeId) async {
    final db = await DatabaseService.database;
    final result = await db.rawQuery(
      '''
      SELECT fs.*
      FROM frais_scolaires fs
      INNER JOIN frais_classes fc ON fs.id = fc.frais_id
      WHERE fc.classe_id = ?
    ''',
      [classeId],
    );
    return result.map((e) => FraisScolaire.fromMap(e)).toList();
  }

  static Future<FraisScolaire?> getFraisScolaireById(int fraisId) async {
    final db = await DatabaseService.database;
    final result = await db.query(
      'frais_scolaires',
      where: 'id = ?',
      whereArgs: [fraisId],
    );
    return result.isNotEmpty ? FraisScolaire.fromMap(result.first) : null;
  }

// [########### REQUÊTES POUR LES PAIEMENTS [###########]
  static Future<List<PaiementFrais>> getPaiementsByEleveAndFrais(
    int eleveId,
    int fraisId,
  ) async {
    final db = await DatabaseService.database;
    final result = await db.query(
      'paiement_frais',
      where: 'eleve_id = ? AND frais_scolaire_id = ?',
      whereArgs: [eleveId, fraisId],
    );
    return result.map((e) => PaiementFrais.fromMap(e)).toList();
  }

  static Future<int> insertPaiement(
    int eleveId,
    int fraisId,
    double montant,
    int userId,
    int entrepriseId,
  ) async {
    final db = await DatabaseService.database;
    int newPaiementId = 0;

    await db.transaction((txn) async {
      final now = DateTime.now().toIso8601String();
      final frais = await txn.query('frais_scolaires', where: 'id = ?', whereArgs: [fraisId]);
      if (frais.isEmpty) throw Exception("Frais scolaire introuvable.");

      final eleve = await txn.query('eleves', where: 'id = ?', whereArgs: [eleveId]);
      if (eleve.isEmpty) throw Exception("Élève introuvable.");

      final nomEleve = '${eleve.first['nom']} ${eleve.first['postnom'] ?? ''} ${eleve.first['prenom']}';
      final libelle = 'Paiement : ${frais.first['nom']} ${nomEleve.trim()}';

      final paiementsExistants = await txn.query('paiement_frais', where: 'eleve_id = ? AND frais_scolaire_id = ?', whereArgs: [eleveId, fraisId]);
      final montantDejaPaye = paiementsExistants.fold<double>(0.0, (sum, p) => sum + (p['montant_paye'] as num));
      final totalFrais = frais.first['montant'] as num;
      final resteAPayer = totalFrais - montantDejaPaye - montant;
      
      newPaiementId = await txn.insert('paiement_frais', {
        'eleve_id': eleveId,
        'frais_scolaire_id': fraisId,
        'montant_paye': montant,
        'date_paiement': now.split('T').first,
        'reste_a_payer': resteAPayer > 0 ? resteAPayer : 0,
        'statut': resteAPayer <= 0 ? 'complet' : 'partiel',
        'user_id': userId,
      });

      final journalId = await txn.insert('journaux_comptables', {
        'date_operation': now,
        'libelle': libelle,
        'montant': montant,
        'type_operation': 'Entrée',
        'paiement_frais_id': newPaiementId,
        'entreprise_id': entrepriseId,
        'created_at': now,
        'date_creation': now,
        'date_modification': now,
      });

      final config = await txn.query('comptes_config', where: 'entreprise_id = ?', whereArgs: [entrepriseId]);
      if (config.isEmpty) throw Exception("Configuration comptable introuvable.");

      final compteCaisseId = config.first['compte_caisse_id'];
      final compteFraisId = config.first['compte_frais_id'];

      await txn.insert('ecritures_comptables', {
        'journal_id': journalId,
        'compte_comptable_id': compteCaisseId,
        'debit': montant,
        'credit': 0,
        'ordre': 1,
        'created_at': now,
        'date_creation': now,
        'date_modification': now,
      });

      await txn.insert('ecritures_comptables', {
        'journal_id': journalId,
        'compte_comptable_id': compteFraisId,
        'debit': 0,
        'credit': montant,
        'ordre': 2,
        'created_at': now,
        'date_creation': now,
        'date_modification': now,
      });
    });

    return newPaiementId;
  }
  
  static Future<void> enregistrerPaiement({
    required int eleveId,
    required int fraisId,
    required double montant,
  }) async {
    const int currentUserId = 2; 
    const int currentEntrepriseId = 2;
    
    await insertPaiement(eleveId, fraisId, montant, currentUserId, currentEntrepriseId);
  }

  static Future<EleveFraisDetails> getEleveFraisDetails(int eleveId) async {
    final db = await DatabaseService.database;

    final eleveResult = await db.query('eleves', where: 'id = ?', whereArgs: [eleveId]);
    if (eleveResult.isEmpty) throw Exception('Élève non trouvé');
    final eleve = Eleve.fromMap(eleveResult.first);

    final fraisListResult = await db.rawQuery('''
      SELECT fs.* FROM frais_scolaires fs
      JOIN frais_classes fc ON fs.id = fc.frais_id
      WHERE fc.classe_id = ?
    ''', [eleve.classeId]);
    final fraisList = fraisListResult.map((f) => FraisScolaire.fromMap(f)).toList();

    List<FraisDetails> fraisDetailsList = [];
    for (final frais in fraisList) {
      final paiements = await getPaiementsByEleveAndFrais(eleveId, frais.id);
      final montantPaye = paiements.fold<double>(0.0, (sum, p) => sum + p.montantPaye);
      final resteAPayer = frais.montant - montantPaye;

      String statut = (resteAPayer <= 0) ? 'en_ordre' : (montantPaye > 0 ? 'partiellement_paye' : 'pas_en_ordre');

      fraisDetailsList.add(FraisDetails(
        frais: frais,
        montantPaye: montantPaye,
        resteAPayer: resteAPayer,
        historiquePaiements: paiements,
        statut: statut,
      ));
    }

    return EleveFraisDetails(eleve: eleve, fraisDetails: fraisDetailsList);
  }

  // --- [######### REQUÊTES POUR LE JOURNAL DE CAISSE ##########] ---

  static Future<List<JournalComptable>> getJournalEntries(
    DateTime date, {
    String filter = 'Tous',
  }) async {
    final db = await DatabaseService.database;
    final dateString = date.toIso8601String().split('T').first;

    String whereClause = 'DATE(date_operation) = ?';
    List<dynamic> whereArgs = [dateString];

    if (filter != 'Tous') {
      whereClause += ' AND type_operation = ?';
      whereArgs.add(filter);
    }

    final result = await db.query(
      'journaux_comptables',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'date_operation DESC',
    );

    return result.map((map) => JournalComptable.fromMap(map)).toList();
  }

  // --- [######### REQUÊTES POUR LES DÉPENSES (SORTIES DE CAISSE) ##########] ---
  
  // [CORRIGÉ] La fonction ne retourne que les comptes de charges (classe 6)
  static Future<List<CompteComptable>> getComptesComptables() async {
    final db = await DatabaseService.database;
    final result = await db.query(
      'comptes_comptables', 
      where: 'classe_comptable_id = ?', 
      whereArgs: [6], // ID de la classe "Charges"
      orderBy: 'numero'
    );
    return result.map((map) => CompteComptable.fromMap(map)).toList();
  }

  static Future<void> insertSortieCaisse({
    required int entrepriseId,
    required double montant,
    required String libelle,
    required int compteDestinationId,
    String? pieceJustification,
    String? observation,
    int? userId,
  }) async {
    final db = await DatabaseService.database;

    await db.transaction((txn) async {
      final now = DateTime.now().toIso8601String();

      final depenseId = await txn.insert('depenses', {
        'libelle': libelle,
        'montant': montant,
        'date_depense': now,
        'entreprise_id': entrepriseId,
        'piece': pieceJustification,
        'observation': observation,
        'user_id': userId,
        'date_creation': now,
        'date_modification': now,
      });

      final journalId = await txn.insert('journaux_comptables', {
        'date_operation': now,
        'libelle': libelle,
        'montant': montant,
        'type_operation': 'Sortie',
        'entreprise_id': entrepriseId,
        'created_at': now,
        'date_creation': now,
        'date_modification': now,
      });
      
      await txn.update('depenses', {'journal_id': journalId}, where: 'id = ?', whereArgs: [depenseId]);

      final config = await txn.query('comptes_config', where: 'entreprise_id = ?', whereArgs: [entrepriseId]);
      if (config.isEmpty) throw Exception("Configuration comptable introuvable.");
      
      final compteCaisseId = config.first['compte_caisse_id'];

      await txn.insert('ecritures_comptables', {
        'journal_id': journalId,
        'compte_comptable_id': compteDestinationId,
        'debit': montant,
        'credit': 0,
        'ordre': 1,
        'created_at': now,
        'date_creation': now,
        'date_modification': now,
      });

      await txn.insert('ecritures_comptables', {
        'journal_id': journalId,
        'compte_comptable_id': compteCaisseId,
        'debit': 0,
        'credit': montant,
        'ordre': 2,
        'created_at': now,
        'date_creation': now,
        'date_modification': now,
      });
    });
  }

  // Logique pour le tableau de bord de la classe
  static Future<Map<String, dynamic>> getDashboardDataForFrais(int classeId, int fraisId) async {
    final db = await DatabaseService.database;

    final eleves = await getElevesByClasse(classeId);
    final totalEleves = eleves.length;

    if (totalEleves == 0) {
      return {
        'totalEleves': 0, 'enOrdre': 0, 'pasEnOrdre': 0, 
        'totalAttendu': 0.0, 'totalRecu': 0.0
      };
    }
    
    final frais = await getFraisScolaireById(fraisId);
    final montantFrais = frais?.montant ?? 0.0;

    double totalRecu = 0;
    int enOrdre = 0;
    
    for (final eleve in eleves) {
      final paiements = await getPaiementsByEleveAndFrais(eleve.id, fraisId);
      final montantPayePourEleve = paiements.fold<double>(0.0, (sum, p) => sum + p.montantPaye);
      totalRecu += montantPayePourEleve;
      if (montantPayePourEleve >= montantFrais) {
        enOrdre++;
      }
    }
    
    return {
      'totalEleves': totalEleves,
      'enOrdre': enOrdre,
      'pasEnOrdre': totalEleves - enOrdre,
      'totalAttendu': totalEleves * montantFrais,
      'totalRecu': totalRecu,
    };
  }
}