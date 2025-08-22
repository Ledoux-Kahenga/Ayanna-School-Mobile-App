import 'dart:async';

import 'package:ayanna_school/models/anneeScolaire.dart';
import 'package:floor/floor.dart';

@dao
abstract class AnneeScolaireDao {

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertAll(List<AnneeScolaireModel> anneeScolaire);

  @Query('SELECT * FROM annees_scolaires WHERE en_cours = 1')
  Future<AnneeScolaireModel?> getAnneescolaireEnCours();

}