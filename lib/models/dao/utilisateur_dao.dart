import 'package:floor/floor.dart';
import '../entities/utilisateur.dart';

@dao
abstract class UtilisateurDao {
  @Query('SELECT * FROM utilisateurs')
  Future<List<Utilisateur>> getAllUtilisateurs();

  @Query(
    'SELECT * FROM utilisateurs WHERE email = :email AND mot_de_passe_hash = :password limit 1',
  )
  Future<Utilisateur?> loginLocalement(String email, String password);

  @Query('SELECT mot_de_passe_hash FROM utilisateurs WHERE email = :email')
  Future<String?> getMotDePasseHashByEmail(String email);

  @Query('SELECT * FROM utilisateurs WHERE id = :id')
  Future<Utilisateur?> getUtilisateurById(int id);

  @Query('SELECT * FROM utilisateurs WHERE email = :email')
  Future<Utilisateur?> getUtilisateurByEmail(String email);

  @Query('SELECT * FROM utilisateurs WHERE entreprise_id = :entrepriseId')
  Future<List<Utilisateur>> getUtilisateursByEntreprise(int entrepriseId);

  @Query('SELECT * FROM utilisateurs WHERE is_sync = 0')
  Future<List<Utilisateur>> getUnsyncedUtilisateurs();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertUtilisateur(Utilisateur utilisateur);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<List<int>> insertUtilisateurs(List<Utilisateur> utilisateurs);

  @update
  Future<void> updateUtilisateur(Utilisateur utilisateur);

  @update
  Future<void> updateUtilisateurs(List<Utilisateur> utilisateurs);

  @delete
  Future<void> deleteUtilisateur(Utilisateur utilisateur);

  @Query('DELETE FROM utilisateurs')
  Future<void> deleteAllUtilisateurs();

  @Query('DELETE FROM utilisateurs WHERE entreprise_id = :entrepriseId')
  Future<void> deleteUtilisateursByEntreprise(int entrepriseId);

  @Query('UPDATE utilisateurs SET is_sync = 1 WHERE id = :id')
  Future<void> markAsSynced(int id);

  @Query(
    'UPDATE utilisateurs SET server_id = :serverId, is_sync = 1 WHERE id = :id',
  )
  Future<void> updateServerIdAndSync(int id, int serverId);
}
