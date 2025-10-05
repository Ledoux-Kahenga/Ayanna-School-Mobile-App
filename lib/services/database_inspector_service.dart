import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as path;
import '../models/app_database.dart';

class DatabaseInspectorService {
  static const String dbName = 'ayanna_school_database.db';

  static Future<String> getDatabasePath() async {
    final appDir = await getApplicationDocumentsDirectory();
    return path.join(appDir.path, dbName);
  }

  static Future<String> exportDatabase() async {
    try {
      // Obtenir le chemin de la base de données
      final dbPath = await getDatabasePath();
      final dbFile = File(dbPath);

      if (!await dbFile.exists()) {
        throw Exception('Base de données non trouvée: $dbPath');
      }

      // Créer un dossier temporaire pour l'export
      final tempDir = await getTemporaryDirectory();
      final exportPath = '${tempDir.path}/ayanna_school_export.db';

      // Copier la base de données
      await dbFile.copy(exportPath);

      return exportPath;
    } catch (e) {
      throw Exception('Erreur lors de l\'export de la base de données: $e');
    }
  }

  static Future<void> shareDatabase() async {
    try {
      final exportPath = await exportDatabase();
      final file = XFile(exportPath);

      await Share.shareXFiles(
        [file],
        text: 'Export de la base de données Ayanna School',
        subject: 'Base de données SQLite',
      );
    } catch (e) {
      throw Exception('Erreur lors du partage: $e');
    }
  }

  static Future<Map<String, dynamic>> getDatabaseInfo() async {
    try {
      final dbPath = await getDatabasePath();
      final dbFile = File(dbPath);

      final size = await dbFile.length();
      final exists = await dbFile.exists();
      final lastModified = await dbFile.lastModified();

      return {
        'path': dbPath,
        'exists': exists,
        'size': size,
        'sizeFormatted': _formatBytes(size),
        'lastModified': lastModified.toIso8601String(),
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  static Future<List<String>> getTableNames() async {
    try {
      final database = await AppDatabase.create();
      final result = await database.database.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
      );

      await database.close();
      return result.map((row) => row['name'] as String).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des tables: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getTableInfo(
    String tableName,
  ) async {
    try {
      final database = await AppDatabase.create();
      final result = await database.database.rawQuery(
        'PRAGMA table_info($tableName)',
      );

      await database.close();
      return result;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des infos table: $e');
    }
  }

  static Future<int> getTableCount(String tableName) async {
    try {
      final database = await AppDatabase.create();
      final result = await database.database.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName',
      );

      await database.close();
      return result.first['count'] as int;
    } catch (e) {
      throw Exception('Erreur lors du comptage: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getTableSample(
    String tableName, {
    int limit = 5,
  }) async {
    try {
      final database = await AppDatabase.create();
      final result = await database.database.rawQuery(
        'SELECT * FROM $tableName LIMIT $limit',
      );

      await database.close();
      return result;
    } catch (e) {
      throw Exception('Erreur lors de l\'échantillonnage: $e');
    }
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
