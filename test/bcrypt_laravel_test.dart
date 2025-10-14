import 'package:flutter_test/flutter_test.dart';
import 'package:ayanna_school/services/bcrypt_laravel.dart';

void main() {
  group('LaravelBcrypt Tests', () {
    test('Hash generation with different versions', () {
      const password = 'test_password_123';

      // Test version 2y (Laravel default)
      final hash2y = LaravelBcrypt.hashPassword(password, version: '2y');
      expect(hash2y.startsWith(r'$2y$'), true);
      expect(LaravelBcrypt.checkPassword(password, hash2y), true);

      // Test version 2b
      final hash2b = LaravelBcrypt.hashPassword(password, version: '2b');
      expect(hash2b.startsWith(r'$2b$'), true);
      expect(LaravelBcrypt.checkPassword(password, hash2b), true);

      // Test version 2a
      final hash2a = LaravelBcrypt.hashPassword(password, version: '2a');
      expect(hash2a.startsWith(r'$2a$'), true);
      expect(LaravelBcrypt.checkPassword(password, hash2a), true);
    });

    test('Laravel compatible hash generation', () {
      const password = 'laravel_password';
      final hash = LaravelBcrypt.hashForLaravel(password);

      expect(hash.startsWith(r'$2y$'), true);
      expect(LaravelBcrypt.checkPassword(password, hash), true);
    });

    test('Legacy hash generation', () {
      const password = 'legacy_password';
      final hash = LaravelBcrypt.hashLegacy(password);

      expect(hash.startsWith(r'$2a$'), true);
      expect(LaravelBcrypt.checkPassword(password, hash), true);
    });

    test('Password verification with different hash versions', () {
      const password = 'verify_password';

      // Créer des hashes avec différentes versions
      final hash2y = LaravelBcrypt.hashPassword(password, version: '2y');
      final hash2b = LaravelBcrypt.hashPassword(password, version: '2b');
      final hash2a = LaravelBcrypt.hashPassword(password, version: '2a');

      // Vérifier que tous les hashes peuvent être vérifiés
      expect(LaravelBcrypt.checkPassword(password, hash2y), true);
      expect(LaravelBcrypt.checkPassword(password, hash2b), true);
      expect(LaravelBcrypt.checkPassword(password, hash2a), true);

      // Vérifier qu'un mauvais mot de passe échoue
      expect(LaravelBcrypt.checkPassword('wrong_password', hash2y), false);
    });

    test('Invalid version handling', () {
      expect(
        () => LaravelBcrypt.hashPassword('password', version: 'invalid'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Invalid cost factor handling', () {
      expect(
        () => LaravelBcrypt.hashPassword('password', cost: 3),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => LaravelBcrypt.hashPassword('password', cost: 32),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Malformed hash handling', () {
      expect(LaravelBcrypt.checkPassword('password', 'invalid_hash'), false);
      expect(LaravelBcrypt.checkPassword('password', ''), false);
      expect(LaravelBcrypt.checkPassword('password', r'$2y$invalid'), false);
    });
  });
}
