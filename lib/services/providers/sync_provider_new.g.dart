// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_provider_new.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$syncServiceHash() => r'1414f301bb70b333fd85dfd5c91260024a976d33';

/// Provider pour le service de synchronisation
///
/// Copied from [syncService].
@ProviderFor(syncService)
final syncServiceProvider = AutoDisposeProvider<SyncService>.internal(
  syncService,
  name: r'syncServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$syncServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SyncServiceRef = AutoDisposeProviderRef<SyncService>;
String _$syncManagerHash() => r'74c837bdeccdc018e86188b6b7996ad0d6cb8131';

/// Provider pour gérer la synchronisation bidirectionnelle
///
/// Copied from [syncManager].
@ProviderFor(syncManager)
final syncManagerProvider = AutoDisposeProvider<SyncManager>.internal(
  syncManager,
  name: r'syncManagerProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$syncManagerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SyncManagerRef = AutoDisposeProviderRef<SyncManager>;
String _$syncStateNotifierHash() => r'2a93aa23ee6b523ae37fed4f00f77f88ece3a0af';

/// Provider pour l'état de synchronisation
///
/// Copied from [SyncStateNotifier].
@ProviderFor(SyncStateNotifier)
final syncStateNotifierProvider =
    AutoDisposeNotifierProvider<SyncStateNotifier, SyncState>.internal(
  SyncStateNotifier.new,
  name: r'syncStateNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$syncStateNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SyncStateNotifier = AutoDisposeNotifier<SyncState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
