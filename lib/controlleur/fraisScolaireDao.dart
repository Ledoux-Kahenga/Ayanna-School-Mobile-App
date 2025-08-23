import 'dart:async';
import 'package:ayanna_school/models/fraisScolaire.dart';
import 'package:floor/floor.dart';

@dao
abstract class FraisScolaireDao {

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertAll(List<FraisScolaireModel> fraisScolaires);

}