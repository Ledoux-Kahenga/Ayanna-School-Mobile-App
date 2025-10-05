// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_provider_new.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$syncServiceHash() => r'9bd1e552daf3dd7f22f04dc7251e8b11466f0e84';

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
String _$syncStateNotifierHash() => r'ba52bd63a25c77e9dd4f59543b1c0a664248b759';

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
