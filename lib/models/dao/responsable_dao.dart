import 'package:floor/floor.dart';
import '../entities/responsable.dart';

@dao
abstract class ResponsableDao {
  @Query('SELECT * FROM responsables')
  Future<List<Responsable>> getAllResponsables();

  @Query('SELECT * FROM responsables WHERE id = :id')
  Future<Responsable?> getResponsableById(int id);

  @Query('SELECT * FROM responsables WHERE server_id = :serverId')
  Future<Responsable?> getResponsableByServerId(int serverId);

  @Query(
    'SELECT * FROM responsables WHERE nom LIKE :searchTerm OR prenom LIKE :searchTerm',
  )
  Future<List<Responsable>> searchResponsablesByName(String searchTerm);

  @Query('SELECT * FROM responsables WHERE telephone = :telephone')
  Future<Responsable?> getResponsableByTelephone(String telephone);

  @Query('SELECT * FROM responsables WHERE email = :email')
  Future<Responsable?> getResponsableByEmail(String email);

  @Query('SELECT * FROM responsables WHERE type_responsable = :typeResponsable')
  Future<List<Responsable>> getResponsablesByType(String typeResponsable);

  @Query('SELECT * FROM responsables WHERE profession = :profession')
  Future<List<Responsable>> getResponsablesByProfession(String profession);

  @Query('SELECT * FROM responsables WHERE adresse LIKE :searchTerm')
  Future<List<Responsable>> getResponsablesByAdresse(String searchTerm);

  @Query('SELECT * FROM responsables WHERE nom = :nom AND prenom = :prenom')
  Future<List<Responsable>> getResponsablesByNomPrenom(
    String nom,
    String prenom,
  );

  @Query('SELECT * FROM responsables WHERE is_sync = 0')
  Future<List<Responsable>> getUnsyncedResponsables();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertResponsable(Responsable responsable);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<List<int>> insertResponsables(List<Responsable> responsables);

  @update
  Future<void> updateResponsable(Responsable responsable);

  @update
  Future<void> updateResponsables(List<Responsable> responsables);

  @delete
  Future<void> deleteResponsable(Responsable responsable);

  @Query('DELETE FROM responsables')
  Future<void> deleteAllResponsables();
  
  @Query('DELETE FROM responsables WHERE type_responsable = :typeResponsable')
  Future<void> deleteResponsablesByType(String typeResponsable);

  @Query('UPDATE responsables SET is_sync = 1 WHERE id = :id')
  Future<void> markAsSynced(int id);

  @Query(
    'UPDATE responsables SET server_id = :serverId, is_sync = 1 WHERE id = :id',
  )
  Future<void> updateServerIdAndSync(int id, int serverId);

  @Query('UPDATE responsables SET telephone = :nouveauTelephone WHERE id = :id')
  Future<void> updateTelephone(int id, String nouveauTelephone);

  @Query('UPDATE responsables SET email = :nouveauEmail WHERE id = :id')
  Future<void> updateEmail(int id, String nouveauEmail);

  @Query('UPDATE responsables SET adresse = :nouvelleAdresse WHERE id = :id')
  Future<void> updateAdresse(int id, String nouvelleAdresse);
}
