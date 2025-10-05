import 'package:floor/floor.dart';
import '../entities/classe.dart';

@dao
abstract class ClasseDao {
  @Query('SELECT * FROM classes')
  Future<List<Classe>> getAllClasses();

  @Query('SELECT * FROM classes WHERE id = :id')
  Future<Classe?> getClasseById(int id);

  @Query('SELECT * FROM classes WHERE server_id = :serverId')
  Future<Classe?> getClasseByServerId(int serverId);

  @Query('SELECT * FROM classes WHERE code = :code')
  Future<Classe?> getClasseByCode(String code);

  @Query('SELECT * FROM classes WHERE annee_scolaire_id = :anneeScolaireId')
  Future<List<Classe>> getClassesByAnneeScolaire(int anneeScolaireId);

  @Query('SELECT * FROM classes WHERE enseignant_id = :enseignantId')
  Future<List<Classe>> getClassesByEnseignant(int enseignantId);

  @Query(
    'SELECT * FROM classes WHERE niveau = :niveau AND annee_scolaire_id = :anneeScolaireId',
  )
  Future<List<Classe>> getClassesByNiveau(String niveau, int anneeScolaireId);

  @Query('SELECT * FROM classes WHERE is_sync = 0')
  Future<List<Classe>> getUnsyncedClasses();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertClasse(Classe classe);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<List<int>> insertClasses(List<Classe> classes);

  @update
  Future<void> updateClasse(Classe classe);

  @update
  Future<void> updateClasses(List<Classe> classes);

  @delete
  Future<void> deleteClasse(Classe classe);

  @Query('DELETE FROM classes')
  Future<void> deleteAllClasses();
  
  @Query('DELETE FROM classes WHERE annee_scolaire_id = :anneeScolaireId')
  Future<void> deleteClassesByAnneeScolaire(int anneeScolaireId);

  @Query('UPDATE classes SET is_sync = 1 WHERE id = :id')
  Future<void> markAsSynced(int id);

  @Query('UPDATE classes SET server_id = :serverId, is_sync = 1 WHERE id = :id')
  Future<void> updateServerIdAndSync(int id, int serverId);

  @Query('UPDATE classes SET effectif = :effectif WHERE id = :id')
  Future<void> updateEffectif(int id, int effectif);
}
