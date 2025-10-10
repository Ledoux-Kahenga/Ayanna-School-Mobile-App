import 'package:floor/floor.dart';
import '../entities/eleve.dart';

@dao
abstract class EleveDao {
  @Query('SELECT * FROM eleves')
  Future<List<Eleve>> getAllEleves();

  @Query('SELECT * FROM eleves ORDER BY nom, prenom')
  Future<List<Eleve>> getAllElevesOrdered();

  @Query('SELECT * FROM eleves WHERE id = :id')
  Future<Eleve?> getEleveById(int id);

  @Query('SELECT * FROM eleves WHERE server_id = :serverId')
  Future<Eleve?> getEleveByServerId(int serverId);

  @Query('SELECT * FROM eleves WHERE matricule = :matricule')
  Future<Eleve?> getEleveByMatricule(String matricule);

  @Query('SELECT * FROM eleves WHERE numero_permanent = :numeroPermanent')
  Future<Eleve?> getEleveByNumeroPermanent(String numeroPermanent);

  @Query('SELECT * FROM eleves WHERE classe_id = :classeId')
  Future<List<Eleve>> getElevesByClasse(int classeId);

  @Query('SELECT * FROM eleves WHERE responsable_id = :responsableId')
  Future<List<Eleve>> getElevesByResponsable(int responsableId);

  @Query('SELECT * FROM eleves WHERE sexe = :sexe AND classe_id = :classeId')
  Future<List<Eleve>> getElevesBySexeAndClasse(String sexe, int classeId);

  @Query('SELECT * FROM eleves WHERE statut = :statut')
  Future<List<Eleve>> getElevesByStatut(String statut);

  @Query(
    'SELECT * FROM eleves WHERE nom LIKE :searchTerm OR prenom LIKE :searchTerm OR postnom LIKE :searchTerm',
  )
  Future<List<Eleve>> searchEleves(String searchTerm);

  @Query('SELECT * FROM eleves WHERE is_sync = 0')
  Future<List<Eleve>> getUnsyncedEleves();

  @Query('SELECT COUNT(*) FROM eleves WHERE classe_id = :classeId')
  Future<int?> getEffectifByClasse(int classeId);

  @Query(
    'SELECT COUNT(*) FROM eleves WHERE classe_id = :classeId AND sexe = :sexe',
  )
  Future<int?> getEffectifBySexeAndClasse(String sexe, int classeId);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertEleve(Eleve eleve);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<List<int>> insertEleves(List<Eleve> eleves);

  @update
  Future<void> updateEleve(Eleve eleve);

  @update
  Future<void> updateEleves(List<Eleve> eleves);

  @delete
  Future<void> deleteEleve(Eleve eleve);

  @Query('DELETE FROM eleves')
  Future<void> deleteAllEleves();

  @Query('DELETE FROM eleves WHERE classe_id = :classeId')
  Future<void> deleteElevesByClasse(int classeId);

  @Query('UPDATE eleves SET is_sync = 1 WHERE id = :id')
  Future<void> markAsSynced(int id);

  @Query('UPDATE eleves SET server_id = :serverId, is_sync = 1 WHERE id = :id')
  Future<void> updateServerIdAndSync(int id, int serverId);

  @Query('UPDATE eleves SET classe_id = :nouvelleClasseId WHERE id = :eleveId')
  Future<void> changerClasse(int eleveId, int nouvelleClasseId);

  @Query('UPDATE eleves SET statut = :nouveauStatut WHERE id = :eleveId')
  Future<void> changerStatut(int eleveId, String nouveauStatut);
}
