// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ExportViewModel)
final exportViewModelProvider = ExportViewModelProvider._();

final class ExportViewModelProvider
    extends $NotifierProvider<ExportViewModel, bool> {
  ExportViewModelProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'exportViewModelProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$exportViewModelHash();

  @$internal
  @override
  ExportViewModel create() => ExportViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$exportViewModelHash() => r'724b8590df3d904c62bf6279cc6f63a1510207f7';

abstract class _$ExportViewModel extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<bool, bool>, bool, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}
