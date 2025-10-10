import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';
import '../api/utilisateur_service.dart';
import 'api_client_provider.dart';
import 'sync_provider_new.dart';

part 'auth_provider.g.dart';

/// État d'authentification
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? token;
  final int? userId;
  final int? entrepriseId;
  final String? userEmail;
  final String? errorMessage;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.token,
    this.userId,
    this.entrepriseId,
    this.userEmail,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? token,
    int? userId,
    int? entrepriseId,
    String? userEmail,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      token: token ?? this.token,
      userId: userId ?? this.userId,
      entrepriseId: entrepriseId ?? this.entrepriseId,
      userEmail: userEmail ?? this.userEmail,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  String toString() {
    return 'AuthState(isAuthenticated: $isAuthenticated, isLoading: $isLoading, userId: $userId, entrepriseId: $entrepriseId, userEmail: $userEmail, errorMessage: $errorMessage)';
  }
}

/// Provider pour l'état d'authentification
@riverpod
class AuthNotifier extends _$AuthNotifier {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _entrepriseIdKey = 'entreprise_id';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';
  static const String _passwordKey = 'user_password';
  static const String _isFirstLaunchKey = 'is_first_launch';

  late UtilisateurService _utilisateurService;

  @override
  Future<AuthState> build() async {
    _utilisateurService = ref.read(utilisateurServiceProvider);

    // Vérifier si l'utilisateur est déjà connecté au démarrage
    final isLoggedIn = await _isLoggedIn();

    if (isLoggedIn) {
      final token = await _getToken();
      final userId = await _getUserId();
      final entrepriseId = await _getEntrepriseId();
      final userEmail = await _getUserEmail();

      return AuthState(
        isAuthenticated: true,
        token: token,
        userId: userId,
        entrepriseId: entrepriseId,
        userEmail: userEmail,
      );
    }

    return const AuthState();
  }

  /// Connexion avec email et mot de passe
  /// Au premier lancement : connexion obligatoire au serveur pour l'initialisation
  /// Aux lancements suivants : vérification locale en premier avec SharedPreferences
  Future<bool> login(String email, String password) async {
    print('🔐 [AUTH] Début de la tentative de connexion pour: $email');

    state = const AsyncValue.loading();

    try {
      final prefs = await SharedPreferences.getInstance();
      final isFirstLaunch = prefs.getBool(_isFirstLaunchKey) ?? true;

      print('� [AUTH] Premier lancement: $isFirstLaunch');

      if (isFirstLaunch) {
        // Premier lancement : connexion serveur obligatoire
        return await _firstTimeLogin(email, password);
      } else {
        // Lancements suivants : vérification locale en premier
        return await _subsequentLogin(email, password);
      }
    } catch (e) {
      print('💥 [AUTH] Exception lors de la connexion: $e');
      print('📊 [AUTH] Stack trace: ${StackTrace.current}');

      final userMessage = _getNetworkErrorMessage(e);

      state = AsyncValue.data(
        AuthState(isAuthenticated: false, errorMessage: userMessage),
      );
      return false;
    }
  }

