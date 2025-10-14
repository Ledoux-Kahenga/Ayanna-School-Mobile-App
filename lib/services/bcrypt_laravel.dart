import 'package:bcrypt/bcrypt.dart';

class LaravelBcrypt {
  const LaravelBcrypt._();

  /// Vérifie si un mot de passe correspond à un hash bcrypt (compatible Laravel)
  ///
  /// [password] Le mot de passe en clair
  /// [hashedPassword] Le hash bcrypt généré par Laravel (format: $2a/b/y$...)
  /// Retourne true si le mot de passe est correct
  static bool checkPassword(String password, String hashedPassword) {
    try {
      // Nettoyer le hash (au cas où il y aurait des espaces)
      final cleanHash = hashedPassword.trim();

      // Vérifier le format du hash
      if (!_isValidBcryptHash(cleanHash)) {
        print('❌ [LaravelBcrypt] Format de hash invalide: $cleanHash');
        return false;
      }

      // Extraire les informations du hash
      final hashInfo = getHashInfo(cleanHash);
      final version = hashInfo['version'] as String;
      final cost = hashInfo['cost'] as int;

      print('🔍 [LaravelBcrypt] Analyse du hash:');
      print('   Version: $version');
      print('   Cost factor: $cost');
      print('   Hash: $cleanHash');

      // Essayer d'abord avec BCrypt.checkpw (devrait supporter toutes les versions)
      try {
        final isValid =
            cleanHash.compareTo(
              hashPassword(password, cost: cost, version: version,salt: cleanHash,),
            ) ==
            0;
        print('✅ [LaravelBcrypt] Vérification BCrypt.checkpw: $isValid');
        return isValid;
      } catch (e) {
        print(
          '⚠️ [LaravelBcrypt] BCrypt.checkpw a échoué, tentative de fallback: $e',
        );

        // Fallback: Implémentation manuelle pour les cas difficiles
        return _manualBcryptCheck(password, cleanHash, version, cost);
      }
    } catch (e) {
      print('❌ [LaravelBcrypt] Erreur lors de la vérification: $e');
      return false;
    }
  }

  /// Vérification manuelle bcrypt pour les cas où BCrypt.checkpw échoue
  static bool _manualBcryptCheck(
    String password,
    String hash,
    String version,
    int cost,
  ) {
    try {
      print('🔧 [LaravelBcrypt] Tentative de vérification manuelle...');

      // Pour une vérification complète, il faudrait implémenter l'algorithme bcrypt complet
      // Pour l'instant, on utilise une approche simplifiée

      // Générer un hash avec le même mot de passe et comparer
      final testSalt = hash.substring(0, 29); // $2x$xx$xxxxxxxxxxxxxxxxxxxxxx
      final expectedHash = hash.substring(29); // La partie hash

      // Créer un nouveau hash avec le même salt
      final testHash = BCrypt.hashpw(password, testSalt);

      // Comparer les hashes (doivent être identiques)
      final isValid = testHash == hash;

      print('🔧 [LaravelBcrypt] Vérification manuelle: $isValid');
      print('   Attendu: ${expectedHash.substring(0, 10)}...');
      print('   Calculé: ${testHash.substring(29, 39)}...');

      return isValid;
    } catch (e) {
      print('❌ [LaravelBcrypt] Échec de la vérification manuelle: $e');
      return false;
    }
  }

  /// Vérifie si le hash a un format bcrypt valide
  static bool _isValidBcryptHash(String hash) {
    // Format attendu: $2a/b/y$cost$salt+hash (60 caractères)
    if (hash.length != 60) {
      return false;
    }

    // Commence par $2
    if (!hash.startsWith(r'$2')) {
      return false;
    }

    // Version valide (a, b, y)
    final version = hash[2];
    if (version != 'a' && version != 'b' && version != 'y') {
      return false;
    }

    // Séparateur $
    if (hash[3] != r'$') {
      return false;
    }

    // Cost factor (2 chiffres)
    final costStr = hash.substring(4, 6);
    final cost = int.tryParse(costStr);
    if (cost == null || cost < 4 || cost > 31) {
      return false;
    }

    // Séparateur $
    if (hash[6] != r'$') {
      return false;
    }

    return true;
  }

  /// Génère un hash bcrypt compatible avec Laravel
  ///
  /// [password] Le mot de passe à hasher
  /// [cost] Le cost factor (par défaut 12 comme Laravel)
  /// [version] La version bcrypt ('2y' pour Laravel, '2b' ou '2a' pour compatibilité)
  /// Retourne le hash au format spécifié
  static String hashPassword(
    String password, {
    int cost = 12,
    String version = '2y',
    String? salt,
  }) {
    try {
      // Valider la version
      if (!['2a', '2b', '2y'].contains(version)) {
        throw ArgumentError(
          'Version bcrypt invalide: $version. Utilisez 2a, 2b ou 2y.',
        );
      }

      // Valider le cost factor
      if (cost < 4 || cost > 31) {
        throw ArgumentError(
          'Cost factor invalide: $cost. Doit être entre 4 et 31.',
        );
      }

      // Générer un salt avec la version spécifiée
      final prefix = '\$$version';
      final salt2 = BCrypt.gensalt(prefix: prefix, logRounds: cost);
      final hashed = BCrypt.hashpw(password, salt ?? salt2);

      print('🔐 [LaravelBcrypt] Hash généré:');
      print('   Version: $version');
      print('   Cost: $cost');
      print('   Salt: $salt');
      print('   Hash: $hashed');

      return hashed;
    } catch (e) {
      print('❌ [LaravelBcrypt] Erreur lors du hash: $e');
      throw Exception('Impossible de hasher le mot de passe: $e');
    }
  }

  /// Génère un hash compatible Laravel (version 2y par défaut)
  static String hashForLaravel(String password, {int cost = 12}) {
    return hashPassword(password, cost: cost, version: '2y');
  }

  /// Génère un hash compatible avec l'ancienne version (2a)
  static String hashLegacy(String password, {int cost = 10}) {
    return hashPassword(password, cost: cost, version: '2a');
  }

  /// Extrait les informations d'un hash bcrypt
  static Map<String, dynamic> getHashInfo(String hash) {
    if (!_isValidBcryptHash(hash)) {
      return {'valid': false};
    }

    return {
      'valid': true,
      'version': hash.substring(1, 3), // 2a, 2b, 2y
      'cost': int.parse(hash.substring(4, 6)),
      'salt': hash.substring(7, 29), // 22 caractères
      'hash': hash.substring(29), // 31 caractères
    };
  }

  /// Test de compatibilité avec différents formats
  static void testCompatibility() {
    print('🧪 [LaravelBcrypt] Test de compatibilité:');

    // Test avec format $2y$ (Laravel standard)
    const testPassword = 'test123';
    final hash2y = hashPassword(testPassword, cost: 12);
    final check2y = checkPassword(testPassword, hash2y);
    print('   \$2y\$12\$...: $check2y');

    // Test avec format $2b$
    final hash2b = BCrypt.hashpw(
      testPassword,
      BCrypt.gensalt(prefix: r'$2b', logRounds: 12),
    );
    final check2b = checkPassword(testPassword, hash2b);
    print('   \$2b\$12\$...: $check2b');

    // Test avec format $2a$
    final hash2a = BCrypt.hashpw(
      testPassword,
      BCrypt.gensalt(prefix: r'$2a', logRounds: 10),
    );
    final check2a = checkPassword(testPassword, hash2a);
    print('   \$2a\$10\$...: $check2a');
  }
}
