import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/entities/licence.dart';
import '../providers/providers.dart';

/// Provider qui vérifie la validité de la licence courante
///
/// Retourne:
/// - `null` si aucune licence n'existe
/// - `Licence` valide si active==true et date valide
/// - `Licence` invalide si expirée ou active==false
final licenceValidationProvider = FutureProvider.autoDispose<LicenceValidationState>((
  ref,
) async {
  try {
    // Get entreprise
    final entreprises = await ref.watch(entreprisesNotifierProvider.future);
    if (entreprises.isEmpty) {
      return LicenceValidationState.noEntreprise();
    }

    final entreprise = entreprises.first;

    // SQL: SELECT * FROM licence WHERE entreprise_id = entreprise.id
    final dao = ref.watch(licenceDaoProvider);
    final licence = await dao.getLicencesByEntreprise(entreprise.id!);

    if (licence == null) {
      return LicenceValidationState.noLicence();
    }

    print(
      '✅ Licence trouvée: ID ${licence.id}, Server ID: ${licence.serverId}',
    );

    Licence chosen = licence;

    // ⚠️ NOUVELLE LOGIQUE: Validation basée UNIQUEMENT sur les dates
    // On ignore le champ 'active' car le serveur ne le gère pas
    final now = DateTime.now();

    // La licence expire à la fin du jour (23h59:59)
    final expirationEndOfDay = DateTime(
      chosen.dateExpiration.year,
      chosen.dateExpiration.month,
      chosen.dateExpiration.day,
      23,
      59,
      59,
    );

    // Vérification: Si date actuelle > date expiration à 23h59 → BLOQUER
    final isExpired = now.isAfter(expirationEndOfDay);
    final isAfterActivation = now.isAfter(chosen.dateActivation);

    // La licence est valide SI: activée ET non expirée
    final isValid = isAfterActivation && !isExpired;

    // Debug log
    print('🔍 Validation Licence (à chaque démarrage):');
    print('  - ID: ${chosen.id}, Server ID: ${chosen.serverId}');
    print('  - Date activation: ${chosen.dateActivation}');
    print('  - Date expiration: ${chosen.dateExpiration}');
    print('  - Expiration (fin de journée): $expirationEndOfDay');
    print('  - Date actuelle: $now');
    print('  - Après activation: $isAfterActivation');
    print('  - Expirée (now > 23h59 du jour expiration): $isExpired');
    print('  - isValid: $isValid');

    // Auto-update du statut actif local basé sur les dates
    if (chosen.id != null) {
      if (isValid && chosen.active != true) {
        // Licence valide mais marquée inactive → activer
        print('  ✅ Activation automatique (dates valides)');
        await dao.activerLicence(chosen.id!);
        chosen = chosen.copyWith(active: true);
      } else if (!isValid && chosen.active == true) {
        // Licence expirée mais marquée active → désactiver
        print(
          '  ⚠️ Désactivation automatique (licence expirée: now >= dateExpiration)',
        );
        await dao.desactiverLicence(chosen.id!);
        chosen = chosen.copyWith(active: false);
      }
    }

    return LicenceValidationState(
      licence: chosen,
      isValid: isValid,
      reason: isValid
          ? null
          : 'Licence expirée le ${chosen.dateExpiration.toIso8601String().substring(0, 10)}',
    );
  } catch (e) {
    return LicenceValidationState.error(e.toString());
  }
});

/// État de validation de licence
class LicenceValidationState {
  final Licence? licence;
  final bool isValid;
  final String? reason;
  final bool hasError;
  final String? errorMessage;

  const LicenceValidationState({
    this.licence,
    required this.isValid,
    this.reason,
    this.hasError = false,
    this.errorMessage,
  });

  factory LicenceValidationState.noLicence() {
    return const LicenceValidationState(
      isValid: false,
      reason: 'Aucune licence trouvée',
    );
  }

  factory LicenceValidationState.noEntreprise() {
    return const LicenceValidationState(
      isValid: false,
      reason: 'Aucune entreprise configurée',
    );
  }

  factory LicenceValidationState.error(String message) {
    return LicenceValidationState(
      isValid: false,
      hasError: true,
      errorMessage: message,
      reason: 'Erreur de vérification',
    );
  }

  bool get shouldBlockApp => !isValid && licence != null;
}
