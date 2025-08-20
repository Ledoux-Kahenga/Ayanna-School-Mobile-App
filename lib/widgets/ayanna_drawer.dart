import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/classes_screen.dart';
import '../screens/configuration_screen.dart';
import '../screens/eleve_global_screen.dart';

class AyannaDrawer extends StatelessWidget {
  const AyannaDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.school, size: 48, color: Colors.white),
                SizedBox(height: 8),
                Text(
                  'Ayanna School',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Accueil'),
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.class_),
            title: const Text('Classes'),
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const ClassesScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Élève'),
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const EleveGlobalScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_balance),
            title: const Text('Comptabilité'),
            onTap: () {
              // TODO: Naviguer vers la page de comptabilité
              // Navigator.of(context).pushReplacement(
              //   MaterialPageRoute(builder: (_) => const ComptabiliteScreen()),
              // );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Paramètre'),
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
    );
  }
}
