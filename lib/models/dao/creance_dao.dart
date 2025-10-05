import 'package:floor/floor.dart';
import '../entities/creance.dart';

@dao
abstract class CreanceDao {
  @Query('SELECT * FROM creances')
  Future<List<Creance>> getAllCreances();

  @Query('SELECT * FROM creances WHERE id = :id')
  Future<Creance?> getCreanceById(int id);

  @Query('SELECT * FROM creances WHERE server_id = :serverId')
  Future<Creance?> getCreanceByServerId(int serverId);

  @Query('SELECT * FROM creances WHERE eleve_id = :eleveId')
  Future<List<Creance>> getCreancesByEleve(int eleveId);

  @Query('SELECT * FROM creances WHERE frais_scolaire_id = :fraisScolaireId')
  Future<List<Creance>> getCreancesByFraisScolaire(int fraisScolaireId);

  @Query('SELECT * FROM creances WHERE eleve_id = :eleveId AND active = 1')
  Future<List<Creance>> getCreancesActivesByEleve(int eleveId);

  @Query('SELECT * FROM creances WHERE date_echeance < :date AND active = 1')
  Future<List<Creance>> getCreancesEchues(DateTime date);

  @Query('SELECT * FROM creances WHERE is_sync = 0')
  Future<List<Creance>> getUnsyncedCreances();

  @Query(
    'SELECT SUM(montant) FROM creances WHERE eleve_id = :eleveId AND active = 1',
  )
  Future<double?> getTotalCreancesByEleve(int eleveId);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertCreance(Creance creance);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<List<int>> insertCreances(List<Creance> creances);

  @update
  Future<void> updateCreance(Creance creance);

  @update
  Future<void> updateCreances(List<Creance> creances);

  @delete
  Future<void> deleteCreance(Creance creance);

  @Query('DELETE FROM creances')
  Future<void> deleteAllCreances();
  
  @Query('DELETE FROM creances WHERE eleve_id = :eleveId')
  Future<void> deleteCreancesByEleve(int eleveId);

  @Query('UPDATE creances SET is_sync = 1 WHERE id = :id')
  Future<void> markAsSynced(int id);

  @Query(
    'UPDATE creances SET server_id = :serverId, is_sync = 1 WHERE id = :id',
  )
  Future<void> updateServerIdAndSync(int id, int serverId);

  @Query('UPDATE creances SET active = 0 WHERE id = :id')
  Future<void> desactiverCreance(int id);
}