  /// Premier lancement - Connexion serveur obligatoire pour l'initialisation
  Future<bool> _firstTimeLogin(String email, String password) async {
    print('🏁 [AUTH] Premier lancement - Connexion serveur obligatoire');

    try {
      final response = await _utilisateurService.login({
        'email': email,
        'password': password,
      });

      print(
        '📡 [AUTH] Réponse reçue - Status: ${response.statusCode}, Success: ${response.isSuccessful}',
      );

      if (response.isSuccessful && response.body != null) {
        final data = response.body!;
        print('📋 [AUTH] Données reçues: ${data.keys.toList()}');

        if (data['success'] == true) {
          final token = data['token'] as String;
          final userId = data['user_id'] as int?;
          final entrepriseId = data['entreprise_id'] as int?;
          final userName = data['user_name'] as String?;

          print(
            '✅ [AUTH] Connexion serveur réussie - UserID: $userId, EntrepriseID: $entrepriseId, UserName: $userName',
          );
          print('🔑 [AUTH] Token reçu (longueur: ${token.length})');

          // Sauvegarder dans SharedPreferences avec le mot de passe
          print('💾 [AUTH] Sauvegarde des données d\'authentification...');
          await _saveAuthData(
            token: token,
            userId: userId,
            entrepriseId: entrepriseId,
            email: email,
            userName: userName,
            password: password,
          );

          // Marquer que ce n'est plus le premier lancement
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(_isFirstLaunchKey, false);
          print('✅ [AUTH] Premier lancement marqué comme terminé');

          // Sauvegarder le token dans l'intercepteur
          print('🔧 [AUTH] Configuration du token dans l\'intercepteur...');
          await AuthInterceptor.saveToken(token);
          print('🔧 [AUTH] Token configuré avec succès');

          state = AsyncValue.data(
            AuthState(
              isAuthenticated: true,
              token: token,
              userId: userId,
              entrepriseId: entrepriseId,
              userEmail: email,
            ),
          );

          // 🔄 Déclencher la synchronisation automatique après un login réussi
          print('🔄 [AUTH] Déclenchement de la synchronisation automatique...');
          _triggerAutoSync(email);

          print('🎉 [AUTH] Premier lancement connexion réussie');
          return true;
        } else {
          final errorMessage =
              data['message'] as String? ??
              'Identifiants incorrects. Vérifiez votre email et mot de passe.';
          print(
            '❌ [AUTH] Échec de l\'authentification - Message: $errorMessage',
          );

          state = AsyncValue.data(
            AuthState(
              isAuthenticated: false,
              errorMessage: 'Premier lancement - $errorMessage',
            ),
          );
          return false;
        }
      } else {
        final errorMessage = _getHttpErrorMessage(
          response.statusCode,
          response.error?.toString(),
        );

        print(
          '❌ [AUTH] Erreur de réponse API - Status: ${response.statusCode}, Error: $errorMessage',
        );

        state = AsyncValue.data(
          AuthState(
            isAuthenticated: false,
            errorMessage: 'Premier lancement - $errorMessage',
          ),
        );
        return false;
      }
    } catch (e) {
      print('💥 [AUTH] Erreur lors de la connexion serveur: $e');

      final baseMessage = _getNetworkErrorMessage(e);
      final userMessage =
          'Premier lancement - $baseMessage Une connexion est requise pour initialiser l\'application.';

      state = AsyncValue.data(
        AuthState(isAuthenticated: false, errorMessage: userMessage),
      );
      return false;
    }
  }

