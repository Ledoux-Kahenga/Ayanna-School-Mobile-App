import 'package:floor/floor.dart';
import '../entities/periode.dart';

@dao
abstract class PeriodeDao {
  @Query('SELECT * FROM periodes')
  Future<List<Periode>> getAllPeriodes();

  @Query('SELECT * FROM periodes WHERE id = :id')
  Future<Periode?> getPeriodeById(int id);

  @Query('SELECT * FROM periodes WHERE server_id = :serverId')
  Future<Periode?> getPeriodeByServerId(int serverId);

  @Query(
    'SELECT * FROM periodes WHERE nom = :nom AND annee_scolaire_id = :anneeScolaireId',
  )
  Future<Periode?> getPeriodeByNomAndAnnee(String nom, int anneeScolaireId);

  @Query('SELECT * FROM periodes WHERE annee_scolaire_id = :anneeScolaireId')
  Future<List<Periode>> getPeriodesByAnnee(int anneeScolaireId);

  @Query(
    'SELECT * FROM periodes WHERE annee_scolaire_id = :anneeScolaireId ORDER BY numero ASC',
  )
  Future<List<Periode>> getPeriodesByAnneeOrdered(int anneeScolaireId);

  @Query(
    'SELECT * FROM periodes WHERE numero = :numero AND annee_scolaire_id = :anneeScolaireId',
  )
  Future<Periode?> getPeriodeByNumero(int numero, int anneeScolaireId);

  @Query(
    'SELECT * FROM periodes WHERE date_debut <= :date AND date_fin >= :date',
  )
  Future<List<Periode>> getPeriodesByDate(DateTime date);

  @Query(
    'SELECT * FROM periodes WHERE date_debut >= :dateDebut AND date_fin <= :dateFin',
  )
  Future<List<Periode>> getPeriodesInDateRange(
    DateTime dateDebut,
    DateTime dateFin,
  );

  @Query('SELECT * FROM periodes WHERE is_active = 1')
  Future<List<Periode>> getPeriodesActives();

  @Query(
    'SELECT * FROM periodes WHERE is_active = 1 AND annee_scolaire_id = :anneeScolaireId',
  )
  Future<List<Periode>> getPeriodesActivesByAnnee(int anneeScolaireId);

  @Query(
    'SELECT * FROM periodes WHERE date_debut <= :currentDate AND date_fin >= :currentDate AND is_active = 1',
  )
  Future<Periode?> getPeriodeActuelle(DateTime currentDate);

  @Query('SELECT * FROM periodes WHERE is_sync = 0')
  Future<List<Periode>> getUnsyncedPeriodes();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertPeriode(Periode periode);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<List<int>> insertPeriodes(List<Periode> periodes);

  @update
  Future<void> updatePeriode(Periode periode);

  @update
  Future<void> updatePeriodes(List<Periode> periodes);

  @delete
  Future<void> deletePeriode(Periode periode);

  @Query('DELETE FROM periodes')
  Future<void> deleteAllPeriodes();

  @Query('DELETE FROM periodes WHERE annee_scolaire_id = :anneeScolaireId')
  Future<void> deletePeriodesByAnnee(int anneeScolaireId);

  @Query('UPDATE periodes SET is_sync = 1 WHERE id = :id')
  Future<void> markAsSynced(int id);

  @Query(
    'UPDATE periodes SET server_id = :serverId, is_sync = 1 WHERE id = :id',
  )
  Future<void> updateServerIdAndSync(int id, int serverId);

  @Query('UPDATE periodes SET is_active = 0 WHERE id = :id')
  Future<void> desactiverPeriode(int id);

  @Query('UPDATE periodes SET is_active = 1 WHERE id = :id')
  Future<void> activerPeriode(int id);

  @Query(
    'UPDATE periodes SET is_active = 0 WHERE annee_scolaire_id = :anneeScolaireId',
  )
  Future<void> desactiverToutesPeriodesAnnee(int anneeScolaireId);
}
