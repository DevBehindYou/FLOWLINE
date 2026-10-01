// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_providers_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AiProvidersViewModel)
final aiProvidersViewModelProvider = AiProvidersViewModelProvider._();

final class AiProvidersViewModelProvider
    extends $NotifierProvider<AiProvidersViewModel, void> {
  AiProvidersViewModelProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'aiProvidersViewModelProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$aiProvidersViewModelHash();

  @$internal
  @override
  AiProvidersViewModel create() => AiProvidersViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$aiProvidersViewModelHash() =>
    r'c1a72245c88b0f7f23041bbd3876ff50dae04d16';

abstract class _$AiProvidersViewModel extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<void, void>, void, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}
