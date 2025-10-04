import 'package:floor/floor.dart';
import '../entities/depense.dart';

@dao
abstract class DepenseDao {
  @Query('SELECT * FROM depenses')
  Future<List<Depense>> getAllDepenses();

  @Query('SELECT * FROM depenses WHERE id = :id')
  Future<Depense?> getDepenseById(int id);

  @Query('SELECT * FROM depenses WHERE server_id = :serverId')
  Future<Depense?> getDepenseByServerId(int serverId);

  @Query('SELECT * FROM depenses WHERE entreprise_id = :entrepriseId')
  Future<List<Depense>> getDepensesByEntreprise(int entrepriseId);

  @Query('SELECT * FROM depenses WHERE user_id = :userId')
  Future<List<Depense>> getDepensesByUser(int userId);

  @Query('SELECT * FROM depenses WHERE journal_id = :journalId')
  Future<List<Depense>> getDepensesByJournal(int journalId);

  @Query(
    'SELECT * FROM depenses WHERE date_depense BETWEEN :dateDebut AND :dateFin AND entreprise_id = :entrepriseId',
  )
  Future<List<Depense>> getDepensesByPeriode(
    DateTime dateDebut,
    DateTime dateFin,
    int entrepriseId,
  );

  @Query('SELECT * FROM depenses WHERE is_sync = 0')
  Future<List<Depense>> getUnsyncedDepenses();

  @Query(
    'SELECT SUM(montant) FROM depenses WHERE entreprise_id = :entrepriseId AND date_depense BETWEEN :dateDebut AND :dateFin',
  )
  Future<double?> getTotalDepensesByPeriode(
    int entrepriseId,
    DateTime dateDebut,
    DateTime dateFin,
  );

  @Query(
    'SELECT SUM(montant) FROM depenses WHERE entreprise_id = :entrepriseId',
  )
  Future<double?> getTotalDepensesByEntreprise(int entrepriseId);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertDepense(Depense depense);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<List<int>> insertDepenses(List<Depense> depenses);

  @update
  Future<void> updateDepense(Depense depense);

  @update
  Future<void> updateDepenses(List<Depense> depenses);

  @delete
  Future<void> deleteDepense(Depense depense);

  @Query('DELETE FROM depenses WHERE entreprise_id = :entrepriseId')
  Future<void> deleteDepensesByEntreprise(int entrepriseId);

  @Query('UPDATE depenses SET is_sync = 1 WHERE id = :id')
  Future<void> markAsSynced(int id);

  @Query(
    'UPDATE depenses SET server_id = :serverId, is_sync = 1 WHERE id = :id',
  )
  Future<void> updateServerIdAndSync(int id, int serverId);
}
