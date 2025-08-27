import 'package:flutter/material.dart';
import '../../theme/ayanna_theme.dart';
import '../widgets/ayanna_appbar.dart';
import '../widgets/ayanna_widgets.dart';
import '../../services/school_queries.dart';
import '../../services/app_preferences.dart';
import '../../models/models.dart';
import 'classe_eleves_screen.dart';
import '../widgets/ayanna_drawer.dart';

class ClassesScreen extends StatefulWidget {
  final AnneeScolaire? anneeScolaire;
  const ClassesScreen({super.key, this.anneeScolaire});

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  List<Classe> _classes = [];
  List<Classe> _filteredClasses = [];
  Map<int, List<Eleve>> _classeEleves = {};
  bool _loading = false;
  String _errorMessage = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterClasses);
    _initData();
  }

Future<void> _initData() async {
  setState(() {
    _loading = true;
    _classes = [];
    _filteredClasses = [];
    _classeEleves = {};
    _errorMessage = '';
  });
  try {
    AnneeScolaire? anneeScolaireAUtiliser = widget.anneeScolaire;
    anneeScolaireAUtiliser ??= await SchoolQueries.getCurrentAnneeScolaire();
    if (anneeScolaireAUtiliser != null) {
      final loadedClasses = await SchoolQueries.getClassesByAnnee(
        anneeScolaireAUtiliser.id,
      );
      final Map<int, List<Eleve>> classeEleves = {};
      for (final classe in loadedClasses) {
        final eleves = await SchoolQueries.getElevesByClasse(classe.id);
        classeEleves[classe.id] = eleves;
      }

      // AJOUTEZ CETTE LIGNE POUR TRIER LES CLASSES
      loadedClasses.sort((a, b) => a.nom.compareTo(b.nom));

      setState(() {
        _classes = loadedClasses;
        _classeEleves = classeEleves;
        _filteredClasses = loadedClasses;
      });
    }
  } catch (e) {
    setState(() {
      _errorMessage = 'Erreur lors du chargement des classes: $e';
    });
  } finally {
    setState(() {
      _loading = false;
    });
  }
}

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

void _filterClasses() {
  final query = _searchController.text.trim().toLowerCase();
  if (query.isEmpty) {
    setState(() {
      _filteredClasses = _classes;
    });
    return;
  }
  
  final filtered = _classes.where((classe) {
    return classe.nom.toLowerCase().contains(query) ||
        (classe.niveau?.toLowerCase().contains(query) ?? false);
  }).toList();
  
  setState(() {
    _filteredClasses = filtered;
  });
}
  @override
  Widget build(BuildContext context) {
    int drawerIndex = 2;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AyannaColors.orange,
        foregroundColor: AyannaColors.white,
        title: const Text(
          'Classes',
          style: TextStyle(color: AyannaColors.white),
        ),
        iconTheme: const IconThemeData(color: AyannaColors.white),
        elevation: 2,
      ),
      drawer: AyannaDrawer(
        selectedIndex: drawerIndex,
        onItemSelected: (i) => setState(() => drawerIndex = i),
      ),
      backgroundColor: AyannaColors.lightGrey,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AyannaColors.orange, width: 2.0),
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(
                    color: AyannaColors.darkGrey,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Rechercher classes',
                    hintStyle: const TextStyle(color: Color(0xFF666666)),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AyannaColors.orange,
                    ),
                    filled: true,
                    fillColor: AyannaColors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 16,
                    ),
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage.isNotEmpty
                    ? Center(
                        child: Card(
                          color: Colors.red.withOpacity(0.1),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      )
                    : _filteredClasses.isEmpty
                    ? const Center(child: Text('Aucune classe trouvée.'))
                    : ListView.builder(
                        itemCount: _filteredClasses.length,
                        itemBuilder: (context, index) {
                          final classe = _filteredClasses[index];
                          final elevesCount =
                              _classeEleves[classe.id]?.length ?? 0;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ClassElevesScreen(classe: classe),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.school,
                                        color: AyannaColors.orange,
                                        size: 40,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              classe.nom,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Niveau: ${classe.niveau ?? 'N/A'}',
                                              style: const TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '$elevesCount',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                              color: AyannaColors.orange,
                                            ),
                                          ),
                                          const Text(
                                            'Élèves',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
