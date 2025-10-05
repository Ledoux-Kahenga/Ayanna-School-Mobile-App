import 'package:floor/floor.dart';
import '../entities/enseignant.dart';

@dao
abstract class EnseignantDao {
  @Query('SELECT * FROM enseignants')
  Future<List<Enseignant>> getAllEnseignants();

  @Query('SELECT * FROM enseignants WHERE id = :id')
  Future<Enseignant?> getEnseignantById(int id);

  @Query('SELECT * FROM enseignants WHERE server_id = :serverId')
  Future<Enseignant?> getEnseignantByServerId(int serverId);

  @Query('SELECT * FROM enseignants WHERE matricule = :matricule')
  Future<Enseignant?> getEnseignantByMatricule(String matricule);

  @Query('SELECT * FROM enseignants WHERE email = :email')
  Future<Enseignant?> getEnseignantByEmail(String email);

  @Query('SELECT * FROM enseignants WHERE entreprise_id = :entrepriseId')
  Future<List<Enseignant>> getEnseignantsByEntreprise(int entrepriseId);

  @Query(
    'SELECT * FROM enseignants WHERE discipline = :discipline AND entreprise_id = :entrepriseId',
  )
  Future<List<Enseignant>> getEnseignantsByDiscipline(
    String discipline,
    int entrepriseId,
  );

  @Query(
    'SELECT * FROM enseignants WHERE niveau = :niveau AND entreprise_id = :entrepriseId',
  )
  Future<List<Enseignant>> getEnseignantsByNiveau(
    String niveau,
    int entrepriseId,
  );

  @Query(
    'SELECT * FROM enseignants WHERE sexe = :sexe AND entreprise_id = :entrepriseId',
  )
  Future<List<Enseignant>> getEnseignantsBySexe(String sexe, int entrepriseId);

  @Query(
    'SELECT * FROM enseignants WHERE nom LIKE :searchTerm OR prenom LIKE :searchTerm',
  )
  Future<List<Enseignant>> searchEnseignants(String searchTerm);

  @Query('SELECT * FROM enseignants WHERE is_sync = 0')
  Future<List<Enseignant>> getUnsyncedEnseignants();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertEnseignant(Enseignant enseignant);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<List<int>> insertEnseignants(List<Enseignant> enseignants);

  @update
  Future<void> updateEnseignant(Enseignant enseignant);

  @Query('DELETE FROM enseignants')
  Future<void> deleteAllEnseignants();

  @update
  Future<void> updateEnseignants(List<Enseignant> enseignants);

  @delete
  Future<void> deleteEnseignant(Enseignant enseignant);

  @Query('DELETE FROM enseignants WHERE entreprise_id = :entrepriseId')
  Future<void> deleteEnseignantsByEntreprise(int entrepriseId);

  @Query('UPDATE enseignants SET is_sync = 1 WHERE id = :id')
  Future<void> markAsSynced(int id);

  @Query(
    'UPDATE enseignants SET server_id = :serverId, is_sync = 1 WHERE id = :id',
  )
  Future<void> updateServerIdAndSync(int id, int serverId);
}
