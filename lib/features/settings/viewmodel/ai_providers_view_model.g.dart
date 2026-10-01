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
    r'49386e8377ce63257e284b5024a36b67e0bc9592';

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

/// The last model list fetched per provider in this session, so reopening
/// the sheet doesn't need another Test connection.

@ProviderFor(ProviderModels)
final providerModelsProvider = ProviderModelsProvider._();

/// The last model list fetched per provider in this session, so reopening
/// the sheet doesn't need another Test connection.
final class ProviderModelsProvider extends $NotifierProvider<ProviderModels,
    Map<AIProviderId, List<AIModelInfo>>> {
  /// The last model list fetched per provider in this session, so reopening
  /// the sheet doesn't need another Test connection.
  ProviderModelsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'providerModelsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$providerModelsHash();

  @$internal
  @override
  ProviderModels create() => ProviderModels();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<AIProviderId, List<AIModelInfo>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<Map<AIProviderId, List<AIModelInfo>>>(value),
    );
  }
}

String _$providerModelsHash() => r'23014b3706f495dd957375fae023df70395f8c96';

/// The last model list fetched per provider in this session, so reopening
/// the sheet doesn't need another Test connection.

abstract class _$ProviderModels
    extends $Notifier<Map<AIProviderId, List<AIModelInfo>>> {
  Map<AIProviderId, List<AIModelInfo>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Map<AIProviderId, List<AIModelInfo>>,
        Map<AIProviderId, List<AIModelInfo>>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<Map<AIProviderId, List<AIModelInfo>>,
            Map<AIProviderId, List<AIModelInfo>>>,
        Map<AIProviderId, List<AIModelInfo>>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
