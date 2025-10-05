import 'package:ayanna_school/models/frais_details.dart';
import 'package:ayanna_school/services/pdf_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../theme/ayanna_theme.dart';
import '../widgets/facture_recu_widget.dart';
import 'package:printing/printing.dart';
import 'package:ayanna_school/models/entities/entities.dart';
import 'package:ayanna_school/services/providers/providers.dart';

class ClasseEleveDetailsScreen extends ConsumerStatefulWidget {
  final Eleve eleve;
  final FraisScolaire? frais;
  const ClasseEleveDetailsScreen({
    required this.eleve,
    this.frais, // Ajoutez ce paramètre au constructeur
    super.key,
  });

  @override
  ConsumerState<ClasseEleveDetailsScreen> createState() =>
      _ClasseEleveDetailsScreenState();
}

class _ClasseEleveDetailsScreenState
    extends ConsumerState<ClasseEleveDetailsScreen> {
  List<FraisDetails> _fraisDetails = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchEleveDetails();
  }

  Future<void> _fetchEleveDetails() async {
    try {
      // Get all frais scolaires
      final allFrais = await ref.read(fraisScolairesNotifierProvider.future);

      // Get all paiements for this eleve
      final allPaiements = await ref.read(
        paiementsFraisNotifierProvider.future,
      );
      final elevePaiements = widget.eleve.id != null
          ? allPaiements
                .where((paiement) => paiement.eleveId == widget.eleve.id)
                .toList()
          : [];

      // Create FraisDetails for each frais scolaire
      final List<FraisDetails> fraisDetails = [];
      for (final frais in allFrais) {
        final paiementsPourCeFrais = elevePaiements
            .where((paiement) => paiement.fraisScolaireId == frais.id)
            .toList();

        final totalPaye = paiementsPourCeFrais.fold<double>(
          0.0,
          (sum, paiement) => sum + paiement.montantPaye,
        );
        final restePayer = frais.montant - totalPaye;
        final statut = restePayer <= 0
            ? 'Payé'
            : (totalPaye > 0 ? 'Partiellement payé' : 'Non payé');

        final fraisDetail = FraisDetails(
          fraisId: frais.id ?? 0,
          nomFrais: frais.nom,
          montant: frais.montant,
          totalPaye: totalPaye,
          restePayer: restePayer,
          statut: statut,
          historiquePaiements: paiementsPourCeFrais.cast<PaiementFrais>(),
        );
        fraisDetails.add(fraisDetail);
      }

      setState(() {
        _fraisDetails = fraisDetails;
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
      appBar: AppBar(
        backgroundColor: AyannaColors.orange,
        foregroundColor: AyannaColors.white,
        title: Text(
          'Tous les frais',
          style: const TextStyle(
            color: AyannaColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: AyannaColors.white),
        elevation: 2,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
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
                  ..._fraisDetails.map(
                    (fraisDetail) => _buildFraisCard(fraisDetail),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard() {
    final eleve = widget.eleve;
    return Card(
      color: AyannaColors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${eleve.nom.toUpperCase()} ${eleve.postnom} ${eleve.prenom} ',
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

    return StatefulBuilder(
      builder: (context, setState) {
        bool showRecu = false;
        return Card(
          color: AyannaColors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
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
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...fraisDetail.historiquePaiements.map(
                    (paiement) => _buildPaiementHistoryItem(paiement),
                  ),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (fraisDetail.montantPaye > 0)
                      ElevatedButton.icon(
                        icon: const Icon(Icons.receipt_long),
                        label: const Text('Facture'),
                        onPressed: () {
                          setState(() {
                            showRecu = true;
                          });
                        },
                      ),
                    if (showRecu) const SizedBox(width: 8),
                    if (showRecu)
                      ElevatedButton.icon(
                        icon: const Icon(Icons.print),
                        label: const Text('Imprimer'),
                        onPressed: () async {
                          final pdfBytes = await PdfService.generateRecuPdf(
                            fraisDetail,
                            widget.eleve,
                            entrepriseNom: 'Ayanna School',
                            devise: 'CDF',
                          );
                          await Printing.layoutPdf(
                            onLayout: (format) async => pdfBytes,
                          );

                          // await Printing.layoutPdf(
                          //   onLayout: (format) async {
                          //     final doc = pw.Document();
                          //     doc.addPage(
                          //       pw.Page(
                          //         build: (pw.Context context) {
                          //           return pw.Column(
                          //             crossAxisAlignment:
                          //                 pw.CrossAxisAlignment.start,
                          //             children: [
                          //               pw.Text(
                          //                 'Généré par Ayanna School - ${DateTime.now()}',
                          //               ),
                          //               pw.Text('Default School'),
                          //               pw.Text(
                          //                 '14 Av. Bunduki, Q. Plateau, C. Annexe',
                          //               ),
                          //               pw.Text('Tél : +243997554905'),
                          //               pw.Text('Email : comtact@school.com'),
                          //               pw.Divider(),
                          //               pw.Text(
                          //                 'REÇU FRAIS',
                          //                 style: pw.TextStyle(
                          //                   fontSize: 20,
                          //                   fontWeight: pw.FontWeight.bold,
                          //                 ),
                          //               ),
                          //               pw.Text(
                          //                 'Élève : ${widget.eleve.prenom} ${widget.eleve.nom}',
                          //               ),
                          //               pw.Text(
                          //                 'Classe : ${widget.eleve.classeNom ?? "-"}',
                          //               ),
                          //               pw.Text('Frais : ${frais.nom}'),
                          //               pw.Text('Paiements :'),
                          //               pw.Table.fromTextArray(
                          //                 headers: [
                          //                   'Date',
                          //                   'Montant',
                          //                   'Caissier',
                          //                 ],
                          //                 data: fraisDetail.historiquePaiements
                          //                     .map(
                          //                       (p) => [
                          //                         p.datePaiement,
                          //                         p.montantPaye
                          //                             .toStringAsFixed(0),
                          //                         'Admin',
                          //                       ],
                          //                     )
                          //                     .toList(),
                          //               ),
                          //               pw.Text(
                          //                 'Total payé : ${fraisDetail.montantPaye.toInt()} Fc',
                          //               ),
                          //               pw.Text(
                          //                 'Reste : ${fraisDetail.resteAPayer.toInt()} Fc',
                          //               ),
                          //               pw.Text('Statut : $statusText'),
                          //               pw.SizedBox(height: 16),
                          //               pw.Text(
                          //                 'Merci pour votre paiement.',
                          //                 style: pw.TextStyle(
                          //                   fontStyle: pw.FontStyle.italic,
                          //                 ),
                          //               ),
                          //             ],
                          //           );
                          //         },
                          //       ),
                          //     );
                          //     return doc.save();
                          //   },
                          // );

                          setState(() {
                            showRecu = false;
                          });
                        },
                      ),
                  ],
                ),
                if (showRecu)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: FactureRecuWidget(
                      eleve: '${widget.eleve.prenom} ${widget.eleve.nom}',
                      classe: widget.eleve.classeNom ?? '-',
                      frais: frais.nom,
                      paiements: fraisDetail.historiquePaiements
                          .map(
                            (p) => {
                              'date': DateFormat(
                                'dd/MM/yyyy',
                              ).format(p.datePaiement),
                              'montant': p.montantPaye.toStringAsFixed(0),
                              'caissier': 'Admin',
                            },
                          )
                          .toList(),
                      totalPaye: fraisDetail.montantPaye.toInt(),
                      reste: fraisDetail.resteAPayer.toInt(),
                      statut: statusText,
                    ),
                  ),
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
      },
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
            DateFormat('dd/MM/yyyy').format(paiement.datePaiement),
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
                  // Get current user ID from auth state
                  final authState = await ref.read(authNotifierProvider.future);
                  final userId = authState.userId;

                  // Create new payment
                  final now = DateTime.now();
                  final nouveauPaiement = PaiementFrais(
                    id: null,
                    serverId: null,
                    isSync: false,
                    eleveId: widget.eleve.id!,
                    fraisScolaireId: fraisDetail.fraisId,
                    montantPaye: montant,
                    datePaiement: now,
                    userId: userId,
                    resteAPayer: montantRestant - montant,
                    statut: (montantRestant - montant) <= 0
                        ? 'Payé'
                        : 'Partiellement payé',
                    dateCreation: now,
                    dateModification: now,
                    updatedAt: now,
                  );

                  // Add payment using the provider
                  await ref
                      .read(paiementsFraisNotifierProvider.notifier)
                      .addPaiementFrais(nouveauPaiement);

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
