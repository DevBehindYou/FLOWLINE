// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The day shown on the Today tab. Follows [currentDayProvider], so it
/// moves to the new day at midnight instead of staying on yesterday.

@ProviderFor(SelectedDate)
final selectedDateProvider = SelectedDateProvider._();

/// The day shown on the Today tab. Follows [currentDayProvider], so it
/// moves to the new day at midnight instead of staying on yesterday.
final class SelectedDateProvider
    extends $NotifierProvider<SelectedDate, DateTime> {
  /// The day shown on the Today tab. Follows [currentDayProvider], so it
  /// moves to the new day at midnight instead of staying on yesterday.
  SelectedDateProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'selectedDateProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$selectedDateHash();

  @$internal
  @override
  SelectedDate create() => SelectedDate();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$selectedDateHash() => r'137a689018805c5e78fc30c8704f2fa79a938e23';

/// The day shown on the Today tab. Follows [currentDayProvider], so it
/// moves to the new day at midnight instead of staying on yesterday.

abstract class _$SelectedDate extends $Notifier<DateTime> {
  DateTime build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DateTime, DateTime>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<DateTime, DateTime>, DateTime, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(tasksForBlock)
final tasksForBlockProvider = TasksForBlockFamily._();

final class TasksForBlockProvider extends $FunctionalProvider<
        AsyncValue<List<Task>>, List<Task>, Stream<List<Task>>>
    with $FutureModifier<List<Task>>, $StreamProvider<List<Task>> {
  TasksForBlockProvider._(
      {required TasksForBlockFamily super.from, required int super.argument})
      : super(
          retry: null,
          name: r'tasksForBlockProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$tasksForBlockHash();

  @override
  String toString() {
    return r'tasksForBlockProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Task>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Task>> create(Ref ref) {
    final argument = this.argument as int;
    return tasksForBlock(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TasksForBlockProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tasksForBlockHash() => r'5152f0be77b83e99d5503b1837dbe284ae708be5';

final class TasksForBlockFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Task>>, int> {
  TasksForBlockFamily._()
      : super(
          retry: null,
          name: r'tasksForBlockProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  TasksForBlockProvider call(
    int blockId,
  ) =>
      TasksForBlockProvider._(argument: blockId, from: this);

  @override
  String toString() => r'tasksForBlockProvider';
}

@ProviderFor(unscheduledTasks)
final unscheduledTasksProvider = UnscheduledTasksProvider._();

final class UnscheduledTasksProvider extends $FunctionalProvider<
        AsyncValue<List<Task>>, List<Task>, Stream<List<Task>>>
    with $FutureModifier<List<Task>>, $StreamProvider<List<Task>> {
  UnscheduledTasksProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'unscheduledTasksProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$unscheduledTasksHash();

  @$internal
  @override
  $StreamProviderElement<List<Task>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Task>> create(Ref ref) {
    return unscheduledTasks(ref);
  }
}

String _$unscheduledTasksHash() => r'eb6903f9791f909da8764e2b6eb98d10b90bc385';

@ProviderFor(scheduleBlocksForSelectedDate)
final scheduleBlocksForSelectedDateProvider =
    ScheduleBlocksForSelectedDateProvider._();

final class ScheduleBlocksForSelectedDateProvider extends $FunctionalProvider<
        AsyncValue<List<ScheduleBlock>>,
        List<ScheduleBlock>,
        Stream<List<ScheduleBlock>>>
    with
        $FutureModifier<List<ScheduleBlock>>,
        $StreamProvider<List<ScheduleBlock>> {
  ScheduleBlocksForSelectedDateProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'scheduleBlocksForSelectedDateProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$scheduleBlocksForSelectedDateHash();

  @$internal
  @override
  $StreamProviderElement<List<ScheduleBlock>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<ScheduleBlock>> create(Ref ref) {
    return scheduleBlocksForSelectedDate(ref);
  }
}

String _$scheduleBlocksForSelectedDateHash() =>
    r'b2e586367956a369cbb28d6f4273594de059ad69';

/// Action surface for the Today screen. The View calls through here
/// rather than touching repositories directly, keeping the MVVM boundary
/// even though there's no separate state to hold beyond the streams
/// above — see the README for why a full Use Case layer isn't here yet.
// keepAlive (rule R11): an action surface whose methods use `ref` after
// an `await`. Auto-dispose would let it be disposed mid-action (the sheet
// or screen that called it closes), and Riverpod 3 throws on any use of a
// disposed Ref.

@ProviderFor(TodayActions)
final todayActionsProvider = TodayActionsProvider._();

/// Action surface for the Today screen. The View calls through here
/// rather than touching repositories directly, keeping the MVVM boundary
/// even though there's no separate state to hold beyond the streams
/// above — see the README for why a full Use Case layer isn't here yet.
// keepAlive (rule R11): an action surface whose methods use `ref` after
// an `await`. Auto-dispose would let it be disposed mid-action (the sheet
// or screen that called it closes), and Riverpod 3 throws on any use of a
// disposed Ref.
final class TodayActionsProvider extends $NotifierProvider<TodayActions, void> {
  /// Action surface for the Today screen. The View calls through here
  /// rather than touching repositories directly, keeping the MVVM boundary
  /// even though there's no separate state to hold beyond the streams
  /// above — see the README for why a full Use Case layer isn't here yet.
// keepAlive (rule R11): an action surface whose methods use `ref` after
// an `await`. Auto-dispose would let it be disposed mid-action (the sheet
// or screen that called it closes), and Riverpod 3 throws on any use of a
// disposed Ref.
  TodayActionsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'todayActionsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$todayActionsHash();

  @$internal
  @override
  TodayActions create() => TodayActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$todayActionsHash() => r'e1813efec2159414802432837c6e16f25a2a5e56';

/// Action surface for the Today screen. The View calls through here
/// rather than touching repositories directly, keeping the MVVM boundary
/// even though there's no separate state to hold beyond the streams
/// above — see the README for why a full Use Case layer isn't here yet.
// keepAlive (rule R11): an action surface whose methods use `ref` after
// an `await`. Auto-dispose would let it be disposed mid-action (the sheet
// or screen that called it closes), and Riverpod 3 throws on any use of a
// disposed Ref.

abstract class _$TodayActions extends $Notifier<void> {
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
