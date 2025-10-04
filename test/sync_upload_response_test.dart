import 'package:flutter_test/flutter_test.dart';
import 'package:ayanna_school/models/sync_response.dart';

void main() {
  group('SyncUploadResponse Tests', () {
    test('should create response without mapping', () {
      final response = SyncUploadResponse(
        success: true,
        message: 'Upload successful',
      );

      expect(response.success, true);
      expect(response.message, 'Upload successful');
      expect(response.hasIdMapping, false);
      expect(response.totalMappedIds, 0);
      expect(response.affectedTables, isEmpty);
    });

    test('should create response with ID mapping', () {
      final response = SyncUploadResponse(
        success: true,
        message: 'Upload successful',
        idMapping: [
          IdMapping(table: 'eleves', idLocal: 71, idServeur: 88),
          IdMapping(table: 'eleves', idLocal: 75, idServeur: 89),
          IdMapping(table: 'enseignants', idLocal: 12, idServeur: 45),
        ],
      );

      expect(response.success, true);
      expect(response.hasIdMapping, true);
      expect(response.totalMappedIds, 3);
      expect(response.affectedTables, containsAll(['eleves', 'enseignants']));
      expect(response.affectedTables.length, 2);
    });

    test('should get mappings for specific table', () {
      final response = SyncUploadResponse(
        success: true,
        idMapping: [
          IdMapping(table: 'eleves', idLocal: 71, idServeur: 88),
          IdMapping(table: 'eleves', idLocal: 75, idServeur: 89),
          IdMapping(table: 'enseignants', idLocal: 12, idServeur: 45),
        ],
      );

      final elevesMappings = response.getMappingsForTable('eleves');
      expect(elevesMappings.length, 2);
      expect(elevesMappings.every((m) => m.table == 'eleves'), true);

      final enseignantsMappings = response.getMappingsForTable('enseignants');
      expect(enseignantsMappings.length, 1);
      expect(enseignantsMappings.first.table, 'enseignants');

      final nonExistentMappings = response.getMappingsForTable('nonexistent');
      expect(nonExistentMappings, isEmpty);
    });

    test('should get server ID for local ID', () {
      final response = SyncUploadResponse(
        success: true,
        idMapping: [
          IdMapping(table: 'eleves', idLocal: 71, idServeur: 88),
          IdMapping(table: 'eleves', idLocal: 75, idServeur: 89),
          IdMapping(table: 'enseignants', idLocal: 12, idServeur: 45),
        ],
      );

      expect(response.getServerIdForLocal('eleves', 71), 88);
      expect(response.getServerIdForLocal('eleves', 75), 89);
      expect(response.getServerIdForLocal('enseignants', 12), 45);
      expect(response.getServerIdForLocal('eleves', 999), null);
      expect(response.getServerIdForLocal('nonexistent', 71), null);
    });

    test('should handle JSON serialization/deserialization', () {
      final originalResponse = SyncUploadResponse(
        success: true,
        message: 'Upload successful',
        idMapping: [
          IdMapping(table: 'eleves', idLocal: 71, idServeur: 88),
          IdMapping(table: 'enseignants', idLocal: 12, idServeur: 45),
        ],
      );

      // Test toJson
      final json = originalResponse.toJson();
      expect(json['success'], true);
      expect(json['message'], 'Upload successful');
      expect(json['id_mapping'], isA<List>());
      expect(json['id_mapping'].length, 2);

      // Test fromJson
      final deserializedResponse = SyncUploadResponse.fromJson(json);
      expect(deserializedResponse.success, originalResponse.success);
      expect(deserializedResponse.message, originalResponse.message);
      expect(deserializedResponse.hasIdMapping, true);
      expect(deserializedResponse.totalMappedIds, 2);
      expect(
        deserializedResponse.affectedTables,
        containsAll(['eleves', 'enseignants']),
      );
    });
  });

  group('IdMapping Tests', () {
    test('should create IdMapping correctly', () {
      final mapping = IdMapping(table: 'eleves', idLocal: 71, idServeur: 88);

      expect(mapping.table, 'eleves');
      expect(mapping.idLocal, 71);
      expect(mapping.idServeur, 88);
    });

    test('should handle JSON serialization/deserialization', () {
      final originalMapping = IdMapping(
        table: 'eleves',
        idLocal: 71,
        idServeur: 88,
      );

      // Test toJson
      final json = originalMapping.toJson();
      expect(json['table'], 'eleves');
      expect(json['id_local'], 71);
      expect(json['id_serveur'], 88);

      // Test fromJson
      final deserializedMapping = IdMapping.fromJson(json);
      expect(deserializedMapping.table, originalMapping.table);
      expect(deserializedMapping.idLocal, originalMapping.idLocal);
      expect(deserializedMapping.idServeur, originalMapping.idServeur);
    });

    test('should handle equality correctly', () {
      final mapping1 = IdMapping(table: 'eleves', idLocal: 71, idServeur: 88);
      final mapping2 = IdMapping(table: 'eleves', idLocal: 71, idServeur: 88);
      final mapping3 = IdMapping(table: 'eleves', idLocal: 72, idServeur: 89);

      expect(mapping1 == mapping2, true);
      expect(mapping1 == mapping3, false);
      expect(mapping1.hashCode == mapping2.hashCode, true);
    });
  });

  group('Real API Response Tests', () {
    test('should parse real server response format', () {
      // Format exact de la réponse du serveur
      final serverResponseJson = {
        "success": true,
        "id_mapping": [
          {"table": "eleves", "id_local": 71, "id_serveur": 88},
          {"table": "eleves", "id_local": 75, "id_serveur": 89},
        ],
      };

      final response = SyncUploadResponse.fromJson(serverResponseJson);

      expect(response.success, true);
      expect(response.hasIdMapping, true);
      expect(response.totalMappedIds, 2);
      expect(response.affectedTables, ['eleves']);
      expect(response.getServerIdForLocal('eleves', 71), 88);
      expect(response.getServerIdForLocal('eleves', 75), 89);
    });

    test('should handle server response without mapping', () {
      final serverResponseJson = {
        "success": true,
        "message": "No new records to map",
      };

      final response = SyncUploadResponse.fromJson(serverResponseJson);

      expect(response.success, true);
      expect(response.hasIdMapping, false);
      expect(response.totalMappedIds, 0);
      expect(response.affectedTables, isEmpty);
    });

    test('should handle error response', () {
      final serverResponseJson = {
        "success": false,
        "message": "Upload failed due to validation error",
      };

      final response = SyncUploadResponse.fromJson(serverResponseJson);

      expect(response.success, false);
      expect(response.message, "Upload failed due to validation error");
      expect(response.hasIdMapping, false);
    });
  });

  group('Edge Cases Tests', () {
    test('should handle empty mapping list', () {
      final response = SyncUploadResponse(success: true, idMapping: []);

      expect(response.hasIdMapping, false);
      expect(response.totalMappedIds, 0);
      expect(response.affectedTables, isEmpty);
    });

    test('should handle null values in mapping', () {
      // Test de robustesse - ne devrait pas se produire en production
      final json = {
        "success": true,
        "id_mapping": [
          {"table": "eleves", "id_local": 71, "id_serveur": 88},
          null, // Valeur null dans la liste
        ],
      };

      // La désérialisation devrait ignorer les valeurs null
      expect(() => SyncUploadResponse.fromJson(json), returnsNormally);
    });

    test('should handle duplicate mappings', () {
      final response = SyncUploadResponse(
        success: true,
        idMapping: [
          IdMapping(table: 'eleves', idLocal: 71, idServeur: 88),
          IdMapping(
            table: 'eleves',
            idLocal: 71,
            idServeur: 89,
          ), // Doublon avec ID serveur différent
        ],
      );

      expect(response.totalMappedIds, 2);
      // Le premier mapping trouvé devrait être retourné
      expect(response.getServerIdForLocal('eleves', 71), 88);
    });
  });
}
