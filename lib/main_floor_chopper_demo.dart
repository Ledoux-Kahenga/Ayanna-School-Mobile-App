import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/entreprise_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => EntrepriseService()..initialize(),
        ),
      ],
      child: MaterialApp(
        title: 'Ayanna School - Floor & Chopper Demo',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Entreprises'),
        actions: [
          IconButton(
            icon: Icon(Icons.sync),
            onPressed: () {
              context.read<EntrepriseService>().syncWithServer();
            },
          ),
        ],
      ),
      body: Consumer<EntrepriseService>(
        builder: (context, service, child) {
          if (service.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (service.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red, size: 48),
                  SizedBox(height: 16),
                  Text(
                    service.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => service.loadEntreprises(),
                    child: Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (service.entreprises.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.business, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Aucune entreprise trouvée',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => service.loadEntreprises(),
            child: ListView.builder(
              itemCount: service.entreprises.length,
              itemBuilder: (context, index) {
                final entreprise = service.entreprises[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(entreprise.nom[0].toUpperCase()),
                    ),
                    title: Text(entreprise.nom),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (entreprise.email != null) Text(entreprise.email!),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              entreprise.isSync
                                  ? Icons.cloud_done
                                  : Icons.cloud_off,
                              size: 16,
                              color:
                                  entreprise.isSync
                                      ? Colors.green
                                      : Colors.orange,
                            ),
                            SizedBox(width: 4),
                            Text(
                              entreprise.isSync
                                  ? 'Synchronisé'
                                  : 'Non synchronisé',
                              style: TextStyle(
                                color:
                                    entreprise.isSync
                                        ? Colors.green
                                        : Colors.orange,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton(
                      itemBuilder:
                          (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 20),
                                  SizedBox(width: 8),
                                  Text('Modifier'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Supprimer'),
                                ],
                              ),
                            ),
                          ],
                      onSelected: (value) {
                        if (value == 'delete') {
                          _showDeleteDialog(context, service, entreprise);
                        }
                        // Ajouter la logique pour 'edit'
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Ouvrir l'écran de création d'entreprise
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Fonction à implémenter')));
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    EntrepriseService service,
    entreprise,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmer la suppression'),
          content: Text('Voulez-vous vraiment supprimer "${entreprise.nom}" ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                service.deleteEntreprise(entreprise);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }
}
