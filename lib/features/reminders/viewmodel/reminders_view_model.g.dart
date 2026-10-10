// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminders_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(openReminders)
final openRemindersProvider = OpenRemindersProvider._();

final class OpenRemindersProvider extends $FunctionalProvider<
        AsyncValue<List<Reminder>>, List<Reminder>, Stream<List<Reminder>>>
    with $FutureModifier<List<Reminder>>, $StreamProvider<List<Reminder>> {
  OpenRemindersProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'openRemindersProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$openRemindersHash();

  @$internal
  @override
  $StreamProviderElement<List<Reminder>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Reminder>> create(Ref ref) {
    return openReminders(ref);
  }
}

String _$openRemindersHash() => r'0853656f0f73c432709383dee5b1b6950b954544';

@ProviderFor(RemindersActions)
final remindersActionsProvider = RemindersActionsProvider._();

final class RemindersActionsProvider
    extends $NotifierProvider<RemindersActions, void> {
  RemindersActionsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'remindersActionsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$remindersActionsHash();

  @$internal
  @override
  RemindersActions create() => RemindersActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$remindersActionsHash() => r'53615865a9b658495c43b72e8f01efc6ef701d9a';

abstract class _$RemindersActions extends $Notifier<void> {
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
