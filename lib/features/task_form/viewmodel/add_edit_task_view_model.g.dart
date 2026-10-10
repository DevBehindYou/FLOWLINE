// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_edit_task_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AddEditTaskViewModel)
final addEditTaskViewModelProvider = AddEditTaskViewModelProvider._();

final class AddEditTaskViewModelProvider
    extends $NotifierProvider<AddEditTaskViewModel, void> {
  AddEditTaskViewModelProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'addEditTaskViewModelProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$addEditTaskViewModelHash();

  @$internal
  @override
  AddEditTaskViewModel create() => AddEditTaskViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$addEditTaskViewModelHash() =>
    r'e3d79aa0b36db6260c8c5be09e9913bcde34bb5d';

abstract class _$AddEditTaskViewModel extends $Notifier<void> {
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
