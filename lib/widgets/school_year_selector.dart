import 'package:flutter/material.dart';
import '../services/school_queries.dart';
import '../models/models.dart';

class SchoolYearSelector extends StatefulWidget {
  final void Function(AnneeScolaire) onSelected;
  const SchoolYearSelector({required this.onSelected, super.key});

  @override
  State<SchoolYearSelector> createState() => _SchoolYearSelectorState();
}

class _SchoolYearSelectorState extends State<SchoolYearSelector> {
  List<AnneeScolaire> _annees = [];
  AnneeScolaire? _selected;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchAnnees();
  }

  Future<void> _fetchAnnees() async {
    final annees = await SchoolQueries.getAllAnneesScolaires();
    final current = await SchoolQueries.getCurrentAnneeScolaire();
    setState(() {
      _annees = annees;
      _selected = current ?? (annees.isNotEmpty ? annees.first : null);
      _loading = false;
    });
    if (_selected != null) widget.onSelected(_selected!);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Année scolaire en cours',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButton<AnneeScolaire>(
          value: _selected,
          isExpanded: true,
          items: _annees
              .map((a) => DropdownMenuItem(value: a, child: Text(a.nom)))
              .toList(),
          onChanged: (a) {
            setState(() => _selected = a);
            if (a != null) widget.onSelected(a);
          },
        ),
      ],
    );
  }
}
