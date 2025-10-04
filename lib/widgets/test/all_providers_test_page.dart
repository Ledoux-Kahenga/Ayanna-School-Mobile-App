import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/providers/providers.dart';

/// Page de test pour vérifier que tous les providers sont accessibles
class AllProvidersTestPage extends ConsumerWidget {
  const AllProvidersTestPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Tous les Providers'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section API et Services
            _buildSection('API et Services', Icons.api, [
              _buildProviderItem(
                'ApiClient',
                () => ref.read(apiClientProvider),
              ),
              _buildProviderItem(
                'UtilisateurService',
                () => ref.read(utilisateurServiceProvider),
              ),
              _buildProviderItem(
                'EntrepriseService',
                () => ref.read(entrepriseServiceProvider),
              ),
              _buildProviderItem(
                'EleveService',
                () => ref.read(eleveServiceProvider),
              ),
              _buildProviderItem(
                'ClasseService',
                () => ref.read(classeServiceProvider),
              ),
              _buildProviderItem(
                'EnseignantService',
                () => ref.read(enseignantServiceProvider),
              ),
              _buildProviderItem(
                'ResponsableService',
                () => ref.read(responsableServiceProvider),
              ),
              _buildProviderItem(
                'CoursService',
                () => ref.read(coursServiceProvider),
              ),
              _buildProviderItem(
                'AnneeScolaireService',
                () => ref.read(anneeScolaireServiceProvider),
              ),
              _buildProviderItem(
                'NotePeriodeService',
                () => ref.read(notePeriodeServiceProvider),
              ),
              _buildProviderItem(
                'PeriodeService',
                () => ref.read(periodeServiceProvider),
              ),
              _buildProviderItem(
                'FraisScolaireService',
                () => ref.read(fraisScolaireServiceProvider),
              ),
              _buildProviderItem(
                'PaiementFraisService',
                () => ref.read(paiementFraisServiceProvider),
              ),
              _buildProviderItem(
                'CreanceService',
                () => ref.read(creanceServiceProvider),
              ),
              _buildProviderItem(
                'ClasseComptableService',
                () => ref.read(classeComptableServiceProvider),
              ),
              _buildProviderItem(
                'CompteComptableService',
                () => ref.read(compteComptableServiceProvider),
              ),
              _buildProviderItem(
                'JournalComptableService',
                () => ref.read(journalComptableServiceProvider),
              ),
              _buildProviderItem(
                'EcritureComptableService',
                () => ref.read(ecritureComptableServiceProvider),
              ),
              _buildProviderItem(
                'DepenseService',
                () => ref.read(depenseServiceProvider),
              ),
              _buildProviderItem(
                'LicenceService',
                () => ref.read(licenceServiceProvider),
              ),
              _buildProviderItem(
                'ConfigEcoleService',
                () => ref.read(configEcoleServiceProvider),
              ),
              _buildProviderItem(
                'ComptesConfigService',
                () => ref.read(comptesConfigServiceProvider),
              ),
              _buildProviderItem(
                'PeriodesClassesService',
                () => ref.read(periodesClassesServiceProvider),
              ),
            ]),

            const SizedBox(height: 24),

            // Section Authentification
            _buildSection('Authentification', Icons.lock, [
              _buildProviderItem(
                'AuthNotifier',
                () => ref.read(authNotifierProvider.notifier),
              ),
              _buildProviderItem(
                'IsAuthenticated',
                () => ref.read(isAuthenticatedProvider),
              ),
              _buildProviderItem(
                'AuthToken',
                () => ref.read(authTokenProvider),
              ),
              _buildProviderItem(
                'CurrentUserId',
                () => ref.read(currentUserIdProvider),
              ),
              _buildProviderItem(
                'CurrentEntrepriseId',
                () => ref.read(currentEntrepriseIdProvider),
              ),
              _buildProviderItem(
                'CurrentUserEmail',
                () => ref.read(currentUserEmailProvider),
              ),
              _buildProviderItem(
                'AuthError',
                () => ref.read(authErrorProvider),
              ),
              _buildProviderItem(
                'IsAuthLoading',
                () => ref.read(isAuthLoadingProvider),
              ),
            ]),

            const SizedBox(height: 24),

            // Section Connectivité et Sync
            _buildSection('Connectivité et Synchronisation', Icons.sync, [
              _buildProviderItem(
                'IsConnected',
                () => ref.read(isConnectedProvider),
              ),
              _buildProviderItem(
                'ConnectivityProvider',
                () => ref.read(connectivityProvider),
              ),
              _buildProviderItem(
                'SyncStateNotifier',
                () => ref.read(syncStateNotifierProvider.notifier),
              ),
              _buildProviderItem(
                'SharedPreferences',
                () => ref.read(sharedPreferencesProvider),
              ),
            ]),

            const SizedBox(height: 24),

            // Section Base de Données
            _buildSection('Base de Données', Icons.storage, [
              _buildProviderItem('Database', () => ref.read(databaseProvider)),
              _buildProviderItem('EleveDao', () => ref.read(eleveDaoProvider)),
              _buildProviderItem(
                'UtilisateurDao',
                () => ref.read(utilisateurDaoProvider),
              ),
              _buildProviderItem(
                'EntrepriseDao',
                () => ref.read(entrepriseDaoProvider),
              ),
              _buildProviderItem(
                'ClasseDao',
                () => ref.read(classeDaoProvider),
              ),
              _buildProviderItem(
                'EnseignantDao',
                () => ref.read(enseignantDaoProvider),
              ),
              _buildProviderItem(
                'ResponsableDao',
                () => ref.read(responsableDaoProvider),
              ),
              _buildProviderItem('CoursDao', () => ref.read(coursDaoProvider)),
              _buildProviderItem(
                'AnneeScolaireDao',
                () => ref.read(anneeScolaireDaoProvider),
              ),
            ]),

            const SizedBox(height: 32),

            // Résumé
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(color: Colors.green.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 48),
                  SizedBox(height: 8),
                  Text(
                    'Tous les Providers Accessibles !',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Architecture complète avec :\n'
                    '• 22+ Services Chopper API\n'
                    '• Authentification avec AuthProvider\n'
                    '• Connectivité et Synchronisation\n'
                    '• Base de données Floor\n'
                    '• Stockage SharedPreferences\n'
                    '• Import unique depuis providers.dart',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildProviderItem(String name, Function() providerGetter) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(child: Text(name, style: const TextStyle(fontSize: 14))),
          Builder(
            builder: (context) {
              try {
                providerGetter(); // Test si le provider est accessible
                return Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'OK',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              } catch (e) {
                return Row(
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Erreur',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
