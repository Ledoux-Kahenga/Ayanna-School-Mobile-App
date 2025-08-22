// Code corrigé
import 'package:ayanna_school/vues/eleves/eleves_screen.dart';
import 'package:ayanna_school/theme/ayanna_theme.dart';
import 'package:flutter/material.dart';
import '../classes/classes_screen.dart';
import '../configuration_screen.dart';
import '../paiementFrais/paiement_frais.dart';
import '../journal_comptable_screen.dart';
import '../grand_livre_screen.dart';
import '../classes/bilan_screen.dart';

class AyannaDrawer extends StatelessWidget {
  const AyannaDrawer({super.key});

  @override
  Widget build(BuildContext context) {
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
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.school,
                          size: 56,
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
                  ],
                ),
              ),
            ),
            _buildDivider(),
            // Paiement frais item
            _buildDrawerItem(
              context,
              icon: Icons.payment,
              text: 'Paiement frais',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) =>  PaiementDesFrais()),
                );
              },
            ),
            _buildDivider(),
            _buildDrawerItem(
              context,
              icon: Icons.class_,
              text: 'Classes',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ClassesScreen()),
                );
              },
            ),
            _buildDivider(),
            _buildDrawerItem(
              context,
              icon: Icons.people,
              text: 'Eleves',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ElevesScreen()),
                );
              },
            ),
            _buildDivider(),
            // Comptabilité dropdown
            ExpansionTile(
              leading: Icon(Icons.account_balance, color: AyannaColors.orange),
              title: const Text(
                'Comptabilité',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              children: [
                _buildSubItem(
                  context,
                  icon: Icons.receipt_long,
                  text: 'Journal comptable',
                  screen: const JournalComptableScreen(),
                ),
                _buildSubItem(
                  context,
                  icon: Icons.library_books,
                  text: 'Grand livre',
                  screen: const GrandLivreScreen(),
                ),
                _buildSubItem(
                  context,
                  icon: Icons.assessment,
                  text: 'Bilan',
                  screen: const BilanScreen(),
                ),
              ],
            ),
            _buildDivider(),
            _buildDrawerItem(
              context,
              icon: Icons.settings,
              text: 'Paramètre',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ConfigurationScreen(isFirstSetup: false),
                  ),
                );
              },
            ),
            _buildDivider(),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AyannaColors.orange),
      title: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
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
  }) {
    return ListTile(
      leading: Icon(icon, color: AyannaColors.orange),
      title: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => screen),
        );
      },
    );
  }

  Widget _buildDivider() {
    return const Divider(thickness: 0.5, height: 0.5, indent: 16.0, endIndent: 16.0, color: Colors.orangeAccent);
  }
}