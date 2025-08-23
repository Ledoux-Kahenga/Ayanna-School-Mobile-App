import 'dart:async';
import 'package:ayanna_school/models/responsable.dart';
import 'package:ayanna_school/models/utilisateurs.dart';
import 'package:floor/floor.dart';

@dao
abstract class UtilisateursDao {

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertAll(List<UtilisateurModel> utilisateurs);

}