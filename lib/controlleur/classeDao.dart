import 'package:ayanna_school/models/classe.dart';
import 'package:floor/floor.dart';

@dao
abstract class ClassesDao {

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertAll(List<ClassModel> classes);

  @Query('SELECT * FROM classes')
  Future<List<ClassModel>> getAllClasses();

  // Requête Floor pour les classes d'une année scolaire en particulier
  @Query('SELECT * FROM classes WHERE annee_scolaire_id = :anneeScolaireId')
  Future<int?> getClassesByAnnee(int anneeScolaireId);

}