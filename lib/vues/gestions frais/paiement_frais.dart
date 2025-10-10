import 'package:ayanna_school/models/entities/annee_scolaire.dart';
import 'package:ayanna_school/models/entities/paiement_frais.dart';
import 'package:ayanna_school/models/frais_details.dart';
import 'package:ayanna_school/services/app_preferences.dart';
import 'package:ayanna_school/vues/widgets/facture_recu_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../theme/ayanna_theme.dart';
import '../widgets/ayanna_drawer.dart';
import '../../models/entities/eleve.dart' as entities;
import '../../services/providers/providers.dart';
import '../../services/bluetooth_print_service.dart';
import '../widgets/bluetooth_printer_selector.dart';

class PaiementDesFrais extends ConsumerStatefulWidget {
  final AnneeScolaire? anneeScolaire;
  const PaiementDesFrais({super.key, this.anneeScolaire});

  @override
  ConsumerState<PaiementDesFrais> createState() => _PaiementDesFraisState();
}

class _PaiementDesFraisState extends ConsumerState<PaiementDesFrais> {
  bool _loading = false;
  String _errorMessage = '';
  final TextEditingController _searchController = TextEditingController();
  entities.Eleve? _selectedEleve;
  List<FraisDetails> _fraisDetails = [];

  // Map pour stocker les noms des classes (classeId -> nom de classe)
  final Map<int, String> _classesNoms = {};

  // Service d'impression Bluetooth
  final BluetoothPrintService _bluetoothService = BluetoothPrintService();

