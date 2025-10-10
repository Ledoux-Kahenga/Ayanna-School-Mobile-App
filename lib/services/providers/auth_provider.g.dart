// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$isAuthenticatedHash() => r'5525109af3fded8041e904367c2097c77dc59c66';

/// Provider pour vérifier si l'utilisateur est authentifié
///
/// Copied from [isAuthenticated].
@ProviderFor(isAuthenticated)
final isAuthenticatedProvider = AutoDisposeProvider<bool>.internal(
  isAuthenticated,
  name: r'isAuthenticatedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isAuthenticatedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef IsAuthenticatedRef = AutoDisposeProviderRef<bool>;
String _$authTokenHash() => r'2a4d17f35dd7c557c0a99e6d630de30966f44672';

/// Provider pour obtenir le token d'authentification
///
/// Copied from [authToken].
@ProviderFor(authToken)
final authTokenProvider = AutoDisposeProvider<String?>.internal(
  authToken,
  name: r'authTokenProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authTokenHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AuthTokenRef = AutoDisposeProviderRef<String?>;
String _$currentUserIdHash() => r'b0db84076a0a3a2e9ecc429013eb91f28151bd9c';

/// Provider pour obtenir l'ID de l'utilisateur connecté
///
/// Copied from [currentUserId].
@ProviderFor(currentUserId)
final currentUserIdProvider = AutoDisposeProvider<int?>.internal(
  currentUserId,
  name: r'currentUserIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentUserIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentUserIdRef = AutoDisposeProviderRef<int?>;
String _$currentEntrepriseIdHash() =>
    r'4ed13c89a458c549ac846fd1667ac292f6750b64';

/// Provider pour obtenir l'ID de l'entreprise
///
/// Copied from [currentEntrepriseId].
@ProviderFor(currentEntrepriseId)
final currentEntrepriseIdProvider = AutoDisposeProvider<int?>.internal(
  currentEntrepriseId,
  name: r'currentEntrepriseIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentEntrepriseIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentEntrepriseIdRef = AutoDisposeProviderRef<int?>;
String _$currentUserEmailHash() => r'da69f78dae05b66b4f0303c428636339a381ddca';

/// Provider pour obtenir l'email de l'utilisateur connecté
///
/// Copied from [currentUserEmail].
@ProviderFor(currentUserEmail)
final currentUserEmailProvider = AutoDisposeProvider<String?>.internal(
  currentUserEmail,
  name: r'currentUserEmailProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentUserEmailHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentUserEmailRef = AutoDisposeProviderRef<String?>;
String _$authErrorHash() => r'eb178e66e3dd0f41de6dcda6f5751c77fea8646a';

/// Provider pour obtenir le message d'erreur d'authentification
///
/// Copied from [authError].
@ProviderFor(authError)
final authErrorProvider = AutoDisposeProvider<String?>.internal(
  authError,
  name: r'authErrorProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authErrorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AuthErrorRef = AutoDisposeProviderRef<String?>;
String _$isAuthLoadingHash() => r'1b7829bdb7aca9f67401500528d1c4d0521f92f8';

/// Provider pour vérifier si une authentification est en cours
///
/// Copied from [isAuthLoading].
@ProviderFor(isAuthLoading)
final isAuthLoadingProvider = AutoDisposeProvider<bool>.internal(
  isAuthLoading,
  name: r'isAuthLoadingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isAuthLoadingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef IsAuthLoadingRef = AutoDisposeProviderRef<bool>;
String _$userFriendlyAuthStatusHash() =>
    r'1eb43e47e808d576357aa6f85f15801a9f47cb7e';

/// Provider pour obtenir un message d'état utilisateur convivial
///
/// Copied from [userFriendlyAuthStatus].
@ProviderFor(userFriendlyAuthStatus)
final userFriendlyAuthStatusProvider = AutoDisposeProvider<String?>.internal(
  userFriendlyAuthStatus,
  name: r'userFriendlyAuthStatusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userFriendlyAuthStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UserFriendlyAuthStatusRef = AutoDisposeProviderRef<String?>;
String _$canWorkOfflineHash() => r'590561547680f132485587a53a8a7f8ec046c678';

/// Provider pour vérifier si l'utilisateur peut travailler hors ligne
///
/// Copied from [canWorkOffline].
@ProviderFor(canWorkOffline)
final canWorkOfflineProvider = AutoDisposeFutureProvider<bool>.internal(
  canWorkOffline,
  name: r'canWorkOfflineProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$canWorkOfflineHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CanWorkOfflineRef = AutoDisposeFutureProviderRef<bool>;
String _$authNotifierHash() => r'65e320a0a4f6dfb11c4eb7c0df2cf57ad67e0b40';

/// Provider pour l'état d'authentification
///
/// Copied from [AuthNotifier].
@ProviderFor(AuthNotifier)
final authNotifierProvider =
    AutoDisposeAsyncNotifierProvider<AuthNotifier, AuthState>.internal(
  AuthNotifier.new,
  name: r'authNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthNotifier = AutoDisposeAsyncNotifier<AuthState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
