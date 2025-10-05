import 'package:floor/floor.dart';
import '../entities/comptes_config.dart';

@dao
abstract class ComptesConfigDao {
  @Query('SELECT * FROM comptes_config')
  Future<List<ComptesConfig>> getAllComptesConfigs();

  @Query('SELECT * FROM comptes_config WHERE id = :id')
  Future<ComptesConfig?> getComptesConfigById(int id);

  @Query('SELECT * FROM comptes_config WHERE server_id = :serverId')
  Future<ComptesConfig?> getComptesConfigByServerId(int serverId);

  @Query('SELECT * FROM comptes_config WHERE entreprise_id = :entrepriseId')
  Future<ComptesConfig?> getComptesConfigByEntreprise(int entrepriseId);

  @Query('SELECT * FROM comptes_config WHERE is_sync = 0')
  Future<List<ComptesConfig>> getUnsyncedComptesConfigs();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertComptesConfig(ComptesConfig comptesConfig);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<List<int>> insertComptesConfigs(List<ComptesConfig> comptesConfigs);

  @update
  Future<void> updateComptesConfig(ComptesConfig comptesConfig);

  @update
  Future<void> updateComptesConfigs(List<ComptesConfig> comptesConfigs);

  @delete
  Future<void> deleteComptesConfig(ComptesConfig comptesConfig);

  @Query('DELETE FROM comptes_config')
  Future<void> deleteAllComptesConfigs();
  
  @Query('DELETE FROM comptes_config WHERE entreprise_id = :entrepriseId')
  Future<void> deleteComptesConfigsByEntreprise(int entrepriseId);

  @Query('UPDATE comptes_config SET is_sync = 1 WHERE id = :id')
  Future<void> markAsSynced(int id);

  @Query(
    'UPDATE comptes_config SET server_id = :serverId, is_sync = 1 WHERE id = :id',
  )
  Future<void> updateServerIdAndSync(int id, int serverId);
}
