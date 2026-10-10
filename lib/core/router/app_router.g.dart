// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Built once, after AtomicAssistApp has the stored settings: the first
/// location is decided then, so a first launch opens onboarding without
/// flashing Today first, and finishing it can't race a redirect against
/// the settings stream. If the settings can't be read, the app opens
/// normally rather than trapping the user in onboarding.

@ProviderFor(appRouter)
final appRouterProvider = AppRouterProvider._();

/// Built once, after AtomicAssistApp has the stored settings: the first
/// location is decided then, so a first launch opens onboarding without
/// flashing Today first, and finishing it can't race a redirect against
/// the settings stream. If the settings can't be read, the app opens
/// normally rather than trapping the user in onboarding.

final class AppRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// Built once, after AtomicAssistApp has the stored settings: the first
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

String _$appRouterHash() => r'c5a13c91dc615abd511df6d29d570541b20941f3';
