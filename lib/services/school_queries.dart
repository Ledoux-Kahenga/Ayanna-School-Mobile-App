import '../services/database_service.dart';
import '../models/models.dart';

class SchoolQueries {
  // Requêtes pour les utilisateurs
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

  // Requêtes pour les années scolaires
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
    );
    return result.isNotEmpty ? AnneeScolaire.fromMap(result.first) : null;
  }

  // Requêtes pour les classes
  static Future<List<Classe>> getClassesByAnnee(int anneeScolaireId) async {
    final db = await DatabaseService.database;
    final result = await db.query(
      'classes',
      where: 'annee_scolaire_id = ?',
      whereArgs: [anneeScolaireId],
    );
    return result.map((e) => Classe.fromMap(e)).toList();
  }

  // Insère un nouvel élève
  static Future<int> insertEleve(Map<String, dynamic> eleveData) async {
    final db = await DatabaseService.database;
    return await db.insert('eleves', eleveData);
  }

  // Met à jour un élève existant
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

  // Requêtes pour les élèves
  static Future<List<Eleve>> getElevesByClasse(int classeId) async {
    final db = await DatabaseService.database;
    final result = await db.query(
      'eleves',
      where: 'classe_id = ?',
      whereArgs: [classeId],
    );
    return result.map((e) => Eleve.fromMap(e)).toList();
  }

  // Requêtes pour les frais scolaires
  static Future<List<FraisScolaire>> getFraisByClasse(int classeId) async {
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

  static Future<FraisScolaire?> getPrincipalFraisByClasse(int classeId) async {
    final db = await DatabaseService.database;
    final fraisClasseResult = await db.query(
      'frais_classes',
      where: 'classe_id = ?',
      whereArgs: [classeId],
    );
    if (fraisClasseResult.isEmpty) return null;

    final fraisId = fraisClasseResult.first['frais_id'] as int;
    final fraisResult = await db.query(
      'frais_scolaires',
      where: 'id = ?',
      whereArgs: [fraisId],
    );
    return fraisResult.isNotEmpty
        ? FraisScolaire.fromMap(fraisResult.first)
        : null;
  }

  // Requêtes pour les paiements
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

  static Future<Map<String, dynamic>> getDashboardDataForClasse(
    int classeId,
  ) async {
    final db = await DatabaseService.database;

    // Récupère les élèves de la classe
    final eleves = await getElevesByClasse(classeId);
    final totalEleves = eleves.length;

    // Récupère le frais principal de la classe
    final fraisPrincipal = await getPrincipalFraisByClasse(classeId);
    if (fraisPrincipal == null) {
      return {
        'totalEleves': totalEleves,
        'enOrdre': 0,
        'pasEnOrdre': totalEleves,
        'totalAttendu': 0.0,
        'totalRecu': 0.0,
        'fraisNom': '',
      };
    }

    final montantFrais = fraisPrincipal.montant;
    final totalAttendu = montantFrais * totalEleves;

    // Récupère les paiements pour ce frais et cette classe
    final paiementResult = await db.rawQuery(
      '''
      SELECT SUM(pf.montant_paye) as total_recu, pf.eleve_id
      FROM paiement_frais pf
      INNER JOIN eleves e ON pf.eleve_id = e.id
      WHERE pf.frais_scolaire_id = ? AND e.classe_id = ?
      GROUP BY pf.eleve_id
    ''',
      [fraisPrincipal.id, classeId],
    );

    double totalRecu = 0;
    int enOrdre = 0;
    int pasEnOrdre = 0;

    for (final row in paiementResult) {
      final recu = row['total_recu'] ?? 0;
      final recuDouble = (recu is int
          ? recu.toDouble()
          : (recu is double ? recu : 0.0));
      totalRecu += recuDouble;

      if (recuDouble >= montantFrais) {
        enOrdre++;
      } else {
        pasEnOrdre++;
      }
    }

    // Les élèves sans paiement sont "pas en ordre"
    pasEnOrdre += totalEleves - paiementResult.length;

    return {
      'totalEleves': totalEleves,
      'enOrdre': enOrdre,
      'pasEnOrdre': pasEnOrdre,
      'totalAttendu': totalAttendu,
      'totalRecu': totalRecu,
      'fraisNom': fraisPrincipal.nom,
    };
  }

  // Requête pour enregistrer un paiement
  static Future<int> insertPaiement(PaiementFrais paiement) async {
    final db = await DatabaseService.database;
    return await db.insert('paiement_frais', {
      'eleve_id': paiement.eleveId,
      'frais_scolaire_id': paiement.fraisScolaireId,
      'montant_paye': paiement.montantPaye,
      'date_paiement': paiement.datePaiement,
      'reste_a_payer': paiement.resteAPayer,
      'statut': paiement.statut,
      'user_id': paiement.userId,
    });
  }

  // Marque une année scolaire comme en cours et désactive les autres
  static Future<void> setCurrentSchoolYear(int yearId) async {
    final db = await DatabaseService.database;
    // Désactive toutes les années scolaires
    await db.update('annees_scolaires', {'en_cours': 0});
    // Active l'année sélectionnée
    await db.update(
      'annees_scolaires',
      {'en_cours': 1},
      where: 'id = ?',
      whereArgs: [yearId],
    );
  }

  // Récupère tous les frais scolaires associés à une classe
  static Future<List<FraisScolaire>> getAllFraisByClasse(int classeId) async {
    final db = await DatabaseService.database;
    final result = await db.rawQuery(
      '''
      SELECT fs.*
      FROM frais_scolaires fs
      INNER JOIN frais_classes fc ON fs.id = fc.frais_id
      WHERE fc.classe_id = ?
      ORDER BY fs.nom
      ''',
      [classeId],
    );
    return result.map((e) => FraisScolaire.fromMap(e)).toList();
  }

  // Calcule les statistiques du tableau de bord pour un frais spécifique
  static Future<Map<String, dynamic>> getDashboardDataForFrais(
    int classeId,
    int fraisId,
  ) async {
    final db = await DatabaseService.database;

    // Nombre total d'élèves dans la classe
    final elevesResult = await db.query(
      'eleves',
      where: 'classe_id = ?',
      whereArgs: [classeId],
    );
    final totalEleves = elevesResult.length;

    // Récupère le frais
    final fraisResult = await db.query(
      'frais_scolaires',
      where: 'id = ?',
      whereArgs: [fraisId],
    );
    if (fraisResult.isEmpty) {
      return {
        'totalEleves': totalEleves,
        'enOrdre': 0,
        'pasEnOrdre': totalEleves,
        'totalAttendu': 0.0,
        'totalRecu': 0.0,
        'fraisNom': 'Aucun frais',
      };
    }

    final frais = FraisScolaire.fromMap(fraisResult.first);
    final montantFrais = frais.montant;

    // Calcule les paiements pour ce frais et cette classe
    final paiementResult = await db.rawQuery(
      '''
      SELECT e.id as eleve_id, 
             COALESCE(SUM(pf.montant_paye), 0) as total_paye
      FROM eleves e
      LEFT JOIN paiement_frais pf ON e.id = pf.eleve_id AND pf.frais_scolaire_id = ?
      WHERE e.classe_id = ?
      GROUP BY e.id
      ''',
      [fraisId, classeId],
    );

    int enOrdre = 0;
    int pasEnOrdre = 0;
    double totalAttendu = totalEleves * montantFrais;
    double totalRecu = 0.0;

    for (final row in paiementResult) {
      final paye = row['total_paye'];
      final payeDouble = (paye is int
          ? paye.toDouble()
          : (paye is double ? paye : 0.0));
      totalRecu += payeDouble;

      if (payeDouble >= montantFrais) {
        enOrdre++;
      } else {
        pasEnOrdre++;
      }
    }

    return {
      'totalEleves': totalEleves,
      'enOrdre': enOrdre,
      'pasEnOrdre': pasEnOrdre,
      'totalAttendu': totalAttendu,
      'totalRecu': totalRecu,
      'fraisNom': frais.nom,
    };
  }

  // Récupère les détails complets d'un élève avec tous ses frais
  static Future<EleveFraisDetails> getEleveFraisDetails(int eleveId) async {
    final db = await DatabaseService.database;

    // Récupère l'élève
    final eleveResult = await db.query(
      'eleves',
      where: 'id = ?',
      whereArgs: [eleveId],
    );
    if (eleveResult.isEmpty) throw Exception('Élève non trouvé');
    final eleve = Eleve.fromMap(eleveResult.first);

    // Récupère tous les frais de la classe de l'élève
    final fraisList = await getAllFraisByClasse(eleve.classeId!);

    List<FraisDetails> fraisDetailsList = [];

    for (final frais in fraisList) {
      // Récupère l'historique des paiements pour ce frais
      final paiements = await getPaiementsByEleveAndFrais(eleveId, frais.id);

      // Calcule le montant total payé
      final montantPaye = paiements.fold<double>(
        0.0,
        (sum, p) => sum + p.montantPaye,
      );
      final resteAPayer = frais.montant - montantPaye;

      // Détermine le statut
      String statut;
      if (resteAPayer <= 0) {
        statut = 'en_ordre';
      } else if (montantPaye > 0) {
        statut = 'partiellement_paye';
      } else {
        statut = 'pas_en_ordre';
      }

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

  // Enregistre un nouveau paiement
  static Future<int> enregistrerPaiement({
    required int eleveId,
    required int fraisId,
    required double montant,
    String? statut,
    int? userId,
  }) async {
    final db = await DatabaseService.database;

    // Calcule le reste à payer
    final fraisResult = await db.query(
      'frais_scolaires',
      where: 'id = ?',
      whereArgs: [fraisId],
    );
    if (fraisResult.isEmpty) throw Exception('Frais non trouvé');

    final frais = FraisScolaire.fromMap(fraisResult.first);
    final paiementsExistants = await getPaiementsByEleveAndFrais(
      eleveId,
      fraisId,
    );
    final montantDejaPaye = paiementsExistants.fold<double>(
      0.0,
      (sum, p) => sum + p.montantPaye,
    );
    final resteAPayer = frais.montant - montantDejaPaye - montant;

    return await db.insert('paiement_frais', {
      'eleve_id': eleveId,
      'frais_scolaire_id': fraisId,
      'montant_paye': montant,
      'date_paiement': DateTime.now().toIso8601String().split('T')[0],
      'reste_a_payer': resteAPayer > 0 ? resteAPayer : 0,
      'statut': statut ?? (resteAPayer <= 0 ? 'complet' : 'partiel'),
      'user_id': userId,
    });
  }
}
