import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/ayanna_theme.dart';
import '../models/entities/licence.dart';
import '../services/providers/providers.dart';
import '../services/licence/licence_validator.dart';

/// Écran de réactivation de licence avec polling automatique
///
/// Cet écran bloque l'application quand la licence est expirée/inactive.
/// Il surveille automatiquement l'API serveur pour détecter la réactivation
/// et débloque l'app automatiquement sans interaction utilisateur.
class LicenceReactivationScreen extends ConsumerStatefulWidget {
  final Licence licence;
  final VoidCallback? onLicenceReactivated;

  const LicenceReactivationScreen({
    required this.licence,
    this.onLicenceReactivated,
    super.key,
  });

  @override
  ConsumerState<LicenceReactivationScreen> createState() =>
      _LicenceReactivationScreenState();
}

class _LicenceReactivationScreenState
    extends ConsumerState<LicenceReactivationScreen> {
  Timer? _pollingTimer;
  Timer? _countdownTimer;
  bool _isChecking = false;
  String? _statusMessage;
  int _secondsUntilNextCheck = 0;
  static const int _pollingIntervalSeconds = 30;

  // Variables pour suivre les changements de dates
  Licence? _currentLicence;
  DateTime? _lastCheckedDate;
  bool _datesHaveChanged = false;

  @override
  void initState() {
    super.initState();
    _currentLicence = widget.licence;
    _lastCheckedDate = widget.licence.dateExpiration;

    print('🏁 [LICENCE] Initialisation écran réactivation');
    print('  Date activation initiale: ${widget.licence.dateActivation}');
    print('  Date expiration initiale: ${widget.licence.dateExpiration}');

    // Démarrer le polling automatique immédiatement pour récupérer les dates serveur
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        print('🔄 [LICENCE] Démarrage polling pour récupération dates serveur');
        _startPolling();
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    // Cancel any existing timer
    _pollingTimer?.cancel();
    _countdownTimer?.cancel();

    // Start countdown timer (updates UI every second)
    _secondsUntilNextCheck = _pollingIntervalSeconds;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _secondsUntilNextCheck--;
        if (_secondsUntilNextCheck <= 0) {
          _secondsUntilNextCheck = _pollingIntervalSeconds;
        }
      });
    });

    // Start actual polling timer
    _pollingTimer = Timer.periodic(Duration(seconds: _pollingIntervalSeconds), (
      timer,
    ) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      await _checkLicenceStatus(isAutomatic: true);
    });

    // Do immediate first check
    _checkLicenceStatus(isAutomatic: true);
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _countdownTimer?.cancel();
    _pollingTimer = null;
    _countdownTimer = null;
  }

  Future<void> _checkLicenceStatus({bool isAutomatic = false}) async {
    if (_isChecking) return;
    if (!mounted)
      return; // Protection: ne pas continuer si le widget est disposé

    setState(() {
      _isChecking = true;
      if (!isAutomatic) {
        _statusMessage = 'Vérification en cours...';
      }
    });

    try {
      // Lire les providers IMMÉDIATEMENT (avant toute opération async)
      final syncService = ref.read(syncServiceProvider);
      final dao = ref.read(licenceDaoProvider);
      final syncPrefs = ref.read(syncPreferencesNotifierProvider.notifier);

      // Récupérer l'entreprise_id depuis la licence locale
      final int? entrepriseId = widget.licence.entrepriseId;
      if (entrepriseId == null) {
        throw Exception('Impossible de vérifier: entreprise_id manquant');
      }

      // Debug log
      print('🔍 Vérification licence pour entreprise ID: $entrepriseId');

      // Récupérer l'email de l'utilisateur connecté depuis les préférences
      final userEmail = await syncPrefs.getLastSyncUserEmail();

      if (!mounted) return; // Vérifier après l'opération async

      if (userEmail == null) {
        throw Exception(
          'Email utilisateur non trouvé. Veuillez vous reconnecter.',
        );
      }

      print('📧 Email utilisateur: $userEmail');

      final response = await syncService.downloadChanges(
        since: '1970-01-01T00:00:00Z',
        clientId: 'flutter-client',
        userEmail: userEmail,
      );

      if (response.isSuccessful && response.body != null) {
        final syncData = response.body!;

        // Filtrer uniquement les changements de la table 'licence'
        final licenceChanges = syncData.changes
            .where((change) => change.table == 'licence')
            .toList();

        print(
          '📊 Nombre total de licences dans la réponse: ${licenceChanges.length}',
        );

        if (licenceChanges.isEmpty) {
          throw Exception('Aucune licence trouvée dans les données sync');
        }

        // ⚠️ CRITÈRE RENFORCÉ: Chercher la licence correspondant à cette entreprise
        // Vérifier entreprise_id + éventuellement server_id si disponible
        final matchingLicences = licenceChanges.where((change) {
          final data = change.data;
          final licenceEntrepriseId = data['entreprise_id'];

          // Critère principal: entreprise_id doit correspondre
          if (licenceEntrepriseId != entrepriseId) {
            return false;
          }

          // Critère additionnel: si on a un serverId local, vérifier qu'il correspond
          if (widget.licence.serverId != null) {
            final serverLicenceId = data['id'];
            if (serverLicenceId != null &&
                serverLicenceId != widget.licence.serverId) {
              print(
                '⚠️ Licence ignorée: server_id différent ($serverLicenceId vs ${widget.licence.serverId})',
              );
              return false;
            }
          }

          return true;
        }).toList();

        print(
          '🎯 Licences correspondantes trouvées: ${matchingLicences.length}',
        );

        if (matchingLicences.isEmpty) {
          throw Exception('Aucune licence pour entreprise ID: $entrepriseId');
        }

        if (matchingLicences.length > 1) {
          print(
            '⚠️ ATTENTION: Plusieurs licences trouvées pour entreprise_id: $entrepriseId',
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

        // Prendre la première licence correspondante (normalement il ne devrait y en avoir qu'une)
        final licenceChange = matchingLicences.first;

        // Debug: Afficher les données brutes du serveur
        print('📦 [LICENCE] Données SÉLECTIONNÉES du serveur:');
        print('  ID serveur: ${licenceChange.data['id']}');
        print('  Type: ${licenceChange.data['type']}');
        print('  Clé: ${licenceChange.data['cle']}');
        print('  Entreprise ID: ${licenceChange.data['entreprise_id']}');
        print('  Date activation: ${licenceChange.data['date_activation']}');
        print('  Date expiration: ${licenceChange.data['date_expiration']}');
        print('  Actif: ${licenceChange.data['actif']}');

        final updatedLicence = Licence.fromJson(licenceChange.data);

        // Debug: Afficher les données parsées
        print('📅 [LICENCE] Données PARSÉES:');
        print('  ID local: ${updatedLicence.id}');
        print('  ID serveur: ${updatedLicence.serverId}');
        print('  Type: ${updatedLicence.type}');
        print('  Clé: ${updatedLicence.cle}');
        print('  Date activation serveur: ${updatedLicence.dateActivation}');
        print('  Date expiration serveur: ${updatedLicence.dateExpiration}');
        print('  Date activation locale: ${widget.licence.dateActivation}');
        print('  Date expiration locale: ${widget.licence.dateExpiration}');

        // Vérifier si les dates ont changé par rapport à la licence actuelle
        final bool datesChanged =
            _lastCheckedDate != updatedLicence.dateExpiration ||
            _currentLicence?.dateActivation != updatedLicence.dateActivation;

        if (datesChanged) {
          print('🔔 [LICENCE] CHANGEMENT DÉTECTÉ !');
          print('  Ancienne expiration: $_lastCheckedDate');
          print('  Nouvelle expiration: ${updatedLicence.dateExpiration}');
          setState(() {
            _datesHaveChanged = true;
            _currentLicence = updatedLicence;
            _lastCheckedDate = updatedLicence.dateExpiration;
          });
        }

        // ⚠️ NOUVELLE LOGIQUE: Validation basée uniquement sur les dates
        // Le serveur ne gère pas le champ 'active', on utilise les dates
        final now = DateTime.now();

        // La licence expire à la fin du jour (23h59:59)
        final expirationEndOfDay = DateTime(
          updatedLicence.dateExpiration.year,
          updatedLicence.dateExpiration.month,
          updatedLicence.dateExpiration.day,
          23,
          59,
          59,
        );

        final isExpired = now.isAfter(expirationEndOfDay);
        final isAfterActivation = now.isAfter(updatedLicence.dateActivation);
        final isValid = isAfterActivation && !isExpired;

        print('📅 Dates du serveur:');
        print('  - Activation: ${updatedLicence.dateActivation}');
        print('  - Expiration: ${updatedLicence.dateExpiration}');
        print('  - Expiration (fin de journée): $expirationEndOfDay');
        print('  - Maintenant: $now');
        print('  - Expirée (now > 23h59): $isExpired');
        print('  - Valide: $isValid');

        // 🔄 MISE À JOUR DE LA BASE LOCALE avec les données du serveur
        // Pour permettre l'utilisation hors ligne avec les informations les plus récentes
        Licence? localUpdated;
        if (widget.licence.id != null) {
          print('💾 [LICENCE] Mise à jour de la base locale...');

          localUpdated = Licence(
            id: widget.licence.id, // Garder l'ID local
            serverId: updatedLicence.serverId ?? updatedLicence.id,
            isSync: true,
            cle: updatedLicence.cle,
            type: updatedLicence.type,
            dateActivation: updatedLicence.dateActivation,
            dateExpiration: updatedLicence.dateExpiration,
            signature: updatedLicence.signature,
            active: isValid, // Activer si valide selon les dates
            entrepriseId: widget.licence.entrepriseId,
            dateCreation: updatedLicence.dateCreation,
            dateModification: updatedLicence.dateModification,
            updatedAt: DateTime.now(), // Timestamp de la mise à jour locale
          );

          await dao.updateLicence(localUpdated);

          if (!mounted) return; // Vérifier après l'opération async

          print('✅ [LICENCE] Base locale mise à jour avec données serveur');
          print('   📅 Date activation: ${localUpdated.dateActivation}');
          print('   📅 Date expiration: ${localUpdated.dateExpiration}');
          print('   🔑 Clé: ${localUpdated.cle}');
          print('   ✓ Active: ${localUpdated.active}');

          // Mettre à jour _currentLicence pour l'affichage
          if (!mounted) return;
          setState(() {
            _currentLicence = localUpdated;
            if (datesChanged) {
              _lastCheckedDate = updatedLicence.dateExpiration;
              _datesHaveChanged = true;
            }
          });
        }

        if (!mounted) return; // Vérifier avant setState

        if (isValid) {
          // Licence valide selon les dates du serveur
          setState(() {
            _currentLicence = localUpdated ?? updatedLicence;
            _datesHaveChanged = false;
            _statusMessage =
                '✅ Licence réactivée ! Nouvelles dates appliquées.';
          });

          _stopPolling();

          // Invalider le provider IMMÉDIATEMENT pour que l'app se rebuilde
          // Cela doit être fait AVANT toute navigation
          try {
            ref.invalidate(licenceValidationProvider);
            print('✅ [LICENCE] Provider invalidé avec succès');
          } catch (e) {
            print('⚠️ [LICENCE] Erreur invalidation provider (ignorée): $e');
          }

          // Appeler le callback immédiatement pour permettre la navigation
          // Le message de succès sera visible brièvement avant la navigation
          if (mounted && widget.onLicenceReactivated != null) {
            // Utiliser un microtask pour éviter les problèmes de frame
            Future.microtask(() {
              if (mounted) {
                widget.onLicenceReactivated!();
              }
            });
          }
        } else {
          // Dates du serveur indiquent que la licence est toujours expirée
          setState(() {
            _statusMessage = isAutomatic
                ? 'Licence expirée. Expiration: ${updatedLicence.dateExpiration.day}/${updatedLicence.dateExpiration.month}/${updatedLicence.dateExpiration.year} (${datesChanged ? "📅 Dates mises à jour" : "Prochaine vérif: ${_secondsUntilNextCheck}s"})'
                : '⚠️ Licence expirée. Date expiration serveur: ${updatedLicence.dateExpiration.day}/${updatedLicence.dateExpiration.month}/${updatedLicence.dateExpiration.year}';
          });

          // Afficher notification de changement de dates
          if (datesChanged && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '📅 Les dates de licence ont été mises à jour !\nNouvelle expiration: ${updatedLicence.dateExpiration.day}/${updatedLicence.dateExpiration.month}/${updatedLicence.dateExpiration.year}',
                ),
                backgroundColor: Colors.blue,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
      } else {
        // Handle different HTTP error codes
        final statusCode = response.statusCode;
        String errorMessage;

        if (statusCode == 404) {
          errorMessage =
              'Licence non trouvée sur le serveur pour entreprise ID: $entrepriseId. Contactez le support.';
        } else if (statusCode == 401 || statusCode == 403) {
          errorMessage = 'Accès non autorisé. Vérifiez votre authentification.';
        } else if (statusCode == 500) {
          errorMessage = 'Erreur serveur (500). Réessayez plus tard.';
        } else {
          errorMessage = 'Erreur serveur (Code: $statusCode)';
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      if (!mounted) return; // Vérifier avant setState

      setState(() {
        _statusMessage = isAutomatic
            ? 'Erreur de connexion. Nouvelle tentative dans $_secondsUntilNextCheck s...'
            : '❌ Erreur: $e';
      });
    } finally {
      if (!mounted) return; // Vérifier avant setState

      setState(() {
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Utiliser la licence mise à jour si disponible, sinon la licence d'origine
    final displayLicence = _currentLicence ?? widget.licence;

    // Calculer les jours restants/expirés en comparant les dates (sans heures)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expirationDate = DateTime(
      displayLicence.dateExpiration.year,
      displayLicence.dateExpiration.month,
      displayLicence.dateExpiration.day,
    );

    final daysDifference = expirationDate.difference(today).inDays;

    // Calculer le nombre de jours depuis l'expiration (valeur absolue)
    final int daysCount = daysDifference.abs();

    final String message =
        'Votre licence a expiré il y a $daysCount jour(s).\n\n'
        'L\'application est temporairement bloquée.\n'
        'Veuillez contacter votre administrateur pour réactiver votre licence.';

    return Scaffold(
      backgroundColor: AyannaColors.lightGrey,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Lock icon avec animation si dates changées
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _datesHaveChanged
                            ? Colors.blue[50]
                            : Colors.red[50],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _datesHaveChanged ? Icons.update : Icons.lock_outline,
                        size: 64,
                        color: _datesHaveChanged
                            ? Colors.blue[700]
                            : Colors.red[700],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      _datesHaveChanged
                          ? 'Licence Mise à Jour'
                          : 'Licence Expirée',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _datesHaveChanged
                                ? Colors.blue[700]
                                : Colors.red[700],
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Message
                    Text(
                      message,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Licence info avec indicateur de mise à jour
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _datesHaveChanged
                            ? Colors.blue[50]
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: _datesHaveChanged
                            ? Border.all(color: Colors.blue, width: 2)
                            : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_datesHaveChanged) ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.update,
                                  color: Colors.blue[700],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Dates mises à jour',
                                  style: TextStyle(
                                    color: Colors.blue[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                          ],
                          _buildInfoRow('Type', displayLicence.type),
                          _buildInfoRow('Clé', displayLicence.cle),
                          _buildInfoRow(
                            'Date d\'activation',
                            '${displayLicence.dateActivation.day.toString().padLeft(2, '0')}/'
                                '${displayLicence.dateActivation.month.toString().padLeft(2, '0')}/'
                                '${displayLicence.dateActivation.year}',
                            isUpdated:
                                _datesHaveChanged &&
                                displayLicence.dateActivation !=
                                    widget.licence.dateActivation,
                          ),
                          _buildInfoRow(
                            'Date d\'expiration',
                            '${displayLicence.dateExpiration.day.toString().padLeft(2, '0')}/'
                                '${displayLicence.dateExpiration.month.toString().padLeft(2, '0')}/'
                                '${displayLicence.dateExpiration.year}',
                            isUpdated:
                                _datesHaveChanged &&
                                displayLicence.dateExpiration !=
                                    widget.licence.dateExpiration,
                          ),
                          _buildInfoRow(
                            'Jours depuis l\'expiration',
                            '$daysCount jours',
                          ),
                          _buildInfoRow(
                            'ID Local',
                            '${displayLicence.id ?? "N/A"}',
                          ),
                          _buildInfoRow(
                            'ID Serveur',
                            '${displayLicence.serverId ?? displayLicence.id ?? "N/A"}',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Status message
                    if (_statusMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _statusMessage!.contains('✅')
                              ? Colors.green[50]
                              : _statusMessage!.contains('❌')
                              ? Colors.red[50]
                              : Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _statusMessage!.contains('✅')
                                ? Colors.green
                                : _statusMessage!.contains('❌')
                                ? Colors.red
                                : Colors.blue,
                          ),
                        ),
                        child: Text(
                          _statusMessage!,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Auto-check indicator
                    if (_pollingTimer != null && _pollingTimer!.isActive) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AyannaColors.orange,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Vérification automatique active',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Prochaine vérification dans $_secondsUntilNextCheck s',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Manual check button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isChecking
                            ? null
                            : () => _checkLicenceStatus(),
                        icon: _isChecking
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(Icons.refresh),
                        label: Text(
                          _isChecking
                              ? 'Vérification...'
                              : 'Vérifier la Licence',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AyannaColors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Stop polling button (optional)
                    if (_pollingTimer != null && _pollingTimer!.isActive)
                      TextButton(
                        onPressed: () {
                          _stopPolling();
                          setState(() {
                            _statusMessage =
                                'Vérification automatique arrêtée.';
                          });
                        },
                        child: const Text(
                          'Arrêter la vérification automatique',
                        ),
                      ),

                    // DEBUG: Force local reactivation button
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 10),
                    Text(
                      'Ayanna school',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isUpdated = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isUpdated) ...[
                  Icon(Icons.fiber_new, color: Colors.blue[700], size: 18),
                  const SizedBox(width: 4),
                ],
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isUpdated
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isUpdated ? Colors.blue[700] : Colors.black87,
                    ),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
