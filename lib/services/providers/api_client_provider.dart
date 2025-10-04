import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../api/api_client.dart';
import '../api/api_services.dart';

part 'api_client_provider.g.dart';

/// Provider pour l'instance ApiClient
/// Singleton qui gère tous les services API
@riverpod
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

@riverpod
EntrepriseService entrepriseService(EntrepriseServiceRef ref) {
  return ref.watch(apiClientProvider).entrepriseService;
}

@riverpod
UtilisateurService utilisateurService(UtilisateurServiceRef ref) {
  return ref.watch(apiClientProvider).utilisateurService;
}

@riverpod
AnneeScolaireService anneeScolaireService(AnneeScolaireServiceRef ref) {
  return ref.watch(apiClientProvider).anneeScolaireService;
}

@riverpod
EnseignantService enseignantService(EnseignantServiceRef ref) {
  return ref.watch(apiClientProvider).enseignantService;
}

@riverpod
ClasseService classeService(ClasseServiceRef ref) {
  return ref.watch(apiClientProvider).classeService;
}

@riverpod
EleveService eleveService(EleveServiceRef ref) {
  return ref.watch(apiClientProvider).eleveService;
}

@riverpod
ResponsableService responsableService(ResponsableServiceRef ref) {
  return ref.watch(apiClientProvider).responsableService;
}

@riverpod
CoursService coursService(CoursServiceRef ref) {
  return ref.watch(apiClientProvider).coursService;
}

@riverpod
NotePeriodeService notePeriodeService(NotePeriodeServiceRef ref) {
  return ref.watch(apiClientProvider).notePeriodeService;
}

@riverpod
PeriodeService periodeService(PeriodeServiceRef ref) {
  return ref.watch(apiClientProvider).periodeService;
}

@riverpod
FraisScolaireService fraisScolaireService(FraisScolaireServiceRef ref) {
  return ref.watch(apiClientProvider).fraisScolaireService;
}

@riverpod
PaiementFraisService paiementFraisService(PaiementFraisServiceRef ref) {
  return ref.watch(apiClientProvider).paiementFraisService;
}

@riverpod
CreanceService creanceService(CreanceServiceRef ref) {
  return ref.watch(apiClientProvider).creanceService;
}

@riverpod
ClasseComptableService classeComptableService(ClasseComptableServiceRef ref) {
  return ref.watch(apiClientProvider).classeComptableService;
}

@riverpod
CompteComptableService compteComptableService(CompteComptableServiceRef ref) {
  return ref.watch(apiClientProvider).compteComptableService;
}

@riverpod
JournalComptableService journalComptableService(
  JournalComptableServiceRef ref,
) {
  return ref.watch(apiClientProvider).journalComptableService;
}

@riverpod
EcritureComptableService ecritureComptableService(
  EcritureComptableServiceRef ref,
) {
  return ref.watch(apiClientProvider).ecritureComptableService;
}

@riverpod
DepenseService depenseService(DepenseServiceRef ref) {
  return ref.watch(apiClientProvider).depenseService;
}

@riverpod
LicenceService licenceService(LicenceServiceRef ref) {
  return ref.watch(apiClientProvider).licenceService;
}

@riverpod
ConfigEcoleService configEcoleService(ConfigEcoleServiceRef ref) {
  return ref.watch(apiClientProvider).configEcoleService;
}

@riverpod
ComptesConfigService comptesConfigService(ComptesConfigServiceRef ref) {
  return ref.watch(apiClientProvider).comptesConfigService;
}

@riverpod
PeriodesClassesService periodesClassesService(PeriodesClassesServiceRef ref) {
  return ref.watch(apiClientProvider).periodesClassesService;
}
