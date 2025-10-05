import 'package:floor/floor.dart';
import '../entities/licence.dart';

@dao
abstract class LicenceDao {
  @Query('SELECT * FROM licence')
  Future<List<Licence>> getAllLicences();

  @Query('SELECT * FROM licence WHERE id = :id')
  Future<Licence?> getLicenceById(int id);

  @Query('SELECT * FROM licence WHERE server_id = :serverId')
  Future<Licence?> getLicenceByServerId(int serverId);

  @Query('SELECT * FROM licence WHERE cle = :cle')
  Future<Licence?> getLicenceByCle(String cle);

  @Query('SELECT * FROM licence WHERE entreprise_id = :entrepriseId')
  Future<List<Licence>> getLicencesByEntreprise(int entrepriseId);

  @Query(
    'SELECT * FROM licence WHERE type = :type AND entreprise_id = :entrepriseId',
  )
  Future<List<Licence>> getLicencesByType(String type, int entrepriseId);

  @Query(
    'SELECT * FROM licence WHERE active = 1 AND entreprise_id = :entrepriseId',
  )
  Future<List<Licence>> getLicencesActives(int entrepriseId);

  @Query('SELECT * FROM licence WHERE date_expiration > :date AND active = 1')
  Future<List<Licence>> getLicencesValides(DateTime date);

  @Query('SELECT * FROM licence WHERE date_expiration <= :date AND active = 1')
  Future<List<Licence>> getLicencesExpirees(DateTime date);

  @Query('SELECT * FROM licence WHERE is_sync = 0')
  Future<List<Licence>> getUnsyncedLicences();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertLicence(Licence licence);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<List<int>> insertLicences(List<Licence> licences);

  @update
  Future<void> updateLicence(Licence licence);

  @update
  Future<void> updateLicences(List<Licence> licences);

  @delete
  Future<void> deleteLicence(Licence licence);

  @Query('DELETE FROM licence')
  Future<void> deleteAllLicences();
  
  @Query('DELETE FROM licence WHERE entreprise_id = :entrepriseId')
  Future<void> deleteLicencesByEntreprise(int entrepriseId);

  @Query('UPDATE licence SET is_sync = 1 WHERE id = :id')
  Future<void> markAsSynced(int id);

  @Query('UPDATE licence SET server_id = :serverId, is_sync = 1 WHERE id = :id')
  Future<void> updateServerIdAndSync(int id, int serverId);

  @Query('UPDATE licence SET active = 0 WHERE id = :id')
  Future<void> desactiverLicence(int id);

  @Query('UPDATE licence SET active = 1 WHERE id = :id')
  Future<void> activerLicence(int id);
}
