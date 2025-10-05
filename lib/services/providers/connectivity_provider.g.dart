// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$isConnectedHash() => r'7e7643fc5444c530361a5d9a990874dc744b8d81';

/// Provider simple pour vérifier si l'appareil est connecté
///
/// Copied from [isConnected].
@ProviderFor(isConnected)
final isConnectedProvider = AutoDisposeProvider<bool>.internal(
  isConnected,
  name: r'isConnectedProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$isConnectedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef IsConnectedRef = AutoDisposeProviderRef<bool>;
String _$hasWifiHash() => r'e316f3bf56f075d61ef51fe9b4e0bb5b96ea1916';

/// Provider pour vérifier si le WiFi est disponible
///
/// Copied from [hasWifi].
@ProviderFor(hasWifi)
final hasWifiProvider = AutoDisposeProvider<bool>.internal(
  hasWifi,
  name: r'hasWifiProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$hasWifiHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef HasWifiRef = AutoDisposeProviderRef<bool>;
String _$hasMobileHash() => r'ae0c6541b58569e2a54d1401fc554a1d124cd1fc';

/// Provider pour vérifier si les données mobiles sont disponibles
///
/// Copied from [hasMobile].
@ProviderFor(hasMobile)
final hasMobileProvider = AutoDisposeProvider<bool>.internal(
  hasMobile,
  name: r'hasMobileProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$hasMobileHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef HasMobileRef = AutoDisposeProviderRef<bool>;
String _$hasEthernetHash() => r'652281a32070d2042023e9629caff0b6a9b9aef8';

/// Provider pour vérifier si Ethernet est disponible
///
/// Copied from [hasEthernet].
@ProviderFor(hasEthernet)
final hasEthernetProvider = AutoDisposeProvider<bool>.internal(
  hasEthernet,
  name: r'hasEthernetProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$hasEthernetHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef HasEthernetRef = AutoDisposeProviderRef<bool>;
String _$connectivityResultsHash() =>
    r'f56fc46b54f3530a2757cac2447e53d3ff1717d6';

/// Provider pour obtenir les types de connectivité actuels
///
/// Copied from [connectivityResults].
@ProviderFor(connectivityResults)
final connectivityResultsProvider =
    AutoDisposeProvider<List<ConnectivityResult>>.internal(
  connectivityResults,
  name: r'connectivityResultsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$connectivityResultsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ConnectivityResultsRef
    = AutoDisposeProviderRef<List<ConnectivityResult>>;
String _$connectivityNotifierHash() =>
    r'4498aa56ce05591c40bce929592bff2b5ba52193';

/// Provider pour surveiller les changements de connectivité en temps réel
///
/// Copied from [ConnectivityNotifier].
@ProviderFor(ConnectivityNotifier)
final connectivityNotifierProvider = AutoDisposeNotifierProvider<
    ConnectivityNotifier, ConnectivityState>.internal(
  ConnectivityNotifier.new,
  name: r'connectivityNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$connectivityNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ConnectivityNotifier = AutoDisposeNotifier<ConnectivityState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
