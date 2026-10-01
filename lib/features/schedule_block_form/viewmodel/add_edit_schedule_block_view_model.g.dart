// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_edit_schedule_block_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AddEditScheduleBlockViewModel)
final addEditScheduleBlockViewModelProvider =
    AddEditScheduleBlockViewModelProvider._();

final class AddEditScheduleBlockViewModelProvider
    extends $NotifierProvider<AddEditScheduleBlockViewModel, void> {
  AddEditScheduleBlockViewModelProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'addEditScheduleBlockViewModelProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$addEditScheduleBlockViewModelHash();

  @$internal
  @override
  AddEditScheduleBlockViewModel create() => AddEditScheduleBlockViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$addEditScheduleBlockViewModelHash() =>
    r'733f552fae0513ecb8d808782989dad8b5225095';

abstract class _$AddEditScheduleBlockViewModel extends $Notifier<void> {
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
