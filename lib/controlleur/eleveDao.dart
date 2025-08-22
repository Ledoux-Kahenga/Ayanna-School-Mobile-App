import 'package:ayanna_school/models/eleve.dart';
import 'package:floor/floor.dart';

@dao
abstract class ElevesDao {

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertAll(List<EleveModel> eleves);

  @Query('SELECT * FROM eleves')
  Future<List<EleveModel>> getAllEleves();

  // Requête Floor pour les élèves d'une classe en particulier
  @Query('SELECT * FROM eleves WHERE classe_id = :classeId')
  Future<List<EleveModel>> getElevesByClasseId(int classeId);

}