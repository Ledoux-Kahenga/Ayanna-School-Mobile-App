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
  const ClassesScreen({super.key});

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
    _loadClassesAndEleves();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadClassesAndEleves() async {
    setState(() {
      _loading = true;
      _classes = [];
      _filteredClasses = [];
      _classeEleves = {};
      _errorMessage = '';
    });
    try {
      // Fetching classes for the current school year.
      final yearId = 1;
      final classes = await SchoolQueries.getClassesByAnnee(yearId);
      final Map<int, List<Eleve>> classeEleves = {};
      for (final classe in classes) {
        final eleves = await SchoolQueries.getElevesByClasse(classe.id);
        classeEleves[classe.id] = eleves;
      }
      setState(() {
        _classes = classes;
        _classeEleves = classeEleves;
        _filteredClasses = classes;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = 'Erreur lors du chargement des classes: $e';
      });
    }
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
      final eleves = _classeEleves[classe.id] ?? [];
      return eleves.any(
        (e) =>
            e.nom.toLowerCase().contains(query) ||
            e.prenom.toLowerCase().contains(query) ||
            (e.matricule?.toLowerCase().contains(query) ?? false),
      );
    }).toList();
    setState(() {
      _filteredClasses = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    int _drawerIndex = 2;
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
        selectedIndex: _drawerIndex,
        onItemSelected: (i) => setState(() => _drawerIndex = i),
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
                    bottom: BorderSide(
                      color: AyannaColors.orange,
                      width: 2.0,
                    ),
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(
                    color: AyannaColors.darkGrey,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Rechercher un élève (nom, prénom, matricule)',
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
                            : SingleChildScrollView(
                                child: Table(
                                  columnWidths: const {
                                    0: FlexColumnWidth(1), // Nouvelle colonne N°
                                    1: FlexColumnWidth(2),
                                    2: FlexColumnWidth(2),
                                    3: FlexColumnWidth(2),
                                  },
                                  border: TableBorder.all(
                                    color: AyannaColors.lightGrey.withOpacity(0.5),
                                    width: 1,
                                  ),
                                  children: [
                                    TableRow(
                                      decoration: const BoxDecoration(
                                        color: AyannaColors.orange,
                                      ),
                                      children: const [
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            'N°', // Nouvel en-tête N°
                                            style: TextStyle(
                                              color: AyannaColors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            'Classe',
                                            style: TextStyle(
                                              color: AyannaColors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            'Niveau',
                                            style: TextStyle(
                                              color: AyannaColors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            'Effectif',
                                            style: TextStyle(
                                              color: AyannaColors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    ..._filteredClasses.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final c = entry.value;
                                      return TableRow(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (_) => ClassElevesScreen(classe: c),
                                                ),
                                              );
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                                              child: Text('${index + 1}'), // Numéro de la ligne
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (_) => ClassElevesScreen(classe: c),
                                                ),
                                              );
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                                              child: Text(c.nom),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (_) => ClassElevesScreen(classe: c),
                                                ),
                                              );
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                                              child: Text(c.niveau ?? 'N/A'),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (_) => ClassElevesScreen(classe: c),
                                                ),
                                              );
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                                              child: Text('${c.effectif ?? 0}'),
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}