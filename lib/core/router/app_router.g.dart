// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Built once, after FlowlineApp has the stored settings: the first
/// location is decided then, so a first launch opens onboarding without
/// flashing Today first, and finishing it can't race a redirect against
/// the settings stream. If the settings can't be read, the app opens
/// normally rather than trapping the user in onboarding.

@ProviderFor(appRouter)
final appRouterProvider = AppRouterProvider._();

/// Built once, after FlowlineApp has the stored settings: the first
/// location is decided then, so a first launch opens onboarding without
/// flashing Today first, and finishing it can't race a redirect against
/// the settings stream. If the settings can't be read, the app opens
/// normally rather than trapping the user in onboarding.

final class AppRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// Built once, after FlowlineApp has the stored settings: the first
  /// location is decided then, so a first launch opens onboarding without
  /// flashing Today first, and finishing it can't race a redirect against
  /// the settings stream. If the settings can't be read, the app opens
  /// normally rather than trapping the user in onboarding.
  AppRouterProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'appRouterProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$appRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return appRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$appRouterHash() => r'3a6df975f3fb5adf91ee447eb936cdd7bc9d5da3';
