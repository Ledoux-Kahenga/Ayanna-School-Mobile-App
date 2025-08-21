import 'package:flutter/material.dart';
import '../theme/ayanna_theme.dart';
import '../widgets/ayanna_appbar.dart';
import '../services/school_queries.dart';
import '../models/models.dart';

class EleveDetailsScreen extends StatefulWidget {
  final Eleve eleve;
  const EleveDetailsScreen({required this.eleve, super.key});

  @override
  State<EleveDetailsScreen> createState() => _EleveDetailsScreenState();
}

class _EleveDetailsScreenState extends State<EleveDetailsScreen> {
  EleveFraisDetails? _eleveDetails;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchEleveDetails();
  }

  Future<void> _fetchEleveDetails() async {
    try {
      final details = await SchoolQueries.getEleveFraisDetails(widget.eleve.id);
      setState(() {
        _eleveDetails = details;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AyannaColors.lightGrey,
      appBar: AyannaAppBar(title: '${widget.eleve.prenom} ${widget.eleve.nom}'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _eleveDetails == null
          ? const Center(child: Text('Impossible de charger les détails'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 16),
                  Text(
                    'Frais scolaires',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AyannaColors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._eleveDetails!.fraisDetails.map(
                    (fraisDetail) => _buildFraisCard(fraisDetail),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard() {
    final eleve = _eleveDetails!.eleve;
    return Card(
      color: AyannaColors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AyannaColors.orange.withOpacity(0.15),
                  child: Text(
                    '${eleve.prenom[0]}${eleve.nom[0]}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AyannaColors.orange,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${eleve.prenom} ${eleve.nom}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AyannaColors.darkGrey,
                        ),
                      ),
                      if (eleve.matricule != null)
                        Text(
                          'Matricule: ${eleve.matricule}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      if (eleve.sexe != null)
                        Text(
                          'Sexe: ${eleve.sexe}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFraisCard(FraisDetails fraisDetail) {
    final frais = fraisDetail.frais;
    final isEnOrdre = fraisDetail.isEnOrdre;
    final isPartiellementPaye = fraisDetail.isPartiellementPaye;

    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (isEnOrdre) {
      statusColor = AyannaColors.successGreen;
      statusIcon = Icons.check_circle;
      statusText = 'En ordre';
    } else if (isPartiellementPaye) {
      statusColor = AyannaColors.orange;
      statusIcon = Icons.schedule;
      statusText = 'Partiellement payé';
    } else {
      statusColor = Colors.red;
      statusIcon = Icons.warning;
      statusText = 'Pas en ordre';
    }

    return Card(
      color: AyannaColors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    frais.nom,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AyannaColors.orange,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(color: statusColor, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildFinanceInfo(
                    'Montant total',
                    frais.montant.toStringAsFixed(0),
                    Icons.attach_money,
                  ),
                ),
                Expanded(
                  child: _buildFinanceInfo(
                    'Payé',
                    fraisDetail.montantPaye.toStringAsFixed(0),
                    Icons.payments,
                  ),
                ),
                Expanded(
                  child: _buildFinanceInfo(
                    'Reste',
                    fraisDetail.resteAPayer.toStringAsFixed(0),
                    Icons.pending_actions,
                  ),
                ),
              ],
            ),
            if (fraisDetail.historiquePaiements.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Historique des paiements',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...fraisDetail.historiquePaiements.map(
                (paiement) => _buildPaiementHistoryItem(paiement),
              ),
            ],
            if (!isEnOrdre) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showPaiementDialog(fraisDetail),
                  icon: const Icon(Icons.payment),
                  label: Text(
                    isPartiellementPaye
                        ? 'Compléter le paiement'
                        : 'Effectuer un paiement',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AyannaColors.orange,
                    foregroundColor: AyannaColors.white,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFinanceInfo(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: AyannaColors.orange),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AyannaColors.darkGrey,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AyannaColors.darkGrey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPaiementHistoryItem(PaiementFrais paiement) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.receipt, size: 16, color: AyannaColors.orange),
          const SizedBox(width: 8),
          Text(
            paiement.datePaiement,
            style: const TextStyle(fontSize: 12, color: AyannaColors.darkGrey),
          ),
          const Spacer(),
          Text(
            '+${paiement.montantPaye.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AyannaColors.successGreen,
            ),
          ),
        ],
      ),
    );
  }

  void _showPaiementDialog(FraisDetails fraisDetail) {
    final TextEditingController montantController = TextEditingController();
    final montantRestant = fraisDetail.resteAPayer;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Paiement - ${fraisDetail.frais.nom}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Reste à payer: ${montantRestant.toStringAsFixed(0)}'),
              const SizedBox(height: 16),
              TextField(
                controller: montantController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Montant à payer',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                final montantText = montantController.text.trim();
                if (montantText.isEmpty) return;

                final montant = double.tryParse(montantText);
                if (montant == null || montant <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Montant invalide')),
                  );
                  return;
                }

                if (montant > montantRestant) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Montant supérieur au reste à payer'),
                    ),
                  );
                  return;
                }

                try {
                  await SchoolQueries.enregistrerPaiement(
                    eleveId: widget.eleve.id,
                    fraisId: fraisDetail.frais.id,
                    montant: montant,
                  );

                  Navigator.of(context).pop();
                  _fetchEleveDetails(); // Recharger les données

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Paiement enregistré avec succès'),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
                }
              },
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }
}
