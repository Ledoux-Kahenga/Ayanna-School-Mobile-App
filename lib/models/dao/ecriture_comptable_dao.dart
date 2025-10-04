import 'package:floor/floor.dart';
import '../entities/ecriture_comptable.dart';

@dao
abstract class EcritureComptableDao {
  @Query('SELECT * FROM ecritures_comptables')
  Future<List<EcritureComptable>> getAllEcrituresComptables();

  @Query('SELECT * FROM ecritures_comptables WHERE id = :id')
  Future<EcritureComptable?> getEcritureComptableById(int id);

  @Query('SELECT * FROM ecritures_comptables WHERE server_id = :serverId')
  Future<EcritureComptable?> getEcritureComptableByServerId(int serverId);

  @Query(
    'SELECT * FROM ecritures_comptables WHERE journal_id = :journalId ORDER BY ordre',
  )
  Future<List<EcritureComptable>> getEcrituresComptablesByJournal(
    int journalId,
  );

  @Query(
    'SELECT * FROM ecritures_comptables WHERE compte_comptable_id = :compteComptableId',
  )
  Future<List<EcritureComptable>> getEcrituresComptablesByCompte(
    int compteComptableId,
  );

  @Query('SELECT * FROM ecritures_comptables WHERE reference = :reference')
  Future<List<EcritureComptable>> getEcrituresComptablesByReference(
    String reference,
  );

  @Query(
    'SELECT * FROM ecritures_comptables WHERE date_ecriture BETWEEN :dateDebut AND :dateFin',
  )
  Future<List<EcritureComptable>> getEcrituresComptablesByPeriode(
    DateTime dateDebut,
    DateTime dateFin,
  );

  @Query('SELECT * FROM ecritures_comptables WHERE is_sync = 0')
  Future<List<EcritureComptable>> getUnsyncedEcrituresComptables();

  @Query(
    'SELECT SUM(debit) FROM ecritures_comptables WHERE compte_comptable_id = :compteId',
  )
  Future<double?> getTotalDebitByCompte(int compteId);

  @Query(
    'SELECT SUM(credit) FROM ecritures_comptables WHERE compte_comptable_id = :compteId',
  )
  Future<double?> getTotalCreditByCompte(int compteId);

  @Query(
    'SELECT SUM(debit) - SUM(credit) FROM ecritures_comptables WHERE compte_comptable_id = :compteId',
  )
  Future<double?> getSoldeByCompte(int compteId);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertEcritureComptable(EcritureComptable ecritureComptable);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<List<int>> insertEcrituresComptables(
    List<EcritureComptable> ecrituresComptables,
  );

  @update
  Future<void> updateEcritureComptable(EcritureComptable ecritureComptable);

  @update
  Future<void> updateEcrituresComptables(
    List<EcritureComptable> ecrituresComptables,
  );

  @delete
  Future<void> deleteEcritureComptable(EcritureComptable ecritureComptable);

  @Query('DELETE FROM ecritures_comptables WHERE journal_id = :journalId')
  Future<void> deleteEcrituresComptablesByJournal(int journalId);

  @Query('UPDATE ecritures_comptables SET is_sync = 1 WHERE id = :id')
  Future<void> markAsSynced(int id);

  @Query(
    'UPDATE ecritures_comptables SET server_id = :serverId, is_sync = 1 WHERE id = :id',
  )
  Future<void> updateServerIdAndSync(int id, int serverId);
}
