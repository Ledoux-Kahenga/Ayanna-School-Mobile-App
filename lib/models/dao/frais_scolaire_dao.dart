import 'package:floor/floor.dart';
import '../entities/frais_scolaire.dart';

@dao
abstract class FraisScolaireDao {
  @Query('SELECT * FROM frais_scolaires')
  Future<List<FraisScolaire>> getAllFraisScolaires();

  @Query('SELECT * FROM frais_scolaires WHERE id = :id')
  Future<FraisScolaire?> getFraisScolaireById(int id);

  @Query('SELECT * FROM frais_scolaires WHERE server_id = :serverId')
  Future<FraisScolaire?> getFraisScolaireByServerId(int serverId);

  @Query('SELECT * FROM frais_scolaires WHERE entreprise_id = :entrepriseId')
  Future<List<FraisScolaire>> getFraisScolairesByEntreprise(int entrepriseId);

  @Query(
    'SELECT * FROM frais_scolaires WHERE annee_scolaire_id = :anneeScolaireId',
  )
  Future<List<FraisScolaire>> getFraisScolairesByAnneeScolaire(
    int anneeScolaireId,
  );

  @Query(
    'SELECT * FROM frais_scolaires WHERE entreprise_id = :entrepriseId AND annee_scolaire_id = :anneeScolaireId',
  )
  Future<List<FraisScolaire>> getFraisScolairesByEntrepriseAndAnnee(
    int entrepriseId,
    int anneeScolaireId,
  );

  @Query(
    'SELECT * FROM frais_scolaires WHERE date_limite >= :date AND annee_scolaire_id = :anneeScolaireId',
  )
  Future<List<FraisScolaire>> getFraisScolairesActifs(
    DateTime date,
    int anneeScolaireId,
  );

  @Query(
    'SELECT * FROM frais_scolaires WHERE date_limite < :date AND annee_scolaire_id = :anneeScolaireId',
  )
  Future<List<FraisScolaire>> getFraisScolairesEchus(
    DateTime date,
    int anneeScolaireId,
  );

  @Query('SELECT * FROM frais_scolaires WHERE is_sync = 0')
  Future<List<FraisScolaire>> getUnsyncedFraisScolaires();

  @Query(
    'SELECT SUM(montant) FROM frais_scolaires WHERE annee_scolaire_id = :anneeScolaireId',
  )
  Future<double?> getTotalFraisByAnneeScolaire(int anneeScolaireId);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertFraisScolaire(FraisScolaire fraisScolaire);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<List<int>> insertFraisScolaires(List<FraisScolaire> fraisScolaires);

  @update
  Future<void> updateFraisScolaire(FraisScolaire fraisScolaire);

  @update
  Future<void> updateFraisScolaires(List<FraisScolaire> fraisScolaires);

  @delete
  Future<void> deleteFraisScolaire(FraisScolaire fraisScolaire);

  @Query('DELETE FROM frais_scolaires')
  Future<void> deleteAllFraisScolaires();
  
  @Query('DELETE FROM frais_scolaires WHERE entreprise_id = :entrepriseId')
  Future<void> deleteFraisScolairesByEntreprise(int entrepriseId);

  @Query(
    'DELETE FROM frais_scolaires WHERE annee_scolaire_id = :anneeScolaireId',
  )
  Future<void> deleteFraisScolairesByAnneeScolaire(int anneeScolaireId);

  @Query('UPDATE frais_scolaires SET is_sync = 1 WHERE id = :id')
  Future<void> markAsSynced(int id);

  @Query(
    'UPDATE frais_scolaires SET server_id = :serverId, is_sync = 1 WHERE id = :id',
  )
  Future<void> updateServerIdAndSync(int id, int serverId);
}
