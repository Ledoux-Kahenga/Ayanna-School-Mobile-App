import 'package:flutter/material.dart';
import '../widgets/ayanna_appbar.dart';
import '../widgets/ayanna_widgets.dart';
import '../widgets/school_year_selector.dart';
import '../services/school_queries.dart';
import '../models/models.dart';
import '../ayanna_theme.dart';
import 'eleves_screen.dart';

class ClassesScreen extends StatefulWidget {
  const ClassesScreen({super.key});

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  List<Classe> _classes = [];
  bool _loading = false;
  String _errorMessage = '';

  void _onYearSelected(AnneeScolaire year) async {
    setState(() {
      _loading = true;
      _classes = [];
      _errorMessage = '';
    });

    try {
      final classes = await SchoolQueries.getClassesByAnnee(year.id);
      setState(() {
        _classes = classes;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = 'Erreur lors du chargement des classes: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AyannaAppBar(title: 'Classes'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              // En-tête compact
              Row(
                children: [
                  const AyannaLogo(size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SchoolYearSelector(onSelected: _onYearSelected),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Zone de contenu
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage.isNotEmpty
                    ? Center(
                        child: Card(
                          color: Colors.red.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              _errorMessage,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),
                        ),
                      )
                    : _classes.isEmpty
                    ? const Center(child: Text('Aucune classe trouvée.'))
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1.2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                        itemCount: _classes.length,
                        itemBuilder: (context, i) {
                          final c = _classes[i];
                          return Card(
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ElevesScreen(classe: c),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AyannaTheme.primary,
                                      radius: 24,
                                      child: const Icon(
                                        Icons.class_,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      c.nom,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (c.niveau != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        c.niveau!,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
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
