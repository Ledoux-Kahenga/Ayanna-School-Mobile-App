import 'package:ayanna_school/services/app_preferences.dart';
import 'package:ayanna_school/services/providers/connectivity_provider.dart';
import 'package:ayanna_school/services/providers/database_provider.dart';
import 'package:ayanna_school/vues/eleves/add_eleve_screen.dart';
import 'package:ayanna_school/vues/gestions%20frais/paiement_frais.dart';
import 'package:ayanna_school/services/licence/licence_validator.dart';
import 'package:ayanna_school/vues/licence_reactivation_screen.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme/ayanna_theme.dart';
import 'vues/classes/auth_screen.dart';
import 'widgets/licence_guard.dart';

void main() async {
  // Initialisation de Flutter et des services
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', '');

  // Initialisation de sqflite selon la plateforme
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    // Pour desktop (Linux/Windows/MacOS) - seulement si sqlite3 est disponible
    try {
      sqfliteFfiInit();
      sqflite.databaseFactory = databaseFactoryFfi;
      print('✅ Sqflite FFI initialisé pour desktop');
    } catch (e) {
      print('⚠️ Sqflite FFI non disponible, utilisation de sqflite normal: $e');
      // Ne pas définir databaseFactory, utiliser l'implémentation par défaut
    }
  }
  // Pour mobile (Android/iOS), sqflite utilise l'implémentation native automatiquement

  initializeDatabase();
  // Initialisation de la base de données et des préférences
  await AppPreferences().init();

  // Wrapper l'application avec Phoenix pour permettre le redémarrage complet
  runApp(Phoenix(child: ProviderScope(child: MainApp())));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(connectivityNotifierProvider.notifier).checkConnectivity();
    return MaterialApp(
      title: 'Ayanna School',
      theme: ayannaTheme,
      routes: {
        '/login': (context) => const AuthScreen(),
        '/home': (context) => LicenceGuard(
          child: PaiementDesFrais(),
        ), // Page d'accueil principale avec garde de licence
        '/paiement-frais': (context) => LicenceGuard(child: PaiementDesFrais()),
        '/add-eleve': (context) => LicenceGuard(child: AddEleveScreen()),
      },
      home: const AppInitializer(),
    );
  }
}

/// Widget qui vérifie la licence au démarrage de l'application
class AppInitializer extends ConsumerStatefulWidget {
  const AppInitializer({super.key});

  @override
  ConsumerState<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends ConsumerState<AppInitializer> {
  @override
  Widget build(BuildContext context) {
    // Utiliser un FutureProvider pour gérer l'initialisation de manière plus sûre
    final initAsync = ref.watch(_appInitializationProvider);

    return initAsync.when(
      data: (initState) {
        // Si c'est le premier lancement, afficher l'écran de connexion
        if (initState.isFirstLaunch) {
          print(
            '🏁 [APP_INIT] Premier lancement - Affichage écran de connexion',
          );
          return const AuthScreen();
        }

        // Sinon, vérifier la licence
        print('🔄 [APP_INIT] Lancement ultérieur - Vérification licence');
        final licenceValidation = ref.watch(licenceValidationProvider);

        return licenceValidation.when(
          data: (state) {
            print('🔍 Vérification licence au démarrage:');
            print('  - shouldBlockApp: ${state.shouldBlockApp}');
            print('  - isValid: ${state.isValid}');
            print('  - reason: ${state.reason}');

            // ❌ BLOQUER si la licence bloque l'app ET existe
            if (state.shouldBlockApp && state.licence != null) {
              return LicenceReactivationScreen(
                licence: state.licence!,
                onLicenceReactivated: () {
                  // Invalider le provider pour re-vérifier
                  ref.invalidate(licenceValidationProvider);
                },
              );
            }

            // ❌ BLOQUER également si aucune licence n'existe
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
                          'Contactez votre administrateur pour obtenir une licence.',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            // ✅ Licence valide - Afficher l'écran d'authentification
            return const AuthScreen();
          },
          loading: () => const Scaffold(
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
          ),
          error: (error, stack) {
            print('❌ Erreur validation licence: $error');
            // En cas d'erreur, afficher l'écran d'auth quand même
            return const AuthScreen();
          },
        );
      },
      loading: () => const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initialisation de l\'application...'),
            ],
          ),
        ),
      ),
      error: (error, stack) {
        print('❌ Erreur initialisation: $error');
        // En cas d'erreur, afficher l'écran de connexion par défaut
        return const AuthScreen();
      },
    );
  }
}

/// État d'initialisation de l'application
class AppInitState {
  final bool isFirstLaunch;
  final bool isDbReady;

  const AppInitState({required this.isFirstLaunch, required this.isDbReady});
}

/// Provider pour l'initialisation de l'application
final _appInitializationProvider = FutureProvider.autoDispose<AppInitState>((
  ref,
) async {
  print('🔧 [APP_INIT] Début initialisation...');

  // 1. Attendre que la DB soit prête
  int attempts = 0;
  const maxAttempts = 10;

  while (attempts < maxAttempts) {
    try {
      ref.read(databaseProvider);
      print('✅ [APP_INIT] Base de données prête');
      break;
    } catch (e) {
      attempts++;
      print('⚠️ [APP_INIT] DB pas prête (tentative $attempts/$maxAttempts)');
      if (attempts >= maxAttempts) {
        throw Exception(
          'Impossible d\'initialiser la base de données après $maxAttempts tentatives',
        );
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  // 2. Vérifier si c'est le premier lancement
  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = prefs.getBool('is_first_launch') ?? true;

  print('🔍 [APP_INIT] Premier lancement: $isFirstLaunch');

  return AppInitState(isFirstLaunch: isFirstLaunch, isDbReady: true);
});
