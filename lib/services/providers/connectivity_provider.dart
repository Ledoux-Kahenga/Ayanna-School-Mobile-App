import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_provider.g.dart';

/// État de connectivité de l'application
class ConnectivityState {
  final List<ConnectivityResult> results;
  final bool isConnected;
  final bool hasWifi;
  final bool hasMobile;
  final bool hasEthernet;

  const ConnectivityState({
    required this.results,
    required this.isConnected,
    required this.hasWifi,
    required this.hasMobile,
    required this.hasEthernet,
  });

  factory ConnectivityState.fromResults(List<ConnectivityResult> results) {
    return ConnectivityState(
      results: results,
      isConnected: results.contains(ConnectivityResult.wifi) ||
          results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.ethernet),
      hasWifi: results.contains(ConnectivityResult.wifi),
      hasMobile: results.contains(ConnectivityResult.mobile),
      hasEthernet: results.contains(ConnectivityResult.ethernet),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectivityState &&
          runtimeType == other.runtimeType &&
          results.length == other.results.length &&
          results.every((element) => other.results.contains(element));

  @override
  int get hashCode => results.hashCode;

  @override
  String toString() {
    return 'ConnectivityState{results: $results, isConnected: $isConnected, hasWifi: $hasWifi, hasMobile: $hasMobile, hasEthernet: $hasEthernet}';
  }
}

/// Provider pour surveiller les changements de connectivité en temps réel
@riverpod
class ConnectivityNotifier extends _$ConnectivityNotifier {
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  ConnectivityState build() {
    // Initialiser l'état avec aucune connectivité
    final initialState = ConnectivityState.fromResults([
      ConnectivityResult.none,
    ]);

    // Démarrer l'écoute des changements
    _startListening();

    // Effectuer une vérification initiale
    _checkInitialConnectivity();

    // Nettoyer lors de la destruction
    ref.onDispose(() {
      _subscription?.cancel();
    });

    return initialState;
  }

  void _startListening() {
    _subscription?.cancel();

    _subscription = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        print('🌐 [CONNECTIVITY] Changement détecté: $results');
        final newState = ConnectivityState.fromResults(results);
        print(
          '🌐 [CONNECTIVITY] Nouvel état: isConnected=${newState.isConnected}, hasWifi=${newState.hasWifi}, hasMobile=${newState.hasMobile}, hasEthernet=${newState.hasEthernet}',
        );

        // Émettre seulement si l'état a vraiment changé
        if (state != newState) {
          print('🌐 [CONNECTIVITY] État changé, mise à jour du state');
          state = newState;
        } else {
          print('🌐 [CONNECTIVITY] État inchangé, pas de mise à jour');
        }
      },
      onError: (error) {
        print('❌ [CONNECTIVITY] Erreur surveillance connectivité: $error');
        state = ConnectivityState.fromResults([ConnectivityResult.none]);
      },
    );
  }

  Future<void> _checkInitialConnectivity() async {
    try {
      print(
        '🌐 [CONNECTIVITY] Démarrage vérification connectivité initiale...',
      );
      final results = await Connectivity().checkConnectivity();
      print('🌐 [CONNECTIVITY] Connectivité initiale détectée: $results');
      final newState = ConnectivityState.fromResults(results);
      print(
        '🌐 [CONNECTIVITY] Nouvel état calculé: isConnected=${newState.isConnected}, hasWifi=${newState.hasWifi}, hasMobile=${newState.hasMobile}, hasEthernet=${newState.hasEthernet}',
      );
      state = newState;
    } catch (e) {
      print('❌ [CONNECTIVITY] Erreur vérification connectivité initiale: $e');
      state = ConnectivityState.fromResults([ConnectivityResult.none]);
    }
  }

  /// Vérifier manuellement la connectivité
  Future<void> checkConnectivity() async {
    try {
      print('🌐 [CONNECTIVITY] Vérification manuelle de la connectivité...');
      final results = await Connectivity().checkConnectivity();
      print('🌐 [CONNECTIVITY] Résultats manuels: $results');
      final newState = ConnectivityState.fromResults(results);
      print(
        '🌐 [CONNECTIVITY] État manuel calculé: isConnected=${newState.isConnected}, hasWifi=${newState.hasWifi}, hasMobile=${newState.hasMobile}, hasEthernet=${newState.hasEthernet}',
      );
      state = newState;
    } catch (e) {
      print('❌ [CONNECTIVITY] Erreur vérification manuelle connectivité: $e');
      state = ConnectivityState.fromResults([ConnectivityResult.none]);
    }
  }

  /// Forcer un état de connectivité (utile pour les tests)
  void setConnectivityState(List<ConnectivityResult> results) {
    state = ConnectivityState.fromResults(results);
  }
}

/// Provider simple pour vérifier si l'appareil est connecté
@riverpod
bool isConnected(IsConnectedRef ref) {
  final connectivity = ref.watch(connectivityNotifierProvider);
  return connectivity.isConnected;
}

/// Provider pour vérifier si le WiFi est disponible
@riverpod
bool hasWifi(HasWifiRef ref) {
  final connectivity = ref.watch(connectivityNotifierProvider);
  return connectivity.hasWifi;
}

/// Provider pour vérifier si les données mobiles sont disponibles
@riverpod
bool hasMobile(HasMobileRef ref) {
  final connectivity = ref.watch(connectivityNotifierProvider);
  return connectivity.hasMobile;
}

/// Provider pour vérifier si Ethernet est disponible
@riverpod
bool hasEthernet(HasEthernetRef ref) {
  final connectivity = ref.watch(connectivityNotifierProvider);
  return connectivity.hasEthernet;
}

/// Provider pour obtenir les types de connectivité actuels
@riverpod
List<ConnectivityResult> connectivityResults(ConnectivityResultsRef ref) {
  final connectivity = ref.watch(connectivityNotifierProvider);
  return connectivity.results;
}
