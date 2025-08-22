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
      final yearId = await AppPreferences.getCurrentSchoolYearId();
      if (yearId == null) {
        setState(() {
          _loading = false;
          _errorMessage = 'Aucune année scolaire sélectionnée.';
        });
        return;
      }
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
      drawer: const AyannaDrawer(),
      backgroundColor: AyannaColors.lightGrey,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  'Liste des classes',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AyannaColors.orange,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                height: 60,
                decoration: BoxDecoration(
                  color: AyannaColors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AyannaColors.lightGrey.withOpacity(0.5),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
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
                      vertical: 20,
                      horizontal: 16,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AyannaColors.lightGrey,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AyannaColors.orange,
                        width: 2,
                      ),
                    ),
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
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      )
                    : _filteredClasses.isEmpty
                    ? const Center(child: Text('Aucune classe trouvée.'))
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1.1,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: _filteredClasses.length,
                        itemBuilder: (context, i) {
                          final c = _filteredClasses[i];
                          return Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            color: AyannaColors.white,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ClassElevesScreen(classe: c),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      c.nom,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AyannaColors.orange,
                                          ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (c.niveau != null) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        c.niveau!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: AyannaColors.darkGrey,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                    if (c.effectif != null) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        'Effectif : ${c.effectif}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AyannaColors.orange,
                                              fontWeight: FontWeight.bold,
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ],
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
