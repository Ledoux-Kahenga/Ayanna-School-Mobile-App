import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider simple pour l'état de connectivité
/// Note: Pour une vraie implémentation, utilisez connectivity_plus
class ConnectivityNotifier extends StateNotifier<bool> {
  Timer? _timer;

  ConnectivityNotifier() : super(true) {
    _startPeriodicCheck();
  }

  void _startPeriodicCheck() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      _checkConnectivity();
    });
  }

  Future<void> _checkConnectivity() async {
    try {
      // Simuler une vérification de connectivité
      // Dans une vraie application, utilisez connectivity_plus ou testez une requête réseau
      state = true; // Simuler comme connecté
    } catch (e) {
      state = false;
    }
  }

  /// Vérifier manuellement la connectivité
  Future<bool> checkConnectivity() async {
    try {
      // Ici vous pourriez faire un ping vers votre serveur
      // ou utiliser connectivity_plus
      await _checkConnectivity();
      return state;
    } catch (e) {
      state = false;
      return false;
    }
  }

  /// Forcer l'état de connectivité (utile pour les tests)
  void setConnectivityState(bool isConnected) {
    state = isConnected;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Provider pour l'état de connectivité
final connectivityProvider = StateNotifierProvider<ConnectivityNotifier, bool>((
  ref,
) {
  return ConnectivityNotifier();
});

/// Provider simple pour vérifier si connecté
final isConnectedProvider = Provider<bool>((ref) {
  return ref.watch(connectivityProvider);
});
