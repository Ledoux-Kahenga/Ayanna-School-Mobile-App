import 'package:flutter/material.dart';
import '../api/api_services.dart';

/// Exemple d'utilisation des services API
/// Cette classe montre comment utiliser les différents services
class ApiServiceExample {
  final ApiClient _apiClient = ApiClient();

  /// Exemple d'utilisation des services scolaires
  Future<void> exempleServicesEcoliers() async {
    try {
      // 1. Gestion des utilisateurs
      final utilisateurs =
          await _apiClient.utilisateurService.getUtilisateurs();
      print('Utilisateurs récupérés: ${utilisateurs.body?.length}');

      // 2. Gestion des élèves
      final eleves = await _apiClient.eleveService.getEleves();
      print('Élèves récupérés: ${eleves.body?.length}');

      // 3. Gestion des classes
      final classes = await _apiClient.classeService.getClasses();
      print('Classes récupérées: ${classes.body?.length}');

      // 4. Gestion des enseignants
      final enseignants = await _apiClient.enseignantService.getEnseignants();
      print('Enseignants récupérés: ${enseignants.body?.length}');

      // 5. Gestion des notes
      final notes = await _apiClient.notePeriodeService.getNotesPeriode();
      print('Notes récupérées: ${notes.body?.length}');
    } catch (e) {
      print('Erreur lors de l\'utilisation des services: $e');
    }
  }

  /// Exemple d'utilisation des services financiers
  Future<void> exempleServicesFinanciers() async {
    try {
      // 1. Gestion des frais scolaires
      final frais = await _apiClient.fraisScolaireService.getFraisScolaires();
      print('Frais scolaires récupérés: ${frais.body?.length}');

      // 2. Gestion des paiements
      final paiements =
          await _apiClient.paiementFraisService.getPaiementsFrais();
      print('Paiements récupérés: ${paiements.body?.length}');

      // 3. Gestion des créances
      final creances = await _apiClient.creanceService.getCreances();
      print('Créances récupérées: ${creances.body?.length}');

      // 4. Gestion des dépenses
      final depenses = await _apiClient.depenseService.getDepenses();
      print('Dépenses récupérées: ${depenses.body?.length}');
    } catch (e) {
      print('Erreur lors de l\'utilisation des services financiers: $e');
    }
  }

  /// Exemple d'utilisation des services comptables
  Future<void> exempleServicesComptables() async {
    try {
      // 1. Plan comptable
      final classesComptables =
          await _apiClient.classeComptableService.getClassesComptables();
      print('Classes comptables récupérées: ${classesComptables.body?.length}');

      final comptesComptables =
          await _apiClient.compteComptableService.getComptesComptables();
      print('Comptes comptables récupérés: ${comptesComptables.body?.length}');

      // 2. Journaux comptables
      final journaux =
          await _apiClient.journalComptableService.getJournauxComptables();
      print('Journaux comptables récupérés: ${journaux.body?.length}');

      // 3. Écritures comptables
      final ecritures =
          await _apiClient.ecritureComptableService.getEcrituresComptables();
      print('Écritures comptables récupérées: ${ecritures.body?.length}');
    } catch (e) {
      print('Erreur lors de l\'utilisation des services comptables: $e');
    }
  }

  /// Exemple de création d'un élève
  Future<void> creerEleve(Map<String, dynamic> eleveData) async {
    try {
      final response = await _apiClient.eleveService.createEleve(eleveData);
      if (response.isSuccessful) {
        print('Élève créé avec succès: ${response.body}');
      } else {
        print('Erreur lors de la création de l\'élève: ${response.error}');
      }
    } catch (e) {
      print('Exception lors de la création de l\'élève: $e');
    }
  }

  /// Exemple de synchronisation des données
  Future<void> synchroniserDonnees() async {
    try {
      // Synchroniser les entreprises
      final entreprisesLocales =
          <Map<String, dynamic>>[]; // Récupérer depuis la base locale
      await _apiClient.entrepriseService.syncEntreprises(entreprisesLocales);

      // Synchroniser les utilisateurs
      final utilisateursLocaux =
          <Map<String, dynamic>>[]; // Récupérer depuis la base locale
      await _apiClient.utilisateurService.syncUtilisateurs(utilisateursLocaux);

      // Synchroniser les élèves
      final elevesLocaux =
          <Map<String, dynamic>>[]; // Récupérer depuis la base locale
      await _apiClient.eleveService.syncEleves(elevesLocaux);

      print('Synchronisation terminée avec succès');
    } catch (e) {
      print('Erreur lors de la synchronisation: $e');
    }
  }

  /// Libérer les ressources
  void dispose() {
    _apiClient.dispose();
  }
}

/// Widget d'exemple montrant l'intégration dans une application Flutter
class ExempleIntegrationWidget extends StatefulWidget {
  @override
  _ExempleIntegrationWidgetState createState() =>
      _ExempleIntegrationWidgetState();
}

class _ExempleIntegrationWidgetState extends State<ExempleIntegrationWidget> {
  final ApiServiceExample _exemple = ApiServiceExample();
  bool _isLoading = false;
  String _message = '';

  @override
  void dispose() {
    _exemple.dispose();
    super.dispose();
  }

  Future<void> _testServices() async {
    setState(() {
      _isLoading = true;
      _message = 'Test des services en cours...';
    });

    try {
      await _exemple.exempleServicesEcoliers();
      await _exemple.exempleServicesFinanciers();
      await _exemple.exempleServicesComptables();

      setState(() {
        _message = 'Tous les services ont été testés avec succès!';
      });
    } catch (e) {
      setState(() {
        _message = 'Erreur lors du test des services: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Exemple API Services')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Cet exemple montre comment utiliser tous les services API',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _testServices,
              child:
                  _isLoading
                      ? CircularProgressIndicator()
                      : Text('Tester tous les services'),
            ),
            SizedBox(height: 20),
            Text(
              _message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
