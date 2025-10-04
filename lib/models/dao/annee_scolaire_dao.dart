import 'package:floor/floor.dart';
import '../entities/annee_scolaire.dart';

@dao
abstract class AnneeScolaireDao {
  @Query('SELECT * FROM annees_scolaires')
  Future<List<AnneeScolaire>> getAllAnneesScolaires();

  @Query('SELECT * FROM annees_scolaires WHERE id = :id')
  Future<AnneeScolaire?> getAnneeScolaireById(int id);

  @Query('SELECT * FROM annees_scolaires WHERE server_id = :serverId')
  Future<AnneeScolaire?> getAnneeScolaireByServerId(int serverId);

  @Query('SELECT * FROM annees_scolaires WHERE entreprise_id = :entrepriseId')
  Future<List<AnneeScolaire>> getAnneesScolairesByEntreprise(int entrepriseId);

  @Query(
    'SELECT * FROM annees_scolaires WHERE en_cours = 1 AND entreprise_id = :entrepriseId',
  )
  Future<AnneeScolaire?> getAnneeScolaireEnCours(int entrepriseId);

  @Query('SELECT * FROM annees_scolaires WHERE is_sync = 0')
  Future<List<AnneeScolaire>> getUnsyncedAnneesScolaires();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertAnneeScolaire(AnneeScolaire anneeScolaire);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<List<int>> insertAnneesScolaires(List<AnneeScolaire> anneesScolaires);

  @update
  Future<void> updateAnneeScolaire(AnneeScolaire anneeScolaire);

  @update
  Future<void> updateAnneesScolaires(List<AnneeScolaire> anneesScolaires);

  @delete
  Future<void> deleteAnneeScolaire(AnneeScolaire anneeScolaire);

  @Query('DELETE FROM annees_scolaires WHERE entreprise_id = :entrepriseId')
  Future<void> deleteAnneesScolairesByEntreprise(int entrepriseId);

  @Query('UPDATE annees_scolaires SET is_sync = 1 WHERE id = :id')
  Future<void> markAsSynced(int id);

  @Query(
    'UPDATE annees_scolaires SET server_id = :serverId, is_sync = 1 WHERE id = :id',
  )
  Future<void> updateServerIdAndSync(int id, int serverId);

  @Query(
    'UPDATE annees_scolaires SET en_cours = 0 WHERE entreprise_id = :entrepriseId',
  )
  Future<void> resetAnneesEnCours(int entrepriseId);

  @Query('UPDATE annees_scolaires SET en_cours = 1 WHERE id = :id')
  Future<void> setAnneeScolaireEnCours(int id);
}
