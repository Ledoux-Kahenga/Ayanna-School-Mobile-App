import 'package:floor/floor.dart';
import '../entities/cours.dart';

@dao
abstract class CoursDao {
  @Query('SELECT * FROM cours')
  Future<List<Cours>> getAllCours();

  @Query('SELECT * FROM cours WHERE id = :id')
  Future<Cours?> getCoursById(int id);

  @Query('SELECT * FROM cours WHERE server_id = :serverId')
  Future<Cours?> getCoursByServerId(int serverId);

  @Query('SELECT * FROM cours WHERE code = :code')
  Future<Cours?> getCoursByCode(String code);

  @Query('SELECT * FROM cours WHERE classe_id = :classeId')
  Future<List<Cours>> getCoursByClasse(int classeId);

  @Query('SELECT * FROM cours WHERE enseignant_id = :enseignantId')
  Future<List<Cours>> getCoursByEnseignant(int enseignantId);

  @Query(
    'SELECT * FROM cours WHERE enseignant_id = :enseignantId AND classe_id = :classeId',
  )
  Future<List<Cours>> getCoursByEnseignantAndClasse(
    int enseignantId,
    int classeId,
  );

  @Query('SELECT * FROM cours WHERE is_sync = 0')
  Future<List<Cours>> getUnsyncedCours();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertCours(Cours cours);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<List<int>> insertMultipleCours(List<Cours> cours);

  @update
  Future<void> updateCours(Cours cours);

  @update
  Future<void> updateMultipleCours(List<Cours> cours);

  @delete
  Future<void> deleteCours(Cours cours);

  @Query('DELETE FROM cours WHERE classe_id = :classeId')
  Future<void> deleteCoursByClasse(int classeId);

  @Query('DELETE FROM cours WHERE enseignant_id = :enseignantId')
  Future<void> deleteCoursByEnseignant(int enseignantId);

  @Query('UPDATE cours SET is_sync = 1 WHERE id = :id')
  Future<void> markAsSynced(int id);

  @Query('UPDATE cours SET server_id = :serverId, is_sync = 1 WHERE id = :id')
  Future<void> updateServerIdAndSync(int id, int serverId);
}
