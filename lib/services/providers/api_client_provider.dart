import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../api/api_services.dart';

part 'api_client_provider.g.dart';

/// Provider pour l'instance ApiClient
/// Singleton qui gère tous les services API
@Riverpod(keepAlive: true)
ApiClient apiClient(ApiClientRef ref) {
  final client = ApiClient();

  // Dispose automatiquement quand le provider n'est plus utilisé
  ref.onDispose(() {
    client.dispose();
  });

  return client;
}

/// Providers pour chaque service API individuel
/// Cela permet d'accéder directement aux services spécifiques

@Riverpod(keepAlive: true)
EntrepriseService entrepriseService(EntrepriseServiceRef ref) {
  return ref.watch(apiClientProvider).entrepriseService;
}

@Riverpod(keepAlive: true)
UtilisateurService utilisateurService(UtilisateurServiceRef ref) {
  return ref.watch(apiClientProvider).utilisateurService;
}

@Riverpod(keepAlive: true)
AnneeScolaireService anneeScolaireService(AnneeScolaireServiceRef ref) {
  return ref.watch(apiClientProvider).anneeScolaireService;
}

@Riverpod(keepAlive: true)
EnseignantService enseignantService(EnseignantServiceRef ref) {
  return ref.watch(apiClientProvider).enseignantService;
}

@Riverpod(keepAlive: true)
ClasseService classeService(ClasseServiceRef ref) {
  return ref.watch(apiClientProvider).classeService;
}

@Riverpod(keepAlive: true)
EleveService eleveService(EleveServiceRef ref) {
  return ref.watch(apiClientProvider).eleveService;
}

@Riverpod(keepAlive: true)
ResponsableService responsableService(ResponsableServiceRef ref) {
  return ref.watch(apiClientProvider).responsableService;
}

@Riverpod(keepAlive: true)
CoursService coursService(CoursServiceRef ref) {
  return ref.watch(apiClientProvider).coursService;
}

@Riverpod(keepAlive: true)
NotePeriodeService notePeriodeService(NotePeriodeServiceRef ref) {
  return ref.watch(apiClientProvider).notePeriodeService;
}

@Riverpod(keepAlive: true)
PeriodeService periodeService(PeriodeServiceRef ref) {
  return ref.watch(apiClientProvider).periodeService;
}

@Riverpod(keepAlive: true)
FraisScolaireService fraisScolaireService(FraisScolaireServiceRef ref) {
  return ref.watch(apiClientProvider).fraisScolaireService;
}

@Riverpod(keepAlive: true)
PaiementFraisService paiementFraisService(PaiementFraisServiceRef ref) {
  return ref.watch(apiClientProvider).paiementFraisService;
}

@Riverpod(keepAlive: true)
CreanceService creanceService(CreanceServiceRef ref) {
  return ref.watch(apiClientProvider).creanceService;
}

@Riverpod(keepAlive: true)
ClasseComptableService classeComptableService(ClasseComptableServiceRef ref) {
  return ref.watch(apiClientProvider).classeComptableService;
}

@Riverpod(keepAlive: true)
CompteComptableService compteComptableService(CompteComptableServiceRef ref) {
  return ref.watch(apiClientProvider).compteComptableService;
}

@Riverpod(keepAlive: true)
JournalComptableService journalComptableService(
  JournalComptableServiceRef ref,
) {
  return ref.watch(apiClientProvider).journalComptableService;
}

@Riverpod(keepAlive: true)
EcritureComptableService ecritureComptableService(
  EcritureComptableServiceRef ref,
) {
  return ref.watch(apiClientProvider).ecritureComptableService;
}

@Riverpod(keepAlive: true)
DepenseService depenseService(DepenseServiceRef ref) {
  return ref.watch(apiClientProvider).depenseService;
}

@Riverpod(keepAlive: true)
LicenceService licenceService(LicenceServiceRef ref) {
  return ref.watch(apiClientProvider).licenceService;
}

@Riverpod(keepAlive: true)
ConfigEcoleService configEcoleService(ConfigEcoleServiceRef ref) {
  return ref.watch(apiClientProvider).configEcoleService;
}

@Riverpod(keepAlive: true)
ComptesConfigService comptesConfigService(ComptesConfigServiceRef ref) {
  return ref.watch(apiClientProvider).comptesConfigService;
}

@Riverpod(keepAlive: true)
PeriodesClassesService periodesClassesService(PeriodesClassesServiceRef ref) {
  return ref.watch(apiClientProvider).periodesClassesService;
}
