import 'package:floor/floor.dart';
import '../entities/classe_comptable.dart';

@dao
abstract class ClasseComptableDao {
  @Query('SELECT * FROM classes_comptables')
  Future<List<ClasseComptable>> getAllClassesComptables();

  @Query('SELECT * FROM classes_comptables WHERE id = :id')
  Future<ClasseComptable?> getClasseComptableById(int id);

  @Query('SELECT * FROM classes_comptables WHERE server_id = :serverId')
  Future<ClasseComptable?> getClasseComptableByServerId(int serverId);

  @Query('SELECT * FROM classes_comptables WHERE code = :code')
  Future<ClasseComptable?> getClasseComptableByCode(String code);

  @Query('SELECT * FROM classes_comptables WHERE entreprise_id = :entrepriseId')
  Future<List<ClasseComptable>> getClassesComptablesByEntreprise(
    int entrepriseId,
  );

  @Query(
    'SELECT * FROM classes_comptables WHERE type = :type AND entreprise_id = :entrepriseId',
  )
  Future<List<ClasseComptable>> getClassesComptablesByType(
    String type,
    int entrepriseId,
  );

  @Query(
    'SELECT * FROM classes_comptables WHERE actif = 1 AND entreprise_id = :entrepriseId',
  )
  Future<List<ClasseComptable>> getClassesComptablesActives(int entrepriseId);

  @Query('SELECT * FROM classes_comptables WHERE is_sync = 0')
  Future<List<ClasseComptable>> getUnsyncedClassesComptables();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertClasseComptable(ClasseComptable classeComptable);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<List<int>> insertClassesComptables(
    List<ClasseComptable> classesComptables,
  );

  @update
  Future<void> updateClasseComptable(ClasseComptable classeComptable);

  @update
  Future<void> updateClassesComptables(List<ClasseComptable> classesComptables);

  @delete
  Future<void> deleteClasseComptable(ClasseComptable classeComptable);
  
  @Query('DELETE FROM classes_comptables')
  Future<void> deleteAllClassesComptables();

  @Query('DELETE FROM classes_comptables WHERE entreprise_id = :entrepriseId')
  Future<void> deleteClassesComptablesByEntreprise(int entrepriseId);

  @Query('UPDATE classes_comptables SET is_sync = 1 WHERE id = :id')
  Future<void> markAsSynced(int id);

  @Query(
    'UPDATE classes_comptables SET server_id = :serverId, is_sync = 1 WHERE id = :id',
  )
  Future<void> updateServerIdAndSync(int id, int serverId);
}
