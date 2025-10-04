// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appSettingsNotifierHash() =>
    r'a6e6018e008af6e56b61c1cdaf693c3ee6657e42';

/// Provider pour les paramètres de l'application
///
/// Copied from [AppSettingsNotifier].
@ProviderFor(AppSettingsNotifier)
final appSettingsNotifierProvider = AutoDisposeNotifierProvider<
    AppSettingsNotifier, Map<String, dynamic>>.internal(
  AppSettingsNotifier.new,
  name: r'appSettingsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appSettingsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AppSettingsNotifier = AutoDisposeNotifier<Map<String, dynamic>>;
String _$syncNotifierHash() => r'd809ceb29ebfcbeecf6b228b5bbfbdc5044c5181';

/// Provider pour l'état de synchronisation
///
/// Copied from [SyncNotifier].
@ProviderFor(SyncNotifier)
final syncNotifierProvider =
    AutoDisposeNotifierProvider<SyncNotifier, Map<String, dynamic>>.internal(
  SyncNotifier.new,
  name: r'syncNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$syncNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SyncNotifier = AutoDisposeNotifier<Map<String, dynamic>>;
String _$networkNotifierHash() => r'd6da744ab18af1dd47554c39de050644f5f422b3';

/// Provider pour l'état de connectivité réseau
///
/// Copied from [NetworkNotifier].
@ProviderFor(NetworkNotifier)
final networkNotifierProvider =
    AutoDisposeNotifierProvider<NetworkNotifier, bool>.internal(
  NetworkNotifier.new,
  name: r'networkNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$networkNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NetworkNotifier = AutoDisposeNotifier<bool>;
String _$appStateNotifierHash() => r'62e1b2aa5815c16dd9e7f1248fcd0dfc1e1dc3e8';

/// Provider combiné pour l'état global de l'application
///
/// Copied from [AppStateNotifier].
@ProviderFor(AppStateNotifier)
final appStateNotifierProvider = AutoDisposeNotifierProvider<AppStateNotifier,
    Map<String, dynamic>>.internal(
  AppStateNotifier.new,
  name: r'appStateNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appStateNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AppStateNotifier = AutoDisposeNotifier<Map<String, dynamic>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
