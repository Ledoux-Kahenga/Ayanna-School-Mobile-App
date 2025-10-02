import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../database/sync_migration.dart';

class DatabaseService {
  static Database? _db;
  static const String dbName = 'ayanna_school.db';

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, dbName);

    // Copy from assets if not exists
    if (!await File(path).exists()) {
      ByteData data = await rootBundle.load('assets/$dbName');
      List<int> bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      await File(path).writeAsBytes(bytes, flush: true);
    }

    final db = await openDatabase(path);

    // Exécuter la migration de synchronisation si nécessaire
    try {
      final migrationComplete = await SyncMigration.isSyncMigrationComplete(db);
      if (!migrationComplete) {
        await SyncMigration.runSyncMigration(db);
      }
    } catch (e) {
      print('⚠️ Erreur lors de la migration de synchronisation: $e');
      // Ne pas faire échouer l'initialisation de la DB pour autant
    }

    return db;
  }
}
