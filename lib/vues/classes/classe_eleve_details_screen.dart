import 'package:ayanna_school/models/frais_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../theme/ayanna_theme.dart';
import '../widgets/facture_recu_widget.dart';
import 'package:ayanna_school/models/entities/entities.dart';
import 'package:ayanna_school/services/providers/providers.dart';
import 'dart:async';
import '../../services/app_preferences.dart';
import '../../services/bluetooth_print_service.dart';
import '../widgets/bluetooth_printer_selector.dart';

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
  String _classeNom = '-'; // Nom de la classe de l'élève

  // Service d'impression Bluetooth
  final BluetoothPrintService _bluetoothService = BluetoothPrintService();

  @override
  void initState() {
    super.initState();
    print('📍 [ClasseEleveDetails] initState appelé');
    _fetchEleveDetails();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _printReceipt(Eleve eleve, FraisDetails fraisDetails) async {
    try {
      // Vérifier d'abord les permissions Bluetooth
      debugPrint('🔍 Vérification des permissions Bluetooth...');
      final hasPermissions = await _bluetoothService.checkPermissions();

      if (!hasPermissions) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Permissions Bluetooth requises pour l\'impression.\n'
                'Veuillez accorder les permissions et réessayer.',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      // Vérifier si une imprimante est connectée
      final isConnected = await _bluetoothService.isConnected();

      if (!isConnected) {
        // Afficher le sélecteur d'imprimante
        await _showPrinterSelector();
        return;
      }

      // Préparer les données des paiements
      final paiements = fraisDetails.historiquePaiements
          .map(
            (p) => {
              'date': DateFormat('dd/MM/yy').format(p.datePaiement),
              'montant': p.montantPaye.toStringAsFixed(0),
            },
          )
          .toList();

      // Récupérer les informations de l'entreprise depuis la base
      final entreprises = await ref.read(entreprisesNotifierProvider.future);
      final entreprise = entreprises.isNotEmpty ? entreprises.first : null;

      // Imprimer avec le service Bluetooth
      final success = await _bluetoothService.printReceipt(
        schoolName: entreprise?.nom.toUpperCase() ?? 'AYANNA SCHOOL',
        schoolAddress:
            entreprise?.adresse ?? '14 Av. Bunduki, Q. Plateau, C. Annexe',
        schoolPhone: entreprise?.telephone != null
            ? 'Tél : ${entreprise!.telephone}'
            : 'Tél : +243997554905',
        eleveName: '${eleve.prenomCapitalized} ${eleve.nomPostnomMaj}',
        classe: _classeNom,
        matricule: eleve.matricule ?? '',
        fraisName: fraisDetails.nomFrais,
        paiements: paiements,
        montantTotal: fraisDetails.montant,
        totalPaye: fraisDetails.totalPaye,
        resteAPayer: fraisDetails.restePayer,
        devise: entreprise?.devise,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Reçu envoyé à l\'imprimante'
                  : 'Erreur lors de l\'impression',
            ),
            backgroundColor: success ? AyannaColors.successGreen : Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Erreur impression: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _showPrinterSelector() async {
    // Vérifier les permissions avant d'ouvrir le sélecteur
    final hasPermissions = await _bluetoothService.checkPermissions();

    if (!hasPermissions) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Permissions Bluetooth requises.\n'
              'Veuillez accorder les permissions dans les paramètres et réessayer.',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: BluetoothPrinterSelector(
            onPrinterSelected: (macAddress) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Imprimante connectée! Vous pouvez maintenant imprimer.',
                  ),
                  backgroundColor: AyannaColors.successGreen,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _fetchEleveDetails() async {
    try {
      // Charger le nom de la classe de l'élève
      if (widget.eleve.classeId != null) {
        final classes = await ref.read(classesNotifierProvider.future);
        final classe = classes.firstWhere(
          (c) => c.id == widget.eleve.classeId,
          orElse: () => Classe(
            nom: '-',
            niveau: '-',
            anneeScolaireId: 0,
            dateCreation: DateTime.now(),
            dateModification: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        _classeNom = classe.nom;
      }

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
    // Determine enterprise currency for this card (fallback to AppPreferences)
    String devise = AppPreferences().devise;
    try {
      final entreprisesAsync = ref.watch(entreprisesNotifierProvider);
      if (entreprisesAsync.hasValue) {
        final list = entreprisesAsync.value!;
        if (list.isNotEmpty &&
            list.first.devise != null &&
            list.first.devise!.isNotEmpty) {
          devise = list.first.devise!;
        }
      }
    } catch (_) {}

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
                    '${frais.montant.toStringAsFixed(0)} $devise',
                    Icons.account_balance_wallet,
                  ),
                ),
                Expanded(
                  child: _buildFinanceInfo(
                    'Payé',
                    '${fraisDetail.montantPaye.toStringAsFixed(0)} $devise',
                    Icons.payments,
                  ),
                ),
                Expanded(
                  child: _buildFinanceInfo(
                    'Reste',
                    '${fraisDetail.resteAPayer.toStringAsFixed(0)} $devise',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (fraisDetail.montantPaye > 0)
                  ElevatedButton.icon(
                    icon: fraisDetail.showRecu
                        ? const Icon(Icons.print)
                        : const Icon(Icons.receipt_long),
                    label: Text(fraisDetail.showRecu ? 'Imprimer' : 'Facture'),
                    onPressed: () async {
                      if (!fraisDetail.showRecu) {
                        setState(() {
                          fraisDetail.showRecu = true;
                        });
                      } else {
                        await _printReceipt(widget.eleve, fraisDetail);
                      }
                    },
                  ),
              ],
            ),
            if (fraisDetail.showRecu)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: FactureRecuWidget(
                  eleve: '${widget.eleve.prenom} ${widget.eleve.nom}',
                  classe: _classeNom,
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
                  prefixIcon: Icon(Icons.payments),
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

                  // Enregistrer le paiement avec écritures comptables automatiques
                  print(
                    '💳 Enregistrement paiement avec écritures comptables...',
                  );
                  await ref
                      .read(paiementsFraisNotifierProvider.notifier)
                      .enregistrerPaiementAvecEcritures(
                        eleveId: widget.eleve.id!,
                        fraisId: fraisDetail.fraisId,
                        montant: montant,
                        userId: userId,
                      );

                  Navigator.of(context).pop();
                  await _fetchEleveDetails();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Paiement enregistré avec succès'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
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

class FactureReceiptWidget extends StatelessWidget {
  final Eleve eleve;
  final FraisDetails fraisDetails;

  const FactureReceiptWidget({
    Key? key,
    required this.eleve,
    required this.fraisDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Attempt to get entreprise devise for receipt
    String devise = AppPreferences().devise;
    try {
      final container = ProviderScope.containerOf(context);
      final entreprisesAsync = container.read(entreprisesNotifierProvider);
      if (entreprisesAsync.hasValue) {
        final list = entreprisesAsync.value!;
        if (list.isNotEmpty) devise = list.first.devise ?? devise;
      }
    } catch (_) {}
    // Format date simple SANS locale lourde
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    return SizedBox(
      width: 384,
      child: Material(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // En-tête simple
              const Text(
                'Ayanna School',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 4),
              const Text(
                'RECU DE PAIEMENT',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Infos élève (alignées à gauche)
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Eleve: ${eleve.nomPostnomMaj} ${eleve.prenomCapitalized}',
                      style: const TextStyle(fontSize: 8),
                    ),
                    Text(
                      'Classe: ${eleve.classeNom ?? "-"}',
                      style: const TextStyle(fontSize: 8),
                    ),
                    Text(
                      'Frais: ${fraisDetails.frais.nom}',
                      style: const TextStyle(fontSize: 8),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Titre paiements
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Paiements:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9),
                ),
              ),
              const SizedBox(height: 4),

              // En-têtes SANS Container/Colors.grey
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        'Date',
                        style: TextStyle(
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      child: Text(
                        'Montant',
                        style: TextStyle(
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: Text(
                        'Par',
                        style: TextStyle(
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Lignes SIMPLIFIÉES
              ...fraisDetails.historiquePaiements.map((p) {
                final pDate = p.datePaiement;
                final pDateStr =
                    '${pDate.day.toString().padLeft(2, '0')}/${pDate.month.toString().padLeft(2, '0')}/${pDate.year}';
                final montant = p.montantPaye.toStringAsFixed(0);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          pDateStr,
                          style: const TextStyle(fontSize: 7),
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: Text(
                          montant,
                          style: const TextStyle(fontSize: 7),
                        ),
                      ),
                      const SizedBox(
                        width: 80,
                        child: Text('Admin', style: TextStyle(fontSize: 7)),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 8),

              // Totaux SIMPLIFIÉS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${fraisDetails.montantPaye.toStringAsFixed(0)} $devise',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Reste:',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${fraisDetails.resteAPayer.toStringAsFixed(0)} $devise',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Footer
              const Text('Merci', style: TextStyle(fontSize: 8)),
              const SizedBox(height: 4),
              Text(
                'Ayanna School - $dateStr',
                style: const TextStyle(fontSize: 6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
