import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_result.dart';
import '../config/api_config.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _entrepriseIdKey = 'entreprise_id';
  static const String _userEmailKey = 'user_email';

  String? _authToken;
  String? _userEmail;
  int? _userId;
  int? _entrepriseId;

  /// Vérifie si l'utilisateur est authentifié
  bool get isAuthenticated => _authToken != null;

  /// Obtient le token d'authentification actuel
  String? get authToken => _authToken;

  /// Obtient l'email de l'utilisateur connecté
  String? get userEmail => _userEmail;

  /// Authentifie un utilisateur via email et mot de passe
  ///
  /// Processus d'authentification :
  /// 1. Envoie les credentials (email + password) au serveur
  /// 2. Le serveur vérifie dans la table 'utilisateurs' :
  ///    - SELECT * FROM utilisateurs WHERE email = ? AND actif = 1
  ///    - Vérifie le mot_de_passe_hash avec bcrypt.compare(password, hash)
  /// 3. Si valide, retourne un token JWT + user_id + entreprise_id
  /// 4. Si invalide, retourne une erreur d'authentification
  Future<AuthResult> login(String email, {required String password}) async {
    log('=== DÉBUT AUTHENTIFICATION API ===');
    log('Email: $email');
    log(
      'Password fourni: ${password.isNotEmpty ? "OUI (${password.length} caractères)" : "NON"}',
    );
    log('URL API: ${ApiConfig.baseUrl}${ApiConfig.loginEndpoint}');

    try {
      final requestBody = {'email': email, 'password': password};

      log('Corps de la requête: ${jsonEncode(requestBody)}');

      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.loginEndpoint}'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(
            Duration(seconds: ApiConfig.timeoutSeconds),
            onTimeout: () {
              log('❌ TIMEOUT lors de l\'authentification');
              throw Exception('Timeout lors de l\'authentification');
            },
          );

      log('Status Code: ${response.statusCode}');
      log('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        log('Données décodées: $data');

        if (data['success'] == true && data['token'] != null) {
          _authToken = data['token'];
          _userEmail = email;
          _userId = data['user_id'] ?? 0;
          _entrepriseId = data['entreprise_id'] ?? 0;

          // Sauvegarder les informations d'authentification
          await _saveAuthData(data['token'], _userId!, _entrepriseId!, email);

          log('✅ Authentification réussie');
          log(
            'Token reçu: ${_authToken?.length}${_authToken != null && _authToken!.length > 10 ? _authToken!.substring(0, 10) + "..." : _authToken}',
          );
          log('User ID: ${data['user_id']}');
          log('Entreprise ID: ${data['entreprise_id']}');

          return AuthSuccess(
            token: data['token'],
            userId: data['user_id'] ?? 0,
            entrepriseId: data['entreprise_id'] ?? 0,
          );
        } else {
          log('❌ Échec de l\'authentification: ${data['message']}');
          return AuthError(
            message: data['message'] ?? 'Authentification échouée',
            errorCode: 'INVALID_CREDENTIALS',
          );
        }
      } else {
        final data = jsonDecode(response.body);
        log('❌ Erreur HTTP ${response.statusCode}: ${data['message']}');
        return AuthError(
          message: data['message'] ?? 'Erreur serveur ${response.statusCode}',
          errorCode: 'SERVER_ERROR',
        );
      }
    } catch (e, stackTrace) {
      log('❌ Exception lors de l\'authentification: $e');
      log('Stack trace: $stackTrace');
      return AuthError(
        message: 'Erreur de connexion: $e',
        errorCode: 'CONNECTION_ERROR',
      );
    }
  }

  /// Récupère les informations d'un utilisateur depuis le serveur
  /// via l'endpoint de synchronisation (seul moyen disponible)
  Future<Map<String, dynamic>?> getUserFromServer(String email) async {
    log('=== RÉCUPÉRATION UTILISATEUR VIA SYNC ===');
    log('Email recherché: $email');

    try {
      // Utiliser l'endpoint sync/download pour récupérer tous les utilisateurs
      final syncUrl = Uri.parse('${ApiConfig.baseUrl}/sync/download').replace(
        queryParameters: {
          'since': '1970-01-01T00:00:00.000Z',
          'client_id': 'flutter-client',
          'user_email': email,
        },
      );

      log('URL de sync: $syncUrl');

      final response = await http
          .get(
            syncUrl,
            headers: {
              'Content-Type': 'application/json',
              'Authorization':
                  'Bearer token', // Token statique retourné par l'API
            },
          )
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      log('Status code: ${response.statusCode}');
      log('Response length: ${response.body.length} caractères');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        log('Type de réponse: ${data.runtimeType}');

        List<Map<String, dynamic>> changes = [];
        if (data is Map<String, dynamic> && data.containsKey('changes')) {
          changes = List<Map<String, dynamic>>.from(data['changes']);
        } else if (data is List) {
          changes = List<Map<String, dynamic>>.from(data);
        }

        log('Nombre total de changements: ${changes.length}');

        // Filtrer pour récupérer les utilisateurs
        final utilisateurs =
            changes
                .where((change) => change['table'] == 'utilisateurs')
                .toList();

        log('Utilisateurs trouvés: ${utilisateurs.length}');

        if (utilisateurs.isNotEmpty) {
          // Chercher l'utilisateur spécifique par email
          final userData =
              utilisateurs
                  .where((user) => user['data']?['email'] == email)
                  .firstOrNull;

          if (userData != null) {
            final userInfo = userData['data'] as Map<String, dynamic>;
            log('✅ Utilisateur trouvé:');
            log('- Nom: ${userInfo['nom']}');
            log('- Email: ${userInfo['email']}');
            log(
              '- Hash: ${userInfo['password'] ?? userInfo['mot_de_passe_hash']}',
            );
            return userInfo;
          } else {
            log('❌ Utilisateur avec email $email non trouvé');
            // Afficher les emails disponibles pour debug
            log('Emails disponibles:');
            for (var user in utilisateurs) {
              log('- ${user['data']?['email']}');
            }
          }
        } else {
          log('❌ Aucun utilisateur dans les données de sync');
        }
      } else {
        log('❌ Erreur HTTP: ${response.statusCode}');
        log('Body: ${response.body}');
      }

      return null;
    } catch (e, stackTrace) {
      log('❌ Exception lors de la récupération utilisateur: $e');
      log('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    log('=== DÉCONNEXION ===');

    try {
      if (_authToken != null) {
        // Optionnel: Informer le serveur de la déconnexion
        await http
            .post(
              Uri.parse('${ApiConfig.baseUrl}/auth/logout'),
              headers: {
                'Authorization': 'Bearer $_authToken',
                'Content-Type': 'application/json',
              },
            )
            .timeout(Duration(seconds: ApiConfig.timeoutSeconds));
      }
    } catch (e) {
      log('⚠️ Erreur lors de la déconnexion serveur: $e');
    } finally {
      // Nettoyage local et du stockage persistant
      await _clearAuthData();
      _authToken = null;
      _userEmail = null;
      _userId = null;
      _entrepriseId = null;
      log('✅ Déconnexion locale terminée');
    }
  }

  /// Vérifie si le token est encore valide
  Future<bool> validateToken() async {
    if (_authToken == null) {
      log('❌ Aucun token à valider');
      return false;
    }

    log('=== VALIDATION TOKEN ===');

    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/auth/validate'),
            headers: {
              'Authorization': 'Bearer $_authToken',
              'Accept': 'application/json',
            },
          )
          .timeout(Duration(seconds: ApiConfig.timeoutSeconds));

      log('Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final isValid = data['valid'] == true;
        log(isValid ? '✅ Token valide' : '❌ Token invalide');
        return isValid;
      } else {
        log('❌ Token invalide (${response.statusCode})');
        return false;
      }
    } catch (e) {
      log('❌ Erreur lors de la validation du token: $e');
      return false;
    }
  }

  /// Configure manuellement l'authentification (utile après récupération depuis le stockage local)
  void setAuth(String token, String email) {
    _authToken = token;
    _userEmail = email;
    log('✅ Authentification configurée manuellement pour: $email');
  }

  /// Nettoie l'authentification
  void clearAuth() {
    _authToken = null;
    _userEmail = null;
    _userId = null;
    _entrepriseId = null;
    log('✅ Authentification nettoyée');
  }

  /// Vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return token != null && token.isNotEmpty;
  }

  /// Obtenir le token d'authentification depuis le stockage
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Obtenir l'ID de l'utilisateur connecté
  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  /// Obtenir l'ID de l'entreprise
  Future<int?> getEntrepriseId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_entrepriseIdKey);
  }

  /// Obtenir l'email de l'utilisateur connecté
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  /// Inscription d'un nouvel utilisateur
  Future<AuthResult> register({
    required String nom,
    required String prenom,
    required String email,
    required String password,
    required String passwordConfirmation,
    required int entrepriseId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'nom': nom,
          'prenom': prenom,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'entreprise_id': entrepriseId,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          _authToken = data['data']['token'];
          _userEmail = email;
          _userId = data['data']['user']['id'];
          _entrepriseId = data['data']['user']['entreprise_id'];

          await _saveAuthData(_authToken!, _userId!, _entrepriseId!, email);

          return AuthSuccess(
            token: _authToken!,
            userId: _userId!,
            entrepriseId: _entrepriseId!,
          );
        } else {
          return AuthError(
            message: data['message'] ?? 'Erreur lors de l\'inscription',
            errorCode: 'REGISTER_FAILED',
          );
        }
      } else {
        final data = jsonDecode(response.body);
        return AuthError(
          message: data['message'] ?? 'Erreur serveur',
          errorCode: 'SERVER_ERROR',
        );
      }
    } catch (e) {
      return AuthError(
        message: 'Erreur de connexion: $e',
        errorCode: 'CONNECTION_ERROR',
      );
    }
  }

  /// Rafraîchir le token
  Future<AuthResult> refreshToken() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/refresh'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          final newToken = data['data']['token'];
          _authToken = newToken;

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_tokenKey, newToken);

          return AuthSuccess(
            token: newToken,
            userId: _userId ?? 0,
            entrepriseId: _entrepriseId ?? 0,
          );
        }
      }

      return AuthError(
        message: 'Erreur lors du rafraîchissement du token',
        errorCode: 'REFRESH_FAILED',
      );
    } catch (e) {
      return AuthError(
        message: 'Erreur de connexion: $e',
        errorCode: 'CONNECTION_ERROR',
      );
    }
  }

  /// Sauvegarder les données d'authentification
  Future<void> _saveAuthData(
    String token,
    int userId,
    int entrepriseId,
    String email,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(_tokenKey, token),
      prefs.setInt(_userIdKey, userId),
      prefs.setInt(_entrepriseIdKey, entrepriseId),
      prefs.setString(_userEmailKey, email),
    ]);
  }

  /// Nettoyer les données d'authentification
  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_tokenKey),
      prefs.remove(_userIdKey),
      prefs.remove(_entrepriseIdKey),
      prefs.remove(_userEmailKey),
    ]);
  }
}
