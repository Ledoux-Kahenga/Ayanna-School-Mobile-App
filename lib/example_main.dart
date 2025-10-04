import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/auth/login_page.dart';
import 'widgets/test/simple_test_page.dart';
import 'services/providers/auth_provider.dart';

/// Application principale avec navigation et gestion d'état Riverpod
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Ayanna School App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginPage(),
          '/home': (context) => const HomePage(),
          '/test': (context) => const TestNavigationPage(),
          '/simple-test': (context) => const SimpleTestPage(),
        },
      ),
    );
  }
}

/// Widget qui détermine quelle page afficher selon l'état d'authentification
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    // Si l'utilisateur est authentifié, aller à la page d'accueil
    // Sinon, afficher la page de navigation/test
    if (isAuthenticated) {
      return const HomePage();
    } else {
      return const TestNavigationPage();
    }
  }
}

/// Page d'accueil principale de l'application
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userEmail = ref.watch(currentUserEmailProvider);
    final userId = ref.watch(currentUserIdProvider);
    final authNotifier = ref.read(authNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayanna School - Accueil'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'logout':
                  await authNotifier.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/');
                  }
                  break;
                case 'test':
                  Navigator.of(context).pushNamed('/simple-test');
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'test',
                    child: Row(
                      children: [
                        Icon(Icons.bug_report),
                        SizedBox(width: 8),
                        Text('Tests des Providers'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Se déconnecter'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête de bienvenue
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Bienvenue !',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (userEmail != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  userEmail,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                              if (userId != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'ID: $userId',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Modules de l'application
            const Text(
              'Modules disponibles',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildModuleCard(
                    context,
                    'Élèves',
                    Icons.school,
                    Colors.blue,
                    () => _showComingSoon(context, 'Gestion des élèves'),
                  ),
                  _buildModuleCard(
                    context,
                    'Classes',
                    Icons.class_,
                    Colors.green,
                    () => _showComingSoon(context, 'Gestion des classes'),
                  ),
                  _buildModuleCard(
                    context,
                    'Enseignants',
                    Icons.person_outline,
                    Colors.orange,
                    () => _showComingSoon(context, 'Gestion des enseignants'),
                  ),
                  _buildModuleCard(
                    context,
                    'Comptabilité',
                    Icons.account_balance,
                    Colors.purple,
                    () => _showComingSoon(context, 'Module comptabilité'),
                  ),
                  _buildModuleCard(
                    context,
                    'Frais scolaires',
                    Icons.payment,
                    Colors.teal,
                    () => _showComingSoon(context, 'Gestion des frais'),
                  ),
                  _buildModuleCard(
                    context,
                    'Tests Providers',
                    Icons.bug_report,
                    Colors.red,
                    () => Navigator.of(context).pushNamed('/simple-test'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String module) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('À venir'),
            content: Text('Le module "$module" sera disponible prochainement.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}

/// Point d'entrée de l'application
void main() {
  runApp(const MyApp());
}
