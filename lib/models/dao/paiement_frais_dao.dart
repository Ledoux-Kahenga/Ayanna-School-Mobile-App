import 'package:floor/floor.dart';
import '../entities/paiement_frais.dart';

@dao
abstract class PaiementFraisDao {
  @Query('SELECT * FROM paiement_frais')
  Future<List<PaiementFrais>> getAllPaiementsFrais();

  @Query('SELECT * FROM paiement_frais WHERE id = :id')
  Future<PaiementFrais?> getPaiementFraisById(int id);

  @Query('SELECT * FROM paiement_frais WHERE server_id = :serverId')
  Future<PaiementFrais?> getPaiementFraisByServerId(int serverId);

  @Query('SELECT * FROM paiement_frais WHERE eleve_id = :eleveId')
  Future<List<PaiementFrais>> getPaiementsFraisByEleve(int eleveId);

  @Query(
    'SELECT * FROM paiement_frais WHERE frais_scolaire_id = :fraisScolaireId',
  )
  Future<List<PaiementFrais>> getPaiementsFraisByFrais(int fraisScolaireId);

  @Query(
    'SELECT * FROM paiement_frais WHERE methode_paiement = :methodePaiement',
  )
  Future<List<PaiementFrais>> getPaiementsByMethode(String methodePaiement);

  @Query(
    'SELECT * FROM paiement_frais WHERE date_paiement BETWEEN :dateDebut AND :dateFin',
  )
  Future<List<PaiementFrais>> getPaiementsByPeriode(
    DateTime dateDebut,
    DateTime dateFin,
  );

  @Query(
    'SELECT * FROM paiement_frais WHERE eleve_id = :eleveId AND date_paiement BETWEEN :dateDebut AND :dateFin',
  )
  Future<List<PaiementFrais>> getPaiementsByEleveAndPeriode(
    int eleveId,
    DateTime dateDebut,
    DateTime dateFin,
  );

  @Query('SELECT * FROM paiement_frais WHERE montant_paye >= :montantMin')
  Future<List<PaiementFrais>> getPaiementsSuperieursA(double montantMin);

  @Query('SELECT * FROM paiement_frais WHERE statut = :statut')
  Future<List<PaiementFrais>> getPaiementsByStatut(String statut);

  @Query(
    'SELECT SUM(montant_paye) FROM paiement_frais WHERE eleve_id = :eleveId',
  )
  Future<double?> getTotalPaiementsByEleve(int eleveId);

  @Query(
    'SELECT SUM(montant_paye) FROM paiement_frais WHERE frais_scolaire_id = :fraisScolaireId',
  )
  Future<double?> getTotalPaiementsByFrais(int fraisScolaireId);

  @Query('SELECT * FROM paiement_frais WHERE is_sync = 0')
  Future<List<PaiementFrais>> getUnsyncedPaiementsFrais();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertPaiementFrais(PaiementFrais paiementFrais);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<List<int>> insertPaiementsFrais(List<PaiementFrais> paiementsFrais);

  @update
  Future<void> updatePaiementFrais(PaiementFrais paiementFrais);

  @update
  Future<void> updatePaiementsFrais(List<PaiementFrais> paiementsFrais);

  @delete
  Future<void> deletePaiementFrais(PaiementFrais paiementFrais);

  @Query('DELETE FROM paiement_frais')
  Future<void> deleteAllPaiementsFrais();

  @Query('DELETE FROM paiement_frais WHERE eleve_id = :eleveId')
  Future<void> deletePaiementsByEleve(int eleveId);

  @Query(
    'DELETE FROM paiement_frais WHERE frais_scolaire_id = :fraisScolaireId',
  )
  Future<void> deletePaiementsByFrais(int fraisScolaireId);

  @Query('UPDATE paiement_frais SET is_sync = 1 WHERE id = :id')
  Future<void> markAsSynced(int id);

  @Query(
    'UPDATE paiement_frais SET server_id = :serverId, is_sync = 1 WHERE id = :id',
  )
  Future<void> updateServerIdAndSync(int id, int serverId);

  @Query('UPDATE paiement_frais SET statut = :statut WHERE id = :id')
  Future<void> updateStatutPaiement(int id, String statut);

  /// Calcule le total des paiements pour un élève et un frais spécifique
  @Query(
    'SELECT COALESCE(SUM(montant_paye), 0.0) FROM paiement_frais WHERE eleve_id = :eleveId AND frais_scolaire_id = :fraisId',
  )
  Future<double?> getTotalPaiementsByEleveAndFrais(int eleveId, int fraisId);

  /// Récupère les paiements pour un élève et un frais spécifique
  @Query(
    'SELECT * FROM paiement_frais WHERE eleve_id = :eleveId AND frais_scolaire_id = :fraisId ORDER BY date_paiement DESC',
  )
  Future<List<PaiementFrais>> getPaiementsByEleveAndFrais(
    int eleveId,
    int fraisId,
  );
}
