import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api/api_client.dart';
import 'api/utilisateur_service.dart';

/// Provider pour le client API
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

/// Provider pour le service utilisateur
final utilisateurServiceProvider = Provider<UtilisateurService>((ref) {
  final client = ref.watch(apiClientProvider);
  return client.utilisateurService;
});

/// Data provider pour l'authentification avec Chopper
class AuthDataProvider extends StateNotifier<AsyncValue<AuthState>> {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _entrepriseIdKey = 'entreprise_id';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';

  final UtilisateurService _utilisateurService;

  AuthDataProvider(this._utilisateurService)
    : super(const AsyncValue.loading()) {
    _initAuth();
  }

  /// Initialise l'état d'authentification depuis le stockage local
  Future<void> _initAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);

      if (token != null && token.isNotEmpty) {
        final userId = prefs.getInt(_userIdKey);
        final entrepriseId = prefs.getInt(_entrepriseIdKey);
        final email = prefs.getString(_userEmailKey);
        final name = prefs.getString(_userNameKey);

        state = AsyncValue.data(
          AuthState(
            isAuthenticated: true,
            token: token,
            userId: userId,
            entrepriseId: entrepriseId,
            userEmail: email,
            userName: name,
            isLoading: false,
            error: null,
          ),
        );
      } else {
        state = AsyncValue.data(AuthState.initial());
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Connexion via l'API avec Chopper
  Future<bool> login(String email, String password) async {
    state = AsyncValue.data(
      state.value?.copyWith(isLoading: true) ?? AuthState.loading(),
    );

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

          // Sauvegarder dans SharedPreferences
          await _saveAuthData(
            token: token,
            userId: userId,
            entrepriseId: entrepriseId,
            email: email,
            userName: userName,
          );

          // Sauvegarder le token dans l'intercepteur
          await AuthInterceptor.saveToken(token);

          state = AsyncValue.data(
            AuthState(
              isAuthenticated: true,
              token: token,
              userId: userId,
              entrepriseId: entrepriseId,
              userEmail: email,
              userName: userName,
              isLoading: false,
              error: null,
            ),
          );

          return true;
        } else {
          final errorMessage =
              data['message'] as String? ?? 'Erreur d\'authentification';
          state = AsyncValue.data(
            AuthState(
              isAuthenticated: false,
              isLoading: false,
              error: errorMessage,
            ),
          );
          return false;
        }
      } else {
        final errorMessage =
            response.error?.toString() ?? 'Erreur de connexion';
        state = AsyncValue.data(
          AuthState(
            isAuthenticated: false,
            isLoading: false,
            error: errorMessage,
          ),
        );
        return false;
      }
    } catch (e) {
      state = AsyncValue.data(
        AuthState(
          isAuthenticated: false,
          isLoading: false,
          error: 'Erreur de connexion: $e',
        ),
      );
      return false;
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    try {
      // Appel API de déconnexion (optionnel)
      await _utilisateurService.logout();
    } catch (e) {
      // Ignorer les erreurs de déconnexion API
      print('Erreur lors de la déconnexion API: $e');
    }

    // Nettoyer le stockage local
    await _clearAuthData();
    await AuthInterceptor.clearToken();

    state = AsyncValue.data(AuthState.initial());
  }

  /// Obtenir un utilisateur par email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final response = await _utilisateurService.getUtilisateurByEmail(email);

      if (response.isSuccessful && response.body != null) {
        return response.body!;
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération de l\'utilisateur: $e');
      return null;
    }
  }

  /// Changer le mot de passe
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _utilisateurService.changePassword({
        'current_password': currentPassword,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      });

      if (response.isSuccessful && response.body != null) {
        final data = response.body!;
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Erreur lors du changement de mot de passe: $e');
      return false;
    }
  }

  /// Effacer l'erreur
  void clearError() {
    if (state.value != null) {
      state = AsyncValue.data(state.value!.copyWith(error: null));
    }
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

/// État d'authentification
class AuthState {
  final bool isAuthenticated;
  final String? token;
  final int? userId;
  final int? entrepriseId;
  final String? userEmail;
  final String? userName;
  final bool isLoading;
  final String? error;

  const AuthState({
    required this.isAuthenticated,
    this.token,
    this.userId,
    this.entrepriseId,
    this.userEmail,
    this.userName,
    required this.isLoading,
    this.error,
  });

  factory AuthState.initial() =>
      const AuthState(isAuthenticated: false, isLoading: false);

  factory AuthState.loading() =>
      const AuthState(isAuthenticated: false, isLoading: true);

  AuthState copyWith({
    bool? isAuthenticated,
    String? token,
    int? userId,
    int? entrepriseId,
    String? userEmail,
    String? userName,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      token: token ?? this.token,
      userId: userId ?? this.userId,
      entrepriseId: entrepriseId ?? this.entrepriseId,
      userEmail: userEmail ?? this.userEmail,
      userName: userName ?? this.userName,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Provider principal pour l'authentification
final authDataProvider =
    StateNotifierProvider<AuthDataProvider, AsyncValue<AuthState>>((ref) {
      final utilisateurService = ref.watch(utilisateurServiceProvider);
      return AuthDataProvider(utilisateurService);
    });

/// Providers utilitaires
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authDataProvider);
  return authState.when(
    data: (state) => state.isAuthenticated,
    loading: () => false,
    error: (_, __) => false,
  );
});

final authTokenProvider = Provider<String?>((ref) {
  final authState = ref.watch(authDataProvider);
  return authState.when(
    data: (state) => state.token,
    loading: () => null,
    error: (_, __) => null,
  );
});

final currentUserIdProvider = Provider<int?>((ref) {
  final authState = ref.watch(authDataProvider);
  return authState.when(
    data: (state) => state.userId,
    loading: () => null,
    error: (_, __) => null,
  );
});

final currentEntrepriseIdProvider = Provider<int?>((ref) {
  final authState = ref.watch(authDataProvider);
  return authState.when(
    data: (state) => state.entrepriseId,
    loading: () => null,
    error: (_, __) => null,
  );
});

final currentUserEmailProvider = Provider<String?>((ref) {
  final authState = ref.watch(authDataProvider);
  return authState.when(
    data: (state) => state.userEmail,
    loading: () => null,
    error: (_, __) => null,
  );
});

final currentUserNameProvider = Provider<String?>((ref) {
  final authState = ref.watch(authDataProvider);
  return authState.when(
    data: (state) => state.userName,
    loading: () => null,
    error: (_, __) => null,
  );
});

final authErrorProvider = Provider<String?>((ref) {
  final authState = ref.watch(authDataProvider);
  return authState.when(
    data: (state) => state.error,
    loading: () => null,
    error: (error, _) => error.toString(),
  );
});

final isLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authDataProvider);
  return authState.when(
    data: (state) => state.isLoading,
    loading: () => true,
    error: (_, __) => false,
  );
});
