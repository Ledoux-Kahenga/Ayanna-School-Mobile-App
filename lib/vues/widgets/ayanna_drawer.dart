// Code corrigé
import 'package:ayanna_school/vues/eleves/eleves_screen.dart';
import 'package:ayanna_school/theme/ayanna_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
                'Attention : Toutes les actions locales non synchronisées seront perdues.',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
              SizedBox(height: 8),
              Text(
                'Assurez-vous d\'avoir synchronisé vos données avant de vous déconnecter.',
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

    try {
      // Afficher un indicateur de chargement
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
                  Expanded(child: Text('Suppression des données locales...')),
                ],
              ),
            ),
          );
        },
      );

      print('🔄 [LOGOUT] Début de la suppression des données locales...');

      // 1. Obtenir toutes les références nécessaires AVANT les opérations asynchrones
      final db = ref.watch(databaseProvider);
      final prefs = await ref.read(sharedPreferencesProvider.future);
      final syncPrefs = ref.read(syncPreferencesNotifierProvider.notifier);

      // 2. Supprimer toutes les données de la base de données locale
      await _clearLocalDatabase(db);

      // 3. Supprimer toutes les données SharedPreferences
      await _clearSharedPreferences(prefs, syncPrefs);

      print('✅ [LOGOUT] Suppression des données locales terminée');
    } catch (e) {
      print('❌ [LOGOUT] Erreur lors de la suppression: $e');
    } finally {
      // Toujours fermer l'indicateur de chargement
      try {
        if (loadingDialogContext != null && loadingDialogContext!.mounted) {
          Navigator.of(loadingDialogContext!).pop();
          print('✅ [UI] Dialog fermé');
        }
      } catch (e) {
        print('⚠️ [UI] Erreur fermeture dialog: $e');
      }

      // Attendre un peu pour s'assurer que le dialog est fermé
      await Future.delayed(const Duration(milliseconds: 200));

      // Naviguer vers l'écran de connexion
      try {
        if (context.mounted) {
          print('🔄 [UI] Navigation vers /login...');
          print('🔍 [UI] Context mounted: ${context.mounted}');
          print('🔍 [UI] Navigator disponible: ${Navigator.canPop(context)}');

          // Forcer la navigation avec await
          await Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);

          print('✅ [UI] Navigation vers /login terminée avec succès');

          // Attendre avant d'invalider le cache
          await Future.delayed(const Duration(milliseconds: 100));

          try {
            _invalidateAllProviders(ref);
            print('✅ [CACHE] Cache Riverpod invalidé après navigation');
          } catch (e) {
            print('⚠️ [CACHE] Erreur invalidation cache (ignorée): $e');
          }
        }
      } catch (e) {
        print('❌ [UI] Erreur navigation: $e');
      }
    }
  }

  /// Supprime toutes les données de la base de données locale
  Future<void> _clearLocalDatabase(dynamic db) async {
    try {
      print(
        '🗄️ [DB] Suppression de toutes les tables de la base de données...',
      );

      // Désactiver temporairement les contraintes de clés étrangères
      print('🔧 [DB] Désactivation des contraintes de clés étrangères...');
      await db.database.execute('PRAGMA foreign_keys = OFF');

      try {
        // Supprimer toutes les données sans se soucier de l'ordre
        await db.creanceDao.deleteAllCreances();
        await db.ecritureComptableDao.deleteAllEcrituresComptables();
        await db.depenseDao.deleteAllDepenses();
        await db.journalComptableDao.deleteAllJournauxComptables();
        await db.paiementFraisDao.deleteAllPaiementsFrais();
        await db.fraisScolaireDao.deleteAllFraisScolaires();
        await db.periodesClassesDao.deleteAllPeriodesClasses();
        await db.notePeriodeDao.deleteAllNotesPeriode();
        await db.coursDao.deleteAllCours();
        await db.periodeDao.deleteAllPeriodes();
        await db.configEcoleDao.deleteAllConfigsEcole();
        await db.comptesConfigDao.deleteAllComptesConfigs();
        await db.compteComptableDao.deleteAllComptesComptables();
        await db.classeComptableDao.deleteAllClassesComptables();
        await db.licenceDao.deleteAllLicences();
        await db.eleveDao.deleteAllEleves();
        await db.responsableDao.deleteAllResponsables();
        await db.enseignantDao.deleteAllEnseignants();
        await db.classeDao.deleteAllClasses();
        await db.anneeScolaireDao.deleteAllAnneesScolaires();
        await db.utilisateurDao.deleteAllUtilisateurs();
        await db.entrepriseDao.deleteAllEntreprises();

        print('✅ [DB] Toutes les tables supprimées');
      } finally {
        // Réactiver les contraintes de clés étrangères
        print('🔧 [DB] Réactivation des contraintes de clés étrangères...');
        await db.database.execute('PRAGMA foreign_keys = ON');
      }

      print('✅ [DB] Base de données complètement vidée');
    } catch (e) {
      print('❌ [DB] Erreur lors de la suppression de la base de données: $e');
      rethrow;
    }
  }

  /// Supprime toutes les données SharedPreferences
  Future<void> _clearSharedPreferences(dynamic prefs, dynamic syncPrefs) async {
    try {
      print('📱 [PREFS] Suppression des SharedPreferences...');

      // Supprimer le token d'authentification
      await prefs.clear(); // Supprime TOUTES les données SharedPreferences

      // Supprimer spécifiquement les données de sync
      await syncPrefs.clearSyncData();

      print('✅ [PREFS] SharedPreferences complètement vidées');
    } catch (e) {
      print(
        '❌ [PREFS] Erreur lors de la suppression des SharedPreferences: $e',
      );
      throw e;
    }
  }

  /// Invalide tous les providers pour vider le cache Riverpod
  void _invalidateAllProviders(WidgetRef ref) {
    try {
      print('🔄 [CACHE] Invalidation du cache Riverpod...');

      // Invalider le provider d'authentification en premier (critique)
      ref.invalidate(authNotifierProvider);

      // Invalider tous les providers de données pour forcer le rechargement
      ref.invalidate(elevesNotifierProvider);
      ref.invalidate(classesNotifierProvider);
      ref.invalidate(enseignantsNotifierProvider);
      ref.invalidate(utilisateursNotifierProvider);
      ref.invalidate(entreprisesNotifierProvider);
      ref.invalidate(anneesScolairesNotifierProvider);
      ref.invalidate(fraisScolairesNotifierProvider);
      ref.invalidate(paiementsFraisNotifierProvider);
      ref.invalidate(periodesNotifierProvider);
      ref.invalidate(coursNotifierProvider);
      ref.invalidate(fraisClassesNotifierProvider);
      ref.invalidate(periodesClassesNotifierProvider);
      ref.invalidate(comptesConfigsNotifierProvider);
      ref.invalidate(comptesComptablesNotifierProvider);
      ref.invalidate(classesComptablesNotifierProvider);
      ref.invalidate(licencesNotifierProvider);
      ref.invalidate(responsablesNotifierProvider);
      ref.invalidate(journauxComptablesNotifierProvider);
      ref.invalidate(depensesNotifierProvider);
      ref.invalidate(ecrituresComptablesNotifierProvider);
      ref.invalidate(creancesNotifierProvider);

      print('✅ [CACHE] Cache Riverpod invalidé');
    } catch (e) {
      print('❌ [CACHE] Erreur lors de l\'invalidation du cache: $e');
      // Ne pas lancer l'erreur, continuer la déconnexion même si l'invalidation échoue
    }
  }

  /// Construit un élément de déconnexion avec un style spécial
  Widget _buildLogoutItem(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade300, width: 1),
      ),
      child: ListTile(
        leading: Icon(Icons.logout, color: Colors.red.shade600),
        title: Text(
          'Se déconnecter',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.red.shade600,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        hoverColor: Colors.red.withOpacity(0.1),
        onTap: () => _showLogoutConfirmation(context, ref),
      ),
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
