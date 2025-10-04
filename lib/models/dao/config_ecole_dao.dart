import 'package:floor/floor.dart';
import '../entities/config_ecole.dart';

@dao
abstract class ConfigEcoleDao {
  @Query('SELECT * FROM config_ecole')
  Future<List<ConfigEcole>> getAllConfigsEcole();

  @Query('SELECT * FROM config_ecole WHERE id = :id')
  Future<ConfigEcole?> getConfigEcoleById(int id);

  @Query('SELECT * FROM config_ecole WHERE server_id = :serverId')
  Future<ConfigEcole?> getConfigEcoleByServerId(int serverId);

  @Query('SELECT * FROM config_ecole WHERE entreprise_id = :entrepriseId')
  Future<ConfigEcole?> getConfigEcoleByEntreprise(int entrepriseId);

  @Query('SELECT * FROM config_ecole WHERE is_sync = 0')
  Future<List<ConfigEcole>> getUnsyncedConfigsEcole();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertConfigEcole(ConfigEcole configEcole);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<List<int>> insertConfigsEcole(List<ConfigEcole> configsEcole);

  @update
  Future<void> updateConfigEcole(ConfigEcole configEcole);

  @update
  Future<void> updateConfigsEcole(List<ConfigEcole> configsEcole);

  @delete
  Future<void> deleteConfigEcole(ConfigEcole configEcole);

  @Query('DELETE FROM config_ecole WHERE entreprise_id = :entrepriseId')
  Future<void> deleteConfigsEcoleByEntreprise(int entrepriseId);

  @Query('UPDATE config_ecole SET is_sync = 1 WHERE id = :id')
  Future<void> markAsSynced(int id);

  @Query(
    'UPDATE config_ecole SET server_id = :serverId, is_sync = 1 WHERE id = :id',
  )
  Future<void> updateServerIdAndSync(int id, int serverId);

  @Query(
    'UPDATE config_ecole SET annee_scolaire_en_cours_id = :anneeScolaireId WHERE entreprise_id = :entrepriseId',
  )
  Future<void> updateAnneeScolaireEnCours(
    int entrepriseId,
    int anneeScolaireId,
  );
}
