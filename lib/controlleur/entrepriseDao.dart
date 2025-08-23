import 'dart:async';
import 'package:ayanna_school/models/entreprises.dart';
import 'package:floor/floor.dart';

@dao
abstract class EntreprisesDao {

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertAll(List<EntrepriseModel> entreprises);

}