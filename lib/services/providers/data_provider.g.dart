// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentAnneeScolaireHash() =>
    r'9eeeaf7ec431940b58247abd06e13763520ee5d5';

/// Provider pour obtenir l'année scolaire en cours
/// Ce provider récupère la configuration de l'école et retourne l'année scolaire active
///
/// Copied from [currentAnneeScolaire].
@ProviderFor(currentAnneeScolaire)
final currentAnneeScolaireProvider =
    AutoDisposeFutureProvider<AnneeScolaire?>.internal(
  currentAnneeScolaire,
  name: r'currentAnneeScolaireProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentAnneeScolaireHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentAnneeScolaireRef = AutoDisposeFutureProviderRef<AnneeScolaire?>;
String _$elevesNotifierHash() => r'a644ebbe878cf0ad6e1933f9bbed3996617a27cc';

/// Provider pour la liste des élèves
///
/// Copied from [ElevesNotifier].
@ProviderFor(ElevesNotifier)
final elevesNotifierProvider =
    AutoDisposeAsyncNotifierProvider<ElevesNotifier, List<Eleve>>.internal(
  ElevesNotifier.new,
  name: r'elevesNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$elevesNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ElevesNotifier = AutoDisposeAsyncNotifier<List<Eleve>>;
String _$classesNotifierHash() => r'dff7e8afa6a6e4307a30fc80a8dcc05372c0ae8b';

/// Provider pour la liste des classes
///
/// Copied from [ClassesNotifier].
@ProviderFor(ClassesNotifier)
final classesNotifierProvider =
    AutoDisposeAsyncNotifierProvider<ClassesNotifier, List<Classe>>.internal(
  ClassesNotifier.new,
  name: r'classesNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$classesNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ClassesNotifier = AutoDisposeAsyncNotifier<List<Classe>>;
String _$enseignantsNotifierHash() =>
    r'5e3f234c2b1e7cc61ac6529da1887af137d20104';

/// Provider pour la liste des enseignants
///
/// Copied from [EnseignantsNotifier].
@ProviderFor(EnseignantsNotifier)
final enseignantsNotifierProvider = AutoDisposeAsyncNotifierProvider<
    EnseignantsNotifier, List<Enseignant>>.internal(
  EnseignantsNotifier.new,
  name: r'enseignantsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$enseignantsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$EnseignantsNotifier = AutoDisposeAsyncNotifier<List<Enseignant>>;
String _$responsablesNotifierHash() =>
    r'b8b4408ba947b6be2821757d86a528cb1f22d99d';

/// Provider pour la liste des responsables
///
/// Copied from [ResponsablesNotifier].
@ProviderFor(ResponsablesNotifier)
final responsablesNotifierProvider = AutoDisposeAsyncNotifierProvider<
    ResponsablesNotifier, List<Responsable>>.internal(
  ResponsablesNotifier.new,
  name: r'responsablesNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$responsablesNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ResponsablesNotifier = AutoDisposeAsyncNotifier<List<Responsable>>;
String _$utilisateursNotifierHash() =>
    r'f9e346f0f720fe6f611f706c864a24f87a80c6ef';

/// Provider pour la liste des utilisateurs
///
/// Copied from [UtilisateursNotifier].
@ProviderFor(UtilisateursNotifier)
final utilisateursNotifierProvider = AutoDisposeAsyncNotifierProvider<
    UtilisateursNotifier, List<Utilisateur>>.internal(
  UtilisateursNotifier.new,
  name: r'utilisateursNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$utilisateursNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UtilisateursNotifier = AutoDisposeAsyncNotifier<List<Utilisateur>>;
String _$anneesScolairesNotifierHash() =>
    r'b779de759ebed3e868da117696f6d0a51032f14e';

/// Provider pour la liste des années scolaires
///
/// Copied from [AnneesScolairesNotifier].
@ProviderFor(AnneesScolairesNotifier)
final anneesScolairesNotifierProvider = AutoDisposeAsyncNotifierProvider<
    AnneesScolairesNotifier, List<AnneeScolaire>>.internal(
  AnneesScolairesNotifier.new,
  name: r'anneesScolairesNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$anneesScolairesNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AnneesScolairesNotifier
    = AutoDisposeAsyncNotifier<List<AnneeScolaire>>;
String _$fraisScolairesNotifierHash() =>
    r'bf265b1321000909af42b9935f8c46dc7fecf650';

/// Provider pour la liste des frais scolaires
///
/// Copied from [FraisScolairesNotifier].
@ProviderFor(FraisScolairesNotifier)
final fraisScolairesNotifierProvider = AutoDisposeAsyncNotifierProvider<
    FraisScolairesNotifier, List<FraisScolaire>>.internal(
  FraisScolairesNotifier.new,
  name: r'fraisScolairesNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fraisScolairesNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FraisScolairesNotifier
    = AutoDisposeAsyncNotifier<List<FraisScolaire>>;
String _$paiementsFraisNotifierHash() =>
    r'e965bc691e94fd0f90369b096b887e9124bb433a';

/// Provider pour la liste des paiements de frais
///
/// Copied from [PaiementsFraisNotifier].
@ProviderFor(PaiementsFraisNotifier)
final paiementsFraisNotifierProvider = AutoDisposeAsyncNotifierProvider<
    PaiementsFraisNotifier, List<PaiementFrais>>.internal(
  PaiementsFraisNotifier.new,
  name: r'paiementsFraisNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$paiementsFraisNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PaiementsFraisNotifier
    = AutoDisposeAsyncNotifier<List<PaiementFrais>>;
String _$notesPeriodesNotifierHash() =>
    r'11c80074a6030d4e9cb3277dd76e191c04a7a167';

/// Provider pour la liste des notes par période
///
/// Copied from [NotesPeriodesNotifier].
@ProviderFor(NotesPeriodesNotifier)
final notesPeriodesNotifierProvider = AutoDisposeAsyncNotifierProvider<
    NotesPeriodesNotifier, List<NotePeriode>>.internal(
  NotesPeriodesNotifier.new,
  name: r'notesPeriodesNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notesPeriodesNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NotesPeriodesNotifier = AutoDisposeAsyncNotifier<List<NotePeriode>>;
String _$configEcolesNotifierHash() =>
    r'3794ac8267a16cde1b0a7e4b24620d2a0ddaa857';

/// Provider pour la liste des configurations d'école
///
/// Copied from [ConfigEcolesNotifier].
@ProviderFor(ConfigEcolesNotifier)
final configEcolesNotifierProvider = AutoDisposeAsyncNotifierProvider<
    ConfigEcolesNotifier, List<ConfigEcole>>.internal(
  ConfigEcolesNotifier.new,
  name: r'configEcolesNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$configEcolesNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ConfigEcolesNotifier = AutoDisposeAsyncNotifier<List<ConfigEcole>>;
String _$coursNotifierHash() => r'684d360e1d1f19dd9f2e80d4f06b8b91fabc3470';

/// Provider pour la liste des cours
///
/// Copied from [CoursNotifier].
@ProviderFor(CoursNotifier)
final coursNotifierProvider =
    AutoDisposeAsyncNotifierProvider<CoursNotifier, List<Cours>>.internal(
  CoursNotifier.new,
  name: r'coursNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$coursNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CoursNotifier = AutoDisposeAsyncNotifier<List<Cours>>;
String _$entreprisesNotifierHash() =>
    r'ba5e603f02569d79e60fb53a5701cb469bc913ed';

/// Provider pour la liste des entreprises
///
/// Copied from [EntreprisesNotifier].
@ProviderFor(EntreprisesNotifier)
final entreprisesNotifierProvider = AutoDisposeAsyncNotifierProvider<
    EntreprisesNotifier, List<Entreprise>>.internal(
  EntreprisesNotifier.new,
  name: r'entreprisesNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$entreprisesNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$EntreprisesNotifier = AutoDisposeAsyncNotifier<List<Entreprise>>;
String _$licencesNotifierHash() => r'111c1c42a352be09c7b2eb5ae3162b61e4b56a07';

/// Provider pour la liste des licences
///
/// Copied from [LicencesNotifier].
@ProviderFor(LicencesNotifier)
final licencesNotifierProvider =
    AutoDisposeAsyncNotifierProvider<LicencesNotifier, List<Licence>>.internal(
  LicencesNotifier.new,
  name: r'licencesNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$licencesNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LicencesNotifier = AutoDisposeAsyncNotifier<List<Licence>>;
String _$periodesClassesNotifierHash() =>
    r'fab1ded54877c98e4365b0a3fb6ebb229ab15e6b';

/// Provider pour la liste des périodes classes
///
/// Copied from [PeriodesClassesNotifier].
@ProviderFor(PeriodesClassesNotifier)
final periodesClassesNotifierProvider = AutoDisposeAsyncNotifierProvider<
    PeriodesClassesNotifier, List<PeriodesClasses>>.internal(
  PeriodesClassesNotifier.new,
  name: r'periodesClassesNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$periodesClassesNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PeriodesClassesNotifier
    = AutoDisposeAsyncNotifier<List<PeriodesClasses>>;
String _$creancesNotifierHash() => r'f9b5a737d8e3afb2c1309fa701a58e294e132466';

/// Provider pour la liste des créances
///
/// Copied from [CreancesNotifier].
@ProviderFor(CreancesNotifier)
final creancesNotifierProvider =
    AutoDisposeAsyncNotifierProvider<CreancesNotifier, List<Creance>>.internal(
  CreancesNotifier.new,
  name: r'creancesNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$creancesNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CreancesNotifier = AutoDisposeAsyncNotifier<List<Creance>>;
String _$depensesNotifierHash() => r'610c26512668521fa5f23084ecc7f8e55ee1cdb9';

/// Provider pour la liste des dépenses
///
/// Copied from [DepensesNotifier].
@ProviderFor(DepensesNotifier)
final depensesNotifierProvider =
    AutoDisposeAsyncNotifierProvider<DepensesNotifier, List<Depense>>.internal(
  DepensesNotifier.new,
  name: r'depensesNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$depensesNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DepensesNotifier = AutoDisposeAsyncNotifier<List<Depense>>;
String _$classesComptablesNotifierHash() =>
    r'9324a888db90f2290d3c797f8bf145175faafb51';

/// Provider pour la liste des classes comptables
///
/// Copied from [ClassesComptablesNotifier].
@ProviderFor(ClassesComptablesNotifier)
final classesComptablesNotifierProvider = AutoDisposeAsyncNotifierProvider<
    ClassesComptablesNotifier, List<ClasseComptable>>.internal(
  ClassesComptablesNotifier.new,
  name: r'classesComptablesNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$classesComptablesNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ClassesComptablesNotifier
    = AutoDisposeAsyncNotifier<List<ClasseComptable>>;
String _$comptesComptablesNotifierHash() =>
    r'689637b0452bb9a22adce6a7a69ecc3366c042b4';

/// Provider pour la liste des comptes comptables
///
/// Copied from [ComptesComptablesNotifier].
@ProviderFor(ComptesComptablesNotifier)
final comptesComptablesNotifierProvider = AutoDisposeAsyncNotifierProvider<
    ComptesComptablesNotifier, List<CompteComptable>>.internal(
  ComptesComptablesNotifier.new,
  name: r'comptesComptablesNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$comptesComptablesNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ComptesComptablesNotifier
    = AutoDisposeAsyncNotifier<List<CompteComptable>>;
String _$comptesConfigsNotifierHash() =>
    r'27ae068749f97888ef64f738bd715a5b81b76dbd';

/// Provider pour la liste des configurations de comptes
///
/// Copied from [ComptesConfigsNotifier].
@ProviderFor(ComptesConfigsNotifier)
final comptesConfigsNotifierProvider = AutoDisposeAsyncNotifierProvider<
    ComptesConfigsNotifier, List<ComptesConfig>>.internal(
  ComptesConfigsNotifier.new,
  name: r'comptesConfigsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$comptesConfigsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ComptesConfigsNotifier
    = AutoDisposeAsyncNotifier<List<ComptesConfig>>;
String _$ecrituresComptablesNotifierHash() =>
    r'806fa91c293ede16cd98bdc604e0f72bcda88ca1';

/// Provider pour la liste des écritures comptables
///
/// Copied from [EcrituresComptablesNotifier].
@ProviderFor(EcrituresComptablesNotifier)
final ecrituresComptablesNotifierProvider = AutoDisposeAsyncNotifierProvider<
    EcrituresComptablesNotifier, List<EcritureComptable>>.internal(
  EcrituresComptablesNotifier.new,
  name: r'ecrituresComptablesNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$ecrituresComptablesNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$EcrituresComptablesNotifier
    = AutoDisposeAsyncNotifier<List<EcritureComptable>>;
String _$journauxComptablesNotifierHash() =>
    r'4fa2b5136f157173572c7558db86e5c95a5d4ad8';

/// Provider pour la liste des journaux comptables
///
/// Copied from [JournauxComptablesNotifier].
@ProviderFor(JournauxComptablesNotifier)
final journauxComptablesNotifierProvider = AutoDisposeAsyncNotifierProvider<
    JournauxComptablesNotifier, List<JournalComptable>>.internal(
  JournauxComptablesNotifier.new,
  name: r'journauxComptablesNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$journauxComptablesNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$JournauxComptablesNotifier
    = AutoDisposeAsyncNotifier<List<JournalComptable>>;
String _$periodesNotifierHash() => r'9f9592e98855e336d8c00587831ef09776b3495c';

/// Provider pour la liste des périodes
///
/// Copied from [PeriodesNotifier].
@ProviderFor(PeriodesNotifier)
final periodesNotifierProvider =
    AutoDisposeAsyncNotifierProvider<PeriodesNotifier, List<Periode>>.internal(
  PeriodesNotifier.new,
  name: r'periodesNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$periodesNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PeriodesNotifier = AutoDisposeAsyncNotifier<List<Periode>>;
String _$fraisClassesNotifierHash() =>
    r'829e737b6f668504f373000dba5882ed67a31701';

/// See also [FraisClassesNotifier].
@ProviderFor(FraisClassesNotifier)
final fraisClassesNotifierProvider = AutoDisposeAsyncNotifierProvider<
    FraisClassesNotifier, List<FraisClasses>>.internal(
  FraisClassesNotifier.new,
  name: r'fraisClassesNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fraisClassesNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FraisClassesNotifier = AutoDisposeAsyncNotifier<List<FraisClasses>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
