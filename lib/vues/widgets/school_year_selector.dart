import 'package:flutter/material.dart';
import '../../services/school_queries.dart';
import '../../models/models.dart';

class SchoolYearSelector extends StatefulWidget {
  final void Function(AnneeScolaire) onSelected;
  const SchoolYearSelector({required this.onSelected, super.key});

  @override
  State<SchoolYearSelector> createState() => _SchoolYearSelectorState();
}

class _SchoolYearSelectorState extends State<SchoolYearSelector> {
  List<AnneeScolaire> _annees = [];
  int? _selectedId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchAnnees();
  }

  Future<void> _fetchAnnees() async {
    try {
      final annees = await SchoolQueries.getAllAnneesScolaires();
      final current = await SchoolQueries.getCurrentAnneeScolaire();

      setState(() {
        _annees = annees;
        _selectedId =
            current?.id ?? (annees.isNotEmpty ? annees.first.id : null);
        _loading = false;
      });

      if (_selectedId != null) {
        final selectedAnnee = _annees.firstWhere((a) => a.id == _selectedId);
        widget.onSelected(selectedAnnee);
      }
    } catch (e) {
      setState(() {
        _loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des années: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_annees.isEmpty) {
      return const Text('Aucune année trouvée');
    }

    return DropdownButtonFormField<int>(
      value: _selectedId,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Année scolaire',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        isDense: true,
      ),
      items: _annees
          .map(
            (annee) => DropdownMenuItem<int>(
              value: annee.id,
              child: Text(annee.nom, style: const TextStyle(fontSize: 14)),
            ),
          )
          .toList(),
      onChanged: (int? newId) {
        if (newId != null) {
          setState(() {
            _selectedId = newId;
          });
          final selectedAnnee = _annees.firstWhere((a) => a.id == newId);
          widget.onSelected(selectedAnnee);
        }
      },
    );
  }
}
