import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';
import '../api/utilisateur_service.dart';
import 'api_client_provider.dart';

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
  Future<bool> login(String email, String password) async {
    state = const AsyncValue.loading();

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
            ),
          );
          return true;
        } else {
          final errorMessage =
              data['message'] as String? ?? 'Erreur d\'authentification';
          state = AsyncValue.data(
            AuthState(isAuthenticated: false, errorMessage: errorMessage),
          );
          return false;
        }
      } else {
        final errorMessage =
            response.error?.toString() ?? 'Erreur de connexion';
        state = AsyncValue.data(
          AuthState(isAuthenticated: false, errorMessage: errorMessage),
        );
        return false;
      }
    } catch (e) {
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

    state = const AsyncValue.data(AuthState());
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
