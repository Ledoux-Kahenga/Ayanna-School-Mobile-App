import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';
import '../api/utilisateur_service.dart';
import 'api_client_provider.dart';
import 'sync_provider_new.dart';
import 'database_provider.dart';

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
  /// Essaie d'abord l'authentification locale, puis en ligne si elle échoue
  Future<bool> login(String email, String password) async {
    print('🔐 [AUTH] Début de la tentative de connexion pour: $email');

    state = const AsyncValue.loading();

    try {
      // 1. Essayer l'authentification locale d'abord
      print('🏠 [AUTH] Tentative d\'authentification locale...');
      final utilisateurDao = ref.read(utilisateurDaoProvider);
      final utilisateurLocal = await utilisateurDao.loginLocalement(
        email,
        password,
      );

      if (utilisateurLocal != null) {
        print(
          '✅ [AUTH] Authentification locale réussie pour: ${utilisateurLocal.nom}',
        );

        // Générer un token temporaire pour la session locale
        final token =
            'local_${DateTime.now().millisecondsSinceEpoch}_${utilisateurLocal.id}';

        // Sauvegarder dans SharedPreferences
        print('💾 [AUTH] Sauvegarde des données d\'authentification locale...');
        await _saveAuthData(
          token: token,
          userId: utilisateurLocal.id,
          entrepriseId: utilisateurLocal.entrepriseId,
          email: email,
          userName: utilisateurLocal.nom,
        );
        print('💾 [AUTH] Données locales sauvegardées avec succès');

        // Sauvegarder le token dans l'intercepteur
        print('🔧 [AUTH] Configuration du token local dans l\'intercepteur...');
        await AuthInterceptor.saveToken(token);
        print('🔧 [AUTH] Token local configuré avec succès');

        state = AsyncValue.data(
          AuthState(
            isAuthenticated: true,
            token: token,
            userId: utilisateurLocal.id,
            entrepriseId: utilisateurLocal.entrepriseId,
            userEmail: email,
          ),
        );

        print(
          '🎉 [AUTH] Connexion locale réussie - Utilisateur: ${utilisateurLocal.nom}',
        );
        return true;
      }

      // 2. Si l'authentification locale échoue, essayer l'authentification en ligne
      print('🌐 [AUTH] Authentification locale échouée, tentative en ligne...');

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
            '✅ [AUTH] Connexion en ligne réussie - UserID: $userId, EntrepriseID: $entrepriseId, UserName: $userName',
          );
          print('🔑 [AUTH] Token reçu (longueur: ${token.length})');

          // Sauvegarder dans SharedPreferences
          print('💾 [AUTH] Sauvegarde des données d\'authentification...');
          await _saveAuthData(
            token: token,
            userId: userId,
            entrepriseId: entrepriseId,
            email: email,
            userName: userName,
          );
          print('💾 [AUTH] Données sauvegardées avec succès');

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

          print('🎉 [AUTH] Connexion en ligne réussie');
          return true;
        } else {
          final errorMessage =
              data['message'] as String? ?? 'Erreur d\'authentification';
          print(
            '❌ [AUTH] Échec de l\'authentification - Message: $errorMessage',
          );

          state = AsyncValue.data(
            AuthState(isAuthenticated: false, errorMessage: errorMessage),
          );
          return false;
        }
      } else {
        final errorMessage =
            response.error?.toString() ?? 'Erreur de connexion';
        print(
          '❌ [AUTH] Erreur de réponse API - Status: ${response.statusCode}, Error: $errorMessage',
        );

        state = AsyncValue.data(
          AuthState(isAuthenticated: false, errorMessage: errorMessage),
        );
        return false;
      }
    } catch (e) {
      print('💥 [AUTH] Exception lors de la connexion: $e');
      print('📊 [AUTH] Stack trace: ${StackTrace.current}');

      state = AsyncValue.data(
        AuthState(
          isAuthenticated: false,
          errorMessage: 'Erreur de connexion: $e',
        ),
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
      // Ignorer les erreurs de déconnexion API
      print('⚠️ [LOGOUT] Erreur lors de la déconnexion API (ignorée): $e');
    }

    // Nettoyer le stockage local
    print('🧹 [LOGOUT] Nettoyage du stockage local...');
    await _clearAuthData();
    await AuthInterceptor.clearToken();
    print('🧹 [LOGOUT] Stockage local nettoyé');

    state = const AsyncValue.data(AuthState());
    print('✅ [LOGOUT] Déconnexion terminée avec succès');
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
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString(_tokenKey);
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
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await Future.wait([
      prefs.setString(_tokenKey, token),
      if (userId != null) prefs.setInt(_userIdKey, userId),
      if (entrepriseId != null) prefs.setInt(_entrepriseIdKey, entrepriseId),
      if (email != null) prefs.setString(_userEmailKey, email),
      if (userName != null) prefs.setString(_userNameKey, userName),
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
    ]);
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
