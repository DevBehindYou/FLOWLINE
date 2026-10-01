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

/// The selected day's blocks with their tasks, from one query (B21).

@ProviderFor(dayPlan)
final dayPlanProvider = DayPlanProvider._();

/// The selected day's blocks with their tasks, from one query (B21).

final class DayPlanProvider extends $FunctionalProvider<
        AsyncValue<List<PlannedBlock>>,
        List<PlannedBlock>,
        Stream<List<PlannedBlock>>>
    with
        $FutureModifier<List<PlannedBlock>>,
        $StreamProvider<List<PlannedBlock>> {
  /// The selected day's blocks with their tasks, from one query (B21).
  DayPlanProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'dayPlanProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$dayPlanHash();

  @$internal
  @override
  $StreamProviderElement<List<PlannedBlock>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<PlannedBlock>> create(Ref ref) {
    return dayPlan(ref);
  }
}

String _$dayPlanHash() => r'f7bddf9cc5b012014b363d22320bff0f4287ddd0';

/// How many open backlog tasks are shown; "Show more" raises it (B20).

@ProviderFor(BacklogLimit)
final backlogLimitProvider = BacklogLimitProvider._();

/// How many open backlog tasks are shown; "Show more" raises it (B20).
final class BacklogLimitProvider extends $NotifierProvider<BacklogLimit, int> {
  /// How many open backlog tasks are shown; "Show more" raises it (B20).
  BacklogLimitProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'backlogLimitProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$backlogLimitHash();

  @$internal
  @override
  BacklogLimit create() => BacklogLimit();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$backlogLimitHash() => r'5886af562555bf23c22821ffb40f034132b529ba';

/// How many open backlog tasks are shown; "Show more" raises it (B20).

abstract class _$BacklogLimit extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element = ref.element
        as $ClassProviderElement<AnyNotifier<int, int>, int, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}

/// Open backlog tasks. Reads one past the limit, so the view knows
/// whether to offer "Show more" without a separate count query.

@ProviderFor(openBacklog)
final openBacklogProvider = OpenBacklogProvider._();

/// Open backlog tasks. Reads one past the limit, so the view knows
/// whether to offer "Show more" without a separate count query.

final class OpenBacklogProvider extends $FunctionalProvider<
        AsyncValue<List<Task>>, List<Task>, Stream<List<Task>>>
    with $FutureModifier<List<Task>>, $StreamProvider<List<Task>> {
  /// Open backlog tasks. Reads one past the limit, so the view knows
  /// whether to offer "Show more" without a separate count query.
  OpenBacklogProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'openBacklogProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$openBacklogHash();

  @$internal
  @override
  $StreamProviderElement<List<Task>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Task>> create(Ref ref) {
    return openBacklog(ref);
  }
}

String _$openBacklogHash() => r'13b00acb753f351d6e24818206f526c7d3fa323f';

/// Whether completed backlog tasks are listed (collapsed by default).

@ProviderFor(ShowCompletedBacklog)
final showCompletedBacklogProvider = ShowCompletedBacklogProvider._();

/// Whether completed backlog tasks are listed (collapsed by default).
final class ShowCompletedBacklogProvider
    extends $NotifierProvider<ShowCompletedBacklog, bool> {
  /// Whether completed backlog tasks are listed (collapsed by default).
  ShowCompletedBacklogProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'showCompletedBacklogProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$showCompletedBacklogHash();

  @$internal
  @override
  ShowCompletedBacklog create() => ShowCompletedBacklog();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$showCompletedBacklogHash() =>
    r'cc49c22b819ac252a461f5f5b5610ba5196fd247';

/// Whether completed backlog tasks are listed (collapsed by default).

abstract class _$ShowCompletedBacklog extends $Notifier<bool> {
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

@ProviderFor(completedBacklogCount)
final completedBacklogCountProvider = CompletedBacklogCountProvider._();

final class CompletedBacklogCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  CompletedBacklogCountProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'completedBacklogCountProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$completedBacklogCountHash();

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return completedBacklogCount(ref);
  }
}

String _$completedBacklogCountHash() =>
    r'abe3ad556966293c5d3c6c1fbba6e4fc35e7df0b';

/// The most recent completed backlog tasks, when they're shown.

@ProviderFor(completedBacklog)
final completedBacklogProvider = CompletedBacklogProvider._();

/// The most recent completed backlog tasks, when they're shown.

final class CompletedBacklogProvider extends $FunctionalProvider<
        AsyncValue<List<Task>>, List<Task>, Stream<List<Task>>>
    with $FutureModifier<List<Task>>, $StreamProvider<List<Task>> {
  /// The most recent completed backlog tasks, when they're shown.
  CompletedBacklogProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'completedBacklogProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$completedBacklogHash();

  @$internal
  @override
  $StreamProviderElement<List<Task>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Task>> create(Ref ref) {
    return completedBacklog(ref);
  }
}

String _$completedBacklogHash() => r'acacfd9ee9a2f20163e2f31d05c85ca90524ac5f';

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
