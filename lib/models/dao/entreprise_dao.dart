import 'package:floor/floor.dart';
import '../entities/entreprise.dart';

@dao
abstract class EntrepriseDao {
  @Query('SELECT * FROM entreprises')
  Future<List<Entreprise>> getAllEntreprises();

  @Query('SELECT * FROM entreprises WHERE id = :id')
  Future<Entreprise?> getEntrepriseById(int id);

  @Query('SELECT * FROM entreprises WHERE server_id = :serverId')
  Future<Entreprise?> getEntrepriseByServerId(int serverId);

  @Query('SELECT * FROM entreprises WHERE is_sync = 0')
  Future<List<Entreprise>> getUnsyncedEntreprises();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertEntreprise(Entreprise entreprise);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<List<int>> insertEntreprises(List<Entreprise> entreprises);

  @update
  Future<void> updateEntreprise(Entreprise entreprise);

  @update
  Future<void> updateEntreprises(List<Entreprise> entreprises);

  @delete
  Future<void> deleteEntreprise(Entreprise entreprise);

  @Query('DELETE FROM entreprises WHERE id = :id')
  Future<void> deleteEntrepriseById(int id);  

  @Query('DELETE FROM entreprises')
  Future<void> deleteAllEntreprises();

  @Query('UPDATE entreprises SET is_sync = 1 WHERE id = :id')
  Future<void> markAsSynced(int id);

  @Query(
    'UPDATE entreprises SET server_id = :serverId, is_sync = 1 WHERE id = :id',
  )
  Future<void> updateServerIdAndSync(int id, int serverId);
}
