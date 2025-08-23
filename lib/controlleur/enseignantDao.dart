import 'dart:async';
import 'package:ayanna_school/models/enseignant.dart';
import 'package:floor/floor.dart';

@dao
abstract class EnseignantDao {

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertAll(List<EnseignantModel> enseignants);

} 