import 'dart:async';
import 'package:ayanna_school/models/fraisClasse.dart';
import 'package:floor/floor.dart';

@dao
abstract class FraisclasseDao {

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertAll(List<FraisClassesModel> fraisClasses);

}