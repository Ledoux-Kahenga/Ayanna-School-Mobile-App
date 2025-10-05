import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/ayanna_theme.dart';
import '../widgets/ayanna_appbar.dart';
import '../widgets/ayanna_widgets.dart';
import 'package:ayanna_school/models/entities/entities.dart';
import 'package:ayanna_school/services/providers/providers.dart';
import 'classe_eleves_screen.dart';
import '../widgets/ayanna_drawer.dart';

class ClassesScreen extends ConsumerStatefulWidget {
  final AnneeScolaire? anneeScolaire;
  const ClassesScreen({super.key, this.anneeScolaire});

  @override
  ConsumerState<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends ConsumerState<ClassesScreen> {
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
      // Get current annee scolaire from config or widget parameter
      AnneeScolaire? anneeScolaireAUtiliser = widget.anneeScolaire;

      // If no annee scolaire provided, get the current one from config
      if (anneeScolaireAUtiliser == null) {
        anneeScolaireAUtiliser = await ref.read(
          currentAnneeScolaireProvider.future,
        );
      }

      if (anneeScolaireAUtiliser != null) {
        // Get all classes and filter by annee scolaire
        final allClasses = await ref.read(classesNotifierProvider.future);
        final loadedClasses = allClasses
            .where(
              (classe) => classe.anneeScolaireId == anneeScolaireAUtiliser!.id,
            )
            .toList();

        final Map<int, List<Eleve>> classeEleves = {};

        // Get all eleves and filter by classe
        final allEleves = await ref.read(elevesNotifierProvider.future);
        for (final classe in loadedClasses) {
          if (classe.id != null) {
            final eleves = allEleves
                .where((eleve) => eleve.classeId == classe.id)
                .toList();
            classeEleves[classe.id!] = eleves;
          }
        }

        // Sort classes by name
        loadedClasses.sort((a, b) => a.nom.compareTo(b.nom));

        setState(() {
          _classes = loadedClasses;
          _classeEleves = classeEleves;
          _filteredClasses = loadedClasses;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des données: $e';
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
