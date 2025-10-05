import 'package:floor/floor.dart';
import '../entities/compte_comptable.dart';

@dao
abstract class CompteComptableDao {
  @Query('SELECT * FROM comptes_comptables')
  Future<List<CompteComptable>> getAllComptesComptables();

  @Query('SELECT * FROM comptes_comptables WHERE id = :id')
  Future<CompteComptable?> getCompteComptableById(int id);

  @Query('SELECT * FROM comptes_comptables WHERE server_id = :serverId')
  Future<CompteComptable?> getCompteComptableByServerId(int serverId);

  @Query('SELECT * FROM comptes_comptables WHERE numero = :numero')
  Future<CompteComptable?> getCompteComptableByNumero(String numero);

  @Query(
    'SELECT * FROM comptes_comptables WHERE classe_comptable_id = :classeComptableId',
  )
  Future<List<CompteComptable>> getComptesComptablesByClasse(
    int classeComptableId,
  );

  @Query(
    'SELECT * FROM comptes_comptables WHERE actif = 1 AND classe_comptable_id = :classeComptableId',
  )
  Future<List<CompteComptable>> getComptesComptablesActifs(
    int classeComptableId,
  );

  @Query('SELECT * FROM comptes_comptables WHERE is_sync = 0')
  Future<List<CompteComptable>> getUnsyncedComptesComptables();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertCompteComptable(CompteComptable compteComptable);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<List<int>> insertComptesComptables(
    List<CompteComptable> comptesComptables,
  );

  @update
  Future<void> updateCompteComptable(CompteComptable compteComptable);

  @update
  Future<void> updateComptesComptables(List<CompteComptable> comptesComptables);

  @delete
  Future<void> deleteCompteComptable(CompteComptable compteComptable);

  @Query('DELETE FROM comptes_comptables')
  Future<void> deleteAllComptesComptables();
  
  @Query(
    'DELETE FROM comptes_comptables WHERE classe_comptable_id = :classeComptableId',
  )
  Future<void> deleteComptesComptablesByClasse(int classeComptableId);

  @Query('UPDATE comptes_comptables SET is_sync = 1 WHERE id = :id')
  Future<void> markAsSynced(int id);

  @Query(
    'UPDATE comptes_comptables SET server_id = :serverId, is_sync = 1 WHERE id = :id',
  )
  Future<void> updateServerIdAndSync(int id, int serverId);
}
