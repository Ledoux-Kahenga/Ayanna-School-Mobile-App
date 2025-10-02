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

  static Future<String> getNomEcole() async {
    final db = await DatabaseService.database;
    final result = await db.query('entreprises', columns: ['nom'], limit: 1);
    if (result.isNotEmpty) {
      return result.first['nom'] as String? ?? 'École';
    }
    return 'École';
  }

  static Future<int> insertEntreprise(
    Map<String, dynamic> entrepriseData,
  ) async {
    final db = await DatabaseService.database;
    final now = DateTime.now().toIso8601String();

    // Ajouter les champs de date
    if (!entrepriseData.containsKey('date_creation')) {
      entrepriseData['date_creation'] = now;
    }
    if (!entrepriseData.containsKey('date_modification')) {
      entrepriseData['date_modification'] = now;
    }
    entrepriseData['updated_at'] = now;

    return await db.insert('entreprises', entrepriseData);
  }

  static Future<int> updateEntreprise(
    int entrepriseId,
    Map<String, dynamic> entrepriseData,
  ) async {
    final db = await DatabaseService.database;
    final now = DateTime.now().toIso8601String();

    // Ajouter les champs de date
    entrepriseData['date_modification'] = now;
    entrepriseData['updated_at'] = now;

    return await db.update(
      'entreprises',
      entrepriseData,
      where: 'id = ?',
      whereArgs: [entrepriseId],
    );
  }

  // [########### REQUÊTES POUR LES UTILISATEURS [###########]
  static Future<List<Utilisateur>> getAllUtilisateurs() async {
    final db = await DatabaseService.database;
    final result = await db.query('utilisateurs');
    return result.map((e) => Utilisateur.fromMap(e)).toList();
  }

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

  static Future<int> insertUtilisateur(Map<String, dynamic> userData) async {
    final db = await DatabaseService.database;
    final now = DateTime.now().toIso8601String();

    // Ajouter les champs de date
    userData['date_creation'] = now;
    userData['date_modification'] = now;
    userData['updated_at'] = now;

    return await db.insert('utilisateurs', userData);
  }

  static Future<int> updateUtilisateur(
    int userId,
    Map<String, dynamic> userData,
  ) async {
    final db = await DatabaseService.database;
    final now = DateTime.now().toIso8601String();

    // Ajouter le champ updated_at
    userData['updated_at'] = now;

    return await db.update(
      'utilisateurs',
      userData,
      where: 'id = ?',
      whereArgs: [userId],
    );
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

  static Future<int> insertAnneeScolaire(Map<String, dynamic> anneeData) async {
    final db = await DatabaseService.database;
    final now = DateTime.now().toIso8601String();

    // Ajouter les champs de date
    anneeData['date_creation'] = now;
    anneeData['date_modification'] = now;
    anneeData['updated_at'] = now;

    return await db.insert('annees_scolaires', anneeData);
  }

  static Future<int> updateAnneeScolaire(
    int anneeId,
    Map<String, dynamic> anneeData,
  ) async {
    final db = await DatabaseService.database;
    final now = DateTime.now().toIso8601String();

    // Ajouter le champ updated_at
    anneeData['updated_at'] = now;

    return await db.update(
      'annees_scolaires',
      anneeData,
      where: 'id = ?',
      whereArgs: [anneeId],
    );
  }

  static Future<void> setCurrentSchoolYear(int yearId) async {
    final db = await DatabaseService.database;
    final now = DateTime.now().toIso8601String();

    await db.update('annees_scolaires', {'en_cours': 0, 'updated_at': now});
    await db.update(
      'annees_scolaires',
      {'en_cours': 1, 'updated_at': now},
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
    final now = DateTime.now().toIso8601String();

    // Ajouter les champs de date
    eleveData['date_creation'] = now;
    eleveData['date_modification'] = now;
    eleveData['updated_at'] = now;

    return await db.insert('eleves', eleveData);
  }

  static Future<int> updateEleve(
    int eleveId,
    Map<String, dynamic> eleveData,
  ) async {
    final db = await DatabaseService.database;
    final now = DateTime.now().toIso8601String();

    // Ajouter le champ updated_at
    eleveData['updated_at'] = now;

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
    final result = await db.query(
      'responsables',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? Responsable.fromMap(result.first) : null;
  }

  static Future<int> insertResponsable(Map<String, dynamic> data) async {
    final db = await DatabaseService.database;
    final now = DateTime.now().toIso8601String();

    // Ajouter les champs de date
    data['date_creation'] = now;
    data['date_modification'] = now;
    data['updated_at'] = now;

    return await db.insert('responsables', data);
  }

  static Future<int> updateResponsable(
    int id,
    Map<String, dynamic> data,
  ) async {
    final db = await DatabaseService.database;
    final now = DateTime.now().toIso8601String();

    // Ajouter le champ updated_at
    data['updated_at'] = now;

    return await db.update(
      'responsables',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
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

  static Future<int> insertClasse(Map<String, dynamic> classeData) async {
    final db = await DatabaseService.database;
    final now = DateTime.now().toIso8601String();

    // Ajouter les champs de date
    classeData['date_creation'] = now;
    classeData['date_modification'] = now;
    classeData['updated_at'] = now;

    return await db.insert('classes', classeData);
  }

  static Future<int> updateClasse(
    int classeId,
    Map<String, dynamic> classeData,
  ) async {
    final db = await DatabaseService.database;
    final now = DateTime.now().toIso8601String();

    // Ajouter le champ updated_at
    classeData['updated_at'] = now;

    return await db.update(
      'classes',
      classeData,
      where: 'id = ?',
      whereArgs: [classeId],
    );
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

  static Future<int> insertFraisScolaire(Map<String, dynamic> fraisData) async {
    final db = await DatabaseService.database;
    final now = DateTime.now().toIso8601String();

    // Ajouter les champs de date
    fraisData['date_creation'] = now;
    fraisData['date_modification'] = now;
    fraisData['updated_at'] = now;

    return await db.insert('frais_scolaires', fraisData);
  }

  static Future<int> updateFraisScolaire(
    int fraisId,
    Map<String, dynamic> fraisData,
  ) async {
    final db = await DatabaseService.database;
    final now = DateTime.now().toIso8601String();

    // Ajouter le champ updated_at
    fraisData['updated_at'] = now;

    return await db.update(
      'frais_scolaires',
      fraisData,
      where: 'id = ?',
      whereArgs: [fraisId],
    );
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
      final frais = await txn.query(
        'frais_scolaires',
        where: 'id = ?',
        whereArgs: [fraisId],
      );
      if (frais.isEmpty) throw Exception("Frais scolaire introuvable.");

      final eleve = await txn.query(
        'eleves',
        where: 'id = ?',
        whereArgs: [eleveId],
      );
      if (eleve.isEmpty) throw Exception("Élève introuvable.");

      final nomEleve =
          '${eleve.first['nom']} ${eleve.first['postnom'] ?? ''} ${eleve.first['prenom']}';
      final libelle = 'Paiement : ${frais.first['nom']} ${nomEleve.trim()}';

      final paiementsExistants = await txn.query(
        'paiement_frais',
        where: 'eleve_id = ? AND frais_scolaire_id = ?',
        whereArgs: [eleveId, fraisId],
      );
      final montantDejaPaye = paiementsExistants.fold<double>(
        0.0,
        (sum, p) => sum + (p['montant_paye'] as num),
      );
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
        'date_creation': now,
        'updated_at': now,
        'date_modification': now,
      });

      final journalId = await txn.insert('journaux_comptables', {
        'date_operation': now,
        'libelle': libelle,
        'montant': montant,
        'type_operation': 'Entrée',
        'paiement_frais_id': newPaiementId,
        'entreprise_id': entrepriseId,
        'date_creation': now,
        'date_modification': now,
        'updated_at': now,
      });

      print(
        '🔍 Recherche configuration comptable pour entreprise_id: $entrepriseId',
      );
      final config = await txn.query(
        'comptes_config',
        where: 'entreprise_id = ?',
        whereArgs: [entrepriseId],
      );
      print('📋 Configurations trouvées: ${config.length}');
      if (config.isNotEmpty) {
        print('✅ Configuration: ${config.first}');
      }

      if (config.isEmpty) {
        // Vérifier toutes les configurations disponibles
        final allConfigs = await txn.query('comptes_config');
        print('❌ Aucune config pour entreprise $entrepriseId');
        print('📊 Toutes les configs disponibles: $allConfigs');
        throw Exception(
          "Configuration comptable introuvable pour entreprise_id $entrepriseId",
        );
      }

      final compteCaisseId = config.first['compte_caisse_id'];
      final compteFraisId = config.first['compte_frais_id'];

      await txn.insert('ecritures_comptables', {
        'journal_id': journalId,
        'compte_comptable_id': compteCaisseId,
        'debit': montant,
        'credit': 0,
        'ordre': 1,
        'date_ecriture': now,
        'date_creation': now,
        'date_modification': now,
        'updated_at': now,
      });

      await txn.insert('ecritures_comptables', {
        'journal_id': journalId,
        'compte_comptable_id': compteFraisId,
        'debit': 0,
        'credit': montant,
        'ordre': 2,
        'date_ecriture': now,
        'date_creation': now,
        'date_modification': now,
        'updated_at': now,
      });
    });

    return newPaiementId;
  }

  // [NOUVEAU] Récupère l'entreprise_id active depuis la config_ecole
  static Future<int> getCurrentEntrepriseId() async {
    final db = await DatabaseService.database;
    final result = await db.query('config_ecole', limit: 1);

    if (result.isNotEmpty) {
      final entrepriseId = result.first['entreprise_id'] as int;
      print('🏢 Entreprise active trouvée: $entrepriseId');
      return entrepriseId;
    }

    // Si pas de config, prendre la première entreprise disponible
    print('⚠️ Pas de config_ecole, utilisation de la première entreprise');
    final entreprises = await getAllEntreprises();
    if (entreprises.isEmpty) {
      throw Exception('Aucune entreprise trouvée dans la base de données');
    }
    return entreprises.first.id;
  }

  static Future<void> enregistrerPaiement({
    required int eleveId,
    required int fraisId,
    required double montant,
  }) async {
    const int currentUserId = 2;

    // Récupérer l'entreprise_id depuis la configuration active
    final int currentEntrepriseId = 68;

    print('🏢 Utilisation entreprise_id: $currentEntrepriseId');

    await insertPaiement(
      eleveId,
      fraisId,
      montant,
      currentUserId,
      currentEntrepriseId,
    );
  }

  static Future<EleveFraisDetails> getEleveFraisDetails(int eleveId) async {
    final db = await DatabaseService.database;

    final eleveResult = await db.query(
      'eleves',
      where: 'id = ?',
      whereArgs: [eleveId],
    );
    if (eleveResult.isEmpty) throw Exception('Élève non trouvé');
    final eleve = Eleve.fromMap(eleveResult.first);

    final fraisListResult = await db.rawQuery(
      '''
      SELECT fs.* FROM frais_scolaires fs
      JOIN frais_classes fc ON fs.id = fc.frais_id
      WHERE fc.classe_id = ?
    ''',
      [eleve.classeId],
    );
    final fraisList = fraisListResult
        .map((f) => FraisScolaire.fromMap(f))
        .toList();

    List<FraisDetails> fraisDetailsList = [];
    for (final frais in fraisList) {
      final paiements = await getPaiementsByEleveAndFrais(eleveId, frais.id);
      final montantPaye = paiements.fold<double>(
        0.0,
        (sum, p) => sum + p.montantPaye,
      );
      final resteAPayer = frais.montant - montantPaye;

      String statut = (resteAPayer <= 0)
          ? 'en_ordre'
          : (montantPaye > 0 ? 'partiellement_paye' : 'pas_en_ordre');

      fraisDetailsList.add(
        FraisDetails(
          frais: frais,
          montantPaye: montantPaye,
          resteAPayer: resteAPayer,
          historiquePaiements: paiements,
          statut: statut,
        ),
      );
    }

    return EleveFraisDetails(eleve: eleve, fraisDetails: fraisDetailsList);
  }

  // [NOUVEAU] Récupère tous les paiements pour un élève
  static Future<List<PaiementFrais>> getPaiementsByEleve(int eleveId) async {
    final db = await DatabaseService.database;
    final result = await db.query(
      'paiement_frais',
      where: 'eleve_id = ?',
      whereArgs: [eleveId],
    );
    return result.map((e) => PaiementFrais.fromMap(e)).toList();
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
      orderBy: 'numero',
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
        'updated_at': now,
      });

      final journalId = await txn.insert('journaux_comptables', {
        'date_operation': now,
        'libelle': libelle,
        'montant': montant,
        'type_operation': 'Sortie',
        'entreprise_id': entrepriseId,
        'date_creation': now,
        'date_modification': now,
        'updated_at': now,
      });

      await txn.update(
        'depenses',
        {'journal_id': journalId, 'updated_at': now},
        where: 'id = ?',
        whereArgs: [depenseId],
      );

      final config = await txn.query(
        'comptes_config',
        where: 'entreprise_id = ?',
        whereArgs: [entrepriseId],
      );
      if (config.isEmpty)
        throw Exception("Configuration comptable introuvable.");

      final compteCaisseId = config.first['compte_caisse_id'];

      await txn.insert('ecritures_comptables', {
        'journal_id': journalId,
        'compte_comptable_id': compteDestinationId,
        'debit': montant,
        'credit': 0,
        'ordre': 1,
        'date_ecriture': now,
        'date_creation': now,
        'date_modification': now,
        'updated_at': now,
      });

      await txn.insert('ecritures_comptables', {
        'journal_id': journalId,
        'compte_comptable_id': compteCaisseId,
        'debit': 0,
        'credit': montant,
        'ordre': 2,
        'date_ecriture': now,
        'date_creation': now,
        'date_modification': now,
        'updated_at': now,
      });
    });
  }

  // Logique pour le tableau de bord de la classe
  static Future<Map<String, dynamic>> getDashboardDataForFrais(
    int classeId,
    int fraisId,
  ) async {
    final db = await DatabaseService.database;

    final eleves = await getElevesByClasse(classeId);
    final totalEleves = eleves.length;

    if (totalEleves == 0) {
      return {
        'totalEleves': 0,
        'enOrdre': 0,
        'pasEnOrdre': 0,
        'totalAttendu': 0.0,
        'totalRecu': 0.0,
      };
    }

    final frais = await getFraisScolaireById(fraisId);
    final montantFrais = frais?.montant ?? 0.0;

    double totalRecu = 0;
    int enOrdre = 0;

    for (final eleve in eleves) {
      final paiements = await getPaiementsByEleveAndFrais(eleve.id, fraisId);
      final montantPayePourEleve = paiements.fold<double>(
        0.0,
        (sum, p) => sum + p.montantPaye,
      );
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

  // NOUVELLE MÉTHODE pour calculer le solde de la caisse
  static Future<double> getSoldeCaisse() async {
    final db = await DatabaseService.database;
    // Calcule la somme de toutes les entrées
    final entreesResult = await db.rawQuery(
      "SELECT SUM(montant) as total FROM journaux_comptables WHERE type_operation = 'Entrée'",
    );
    final double entrees =
        (entreesResult.first['total'] as num?)?.toDouble() ?? 0.0;

    // Calcule la somme de toutes les sorties
    final sortiesResult = await db.rawQuery(
      "SELECT SUM(montant) as total FROM journaux_comptables WHERE type_operation = 'Sortie'",
    );
    final double sorties =
        (sortiesResult.first['total'] as num?)?.toDouble() ?? 0.0;

    return entrees - sorties;
  }

  static Future<void> updateCurrentAnneeScolaire(int anneeId) async {
    final db = await DatabaseService.database;
    await db.transaction((txn) async {
      final now = DateTime.now().toIso8601String();

      await txn.update('annees_scolaires', {'en_cours': 0, 'updated_at': now});
      await txn.update(
        'annees_scolaires',
        {'en_cours': 1, 'updated_at': now},
        where: 'id = ?',
        whereArgs: [anneeId],
      );
    });
  }

  // [########### REQUÊTES POUR LES ÉCRITURES COMPTABLES ###########]

  /// Récupère toutes les écritures comptables
  static Future<List<EcritureComptable>> getAllEcrituresComptables() async {
    final db = await DatabaseService.database;
    final result = await db.query(
      'ecritures_comptables',
      orderBy: 'date_ecriture DESC, ordre ASC',
    );
    return result.map((e) => EcritureComptable.fromMap(e)).toList();
  }

  /// Récupère les écritures comptables pour un journal spécifique
  static Future<List<EcritureComptable>> getEcrituresByJournal(
    int journalId,
  ) async {
    final db = await DatabaseService.database;
    final result = await db.query(
      'ecritures_comptables',
      where: 'journal_id = ?',
      whereArgs: [journalId],
      orderBy: 'ordre ASC',
    );
    return result.map((e) => EcritureComptable.fromMap(e)).toList();
  }

  /// Récupère les écritures comptables pour un compte spécifique
  static Future<List<EcritureComptable>> getEcrituresByCompte(
    int compteId,
  ) async {
    final db = await DatabaseService.database;
    final result = await db.query(
      'ecritures_comptables',
      where: 'compte_comptable_id = ?',
      whereArgs: [compteId],
      orderBy: 'date_ecriture DESC, ordre ASC',
    );
    return result.map((e) => EcritureComptable.fromMap(e)).toList();
  }

  /// Récupère les écritures comptables pour une période donnée
  static Future<List<EcritureComptable>> getEcrituresByPeriod({
    required DateTime dateDebut,
    required DateTime dateFin,
  }) async {
    final db = await DatabaseService.database;
    final result = await db.query(
      'ecritures_comptables',
      where: 'DATE(date_ecriture) BETWEEN ? AND ?',
      whereArgs: [
        dateDebut.toIso8601String().substring(0, 10),
        dateFin.toIso8601String().substring(0, 10),
      ],
      orderBy: 'date_ecriture DESC, ordre ASC',
    );
    return result.map((e) => EcritureComptable.fromMap(e)).toList();
  }
}
