import 'package:floor/floor.dart';
import '../entities/journal_comptable.dart';

@dao
abstract class JournalComptableDao {
  @Query('SELECT * FROM journaux_comptables')
  Future<List<JournalComptable>> getAllJournauxComptables();

  @Query('SELECT * FROM journaux_comptables WHERE id = :id')
  Future<JournalComptable?> getJournalComptableById(int id);

  @Query('SELECT * FROM journaux_comptables WHERE server_id = :serverId')
  Future<JournalComptable?> getJournalComptableByServerId(int serverId);

  @Query(
    'SELECT * FROM journaux_comptables WHERE entreprise_id = :entrepriseId',
  )
  Future<List<JournalComptable>> getJournauxComptablesByEntreprise(
    int entrepriseId,
  );

  @Query(
    'SELECT * FROM journaux_comptables WHERE type_operation = :typeOperation AND entreprise_id = :entrepriseId',
  )
  Future<List<JournalComptable>> getJournauxComptablesByType(
    String typeOperation,
    int entrepriseId,
  );

  @Query(
    'SELECT * FROM journaux_comptables WHERE paiement_frais_id = :paiementFraisId',
  )
  Future<List<JournalComptable>> getJournauxComptablesByPaiementFrais(
    int paiementFraisId,
  );

  @Query(
    'SELECT * FROM journaux_comptables WHERE date_operation BETWEEN :dateDebut AND :dateFin AND entreprise_id = :entrepriseId',
  )
  Future<List<JournalComptable>> getJournauxComptablesByPeriode(
    DateTime dateDebut,
    DateTime dateFin,
    int entrepriseId,
  );

  @Query('SELECT * FROM journaux_comptables WHERE is_sync = 0')
  Future<List<JournalComptable>> getUnsyncedJournauxComptables();

  @Query(
    'SELECT SUM(montant) FROM journaux_comptables WHERE type_operation = :typeOperation AND entreprise_id = :entrepriseId',
  )
  Future<double?> getTotalByTypeOperation(
    String typeOperation,
    int entrepriseId,
  );

  @Query(
    'SELECT SUM(montant) FROM journaux_comptables WHERE entreprise_id = :entrepriseId AND date_operation BETWEEN :dateDebut AND :dateFin',
  )
  Future<double?> getTotalByPeriode(
    int entrepriseId,
    DateTime dateDebut,
    DateTime dateFin,
  );

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertJournalComptable(JournalComptable journalComptable);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<List<int>> insertJournauxComptables(
    List<JournalComptable> journauxComptables,
  );

  @update
  Future<void> updateJournalComptable(JournalComptable journalComptable);

  @update
  Future<void> updateJournauxComptables(
    List<JournalComptable> journauxComptables,
  );

  @delete
  Future<void> deleteJournalComptable(JournalComptable journalComptable);

  @Query('DELETE FROM journaux_comptables')
  Future<void> deleteAllJournauxComptables();
  
  @Query('DELETE FROM journaux_comptables WHERE entreprise_id = :entrepriseId')
  Future<void> deleteJournauxComptablesByEntreprise(int entrepriseId);

  @Query('UPDATE journaux_comptables SET is_sync = 1 WHERE id = :id')
  Future<void> markAsSynced(int id);

  @Query(
    'UPDATE journaux_comptables SET server_id = :serverId, is_sync = 1 WHERE id = :id',
  )
  Future<void> updateServerIdAndSync(int id, int serverId);
}
