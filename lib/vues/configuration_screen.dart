import 'package:ayanna_school/vues/widgets/ayanna_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/ayanna_theme.dart';
import '../models/entities/annee_scolaire.dart';
import '../models/entities/licence.dart';
import '../services/providers/providers.dart';
import '../services/licence/licence_validator.dart';

class ConfigurationScreen extends ConsumerStatefulWidget {
  final bool isFirstSetup;
  const ConfigurationScreen({this.isFirstSetup = true, super.key});

  @override
  ConsumerState<ConfigurationScreen> createState() =>
      _ConfigurationScreenState();
}

class _ConfigurationScreenState extends ConsumerState<ConfigurationScreen> {
  List<AnneeScolaire> _annees = [];
  AnneeScolaire? _selectedYear;
  Licence? _licence;
  bool _licenceValid = false;
  int _licenceDaysRemaining = 0;
  bool _loading = true;
  bool _saving = false;
  bool _loadingLicenceFromServer = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
    });
    try {
      final annees = await ref.read(anneesScolairesNotifierProvider.future);
      final currentYear = await ref.read(currentAnneeScolaireProvider.future);

      // Charger la licence depuis le serveur
      Licence? foundLicence;
      bool licenceValid = false;
      int daysRemaining = 0;

      try {
        final entreprises = await ref.read(entreprisesNotifierProvider.future);
        final entreprise = entreprises.isNotEmpty ? entreprises.first : null;

        if (entreprise != null) {
          print('🔄 [CONFIG] Récupération licence depuis serveur...');

          // Récupérer depuis le SERVEUR (pas la base locale)
          final serverLicence = await _fetchLicenceFromServer(entreprise.id!);

          if (serverLicence != null) {
            foundLicence = serverLicence;

            // Calculer la validité avec les dates SERVEUR
            final result = _validateLicence(serverLicence);
            licenceValid = result['isValid'];
            daysRemaining = result['daysRemaining'];

            print('✅ [CONFIG] Dates serveur récupérées:');
            print('  Activation: ${serverLicence.dateActivation}');
            print('  Expiration: ${serverLicence.dateExpiration}');
            print('  Jours restants: $daysRemaining');
            print('  Statut: ${licenceValid ? "Valide" : "Invalide"}');

            // Mettre à jour la base locale avec les données serveur
            final dao = ref.read(licenceDaoProvider);
            final localLicence = await dao.getLicencesByEntreprise(
              entreprise.id!,
            );
            if (localLicence != null && localLicence.id != null) {
              final updated = localLicence.copyWith(
                dateActivation: serverLicence.dateActivation,
                dateExpiration: serverLicence.dateExpiration,
                active: licenceValid,
                updatedAt: DateTime.now(),
              );
              await dao.updateLicence(updated);
              foundLicence = updated;

              if (licenceValid) {
                await dao.activerLicence(localLicence.id!);
              } else {
                await dao.desactiverLicence(localLicence.id!);
              }
            }
          } else {
            print(
              '⚠️ [CONFIG] Serveur indisponible, utilisation données locales',
            );
            final dao = ref.read(licenceDaoProvider);
            final localLicence = await dao.getLicencesByEntreprise(
              entreprise.id!,
            );
            if (localLicence != null) {
              foundLicence = localLicence;
              final result = _validateLicence(localLicence);
              licenceValid = result['isValid'];
              daysRemaining = result['daysRemaining'];
            }
          }
        }
      } catch (e) {
        print('❌ [CONFIG] Erreur chargement licence: $e');
      }

      setState(() {
        _annees = annees;
        if (currentYear != null) {
          _selectedYear = currentYear;
        } else if (_annees.isNotEmpty) {
          _selectedYear = _annees.first;
        }
        _licence = foundLicence;
        _licenceValid = licenceValid;
        _licenceDaysRemaining = daysRemaining;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur chargement des données: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  /// Valider une licence basée sur les dates
  Map<String, dynamic> _validateLicence(Licence licence) {
    final now = DateTime.now();

    // La licence expire à la fin du jour (23h59:59)
    // donc on compare avec le jour suivant à minuit
    final expirationEndOfDay = DateTime(
      licence.dateExpiration.year,
      licence.dateExpiration.month,
      licence.dateExpiration.day,
      23,
      59,
      59,
    );

    final isExpired = now.isAfter(expirationEndOfDay);
    final isAfterActivation = now.isAfter(licence.dateActivation);
    final isValid = isAfterActivation && !isExpired;

    // Calculer les jours restants en comparant les dates (sans heures)
    final today = DateTime(now.year, now.month, now.day);
    final expirationDate = DateTime(
      licence.dateExpiration.year,
      licence.dateExpiration.month,
      licence.dateExpiration.day,
    );

    // Nombre de jours entre aujourd'hui et la date d'expiration (inclus)
    int daysRemaining = expirationDate.difference(today).inDays;

    // Si la différence est 0, cela signifie que c'est le dernier jour (expiration aujourd'hui à 23h59)
    // Si négatif, la licence est déjà expirée
    if (daysRemaining < 0) daysRemaining = 0;

    return {
      'isValid': isValid,
      'daysRemaining': daysRemaining,
      'isExpired': isExpired,
    };
  }

  /// Met à jour la licence dans la base de données locale
  /// pour permettre l'utilisation hors ligne avec les données les plus récentes
  Future<void> _updateLocalLicence(
    Licence serverLicence,
    int entrepriseId,
  ) async {
    try {
      final licenceDao = ref.read(licenceDaoProvider);

      // Chercher si une licence existe déjà pour cette entreprise
      final allLicences = await licenceDao.getAllLicences();
      final existingLicence = allLicences.firstWhere(
        (l) => l.entrepriseId == entrepriseId,
        orElse: () => serverLicence,
      );

      if (existingLicence.id != null && existingLicence.id != 0) {
        // Licence existe déjà - faire une mise à jour
        print(
          '🔄 [CONFIG] Licence existante trouvée (ID: ${existingLicence.id}) - Mise à jour...',
        );

        final updatedLicence = Licence(
          id: existingLicence.id, // Garder l'ID local
          serverId: serverLicence.serverId ?? serverLicence.id,
          isSync: true,
          cle: serverLicence.cle,
          type: serverLicence.type,
          dateActivation: serverLicence.dateActivation,
          dateExpiration: serverLicence.dateExpiration,
          signature: serverLicence.signature,
          active: serverLicence.active,
          entrepriseId: entrepriseId,
          dateCreation: serverLicence.dateCreation,
          dateModification: serverLicence.dateModification,
          updatedAt: DateTime.now(), // Timestamp de la mise à jour locale
        );

        await licenceDao.updateLicence(updatedLicence);
        print(
          '✅ [CONFIG] Licence mise à jour localement (ID: ${existingLicence.id})',
        );
        print('   📅 Date activation: ${updatedLicence.dateActivation}');
        print('   📅 Date expiration: ${updatedLicence.dateExpiration}');
      } else {
        // Nouvelle licence - insertion
        print('➕ [CONFIG] Nouvelle licence - Insertion...');

        final newLicence = Licence(
          id: null, // Laisser la BDD générer l'ID
          serverId: serverLicence.serverId ?? serverLicence.id,
          isSync: true,
          cle: serverLicence.cle,
          type: serverLicence.type,
          dateActivation: serverLicence.dateActivation,
          dateExpiration: serverLicence.dateExpiration,
          signature: serverLicence.signature,
          active: serverLicence.active,
          entrepriseId: entrepriseId,
          dateCreation: serverLicence.dateCreation,
          dateModification: serverLicence.dateModification,
          updatedAt: DateTime.now(),
        );

        await licenceDao.insertLicence(newLicence);
        print('✅ [CONFIG] Nouvelle licence insérée localement');
      }

      // Invalider le provider de validation de licence pour forcer un rechargement
      ref.invalidate(licenceValidationProvider);
      print('🔄 [CONFIG] Provider de validation de licence invalidé');
    } catch (e, stackTrace) {
      print('❌ [CONFIG] Erreur mise à jour locale de la licence: $e');
      print('Stack trace: $stackTrace');
    }
  }

  /// Récupérer la licence depuis le serveur (pas la base locale!)
  Future<Licence?> _fetchLicenceFromServer(int entrepriseId) async {
    try {
      setState(() {
        _loadingLicenceFromServer = true;
      });

      final syncService = ref.read(syncServiceProvider);
      final syncPrefs = ref.read(syncPreferencesNotifierProvider.notifier);
      final userEmail = await syncPrefs.getLastSyncUserEmail();

      if (userEmail == null) {
        print('⚠️ [CONFIG] Email utilisateur non trouvé');
        return null;
      }

      final response = await syncService.downloadChanges(
        since: '1970-01-01T00:00:00Z',
        clientId: 'flutter-client',
        userEmail: userEmail,
      );

      if (response.isSuccessful && response.body != null) {
        final syncData = response.body!;
        final licenceChanges = syncData.changes
            .where((change) => change.table == 'licence')
            .toList();

        print('📊 [CONFIG] Nombre total de licences: ${licenceChanges.length}');

        if (licenceChanges.isEmpty) {
          print('⚠️ [CONFIG] Aucune licence trouvée dans la réponse serveur');
          return null;
        }

        // ⚠️ CRITÈRE RENFORCÉ: Filtrer par entreprise_id
        final matchingLicences = licenceChanges.where((change) {
          final data = change.data;
          final licenceEntrepriseId = data['entreprise_id'];

          // Critère principal: entreprise_id doit correspondre
          if (licenceEntrepriseId != entrepriseId) {
            return false;
          }

          // Si on a déjà une licence locale avec serverId, vérifier la correspondance
          if (_licence?.serverId != null) {
            final serverLicenceId = data['id'];
            if (serverLicenceId != null &&
                serverLicenceId != _licence!.serverId) {
              print(
                '⚠️ [CONFIG] Licence ignorée: server_id différent ($serverLicenceId vs ${_licence!.serverId})',
              );
              return false;
            }
          }

          return true;
        }).toList();

        print(
          '🎯 [CONFIG] Licences correspondantes: ${matchingLicences.length}',
        );

        if (matchingLicences.isEmpty) {
          print('❌ [CONFIG] Aucune licence pour entreprise ID: $entrepriseId');
          return null;
        }

        if (matchingLicences.length > 1) {
          print(
            '⚠️ [CONFIG] ATTENTION: Plusieurs licences trouvées pour entreprise_id: $entrepriseId',
          );
          for (var i = 0; i < matchingLicences.length; i++) {
            final data = matchingLicences[i].data;
            print('  Licence ${i + 1}:');
            print('    - ID: ${data['id']}');
            print('    - Type: ${data['type']}');
            print('    - Clé: ${data['cle']}');
            print('    - Activation: ${data['date_activation']}');
            print('    - Expiration: ${data['date_expiration']}');
          }
        }

        // Prendre la première licence correspondante
        final licenceChange = matchingLicences.first;

        print('� [CONFIG] Données SÉLECTIONNÉES du serveur:');
        print('  ID serveur: ${licenceChange.data['id']}');
        print('  Type: ${licenceChange.data['type']}');
        print('  Clé: ${licenceChange.data['cle']}');
        print('  Entreprise ID: ${licenceChange.data['entreprise_id']}');
        print(
          '  Date activation (brut): ${licenceChange.data['date_activation']}',
        );
        print(
          '  Date expiration (brut): ${licenceChange.data['date_expiration']}',
        );

        final serverLicence = Licence.fromJson(licenceChange.data);

        print('📅 [CONFIG] Dates PARSÉES:');
        print('  ID local: ${serverLicence.id}');
        print('  ID serveur: ${serverLicence.serverId}');
        print('  Type: ${serverLicence.type}');
        print('  Clé: ${serverLicence.cle}');
        print('  Date activation: ${serverLicence.dateActivation}');
        print('  Date expiration: ${serverLicence.dateExpiration}');

        // 🔄 MISE À JOUR DE LA BASE LOCALE AVEC LES DONNÉES SERVEUR
        print('💾 [CONFIG] Mise à jour de la licence dans la base locale...');
        await _updateLocalLicence(serverLicence, entrepriseId);

        return serverLicence;
      }

      return null;
    } catch (e) {
      print('❌ [CONFIG] Erreur récupération serveur: $e');
      return null;
    } finally {
      if (mounted) {
        setState(() {
          _loadingLicenceFromServer = false;
        });
      }
    }
  }

  Future<void> _saveConfiguration() async {
    if (_selectedYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une année scolaire.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _saving = true;
    });
    try {
      await ref
          .read(configEcolesNotifierProvider.notifier)
          .updateCurrentAnneeScolaire(_selectedYear!.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configuration sauvegardée avec succès.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sauvegarde: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _saving = false;
      });
    }
  }

  /// Affiche un modal pour changer le mot de passe
  Future<void> _showChangePasswordModal() async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    try {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => _ChangePasswordDialog(
          currentPasswordController: currentPasswordController,
          newPasswordController: newPasswordController,
          confirmPasswordController: confirmPasswordController,
          onSuccess: () {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text('Mot de passe modifié avec succès !'),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
          ref: ref,
        ),
      );
    } finally {
      currentPasswordController.dispose();
      newPasswordController.dispose();
      confirmPasswordController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    int drawerIndex = 4;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration'),
        backgroundColor: AyannaColors.orange,
        foregroundColor: AyannaColors.white,
      ),
      drawer: AyannaDrawer(
        selectedIndex: drawerIndex,
        onItemSelected: (i) => setState(() => drawerIndex = i),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Configuration de l\'année scolaire',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Divider(height: 24),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<int>(
                            value: _selectedYear?.id,
                            decoration: const InputDecoration(
                              labelText: 'Année scolaire en cours',
                              border: OutlineInputBorder(),
                            ),
                            items: _annees.map((year) {
                              return DropdownMenuItem<int>(
                                value: year.id,
                                child: Text(year.nom),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedYear = _annees.firstWhere(
                                  (year) => year.id == value,
                                );
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Veuillez sélectionner une année scolaire';
                              }
                              return null;
                            },
                          ),
                          if (_selectedYear != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              'Période: ${_selectedYear!.dateDebut.toString().substring(0, 10)} - ${_selectedYear!.dateFin.toString().substring(0, 10)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 16),
                            // Section Licence (données du SERVEUR)
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: _licenceValid
                                      ? [
                                          AyannaColors.orange.withOpacity(0.1),
                                          AyannaColors.orange.withOpacity(0.05),
                                        ]
                                      : [
                                          Colors.red.withOpacity(0.15),
                                          Colors.red.withOpacity(0.08),
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _licenceValid
                                      ? AyannaColors.orange.withOpacity(0.3)
                                      : Colors.red.withOpacity(0.4),
                                  width: 1.5,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          _licenceValid
                                              ? Icons.verified_user
                                              : Icons.warning_amber_rounded,
                                          color: _licenceValid
                                              ? AyannaColors.orange
                                              : Colors.red[700],
                                          size: 28,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Licence',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: _licenceValid
                                                    ? AyannaColors.orange
                                                    : Colors.red[700],
                                              ),
                                        ),
                                        if (_loadingLicenceFromServer) ...[
                                          const SizedBox(width: 12),
                                          SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    AyannaColors.orange,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    const Divider(),
                                    const SizedBox(height: 8),
                                    if (_licence != null) ...[
                                      _buildLicenceInfoRow(
                                        context,
                                        Icons.category_outlined,
                                        'Type',
                                        _licence!.type,
                                      ),
                                      const SizedBox(height: 10),
                                      _buildLicenceInfoRow(
                                        context,
                                        _licenceValid
                                            ? Icons.check_circle_outline
                                            : Icons.cancel_outlined,
                                        'Statut',
                                        _licenceValid ? 'Valide' : 'Invalide',
                                        valueColor: _licenceValid
                                            ? Colors.green[700]
                                            : Colors.red[700],
                                      ),
                                      const SizedBox(height: 10),
                                      _buildLicenceInfoRow(
                                        context,
                                        Icons.play_circle_outline,
                                        'Activation',
                                        '${_licence!.dateActivation.day}/${_licence!.dateActivation.month}/${_licence!.dateActivation.year}',
                                      ),
                                      const SizedBox(height: 10),
                                      _buildLicenceInfoRow(
                                        context,
                                        Icons.calendar_today_outlined,
                                        'Expiration',
                                        '${_licence!.dateExpiration.day}/${_licence!.dateExpiration.month}/${_licence!.dateExpiration.year}',
                                      ),
                                      const SizedBox(height: 10),
                                      _buildLicenceInfoRow(
                                        context,
                                        Icons.access_time_outlined,
                                        'Jours restants',
                                        '$_licenceDaysRemaining jour${_licenceDaysRemaining > 1 ? 's' : ''}',
                                        valueColor: _licenceDaysRemaining < 30
                                            ? (_licenceDaysRemaining < 7
                                                  ? Colors.red[700]
                                                  : Colors.orange[700])
                                            : null,
                                      ),
                                      if (_licenceDaysRemaining < 30 &&
                                          _licenceDaysRemaining > 0) ...[
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.all(8.0),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.withOpacity(
                                              0.15,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.info_outline,
                                                size: 18,
                                                color: Colors.orange[800],
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  'Licence bientôt expirée',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.orange[900],
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ] else ...[
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.error_outline,
                                            color: Colors.red[700],
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Aucune licence définie pour cette entreprise.',
                                              style: TextStyle(
                                                color: Colors.red[900],
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Section Sécurité - Changement de mot de passe
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.security, color: AyannaColors.orange),
                              const SizedBox(width: 12),
                              Text(
                                'Sécurité',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AyannaColors.orange.withOpacity(0.05),
                                  AyannaColors.orange.withOpacity(0.02),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AyannaColors.orange.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AyannaColors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.lock_reset,
                                  color: AyannaColors.orange,
                                  size: 24,
                                ),
                              ),
                              title: Text(
                                'Modifier le mot de passe',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                'Changez votre mot de passe local',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                color: AyannaColors.orange,
                                size: 18,
                              ),
                              onTap: _showChangePasswordModal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Sauvegarder'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: AyannaColors.orange,
                        foregroundColor: AyannaColors.white,
                      ),
                      onPressed: _saving ? null : _saveConfiguration,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLicenceInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AyannaColors.orange.withOpacity(0.7)),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget séparé pour le dialog de changement de mot de passe
class _ChangePasswordDialog extends ConsumerStatefulWidget {
  final TextEditingController currentPasswordController;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;
  final VoidCallback onSuccess;
  final WidgetRef ref;

  const _ChangePasswordDialog({
    required this.currentPasswordController,
    required this.newPasswordController,
    required this.confirmPasswordController,
    required this.onSuccess,
    required this.ref,
  });

  @override
  ConsumerState<_ChangePasswordDialog> createState() =>
      _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<_ChangePasswordDialog> {
  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _errorMessage;
  bool _isProcessing = false;

  Future<void> _handleSubmit() async {
    // Validation
    final currentPassword = widget.currentPasswordController.text.trim();
    final newPassword = widget.newPasswordController.text.trim();
    final confirmPassword = widget.confirmPasswordController.text.trim();

    if (currentPassword.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez saisir votre mot de passe actuel';
      });
      return;
    }

    if (newPassword.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez saisir un nouveau mot de passe';
      });
      return;
    }

    if (newPassword.length < 6) {
      setState(() {
        _errorMessage = 'Le mot de passe doit contenir au moins 6 caractères';
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        _errorMessage = 'Les mots de passe ne correspondent pas';
      });
      return;
    }

    // Traitement
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final prefs = await widget.ref.read(sharedPreferencesProvider.future);
      final savedPassword = prefs.getString('local_password');

      // Vérifier le mot de passe actuel
      if (savedPassword != currentPassword) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Mot de passe actuel incorrect';
            _isProcessing = false;
          });
        }
        return;
      }

      // Sauvegarder le nouveau mot de passe
      await prefs.setString('local_password', newPassword);

      // Fermer le modal
      if (mounted) {
        Navigator.of(context).pop();
        widget.onSuccess();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur: $e';
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.lock_reset, color: AyannaColors.orange),
          const SizedBox(width: 12),
          Expanded(child: Text('Changer mot de passe')),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Mot de passe actuel
            TextField(
              controller: widget.currentPasswordController,
              obscureText: !_isCurrentPasswordVisible,
              enabled: !_isProcessing,
              decoration: InputDecoration(
                labelText: 'Mot de passe actuel',
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: AyannaColors.orange,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isCurrentPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: AyannaColors.orange,
                  ),
                  onPressed: () {
                    setState(() {
                      _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AyannaColors.orange, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Nouveau mot de passe
            TextField(
              controller: widget.newPasswordController,
              obscureText: !_isNewPasswordVisible,
              enabled: !_isProcessing,
              decoration: InputDecoration(
                labelText: 'Nouveau mot de passe (min 6 caractères)',
                prefixIcon: Icon(Icons.lock, color: AyannaColors.orange),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isNewPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: AyannaColors.orange,
                  ),
                  onPressed: () {
                    setState(() {
                      _isNewPasswordVisible = !_isNewPasswordVisible;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AyannaColors.orange, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Confirmer nouveau mot de passe
            TextField(
              controller: widget.confirmPasswordController,
              obscureText: !_isConfirmPasswordVisible,
              enabled: !_isProcessing,
              decoration: InputDecoration(
                labelText: 'Confirmer le nouveau mot de passe',
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: AyannaColors.orange,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: AyannaColors.orange,
                  ),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AyannaColors.orange, width: 2),
                ),
              ),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
          child: Text('Annuler'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AyannaColors.orange,
            foregroundColor: Colors.white,
          ),
          onPressed: _isProcessing ? null : _handleSubmit,
          child: _isProcessing
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text('Modifier'),
        ),
      ],
    );
  }
}
