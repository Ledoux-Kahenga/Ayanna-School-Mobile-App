import 'package:ayanna_school/theme/ayanna_theme.dart';
import 'package:flutter/material.dart';
import '../screens/classes_screen.dart';
import '../screens/configuration_screen.dart';
import '../screens/eleve_global_screen.dart';

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
            // Menu items stylisés
            _buildDrawerItem(
              context,
              icon: Icons.payment,
              text: 'Paiement frais',
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const EleveGlobalScreen()),
                );
              },
            ),
            _buildDivider(),
            _buildDrawerItem(
              context,
              icon: Icons.class_,
              text: 'Classes',
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const ClassesScreen()),
                );
              },
            ),
            _buildDivider(),
            _buildDrawerItem(
              context,
              icon: Icons.account_balance,
              text: 'Comptabilité',
              onTap: () {}, // Ne navigue pas, affiche les sous-items
            ),
            Padding(
              padding: const EdgeInsets.only(left: 32.0),
              child: Column(
                children: [
                  _buildDrawerItem(
                    context,
                    icon: Icons.book,
                    text: 'Journal comptable',
                    onTap: () {
                      // TODO: Naviguer vers la page Journal comptable
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.library_books,
                    text: 'Grand livre',
                    onTap: () {
                      // TODO: Naviguer vers la page Grand livre
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.assessment,
                    text: 'Bilan',
                    onTap: () {
                      // TODO: Naviguer vers la page Bilan
                    },
                  ),
                ],
              ),
            ),
            _buildDivider(),
            _buildDrawerItem(
              context,
              icon: Icons.settings,
              text: 'Paramètre',
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) =>
                        const ConfigurationScreen(isFirstSetup: false),
                  ),
                );
              },
            ),
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

  Widget _buildDivider() {
    return const Divider(thickness: 0.7, height: 1, color: Colors.orangeAccent);
  }
}
