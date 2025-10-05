import 'package:floor/floor.dart';
import '../entities/periodes_classes.dart';

@dao
abstract class PeriodesClassesDao {
  @Query('SELECT * FROM periodes_classes')
  Future<List<PeriodesClasses>> getAllPeriodesClasses();

  @Query('SELECT * FROM periodes_classes WHERE id = :id')
  Future<PeriodesClasses?> getPeriodeClasseById(int id);

  @Query('SELECT * FROM periodes_classes WHERE server_id = :serverId')
  Future<PeriodesClasses?> getPeriodeClasseByServerId(int serverId);

  @Query('SELECT * FROM periodes_classes WHERE periode_id = :periodeId')
  Future<List<PeriodesClasses>> getPeriodeClassesByPeriode(int periodeId);

  @Query('SELECT * FROM periodes_classes WHERE classe_id = :classeId')
  Future<List<PeriodesClasses>> getPeriodeClassesByClasse(int classeId);

  @Query(
    'SELECT * FROM periodes_classes WHERE periode_id = :periodeId AND classe_id = :classeId',
  )
  Future<PeriodesClasses?> getPeriodeClasseByPeriodeAndClasse(
    int periodeId,
    int classeId,
  );

  @Query(
    'SELECT * FROM periodes_classes WHERE date_debut <= :date AND date_fin >= :date',
  )
  Future<List<PeriodesClasses>> getPeriodeClassesByDate(DateTime date);

  @Query(
    'SELECT * FROM periodes_classes WHERE date_debut >= :dateDebut AND date_fin <= :dateFin',
  )
  Future<List<PeriodesClasses>> getPeriodeClassesInDateRange(
    DateTime dateDebut,
    DateTime dateFin,
  );

  @Query('SELECT * FROM periodes_classes WHERE is_active = 1')
  Future<List<PeriodesClasses>> getPeriodeClassesActives();

  @Query(
    'SELECT * FROM periodes_classes WHERE is_active = 1 AND classe_id = :classeId',
  )
  Future<List<PeriodesClasses>> getPeriodeClassesActivesByClasse(int classeId);

  @Query(
    'SELECT * FROM periodes_classes WHERE is_active = 1 AND periode_id = :periodeId',
  )
  Future<List<PeriodesClasses>> getPeriodeClassesActivesByPeriode(
    int periodeId,
  );

  @Query(
    'SELECT * FROM periodes_classes WHERE date_debut <= :currentDate AND date_fin >= :currentDate AND is_active = 1 AND classe_id = :classeId',
  )
  Future<PeriodesClasses?> getPeriodeClasseActuelle(
    DateTime currentDate,
    int classeId,
  );

  @Query('SELECT * FROM periodes_classes WHERE is_sync = 0')
  Future<List<PeriodesClasses>> getUnsyncedPeriodesClasses();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertPeriodeClasse(PeriodesClasses periodesClasses);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<List<int>> insertPeriodesClasses(
    List<PeriodesClasses> periodesClasses,
  );

  @update
  Future<void> updatePeriodeClasse(PeriodesClasses periodesClasses);

  @update
  Future<void> updatePeriodesClasses(List<PeriodesClasses> periodesClasses);

  @delete
  Future<void> deletePeriodeClasse(PeriodesClasses periodesClasses);

  @Query('DELETE FROM periodes_classes')
  Future<void> deleteAllPeriodesClasses();
  @Query('DELETE FROM periodes_classes WHERE periode_id = :periodeId')
  Future<void> deletePeriodeClassesByPeriode(int periodeId);

  @Query('DELETE FROM periodes_classes WHERE classe_id = :classeId')
  Future<void> deletePeriodeClassesByClasse(int classeId);

  @Query('UPDATE periodes_classes SET is_sync = 1 WHERE id = :id')
  Future<void> markAsSynced(int id);

  @Query(
    'UPDATE periodes_classes SET server_id = :serverId, is_sync = 1 WHERE id = :id',
  )
  Future<void> updateServerIdAndSync(int id, int serverId);

  @Query('UPDATE periodes_classes SET is_active = 0 WHERE id = :id')
  Future<void> desactiverPeriodeClasse(int id);

  @Query('UPDATE periodes_classes SET is_active = 1 WHERE id = :id')
  Future<void> activerPeriodeClasse(int id);

  @Query(
    'UPDATE periodes_classes SET is_active = 0 WHERE classe_id = :classeId',
  )
  Future<void> desactiverToutesPeriodesClasse(int classeId);

  @Query(
    'UPDATE periodes_classes SET is_active = 0 WHERE periode_id = :periodeId',
  )
  Future<void> desactiverToutesClassesPeriode(int periodeId);
}
