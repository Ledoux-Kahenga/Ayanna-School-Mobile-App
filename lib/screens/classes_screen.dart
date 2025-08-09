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

  void _onYearSelected(AnneeScolaire year) async {
    setState(() {
      _loading = true;
      _classes = [];
    });
    final classes = await SchoolQueries.getClassesByAnnee(year.id);
    setState(() {
      _classes = classes;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AyannaAppBar(title: 'Classes'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AyannaLogo(size: 60),
            const SizedBox(height: 16),
            SchoolYearSelector(onSelected: _onYearSelected),
            const SizedBox(height: 24),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_classes.isEmpty)
              const Center(child: Text('Aucune classe trouvée.'))
            else
              Expanded(
                child: ListView.separated(
                  itemCount: _classes.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, i) {
                    final c = _classes[i];
                    return ListTile(
                      title: Text(
                        c.nom,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      subtitle: c.niveau != null
                          ? Text('Niveau : ${c.niveau}')
                          : null,
                      leading: Icon(Icons.class_, color: AyannaTheme.primary),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ElevesScreen(classe: c),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
