// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_preferences_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sharedPreferencesHash() => r'7cd30c9640ca952d1bcf1772c709fc45dc47c8b3';

/// Provider pour SharedPreferences
///
/// Copied from [sharedPreferences].
@ProviderFor(sharedPreferences)
final sharedPreferencesProvider =
    AutoDisposeFutureProvider<SharedPreferences>.internal(
  sharedPreferences,
  name: r'sharedPreferencesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sharedPreferencesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SharedPreferencesRef = AutoDisposeFutureProviderRef<SharedPreferences>;
String _$syncPreferencesNotifierHash() =>
    r'444b20dcf8bbd10c3dee287c6010225596261154';

/// Provider pour gérer les données de synchronisation dans SharedPreferences
///
/// Copied from [SyncPreferencesNotifier].
@ProviderFor(SyncPreferencesNotifier)
final syncPreferencesNotifierProvider = AutoDisposeAsyncNotifierProvider<
    SyncPreferencesNotifier, Map<String, dynamic>>.internal(
  SyncPreferencesNotifier.new,
  name: r'syncPreferencesNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$syncPreferencesNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SyncPreferencesNotifier
    = AutoDisposeAsyncNotifier<Map<String, dynamic>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
