import 'dart:async';

import 'package:ayanna_school/controlleur/anneeScolaireDao.dart';
import 'package:ayanna_school/controlleur/classeDao.dart';
import 'package:ayanna_school/controlleur/eleveDao.dart';
import 'package:ayanna_school/models/anneeScolaire.dart';
import 'package:ayanna_school/models/classe.dart';
import 'package:ayanna_school/models/eleve.dart';

import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;




part 'database.g.dart'; 

// the generated code will be there

@Database(version: 1, entities: [AnneeScolaireModel, ClassModel, EleveModel])
abstract class MainDatabaseAppFloor extends FloorDatabase {
  AnneeScolaireDao get anneeScolaireDao;
  ClassesDao get classDaos;
  ElevesDao get elevesDao;

}