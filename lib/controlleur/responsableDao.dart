import 'dart:async';
import 'package:ayanna_school/models/responsable.dart';
import 'package:floor/floor.dart';

@dao
abstract class ResponsableDao {

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertAll(List<ResponsableModel> responsables);

}