  @override
  void initState() {
    super.initState();
    print('📍 [PaiementFrais] initState appelé');
    _initData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _printReceipt(
    entities.Eleve eleve,
    FraisDetails fraisDetails,
  ) async {
    try {
      // Vérifier d'abord si une imprimante est connectée
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

      // Imprimer avec le service Bluetooth
      final success = await _bluetoothService.printReceipt(
        schoolName: 'AYANNA SCHOOL',
        schoolAddress: '14 Av. Bunduki, Q. Plateau, C. Annexe',
        schoolPhone: 'Tél : +243997554905',
        eleveName: '${eleve.prenomCapitalized} ${eleve.nomPostnomMaj}',
        classe: _classesNoms[eleve.classeId] ?? '-',
        matricule: eleve.matricule ?? '',
        fraisName: fraisDetails.frais.nom,
        paiements: paiements,
        montantTotal: fraisDetails.montant,
        totalPaye: fraisDetails.montantPaye,
        resteAPayer: fraisDetails.resteAPayer,
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

  Future<void> _initData() async {
    setState(() {
      _loading = true;
      _errorMessage = '';
      _selectedEleve = null;
      _fraisDetails = [];
    });
    try {
      // Charger les noms des classes
      await _loadClassesNoms();
      // No need to load élèves here since we're using reactive data fetching
      // The reactive provider will handle loading élèves
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // Méthode pour charger les noms des classes
  Future<void> _loadClassesNoms() async {
    try {
      final classes = await ref.read(classesNotifierProvider.future);
      setState(() {
        _classesNoms.clear();
        for (final classe in classes) {
          if (classe.id != null) {
            _classesNoms[classe.id!] = classe.nom;
          }
        }
      });
    } catch (e) {
      debugPrint('Erreur lors du chargement des classes: $e');
    }
  }

  Future<void> _loadFraisForEleve(entities.Eleve eleve) async {
    setState(() {
      _selectedEleve = eleve;
      _fraisDetails = [];
      _loading = true;
    });
    try {
      final details = await ref
          .read(paiementsFraisNotifierProvider.notifier)
          .getEleveFraisDetails(eleve.id!);
      setState(() {
        _fraisDetails = details;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = 'Erreur lors du chargement des frais: $e';
      });
    }
  }

  Future<String> formatAmount(double amount) async {
    final devise = AppPreferences().devise;
    // Utilise NumberFormat pour un formatage propre
    final format = NumberFormat("#,##0", "fr_FR");
    return '${format.format(amount)} $devise';
  }

  @override
  Widget build(BuildContext context) {
    int drawerIndex = 0;
    return WillPopScope(
      onWillPop: () async {
        if (_selectedEleve != null) {
          // Si on est sur la vue des frais, le bouton de retour doit revenir à la liste des élèves
          setState(() {
            _selectedEleve = null;
            _fraisDetails = [];
          });
          return false; // Empêche l'application de se fermer
        } else {
          // Si on est sur la liste des élèves (premier niveau), on peut demander une confirmation de sortie
          final shouldExit = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Quitter l'application"),
              content: const Text(
                "Voulez-vous vraiment quitter Ayanna School ?",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AyannaColors.orange,
                  ),
                  child: const Text('Quitter'),
                ),
              ],
            ),
          );
          return shouldExit ?? false;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AyannaColors.orange,
          foregroundColor: AyannaColors.white,
          title: const Text(
            'Paiement frais',
            style: TextStyle(color: AyannaColors.white),
          ),
          iconTheme: const IconThemeData(color: AyannaColors.white),
          actions: [
            IconButton(
              onPressed: _showPrinterSelector,
              icon: const Icon(Icons.print),
              tooltip: 'Configurer imprimante',
            ),
          ],
        ),
        drawer: AyannaDrawer(
          selectedIndex: drawerIndex,
          onItemSelected: (i) => setState(() => drawerIndex = i),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                if (_selectedEleve == null)
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
                      onChanged: (value) {
                        setState(() {
                          // Déclenche la reconstruction pour filtrer la liste
                        });
                      },
                      style: const TextStyle(
                        color: AyannaColors.darkGrey,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Rechercher un élève (nom, prénom)',
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
                if (_loading)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_errorMessage.isNotEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  )
                else if (_selectedEleve == null)
                  Expanded(
                    child: Consumer(
                      builder: (context, ref, child) {
                        final elevesAsync = ref.watch(elevesNotifierProvider);

                        return elevesAsync.when(
                          data: (allEleves) {
                            List<entities.Eleve> filtered;

                            if (_searchController.text.trim().isEmpty) {
                              filtered = allEleves;
                            } else {
                              final query = _searchController.text
                                  .trim()
                                  .toLowerCase();
                              filtered = allEleves
                                  .where(
                                    (e) =>
                                        e.nom.toLowerCase().contains(query) ||
                                        e.prenom.toLowerCase().contains(
                                          query,
                                        ) ||
                                        (e.matricule?.toLowerCase().contains(
                                              query,
                                            ) ??
                                            false),
                                  )
                                  .toList();
                            }

                            // Tri alphabétique
                            filtered.sort((a, b) {
                              final nomCmp = a.nom.toLowerCase().compareTo(
                                b.nom.toLowerCase(),
                              );
                              if (nomCmp != 0) return nomCmp;
                              return a.prenom.toLowerCase().compareTo(
                                b.prenom.toLowerCase(),
                              );
                            });

                            if (filtered.isEmpty) {
                              return const Center(
                                child: Text('Aucun élève trouvé.'),
                              );
                            }

                            return ListView.separated(
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) => Divider(
                                height: 1,
                                thickness: 0.7,
                                color: AyannaColors.lightGrey,
                                indent: 16,
                                endIndent: 16,
                              ),
                              itemBuilder: (context, i) {
                                final e = filtered[i];
                                return Card(
                                  margin: EdgeInsets.zero,
                                  elevation: 0,
                                  shape: const RoundedRectangleBorder(),
                                  color: AyannaColors.white,
                                  child: ListTile(
                                    dense: true,
                                    leading: CircleAvatar(
                                      radius: 20,
                                      backgroundColor: AyannaColors.orange
                                          .withOpacity(0.15),
                                      child: Text(
                                        e.prenom.isNotEmpty && e.nom.isNotEmpty
                                            ? '${e.prenom[0]}${e.nom[0]}'
                                            : '?',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AyannaColors.orange,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      '${e.nom.toUpperCase()}${e.postnom != null && e.postnom!.isNotEmpty ? ' ${e.postnom!.toUpperCase()}' : ''} ${e.prenomCapitalized}',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: AyannaColors.darkGrey,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (e.matricule != null)
                                          Text(
                                            'Mat: ${e.matricule}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF666666),
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Classe : ${_classesNoms[e.classeId] ?? "-"}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AyannaColors.orange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: AyannaColors.orange,
                                    ),
                                    shape: const RoundedRectangleBorder(),
                                    onTap: () => _loadFraisForEleve(e),
                                  ),
                                );
                              },
                            );
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (error, stack) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error,
                                  size: 64,
                                  color: Colors.red,
                                ),
                                const SizedBox(height: 16),
                                Text('Erreur: $error'),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    ref.invalidate(elevesNotifierProvider);
                                  },
                                  child: const Text('Réessayer'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                else ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, bottom: 2.0),
                    child: Text(
                      _selectedEleve!.prenomCapitalized,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AyannaColors.darkGrey,
                        fontSize: 22,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      _selectedEleve!.nomPostnomMaj,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AyannaColors.orange,
                        fontSize: 26,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (_selectedEleve!.matricule != null)
                    Column(
                      children: [
                        Text(
                          'Matricule : ${_selectedEleve!.matricule!}',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Classe : ${_classesNoms[_selectedEleve!.classeId] ?? "-"}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AyannaColors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _fraisDetails.isEmpty
                        ? const Center(
                            child: Text('Aucun frais trouvé pour cet élève.'),
                          )
                        : ListView.separated(
                            itemCount: _fraisDetails.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, i) {
                              final fd = _fraisDetails[i];
                              return Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              fd.frais.nom,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ),
                                          Text(
                                            fd.statut == 'en_ordre'
                                                ? 'En ordre'
                                                : fd.statut ==
                                                      'partiellement_paye'
                                                ? 'Partiel'
                                                : 'Pas en ordre',
                                            style: TextStyle(
                                              color: fd.statut == 'en_ordre'
                                                  ? AyannaColors.successGreen
                                                  : fd.statut ==
                                                        'partiellement_paye'
                                                  ? AyannaColors.orange
                                                  : Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      FutureBuilder<String>(
                                        future: formatAmount(fd.montant),
                                        builder: (context, snapshot) => Text(
                                          'Montant : ${snapshot.data ?? fd.montant.toStringAsFixed(0)}',
                                        ),
                                      ),
                                      FutureBuilder<String>(
                                        future: formatAmount(fd.montantPaye),
                                        builder: (context, snapshot) => Text(
                                          'Payé : ${snapshot.data ?? fd.montantPaye.toStringAsFixed(0)}',
                                        ),
                                      ),
                                      FutureBuilder<String>(
                                        future: formatAmount(fd.resteAPayer),
                                        builder: (context, snapshot) => Text(
                                          'Reste : ${snapshot.data ?? fd.resteAPayer.toStringAsFixed(0)}',
                                        ),
                                      ),
                                      if (fd
                                          .historiquePaiements
                                          .isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          'Historique :',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                        ),
                                        _buildPaiementTable(
                                          fd.historiquePaiements,
                                        ), // Table view here
                                      ],
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          if (fd.resteAPayer > 0)
                                            ElevatedButton.icon(
                                              icon: const Icon(Icons.payment),
                                              label: const Text('Régler'),
                                              onPressed: () async {
                                                final montantController =
                                                    TextEditingController();
                                                final result = await showDialog<double>(
                                                  context: context,
                                                  builder: (ctx) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                        'Effectuer un paiement',
                                                      ),
                                                      content: TextField(
                                                        controller:
                                                            montantController,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        decoration: InputDecoration(
                                                          labelText:
                                                              'Montant à payer (max ${fd.resteAPayer.toStringAsFixed(0)})',
                                                        ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                ctx,
                                                              ).pop(),
                                                          child: const Text(
                                                            'Annuler',
                                                          ),
                                                        ),
                                                        ElevatedButton(
                                                          onPressed: () {
                                                            final value =
                                                                double.tryParse(
                                                                  montantController
                                                                      .text,
                                                                );
                                                            if (value != null &&
                                                                value > 0 &&
                                                                value <=
                                                                    fd.resteAPayer) {
                                                              Navigator.of(
                                                                ctx,
                                                              ).pop(value);
                                                            }
                                                          },
                                                          child: const Text(
                                                            'Valider',
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                                if (result != null) {
                                                  await ref
                                                      .read(
                                                        paiementsFraisNotifierProvider
                                                            .notifier,
                                                      )
                                                      .enregistrerPaiement(
                                                        eleveId:
                                                            _selectedEleve!.id!,
                                                        fraisId: fd.frais.id,
                                                        montant: result,
                                                      );
                                                  await _loadFraisForEleve(
                                                    _selectedEleve!,
                                                  );
                                                }
                                              },
                                            ),
                                          if (fd.montantPaye > 0)
                                            const SizedBox(width: 8),
                                          if (fd.montantPaye > 0)
                                            ElevatedButton.icon(
                                              icon: fd.showRecu
                                                  ? const Icon(Icons.print)
                                                  : const Icon(
                                                      Icons.receipt_long,
                                                    ),
                                              label: Text(
                                                fd.showRecu
                                                    ? 'Imprimer'
                                                    : 'Facture',
                                              ),
                                              onPressed: () async {
                                                if (!fd.showRecu) {
                                                  setState(() {
                                                    fd.showRecu = true;
                                                  });
                                                } else {
                                                  await _printReceipt(
                                                    _selectedEleve!,
                                                    fd,
                                                  );
                                                }
                                              },
                                            ),
                                        ],
                                      ),
                                      if (fd.showRecu)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8.0,
                                          ),
                                          child: FactureRecuWidget(
                                            eleve:
                                                '${_selectedEleve!.prenomCapitalized} ${_selectedEleve!.nomPostnomMaj}',
                                            classe:
                                                _classesNoms[_selectedEleve!
                                                    .classeId] ??
                                                '-',
                                            frais: fd.frais.nom,
                                            paiements: fd.historiquePaiements
                                                .map(
                                                  (p) => {
                                                    'date': DateFormat(
                                                      'dd/MM/yyyy',
                                                    ).format(p.datePaiement),
                                                    'montant': p.montantPaye
                                                        .toStringAsFixed(0),
                                                    'caissier': 'Admin',
                                                  },
                                                )
                                                .toList(),
                                            totalPaye: fd.montantPaye.toInt(),
                                            reste: fd.resteAPayer.toInt(),
                                            statut: fd.statut == 'en_ordre'
                                                ? 'En ordre'
                                                : fd.statut ==
                                                      'partiellement_paye'
                                                ? 'Partiel'
                                                : 'Pas en ordre',
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedEleve = null;
                        _fraisDetails = [];
                      });
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Retour à la liste'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // New widget for the table view
  Widget _buildPaiementTable(List<PaiementFrais> paiements) {
    if (paiements.isEmpty) {
      return const Text("Aucun paiement enregistré.");
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AyannaColors.lightGrey),
      ),
      child: Table(
        border: TableBorder.symmetric(
          inside: const BorderSide(color: AyannaColors.lightGrey),
        ),
        columnWidths: const {
          0: FlexColumnWidth(1.5),
          1: FlexColumnWidth(1.0),
          2: FlexColumnWidth(1.0),
        },
        children: [
          // Header Row
          TableRow(
            decoration: BoxDecoration(
              color: AyannaColors.orange.withOpacity(0.1),
            ),
            children: [
              _buildTableCell('Date', isHeader: true),
              _buildTableCell('Montant', isHeader: true),
              _buildTableCell('Caissier', isHeader: true),
            ],
          ),
          // Data Rows
          ...paiements.map((p) {
            return TableRow(
              children: [
                _buildTableCell(
                  DateFormat('dd/MM/yyyy').format(p.datePaiement),
                ),
                _buildTableCell(
                  '${p.montantPaye.toStringAsFixed(0)} ${AppPreferences().devise}',
                ),
                _buildTableCell('Admin'),
              ],
            );
          }),
        ],
      ),
    );
  }

  // Helper method for consistent cell styling
  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: isHeader ? AyannaColors.orange : AyannaColors.darkGrey,
          fontSize: 14,
        ),
      ),
    );
  }
}

class FactureReceiptWidgetPaiement extends StatelessWidget {
  final entities.Eleve eleve;
  final FraisDetails fraisDetails;
  final String? classeNom;

  const FactureReceiptWidgetPaiement({
    Key? key,
    required this.eleve,
    required this.fraisDetails,
    this.classeNom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Formatage simple sans locale lourde
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

              // Infos élève (alignées à gauche, simples)
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
                      'Classe: ${classeNom ?? "-"}',
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

              // En-têtes de colonnes (SANS Container, SANS Colors.grey)
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
                        'Agent',
                        style: TextStyle(
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Lignes de paiements (SIMPLIFIÉES)
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
                          '$montant CDF',
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

              // Totaux (SIMPLIFIÉS, sans couleurs conditionnelles)
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statut: ${fraisDetails.statut.replaceAll('_', ' ').toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Total Paye: ${fraisDetails.montantPaye.toStringAsFixed(0)} CDF',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Reste a Payer: ${fraisDetails.resteAPayer.toStringAsFixed(0)} CDF',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Footer
              const Text(
                'Merci pour votre paiement.',
                style: TextStyle(fontSize: 7),
              ),
              const SizedBox(height: 4),
              Text(
                'Genere par Ayanna School - $dateStr',
                style: const TextStyle(fontSize: 6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
