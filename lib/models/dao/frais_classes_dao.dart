import 'package:floor/floor.dart';
import '../entities/frais_classes.dart';

@dao
abstract class FraisClassesDao {
  @Query('SELECT * FROM frais_classes')
  Future<List<FraisClasses>> getAllFraisClasses();

  @Query('SELECT * FROM frais_classes WHERE id = :id')
  Future<FraisClasses?> getFraisClasseById(int id);

  @Query('SELECT * FROM frais_classes WHERE server_id = :serverId')
  Future<FraisClasses?> getFraisClasseByServerId(int serverId);

  @Query('SELECT * FROM frais_classes WHERE frais_id = :fraisId')
  Future<List<FraisClasses>> getFraisClassesByFrais(int fraisId);

  @Query('SELECT * FROM frais_classes WHERE classe_id = :classeId')
  Future<List<FraisClasses>> getFraisClassesByClasse(int classeId);

  @Query(
    'SELECT * FROM frais_classes WHERE frais_id = :fraisId AND classe_id = :classeId',
  )
  Future<FraisClasses?> getFraisClasseByFraisAndClasse(
    int fraisId,
    int classeId,
  );

  @Query('SELECT * FROM frais_classes WHERE is_sync = 0')
  Future<List<FraisClasses>> getUnsyncedFraisClasses();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertFraisClasse(FraisClasses fraisClasse);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertFraisClasses(List<FraisClasses> fraisClasses);

  @Update(onConflict: OnConflictStrategy.replace)
  Future<void> updateFraisClasse(FraisClasses fraisClasse);

  @Update(onConflict: OnConflictStrategy.replace)
  Future<void> updateFraisClasses(List<FraisClasses> fraisClasses);

  @delete
  Future<void> deleteFraisClasse(FraisClasses fraisClasse);

  @delete
  Future<void> deleteFraisClasses(List<FraisClasses> fraisClasses);

  @Query('DELETE FROM frais_classes WHERE id = :id')
  Future<void> deleteFraisClasseById(int id);

  @Query('DELETE FROM frais_classes WHERE server_id = :serverId')
  Future<void> deleteFraisClasseByServerId(int serverId);

  @Query('UPDATE frais_classes SET is_sync = 1 WHERE id = :id')
  Future<void> markAsSynced(int id);

  @Query('UPDATE frais_classes SET is_sync = 1 WHERE server_id = :serverId')
  Future<void> markAsSyncedByServerId(int serverId);

  @Query('SELECT COUNT(*) FROM frais_classes WHERE is_sync = 0')
  Future<int?> getUnsyncedCount();

  @Query('SELECT COUNT(*) FROM frais_classes')
  Future<int?> getTotalCount();

  @Query(
    'UPDATE frais_classes SET server_id = :serverId, is_sync = 1 WHERE id = :id',
  )
  Future<void> updateServerIdAndSync(int id, int serverId);
}
