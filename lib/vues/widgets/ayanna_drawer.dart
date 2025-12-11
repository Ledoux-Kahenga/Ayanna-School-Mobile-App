// Code corrigé
import 'package:ayanna_school/vues/eleves/eleves_screen.dart';
import 'package:ayanna_school/theme/ayanna_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import '../classes/classes_screen.dart';
import '../configuration_screen.dart';
import '../gestions frais/paiement_frais.dart';
import '../gestions frais/journal_caisse.dart';
import '../synchronisation/sync_status_screen.dart';
import '../../services/providers/providers.dart';

class AyannaDrawer extends ConsumerWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  const AyannaDrawer({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: AyannaColors.orange),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AyannaColors.orange,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AyannaColors.orange.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Image.asset(
                          'assets/icon/icon.png',
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ayanna School',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Consumer(
                      builder: (context, ref, child) {
                        final entreprisesAsync = ref.watch(
                          entreprisesNotifierProvider,
                        );
                        return entreprisesAsync.when(
                          data: (entreprises) {
                            if (entreprises.isNotEmpty) {
                              final entreprise = entreprises.first;
                              return Text(
                                entreprise.nom,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              );
                            }
                            return const SizedBox.shrink();
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            _buildDivider(),
            ExpansionTile(
              initiallyExpanded: true,
              leading: Icon(
                Icons.account_balance_wallet,
                color: AyannaColors.orange,
              ),
              title: const Text(
                'Gestion Frais',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: _buildSubItem(
                    context,
                    icon: Icons.payment,
                    text: 'Paiement frais',
                    screen: PaiementDesFrais(),
                    selected: selectedIndex == 0,
                    onTap: () {
                      onItemSelected(0);
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => PaiementDesFrais()),
                        (Route<dynamic> route) => route.isFirst,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: _buildSubItem(
                    context,
                    icon: Icons.receipt_long,
                    text: 'Journal caisse',
                    screen: const JournalCaisse(),
                    selected: selectedIndex == 1,
                    onTap: () {
                      onItemSelected(1);
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const JournalCaisse(),
                        ),
                        (Route<dynamic> route) => route.isFirst,
                      );
                    },
                  ),
                ),
              ],
            ),
            _buildDivider(),
            _buildDrawerItem(
              context,
              icon: Icons.menu_book,
              text: 'Classes',
              onTap: () {
                onItemSelected(2);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => ClassesScreen()),
                  (Route<dynamic> route) => route.isFirst,
                );
              },
              selected: selectedIndex == 2,
            ),
            _buildDivider(),
            _buildDrawerItem(
              context,
              icon: Icons.people,
              text: 'Eleves',
              onTap: () {
                onItemSelected(3);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => ElevesScreen()),
                  (Route<dynamic> route) => route.isFirst,
                );
              },
              selected: selectedIndex == 3,
            ),
            _buildDivider(),
            _buildDrawerItem(
              context,
              icon: Icons.sync,
              text: 'Synchronisation',
              onTap: () {
                onItemSelected(5);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => SyncStatusScreen()),
                  (Route<dynamic> route) => route.isFirst,
                );
              },
              selected: selectedIndex == 5,
            ),
            _buildDivider(),
            _buildDrawerItem(
              context,
              icon: Icons.settings,
              text: 'Paramètre',
              onTap: () {
                onItemSelected(4);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => ConfigurationScreen(),
                  ),
                  (Route<dynamic> route) => route.isFirst,
                );
              },
              selected: selectedIndex == 4,
            ),
            _buildDivider(),
            // Bouton de déconnexion
            _buildLogoutItem(context, ref),
          ],
        ),
      ),
    );
  }

  /// Affiche une boîte de dialogue de confirmation pour la déconnexion
  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange.shade600),
              const SizedBox(width: 8),
              const Expanded(child: Text('Confirmation de déconnexion')),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Voulez-vous vous déconnecter ?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 12),
              Text(
                'Vous serez déconnecté de votre session. Les données locales resteront présentes sur l\'appareil.',
                style: TextStyle(color: Colors.black87, fontSize: 14),
              ),
              SizedBox(height: 8),
              Text(
                'Si vous avez des actions non synchronisées, pensez à synchroniser avant de vous déconnecter.',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Fermer la boîte de dialogue
                Navigator.of(dialogContext).pop();

                // Fermer le drawer
                Navigator.of(context).pop();

                // Effectuer la déconnexion
                await _performLogout(context, ref);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Se déconnecter'),
            ),
          ],
        );
      },
    );
  }

  /// Effectue la déconnexion locale complète (base de données + SharedPreferences)
  Future<void> _performLogout(BuildContext context, WidgetRef ref) async {
    BuildContext? loadingDialogContext;
    
    // Capturer le context AVANT toute opération async pour Phoenix.rebirth
    final navigatorContext = Navigator.of(context).context;

    try {
      // Afficher un indicateur de chargement simple
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          loadingDialogContext = dialogContext;
          return WillPopScope(
            onWillPop: () async => false,
            child: const AlertDialog(
              content: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Expanded(child: Text('Fermeture de la session...')),
                ],
              ),
            ),
          );
        },
      );

      print('🔒 [LOGOUT] Fermeture de la session en cours...');

      // Invalider les providers AVANT le logout pour éviter "ref disposed"
      print('🔄 [LOGOUT] Invalidation des providers...');
      ref.invalidate(authNotifierProvider);
      ref.invalidate(elevesNotifierProvider);
      ref.invalidate(classesNotifierProvider);
      ref.invalidate(fraisScolairesNotifierProvider);
      ref.invalidate(paiementsFraisNotifierProvider);
      print('✅ [LOGOUT] Providers invalidés');

      // Appeler le provider d'authentification pour effectuer la déconnexion
      await ref.read(authNotifierProvider.notifier).logout();

      print('✅ [LOGOUT] Session fermée, tokens locaux supprimés');

      // Fermer le dialog de chargement
      try {
        if (loadingDialogContext != null && loadingDialogContext!.mounted) {
          Navigator.of(loadingDialogContext!).pop();
          print('✅ [UI] Dialog fermé');
        }
      } catch (e) {
        print('⚠️ [UI] Erreur fermeture dialog: $e');
      }

      // Attendre un peu pour s'assurer que le dialog est fermé
      await Future.delayed(const Duration(milliseconds: 300));

      // Redémarrer l'application avec le context capturé
      if (navigatorContext.mounted) {
        print(
          '🔥 [RESTART] Redémarrage complet de l\'application avec Phoenix...',
        );
        Phoenix.rebirth(navigatorContext);
        print('✅ [RESTART] Application redémarrée');
      } else {
        print('❌ [RESTART] Context non monté, impossible de redémarrer');
      }
    } catch (e) {
      print('❌ [LOGOUT] Erreur lors de la fermeture de session: $e');
      // Fermer le dialog en cas d'erreur
      try {
        if (loadingDialogContext != null && loadingDialogContext!.mounted) {
          Navigator.of(loadingDialogContext!).pop();
        }
      } catch (_) {}
    }
  }

  // NOTE: Legacy destructive helpers (clear DB / clear prefs / full provider invalidation)
  // were intentionally removed from the active logout path to keep local data intact.
  // If you need to restore a full data wipe, the implementation can be recovered
  // from version control and reintroduced behind an explicit 'wipe data' action.

  /// Construit un élément de déconnexion avec un style spécial
  Widget _buildLogoutItem(BuildContext context, WidgetRef ref) {
    // Use the same drawer item style as other items for consistency
    return _buildDrawerItem(
      context,
      icon: Icons.logout,
      text: 'Se déconnecter',
      onTap: () => _showLogoutConfirmation(context, ref),
      selected: false,
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool selected = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: AyannaColors.orange),
      title: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: selected ? AyannaColors.orange : Colors.black,
        ),
      ),
      selected: selected,
      selectedTileColor: AyannaColors.orange.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      hoverColor: Colors.orange.withOpacity(0.1),
      onTap: onTap,
    );
  }

  Widget _buildSubItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    required Widget screen,
    required VoidCallback onTap,
    bool selected = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: AyannaColors.orange),
      title: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: selected ? AyannaColors.orange : Colors.black,
        ),
      ),
      selected: selected,
      selectedTileColor: AyannaColors.orange.withOpacity(0.15),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(
      thickness: 0.5,
      height: 0.5,
      indent: 16.0,
      endIndent: 16.0,
      color: Colors.orangeAccent,
    );
  }
}