  /// Lancements suivants - Vérification locale en premier avec SharedPreferences
  Future<bool> _subsequentLogin(String email, String password) async {
    print('🔄 [AUTH] Lancement ultérieur - Vérification locale en premier');

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString(_userEmailKey);
      final savedPassword = prefs.getString(_passwordKey);

      print('📱 [AUTH] Email sauvegardé: $savedEmail');
      print(
        '🔐 [AUTH] Mot de passe sauvegardé: ${savedPassword != null ? 'Oui' : 'Non'}',
      );

      // Vérifier les identifiants avec les données sauvegardées
      if (savedEmail == email && savedPassword == password) {
        print(
          '✅ [AUTH] Authentification locale réussie avec SharedPreferences',
        );
        print('📡 [AUTH] Mode hors ligne - Pas de synchronisation automatique');

        // Récupérer les autres données sauvegardées
        final token = prefs.getString(_tokenKey);
        final userId = prefs.getInt(_userIdKey);
        final entrepriseId = prefs.getInt(_entrepriseIdKey);

        // Sauvegarder le token dans l'intercepteur
        if (token != null) {
          await AuthInterceptor.saveToken(token);
        }

        state = AsyncValue.data(
          AuthState(
            isAuthenticated: true,
            token: token,
            userId: userId,
            entrepriseId: entrepriseId,
            userEmail: email,
          ),
        );

        print(
          '🎉 [AUTH] Connexion locale réussie - Pas de synchronisation automatique',
        );
        return true;
      } else {
        print(
          '❌ [AUTH] Identifiants locaux incorrects - Tentative connexion serveur...',
        );

        // Si l'authentification locale échoue, essayer le serveur avec un message approprié
        final result = await _fallbackServerLogin(email, password);
        if (!result) {
          // Si la connexion serveur échoue aussi, on met un message spécifique
          state.whenData((currentState) {
            if (currentState.errorMessage?.contains(
                  'Identifiants incorrects',
                ) ==
                true) {
              state = AsyncValue.data(
                currentState.copyWith(
                  errorMessage:
                      'Identifiants incorrects. Vérifiez votre email et mot de passe.',
                ),
              );
            }
          });
        }
        return result;
      }
    } catch (e) {
      print('💥 [AUTH] Erreur lors de l\'authentification locale: $e');

      // En cas d'erreur de lecture locale, essayer le serveur
      final result = await _fallbackServerLogin(email, password);
      if (!result) {
        // Si échec total, message d'erreur approprié
        state = AsyncValue.data(
          AuthState(
            isAuthenticated: false,
            errorMessage:
                'Erreur d\'authentification. Vérifiez vos identifiants et votre connexion internet.',
          ),
        );
      }
      return result;
    }
  }

  /// Connexion serveur de secours lorsque l'authentification locale échoue
  Future<bool> _fallbackServerLogin(String email, String password) async {
    print('🌐 [AUTH] Connexion serveur de secours...');

    try {
      final response = await _utilisateurService.login({
        'email': email,
        'password': password,
      });

      if (response.isSuccessful && response.body != null) {
        final data = response.body!;

        if (data['success'] == true) {
          final token = data['token'] as String;
          final userId = data['user_id'] as int?;
          final entrepriseId = data['entreprise_id'] as int?;
          final userName = data['user_name'] as String?;

          print('✅ [AUTH] Connexion serveur de secours réussie');

          // Mettre à jour les données sauvegardées
          await _saveAuthData(
            token: token,
            userId: userId,
            entrepriseId: entrepriseId,
            email: email,
            userName: userName,
            password: password,
          );

          await AuthInterceptor.saveToken(token);

          state = AsyncValue.data(
            AuthState(
              isAuthenticated: true,
              token: token,
              userId: userId,
              entrepriseId: entrepriseId,
              userEmail: email,
            ),
          );

          // 🔄 Déclencher la synchronisation automatique après une connexion serveur
          print(
            '🔄 [AUTH] Déclenchement de la synchronisation automatique (connexion serveur)...',
          );
          _triggerAutoSync(email);

          return true;
        } else {
          final errorMessage =
              data['message'] as String? ??
              'Identifiants incorrects. Vérifiez votre email et mot de passe.';

          state = AsyncValue.data(
            AuthState(isAuthenticated: false, errorMessage: errorMessage),
          );
          return false;
        }
      } else {
        final baseErrorMessage = _getHttpErrorMessage(
          response.statusCode,
          response.error?.toString(),
        );

        // Message spécifique pour le mode fallback
        String errorMessage;
        if (response.statusCode == 0 || response.statusCode == -1) {
          errorMessage =
              'Pas de connexion internet. Vous pouvez utiliser l\'application hors ligne avec vos anciens identifiants.';
        } else {
          errorMessage = baseErrorMessage;
        }

        state = AsyncValue.data(
          AuthState(isAuthenticated: false, errorMessage: errorMessage),
        );
        return false;
      }
    } catch (e) {
      print('💥 [AUTH] Erreur connexion serveur de secours: $e');

      final baseMessage = _getNetworkErrorMessage(e);
      final userMessage =
          '$baseMessage Vous pouvez utiliser l\'application hors ligne avec vos anciens identifiants.';

      state = AsyncValue.data(
        AuthState(isAuthenticated: false, errorMessage: userMessage),
      );
      return false;
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    print('🚪 [LOGOUT] Démarrage de la procédure de déconnexion');

    try {
      // Appel API de déconnexion (optionnel)
      print('📡 [LOGOUT] Envoi de la requête de déconnexion à l\'API...');
      await _utilisateurService.logout();
      print('✅ [LOGOUT] Déconnexion API réussie');
    } catch (e) {
      // Ignorer les erreurs de déconnexion API car la déconnexion locale suffit
      print('⚠️ [LOGOUT] Erreur lors de la déconnexion API (ignorée): $e');
    }

    try {
      // Nettoyer le stockage local
      print('🧹 [LOGOUT] Nettoyage du stockage local...');
      await _clearAuthData();
      await AuthInterceptor.clearToken();
      print('🧹 [LOGOUT] Stockage local nettoyé');

      state = const AsyncValue.data(AuthState());
      print('✅ [LOGOUT] Déconnexion terminée avec succès');
    } catch (e) {
      print('💥 [LOGOUT] Erreur lors du nettoyage local: $e');
      // Même en cas d'erreur de nettoyage, on considère la déconnexion réussie
      state = AsyncValue.data(
        AuthState(
          isAuthenticated: false,
          errorMessage:
              'Déconnexion effectuée mais erreur de nettoyage. Redémarrez l\'application si nécessaire.',
        ),
      );
    }
  }

  /// Rafraîchir le token (non implémenté pour Chopper)
  Future<bool> refreshToken() async {
    // Pour l'instant, on déconnecte l'utilisateur si le token expire
    await logout();
    return false;
  }

  /// Effacer le message d'erreur
  void clearError() {
    state.whenData((authState) {
      if (authState.errorMessage != null) {
        state = AsyncValue.data(authState.copyWith(errorMessage: null));
      }
    });
  }

  /// Déclencher la synchronisation automatique après login
  void _triggerAutoSync(String userEmail) {
    // Déclencher la synchronisation en arrière-plan
    // sans bloquer le processus de login
    Future.microtask(() async {
      try {
        print(
          '🔄 [SYNC] Démarrage de la synchronisation automatique pour $userEmail',
        );

        // Obtenir le provider de synchronisation
        final syncNotifier = ref.read(syncStateNotifierProvider.notifier);
        print('🔧 [SYNC] Provider de synchronisation obtenu');

        // Vérifier la connectivité avant de synchroniser
        print('📡 [SYNC] Vérification de la connectivité réseau...');
        final isConnected = await syncNotifier.checkConnectivity();
        if (!isConnected) {
          print(
            '❌ [SYNC] Pas de connectivité réseau - synchronisation reportée',
          );
          return;
        }
        print('✅ [SYNC] Connectivité réseau confirmée');

        /* // Vérifier si une synchronisation est nécessaire
        print(
          '⏰ [SYNC] Vérification de la nécessité de synchronisation (seuil: 1 heure)...',
        );
        final needsSync = await syncNotifier.isSyncNeeded(muniteThreshold: 1);
        if (!needsSync) {
          print(
            '✅ [SYNC] Synchronisation récente trouvée - pas besoin de synchroniser',
          );
          return;
        }
        print('🔄 [SYNC] Synchronisation nécessaire - démarrage en cours');
 */
        // Effectuer une synchronisation bidirectionnelle
        // (upload des changements locaux + download des changements serveur)
        print('📤 [SYNC] Démarrage de la synchronisation bidirectionnelle...');
        await syncNotifier.performBidirectionalSync(userEmail);

        print('✅ [SYNC] Synchronisation automatique terminée avec succès');
      } catch (e) {
        print('❌ [SYNC] Erreur lors de la synchronisation automatique: $e');
        print('📊 [SYNC] Stack trace: ${StackTrace.current}');
        // Ne pas propager l'erreur pour ne pas affecter le login
      }
    });
  }

  /// Synchronisation manuelle - méthode publique
  Future<bool> syncManually() async {
    try {
      print('🔄 [SYNC_MANUAL] Démarrage de la synchronisation manuelle');

      // Vérifier si l'utilisateur est connecté
      final authState = state.value;
      if (authState == null ||
          !authState.isAuthenticated ||
          authState.userEmail == null) {
        print(
          '❌ [SYNC_MANUAL] Utilisateur non connecté - synchronisation impossible',
        );
        print('   AuthState: $authState');
        return false;
      }

      print('� [SYNC_MANUAL] Utilisateur connecté: ${authState.userEmail}');

      // Obtenir le provider de synchronisation
      final syncNotifier = ref.read(syncStateNotifierProvider.notifier);
      print('🔧 [SYNC_MANUAL] Provider de synchronisation obtenu');

      // Vérifier la connectivité
      print('📡 [SYNC_MANUAL] Vérification de la connectivité réseau...');
      final isConnected = await syncNotifier.checkConnectivity();
      if (!isConnected) {
        print(
          '❌ [SYNC_MANUAL] Pas de connectivité réseau - synchronisation impossible',
        );
        return false;
      }
      print('✅ [SYNC_MANUAL] Connectivité réseau confirmée');

      // Effectuer une synchronisation forcée (ignore la dernière date)
      print('📤 [SYNC_MANUAL] Démarrage de la synchronisation forcée...');
      await syncNotifier.performForcedSync(authState.userEmail!);

      print('✅ [SYNC_MANUAL] Synchronisation manuelle terminée avec succès');
      return true;
    } catch (e) {
      print('❌ [SYNC_MANUAL] Erreur lors de la synchronisation manuelle: $e');
      print('📊 [SYNC_MANUAL] Stack trace: ${StackTrace.current}');

      // Mettre à jour l'état avec un message d'erreur approprié
      state.whenData((currentState) {
        String errorMessage;
        if (e.toString().contains('401')) {
          errorMessage =
              'Synchronisation échouée : Session expirée. Reconnectez-vous.';
        } else {
          final baseMessage = _getNetworkErrorMessage(e);
          errorMessage = 'Synchronisation échouée : $baseMessage';
        }

        state = AsyncValue.data(
          currentState.copyWith(errorMessage: errorMessage),
        );
      });

      return false;
    }
  }

  /// Obtenir le statut de synchronisation
  SyncState? getSyncStatus() {
    try {
      return ref.read(syncStateNotifierProvider);
    } catch (e) {
      print('❌ Erreur lors de la récupération du statut de sync: $e');
      return null;
    }
  }

  /// Vérifier si une synchronisation est en cours
  bool isSyncInProgress() {
    final syncState = getSyncStatus();
    return syncState?.status == SyncStatus.downloading ||
        syncState?.status == SyncStatus.uploading ||
        syncState?.status == SyncStatus.processing;
  }

  /// Vérifier si l'utilisateur est connecté
  Future<bool> _isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return token != null && token.isNotEmpty;
  }

  /// Obtenir le token d'authentification depuis le stockage
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Obtenir l'ID de l'utilisateur connecté
  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  /// Obtenir l'ID de l'entreprise
  Future<int?> _getEntrepriseId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_entrepriseIdKey);
  }

  /// Obtenir l'email de l'utilisateur connecté
  Future<String?> _getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  /// Sauvegarder les données d'authentification
  Future<void> _saveAuthData({
    required String token,
    int? userId,
    int? entrepriseId,
    String? email,
    String? userName,
    String? password,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await Future.wait([
      prefs.setString(_tokenKey, token),
      if (userId != null) prefs.setInt(_userIdKey, userId),
      if (entrepriseId != null) prefs.setInt(_entrepriseIdKey, entrepriseId),
      if (email != null) prefs.setString(_userEmailKey, email),
      if (userName != null) prefs.setString(_userNameKey, userName),
      if (password != null) prefs.setString(_passwordKey, password),
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
      prefs.remove(_userNameKey),
      prefs.remove(_passwordKey),
      prefs.remove(_isFirstLaunchKey),
    ]);
  }

  /// Vérifier si c'est le premier lancement
  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isFirstLaunchKey) ?? true;
  }

  /// Réinitialiser le flag de premier lancement (utile pour les tests)
  Future<void> resetFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isFirstLaunchKey, true);
  }

  /// Méthode utilitaire pour gérer les erreurs réseau de façon centralisée
  String _getNetworkErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('socketexception')) {
      return 'Pas de connexion internet. Vérifiez votre connexion réseau.';
    } else if (errorString.contains('timeoutexception')) {
      return 'Délai d\'attente dépassé. Vérifiez votre connexion internet.';
    } else if (errorString.contains('handshakeexception')) {
      return 'Erreur de sécurité SSL. Vérifiez la date et l\'heure de votre appareil.';
    } else if (errorString.contains('formatexception')) {
      return 'Erreur de format des données reçues. Contactez le support technique.';
    } else {
      return 'Erreur de connexion inattendue. Réessayez plus tard.';
    }
  }

  /// Méthode utilitaire pour gérer les erreurs HTTP
  String _getHttpErrorMessage(int? statusCode, String? responseMessage) {
    switch (statusCode) {
      case 400:
        return responseMessage ??
            'Requête invalide. Vérifiez les données saisies.';
      case 401:
        return 'Identifiants incorrects. Vérifiez votre email et mot de passe.';
      case 403:
        return 'Accès refusé. Contactez l\'administrateur.';
      case 404:
        return 'Service non trouvé. Contactez le support technique.';
      case 429:
        return 'Trop de tentatives. Attendez quelques minutes avant de réessayer.';
      case 500:
        return 'Erreur du serveur. Réessayez plus tard.';
      case 502:
      case 503:
      case 504:
        return 'Service temporairement indisponible. Réessayez plus tard.';
      default:
        if (statusCode == 0 || statusCode == -1) {
          return 'Pas de connexion internet. Vérifiez votre connexion réseau.';
        }
        return 'Erreur de connexion au serveur${statusCode != null ? ' ($statusCode)' : ''}.';
    }
  }

  /// Effacer le message d'erreur avec succès
  void clearErrorWithSuccess(String? successMessage) {
    state.whenData((authState) {
      if (authState.errorMessage != null) {
        state = AsyncValue.data(authState.copyWith(errorMessage: null));
        // Optionnel: afficher un message de succès temporaire
        if (successMessage != null) {
          Future.delayed(const Duration(milliseconds: 100), () {
            state.whenData((currentState) {
              state = AsyncValue.data(
                currentState.copyWith(errorMessage: successMessage),
              );
              // Effacer le message de succès après 3 secondes
              Future.delayed(const Duration(seconds: 3), () {
                state.whenData((finalState) {
                  if (finalState.errorMessage == successMessage) {
                    state = AsyncValue.data(
                      finalState.copyWith(errorMessage: null),
                    );
                  }
                });
              });
            });
          });
        }
      }
    });
  }
}

