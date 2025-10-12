import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../services/providers/data_provider.dart';

class FactureRecuWidget extends ConsumerWidget {
  final String eleve;
  final String classe;
  final String frais;
  final List<Map<String, String>> paiements; // [{date, montant, caissier}]
  final int totalPaye;
  final int reste;
  final String statut;

  const FactureRecuWidget({
    super.key,
    required this.eleve,
    required this.classe,
    required this.frais,
    required this.paiements,
    required this.totalPaye,
    required this.reste,
    required this.statut,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateGen = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    final entreprisesAsync = ref.watch(entreprisesNotifierProvider);

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Généré par Ayanna School - $dateGen',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 8),

              // Informations de l'entreprise depuis la base de données
              entreprisesAsync.when(
                data: (entreprises) {
                  final entreprise = entreprises.isNotEmpty
                      ? entreprises.first
                      : null;
                  return Column(
                    children: [
                      Center(
                        child: Text(
                          entreprise?.nom.toUpperCase() ?? 'AYANNA SCHOOL',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          entreprise?.adresse ??
                              '14 Av. Bunduki, Q. Plateau, C. Annexe',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Center(
                        child: Text(
                          entreprise?.telephone != null
                              ? 'Tél : ${entreprise!.telephone}'
                              : 'Tél : +243997554905',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Center(
                        child: Text(
                          entreprise?.email != null
                              ? 'Email : ${entreprise!.email}'
                              : 'Email : contact@ayannaschool.cd',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Column(
                  children: [
                    Center(child: CircularProgressIndicator()),
                    SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Chargement des informations...',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                error: (error, stack) => Column(
                  children: [
                    Center(
                      child: Text(
                        'AYANNA SCHOOL',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        '14 Av. Bunduki, Q. Plateau, C. Annexe',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Center(
                      child: Text(
                        'Tél : +243997554905',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Center(
                      child: Text(
                        'Email : contact@ayannaschool.cd',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 24, thickness: 1.2),
              Center(
                child: Text(
                  'REÇU FRAIS',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Theme.of(context).primaryColor,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Élève : $eleve', style: const TextStyle(fontSize: 16)),
              Text('Classe : $classe', style: const TextStyle(fontSize: 16)),
              Text('Frais : $frais', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 12),
              Text(
                'Paiements :',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(2),
                  },
                  children: [
                    const TableRow(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(6),
                          child: Text(
                            'Date',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(6),
                          child: Text(
                            'Montant',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(6),
                          child: Text(
                            'Caissier',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    ...paiements.map(
                      (p) => TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text(p['date'] ?? ''),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text(p['montant'] ?? ''),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text(p['caissier'] ?? ''),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Total payé :',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    '$totalPaye Fc',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Reste :',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    '$reste Fc',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Statut :',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    statut,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: statut == 'En ordre' ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Merci pour votre paiement.',
                  style: const TextStyle(
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
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
