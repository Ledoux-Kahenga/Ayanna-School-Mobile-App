import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/licence/licence_validator.dart';
import '../vues/licence_reactivation_screen.dart';

/// Widget garde qui bloque l'application si la licence est invalide
///
/// Utilisation:
/// ```dart
/// MaterialApp(
///   home: LicenceGuard(
///     child: MyHomeScreen(),
///   ),
/// )
/// ```
class LicenceGuard extends ConsumerWidget {
  final Widget child;
  final Widget? loadingWidget;
  final Widget? errorWidget;

  const LicenceGuard({
    required this.child,
    this.loadingWidget,
    this.errorWidget,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final licenceState = ref.watch(licenceValidationProvider);

    return licenceState.when(
      data: (state) {
        // ❌ BLOQUER si la licence est invalide et existe
        if (state.shouldBlockApp && state.licence != null) {
          return LicenceReactivationScreen(
            licence: state.licence!,
            onLicenceReactivated: () {
              // Invalidate the provider to re-check
              ref.invalidate(licenceValidationProvider);
            },
          );
        }

        // ❌ BLOQUER également si aucune licence n'existe
        // Une application de gestion scolaire DOIT avoir une licence valide
        if (!state.isValid && state.licence == null) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 80,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Licence requise',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.reason ?? 'Aucune licence active trouvée',
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Veuillez contacter votre administrateur pour obtenir une licence valide.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // ✅ Licence valide - Autoriser l'accès
        return child;
      },
      loading: () => loadingWidget ?? _buildLoadingScreen(),
      error: (error, stack) => errorWidget ?? _buildErrorScreen(error),
    );
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Vérification de la licence...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(Object error) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Erreur de vérification de licence',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
