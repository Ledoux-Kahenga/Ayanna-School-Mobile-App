import 'package:floor/floor.dart';
import '../entities/note_periode.dart';

@dao
abstract class NotePeriodeDao {
  @Query('SELECT * FROM notes_periode')
  Future<List<NotePeriode>> getAllNotesPeriode();

  @Query('SELECT * FROM notes_periode WHERE id = :id')
  Future<NotePeriode?> getNotesPeriodeById(int id);

  @Query('SELECT * FROM notes_periode WHERE server_id = :serverId')
  Future<NotePeriode?> getNotesPeriodeByServerId(int serverId);

  @Query('SELECT * FROM notes_periode WHERE eleve_id = :eleveId')
  Future<List<NotePeriode>> getNotesPeriodeByEleve(int eleveId);

  @Query('SELECT * FROM notes_periode WHERE cours_id = :coursId')
  Future<List<NotePeriode>> getNotesPeriodeByCours(int coursId);

  @Query('SELECT * FROM notes_periode WHERE periode_id = :periodeId')
  Future<List<NotePeriode>> getNotesPeriodeByPeriode(int periodeId);

  @Query(
    'SELECT * FROM notes_periode WHERE eleve_id = :eleveId AND periode_id = :periodeId',
  )
  Future<List<NotePeriode>> getNotesByEleveAndPeriode(
    int eleveId,
    int periodeId,
  );

  @Query(
    'SELECT * FROM notes_periode WHERE cours_id = :coursId AND periode_id = :periodeId',
  )
  Future<List<NotePeriode>> getNotesByCoursAndPeriode(
    int coursId,
    int periodeId,
  );

  @Query(
    'SELECT * FROM notes_periode WHERE eleve_id = :eleveId AND cours_id = :coursId AND periode_id = :periodeId',
  )
  Future<NotePeriode?> getNoteByEleveCoursAndPeriode(
    int eleveId,
    int coursId,
    int periodeId,
  );

  @Query('SELECT * FROM notes_periode WHERE note_sur_20 >= :noteMin')
  Future<List<NotePeriode>> getNotesSuperieuresA(double noteMin);

  @Query('SELECT * FROM notes_periode WHERE note_sur_20 < :noteMax')
  Future<List<NotePeriode>> getNotesInferieuresA(double noteMax);

  @Query('SELECT * FROM notes_periode WHERE is_sync = 0')
  Future<List<NotePeriode>> getUnsyncedNotesPeriode();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertNotePeriode(NotePeriode notePeriode);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<List<int>> insertMultipleNotePeriode(List<NotePeriode> notesPeriode);

  @update
  Future<void> updateNotePeriode(NotePeriode notePeriode);

  @update
  Future<void> updateMultipleNotePeriode(List<NotePeriode> notesPeriode);

  @delete
  Future<void> deleteNotePeriode(NotePeriode notePeriode);

  @Query('DELETE FROM notes_periode WHERE id = :id')
  Future<void> deleteNotePeriodeById(int id);

  @Query('DELETE FROM notes_periode')
  Future<void> deleteAllNotesPeriode();

  @Query('DELETE FROM notes_periode WHERE cours_id = :coursId')
  Future<void> deleteNotesByCours(int coursId);

  @Query('DELETE FROM notes_periode WHERE periode_id = :periodeId')
  Future<void> deleteNotesByPeriode(int periodeId);

  @Query('UPDATE notes_periode SET is_sync = 1 WHERE id = :id')
  Future<void> markAsSynced(int id);

  @Query(
    'UPDATE notes_periode SET server_id = :serverId, is_sync = 1 WHERE id = :id',
  )
  Future<void> updateServerIdAndSync(int id, int serverId);
}
