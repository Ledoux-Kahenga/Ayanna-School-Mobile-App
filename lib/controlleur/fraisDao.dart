import 'dart:async';
import 'package:ayanna_school/models/frais.dart';
import 'package:floor/floor.dart';

@dao
abstract class FraisDao {

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertAll(List<FraisModel> frais);

}