/// Provider pour vérifier si l'utilisateur est authentifié
@riverpod
bool isAuthenticated(IsAuthenticatedRef ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.whenOrNull(data: (state) => state.isAuthenticated) ?? false;
}

/// Provider pour obtenir le token d'authentification
@riverpod
String? authToken(AuthTokenRef ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.whenOrNull(data: (state) => state.token);
}

/// Provider pour obtenir l'ID de l'utilisateur connecté
@riverpod
int? currentUserId(CurrentUserIdRef ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.whenOrNull(data: (state) => state.userId);
}

/// Provider pour obtenir l'ID de l'entreprise
@riverpod
int? currentEntrepriseId(CurrentEntrepriseIdRef ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.whenOrNull(data: (state) => state.entrepriseId);
}

/// Provider pour obtenir l'email de l'utilisateur connecté
@riverpod
String? currentUserEmail(CurrentUserEmailRef ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.whenOrNull(data: (state) => state.userEmail);
}

/// Provider pour obtenir le message d'erreur d'authentification
@riverpod
String? authError(AuthErrorRef ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.whenOrNull(data: (state) => state.errorMessage);
}

/// Provider pour vérifier si une authentification est en cours
@riverpod
bool isAuthLoading(IsAuthLoadingRef ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.isLoading;
}

/// Provider pour obtenir un message d'état utilisateur convivial
@riverpod
String? userFriendlyAuthStatus(UserFriendlyAuthStatusRef ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.whenOrNull(
    loading: () => 'Connexion en cours...',
    error: (error, stack) => 'Erreur de connexion',
    data: (state) {
      if (state.isAuthenticated) {
        return 'Connecté${state.userEmail != null ? ' en tant que ${state.userEmail}' : ''}';
      } else if (state.errorMessage != null) {
        return state.errorMessage;
      }
      return 'Non connecté';
    },
  );
}

/// Provider pour vérifier si l'utilisateur peut travailler hors ligne
@riverpod
Future<bool> canWorkOffline(CanWorkOfflineRef ref) async {
  final authNotifier = ref.read(authNotifierProvider.notifier);
  final isFirstLaunch = await authNotifier.isFirstLaunch();
  return !isFirstLaunch; // Peut travailler hors ligne seulement si ce n'est pas le premier lancement
}
