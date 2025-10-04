import 'package:ayanna_school/services/providers/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_provider.g.dart';

/* /// Provider pour l'état d'authentification
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  Utilisateur? build() {
    return null; // Pas d'utilisateur connecté au début
  }

  /// Connecter un utilisateur
  void login(Utilisateur utilisateur) {
    state = utilisateur;
  }

  /// Déconnecter l'utilisateur
  void logout() {
    state = null;
  }

  /// Vérifier si l'utilisateur est connecté
  bool get isLoggedIn => state != null;

  /// Obtenir l'utilisateur connecté
  Utilisateur? get currentUser => state;
} */

/// Provider pour les paramètres de l'application
@riverpod
class AppSettingsNotifier extends _$AppSettingsNotifier {
  @override
  Map<String, dynamic> build() {
    return {
      'theme': 'light',
      'language': 'fr',
      'autoSync': true,
      'syncInterval': 30, // minutes
      'offlineMode': false,
    };
  }

  /// Changer le thème
  void setTheme(String theme) {
    state = {...state, 'theme': theme};
  }

  /// Changer la langue
  void setLanguage(String language) {
    state = {...state, 'language': language};
  }

  /// Activer/désactiver la synchronisation automatique
  void setAutoSync(bool autoSync) {
    state = {...state, 'autoSync': autoSync};
  }

  /// Définir l'intervalle de synchronisation
  void setSyncInterval(int minutes) {
    state = {...state, 'syncInterval': minutes};
  }

  /// Activer/désactiver le mode hors ligne
  void setOfflineMode(bool offlineMode) {
    state = {...state, 'offlineMode': offlineMode};
  }
}

/// Provider pour l'état de synchronisation
@riverpod
class SyncNotifier extends _$SyncNotifier {
  @override
  Map<String, dynamic> build() {
    return {
      'isLoading': false,
      'lastSync': null,
      'pendingUploads': 0,
      'errors': <String>[],
    };
  }

  /// Commencer la synchronisation
  void startSync() {
    state = {...state, 'isLoading': true, 'errors': <String>[]};
  }

  /// Terminer la synchronisation avec succès
  void completSync() {
    state = {
      ...state,
      'isLoading': false,
      'lastSync': DateTime.now().toIso8601String(),
      'pendingUploads': 0,
      'errors': <String>[],
    };
  }

  /// Terminer la synchronisation avec des erreurs
  void completeWithErrors(List<String> errors) {
    state = {...state, 'isLoading': false, 'errors': errors};
  }

  /// Ajouter une erreur
  void addError(String error) {
    final currentErrors = List<String>.from(state['errors'] ?? []);
    currentErrors.add(error);
    state = {...state, 'errors': currentErrors};
  }

  /// Définir le nombre d'uploads en attente
  void setPendingUploads(int count) {
    state = {...state, 'pendingUploads': count};
  }

  /// Obtenir l'état de chargement
  bool get isLoading => state['isLoading'] ?? false;

  /// Obtenir la dernière synchronisation
  DateTime? get lastSync {
    final lastSyncStr = state['lastSync'];
    return lastSyncStr != null ? DateTime.parse(lastSyncStr) : null;
  }

  /// Obtenir les erreurs
  List<String> get errors => List<String>.from(state['errors'] ?? []);

  /// Obtenir le nombre d'uploads en attente
  int get pendingUploads => state['pendingUploads'] ?? 0;
}

/// Provider pour l'état de connectivité réseau
@riverpod
class NetworkNotifier extends _$NetworkNotifier {
  @override
  bool build() {
    return true; // Supposer qu'on est connecté au début
  }

  /// Mettre à jour l'état de connectivité
  void setConnected(bool connected) {
    state = connected;
  }

  /// Vérifier si on est connecté
  bool get isConnected => state;

  /// Vérifier si on est hors ligne
  bool get isOffline => !state;
}

/// Provider combiné pour l'état global de l'application
@riverpod
class AppStateNotifier extends _$AppStateNotifier {
  @override
  Map<String, dynamic> build() {
    final isAuth = ref.watch(isAuthenticatedProvider);
    final currentUser = ref.watch(currentUserEmailProvider);
    final settings = ref.watch(appSettingsNotifierProvider);
    final sync = ref.watch(syncNotifierProvider);
    final network = ref.watch(networkNotifierProvider);

    return {
      'isAuthenticated': isAuth,
      'currentUser': currentUser,
      'settings': settings,
      'sync': sync,
      'isOnline': network,
      'isReady': true,
    };
  }

  /// Vérifier si l'app est prête
  bool get isReady => state['isReady'] ?? false;

  /// Vérifier si l'utilisateur est authentifié
  bool get isAuthenticated => state['isAuthenticated'] ?? false;

  /// Obtenir l'utilisateur actuel
  String? get currentUser => state['currentUser'];

  /// Vérifier si on est en ligne
  bool get isOnline => state['isOnline'] ?? false;

  /// Obtenir les paramètres
  Map<String, dynamic> get settings => state['settings'] ?? {};

  /// Obtenir l'état de synchronisation
  Map<String, dynamic> get syncState => state['sync'] ?? {};
}
