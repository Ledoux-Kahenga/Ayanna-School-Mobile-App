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
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart' as thermal;
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';

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
  final _flutterThermalPrinterPlugin = FlutterThermalPrinter.instance;
  List<thermal.Printer> printers = [];
  StreamSubscription<List<thermal.Printer>>? _devicesStreamSubscription;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    print('📍 [PaiementFrais] initState appelé');
    _initData();
    print('📍 [PaiementFrais] Appel de _requestBluetoothPermissions()');
    _requestBluetoothPermissions();
  }

  @override
  void dispose() {
    print('📍 [PaiementFrais] dispose appelé, annulation du stream');
    _devicesStreamSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _requestBluetoothPermissions() async {
    print('📍 [PaiementFrais] Début de la demande de permissions Bluetooth...');

    // Sur Android 12+ (API 31+), on utilise bluetoothConnect et bluetoothScan
    // Sur Android < 12, on utilise bluetooth et location
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
    ].request();

    print('📍 [PaiementFrais] Statuts des permissions:');
    statuses.forEach((permission, status) {
      print('   - ${permission.toString()}: ${status.toString()}');
    });

    // Vérifier les permissions essentielles selon la version Android
    bool bluetoothConnectGranted =
        statuses[Permission.bluetoothConnect]?.isGranted ?? false;
    bool bluetoothScanGranted =
        statuses[Permission.bluetoothScan]?.isGranted ?? false;
    bool locationGranted = statuses[Permission.location]?.isGranted ?? false;

    // Sur Android 12+, on a besoin de bluetoothConnect et bluetoothScan
    // La location est optionnelle si on utilise neverForLocation
    bool permissionsOk = bluetoothConnectGranted && bluetoothScanGranted;

    print('📍 [PaiementFrais] Analyse des permissions:');
    print('   - bluetoothConnect: $bluetoothConnectGranted');
    print('   - bluetoothScan: $bluetoothScanGranted');
    print('   - location: $locationGranted');
    print('   - Permissions OK: $permissionsOk');

    if (permissionsOk) {
      print(
        '✅ [PaiementFrais] Permissions essentielles accordées, lancement du scan...',
      );
      _startScan();
    } else {
      print('❌ [PaiementFrais] Permissions essentielles refusées');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Permissions Bluetooth requises pour l\'impression thermique',
            ),
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _startScan() async {
    print('📍 [PaiementFrais] Début du scan des imprimantes...');

    setState(() {
      _isScanning = true;
    });

    try {
      // D'abord écouter le stream
      print('📍 [PaiementFrais] Configuration du listener devicesStream...');
      _devicesStreamSubscription = _flutterThermalPrinterPlugin.devicesStream.listen(
        (devices) {
          print(
            '📡 [PaiementFrais] Stream déclenché avec ${devices.length} imprimante(s)',
          );
          if (mounted) {
            setState(() {
              printers = devices;
              print(
                '✅ [PaiementFrais] Liste mise à jour: ${devices.length} imprimante(s)',
              );
              for (var printer in devices) {
                print(
                  '   🖨️  ${printer.name} (${printer.address}) - Type: ${printer.connectionType}',
                );
              }
            });
          } else {
            print('⚠️ [PaiementFrais] Widget non monté, mise à jour ignorée');
          }
        },
        onError: (error) {
          print('❌ [PaiementFrais] Erreur dans le stream: $error');
        },
        cancelOnError: false,
      );

      print(
        '📍 [PaiementFrais] Listener configuré, lancement de getPrinters()...',
      );

      // Puis lancer la découverte des imprimantes Bluetooth
      await _flutterThermalPrinterPlugin.getPrinters(
        refreshDuration: const Duration(seconds: 2),
        connectionTypes: [thermal.ConnectionType.BLE],
      );

      print(
        '✅ [PaiementFrais] getPrinters() terminé, attente des résultats dans le stream...',
      );

      // Attendre 8 secondes pour laisser le temps au scan de trouver les imprimantes
      await Future.delayed(const Duration(seconds: 8));

      print(
        '⏹️ [PaiementFrais] Fin de l\'attente du scan, ${printers.length} imprimante(s) trouvée(s)',
      );

      _flutterThermalPrinterPlugin.stopScan();

      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    } catch (e) {
      print('❌ [PaiementFrais] Erreur lors du scan: $e');
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  Future<void> _showReceiptWidget(
    entities.Eleve eleve,
    FraisDetails fraisDetails,
  ) async {
    print('📍 [PaiementFrais] _showReceiptWidget appelé');
    print(
      '📍 [PaiementFrais] Nombre d\'imprimantes disponibles: ${printers.length}',
    );
    print('📍 [PaiementFrais] Scan en cours: $_isScanning');

    // Si le scan est en cours, afficher un message et attendre
    if (_isScanning) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '⏳ Recherche d\'imprimantes en cours, veuillez patienter...',
          ),
          duration: Duration(seconds: 2),
        ),
      );
      print(
        '⚠️ [PaiementFrais] Scan en cours, impression refusée temporairement',
      );
      return;
    }

    if (printers.isEmpty) {
      print('❌ [PaiementFrais] Aucune imprimante dans la liste');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Aucune imprimante trouvée. Assurez-vous que l\'imprimante est allumée et à portée.',
          ),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    print('✅ [PaiementFrais] Imprimantes disponibles:');
    for (var p in printers) {
      print('   🖨️  ${p.name} (${p.address})');
    }

    // Si plusieurs imprimantes, afficher un dialogue de sélection
    thermal.Printer? selectedPrinter;
    if (printers.length > 1) {
      print(
        '📍 [PaiementFrais] Plusieurs imprimantes, affichage du dialogue de sélection...',
      );
      selectedPrinter = await showDialog<thermal.Printer>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Sélectionner une imprimante'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: printers.map((printer) {
                  return ListTile(
                    leading: const Icon(
                      Icons.print,
                      color: AyannaColors.orange,
                    ),
                    title: Text(printer.name ?? 'Imprimante inconnue'),
                    subtitle: Text(printer.address ?? ''),
                    onTap: () {
                      Navigator.of(context).pop(printer);
                    },
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Annuler'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );

      if (selectedPrinter == null) {
        print('⚠️ [PaiementFrais] Sélection annulée par l\'utilisateur');
        return; // L'utilisateur a annulé
      }
      print(
        '✅ [PaiementFrais] Imprimante sélectionnée: ${selectedPrinter.name}',
      );
    } else {
      selectedPrinter = printers[0];
      print(
        '✅ [PaiementFrais] Une seule imprimante, sélection automatique: ${selectedPrinter.name}',
      );
    }

    print(
      '📍 [PaiementFrais] Début de l\'impression sur ${selectedPrinter.name}...',
    );
    print('📍 [PaiementFrais] Adresse: ${selectedPrinter.address}');
    print('📍 [PaiementFrais] Type: ${selectedPrinter.connectionType}');
    print('📍 [PaiementFrais] isConnected: ${selectedPrinter.isConnected}');

    try {
      // Vérifier si l'imprimante est déjà connectée
      if (selectedPrinter.isConnected != true) {
        print(
          '📍 [PaiementFrais] Imprimante non connectée, connexion en cours...',
        );

        // Connecter à l'imprimante
        final isConnected = await _flutterThermalPrinterPlugin.connect(
          selectedPrinter,
        );
        print('📍 [PaiementFrais] Résultat de la connexion: $isConnected');

        if (!isConnected) {
          print('❌ [PaiementFrais] Échec de la connexion à l\'imprimante');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Impossible de se connecter à l\'imprimante'),
              ),
            );
          }
          return;
        }
        print('✅ [PaiementFrais] Connexion réussie à l\'imprimante');
      } else {
        print('✅ [PaiementFrais] Imprimante déjà connectée');
      }

      print('📍 [PaiementFrais] Génération du widget de reçu...');
      final receiptWidget = FactureReceiptWidgetPaiement(
        eleve: eleve,
        fraisDetails: fraisDetails,
      );
      print('✅ [PaiementFrais] Widget de reçu généré');

      print('📍 [PaiementFrais] Envoi à l\'imprimante...');
      await _flutterThermalPrinterPlugin.printWidget(
        context,
        printer: selectedPrinter,
        widget: receiptWidget,
      );
      print('✅ [PaiementFrais] Impression terminée avec succès');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impression en cours...'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('❌ [PaiementFrais] Erreur lors de l\'impression: $e');
      print('❌ [PaiementFrais] Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur d\'impression: $e')));
      }
    }
  }

  Future<void> _initData() async {
    setState(() {
      _loading = true;
      _errorMessage = '';
      _selectedEleve = null;
      _fraisDetails = [];
    });
    try {
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
                                          'Classe : ${e.classeNom ?? "-"}',
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
                          'Classe : ${_selectedEleve!.classeNom ?? "-"}',
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
                                                  await _showReceiptWidget(
                                                    _selectedEleve!,
                                                    fd,
                                                  );

                                                  // await Printing.layoutPdf(
                                                  //   onLayout: (format) async {
                                                  //     final doc = pw.Document();
                                                  //     doc.addPage(
                                                  //       pw.Page(
                                                  //         build: (pw.Context context) {
                                                  //           return pw.Column(
                                                  //             crossAxisAlignment: pw
                                                  //                 .CrossAxisAlignment
                                                  //                 .start,
                                                  //             children: [
                                                  //               pw.Text(
                                                  //                 'Généré par Ayanna School - ${DateTime.now()}',
                                                  //               ),
                                                  //               pw.Text(
                                                  //                 'Default School',
                                                  //               ),
                                                  //               pw.Text(
                                                  //                 '14 Av. Bunduki, Q. Plateau, C. Annexe',
                                                  //               ),
                                                  //               pw.Text(
                                                  //                 'Tél : +243997554905',
                                                  //               ),
                                                  //               pw.Text(
                                                  //                 'Email : comtact@school.com',
                                                  //               ),
                                                  //               pw.Divider(),
                                                  //               pw.Text(
                                                  //                 'REÇU FRAIS',
                                                  //                 style: pw.TextStyle(
                                                  //                   fontSize:
                                                  //                       20,
                                                  //                   fontWeight: pw
                                                  //                       .FontWeight
                                                  //                       .bold,
                                                  //                 ),
                                                  //               ),
                                                  //               pw.Text(
                                                  //                 'Élève : ${_selectedEleve!.prenomCapitalized} ${_selectedEleve!.nomPostnomMaj}',
                                                  //               ),
                                                  //               pw.Text(
                                                  //                 'Classe : ${_selectedEleve!.classeNom ?? "-"}',
                                                  //               ),
                                                  //               pw.Text(
                                                  //                 'Frais : ${fd.frais.nom}',
                                                  //               ),
                                                  //               pw.Text(
                                                  //                 'Paiements :',
                                                  //               ),
                                                  //               pw.Table.fromTextArray(
                                                  //                 headers: [
                                                  //                   'Date',
                                                  //                   'Montant',
                                                  //                   'Caissier',
                                                  //                 ],
                                                  //                 data: fd
                                                  //                     .historiquePaiements
                                                  //                     .map(
                                                  //                       (p) => [
                                                  //                         p.datePaiement,
                                                  //                         p.montantPaye,

                                                  //                         'Admin',
                                                  //                       ],
                                                  //                     )
                                                  //                     .toList(),
                                                  //               ),
                                                  //               pw.Text(
                                                  //                 'Total payé : ${fd.montantPaye.toInt()} ${AppPreferences().devise}',
                                                  //               ),
                                                  //               pw.Text(
                                                  //                 'Reste : ${fd.resteAPayer.toInt()} ${AppPreferences().devise}',
                                                  //               ),
                                                  //               pw.Text(
                                                  //                 'Statut : ${fd.statut == 'en_ordre'
                                                  //                     ? 'En ordre'
                                                  //                     : fd.statut == 'partiellement_paye'
                                                  //                     ? 'Partiel'
                                                  //                     : 'Pas en ordre'}',
                                                  //               ),
                                                  //               pw.SizedBox(
                                                  //                 height: 16,
                                                  //               ),
                                                  //               pw.Text(
                                                  //                 'Merci pour votre paiement.',
                                                  //                 style: pw.TextStyle(
                                                  //                   fontStyle: pw
                                                  //                       .FontStyle
                                                  //                       .italic,
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
                                                    fd.showRecu = false;
                                                  });
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
                                                _selectedEleve!.classeNom ??
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

  const FactureReceiptWidgetPaiement({
    Key? key,
    required this.eleve,
    required this.fraisDetails,
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
