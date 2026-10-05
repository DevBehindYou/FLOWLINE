// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'focus_timer_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(activeFocusSession)
final activeFocusSessionProvider = ActiveFocusSessionProvider._();

final class ActiveFocusSessionProvider extends $FunctionalProvider<
        AsyncValue<FocusSession?>, FocusSession?, Stream<FocusSession?>>
    with $FutureModifier<FocusSession?>, $StreamProvider<FocusSession?> {
  ActiveFocusSessionProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'activeFocusSessionProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$activeFocusSessionHash();

  @$internal
  @override
  $StreamProviderElement<FocusSession?> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<FocusSession?> create(Ref ref) {
    return activeFocusSession(ref);
  }
}

String _$activeFocusSessionHash() =>
    r'ee71950e0aca9853b959c84ec38c3620eda4f2f7';

@ProviderFor(todaysFocusSummary)
final todaysFocusSummaryProvider = TodaysFocusSummaryProvider._();

final class TodaysFocusSummaryProvider extends $FunctionalProvider<
        AsyncValue<
            ({
              int sessionCount,
              int totalSeconds,
            })>,
        ({
          int sessionCount,
          int totalSeconds,
        }),
        Stream<
            ({
              int sessionCount,
              int totalSeconds,
            })>>
    with
        $FutureModifier<
            ({
              int sessionCount,
              int totalSeconds,
            })>,
        $StreamProvider<
            ({
              int sessionCount,
              int totalSeconds,
            })> {
  TodaysFocusSummaryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'todaysFocusSummaryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$todaysFocusSummaryHash();

  @$internal
  @override
  $StreamProviderElement<
      ({
        int sessionCount,
        int totalSeconds,
      })> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<
      ({
        int sessionCount,
        int totalSeconds,
      })> create(Ref ref) {
    return todaysFocusSummary(ref);
  }
}

String _$todaysFocusSummaryHash() =>
    r'b144a5355400521e543ccf3fd706736731785da4';

@ProviderFor(LastSessionOutcome)
final lastSessionOutcomeProvider = LastSessionOutcomeProvider._();

final class LastSessionOutcomeProvider
    extends $NotifierProvider<LastSessionOutcome, SessionOutcome?> {
  LastSessionOutcomeProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'lastSessionOutcomeProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$lastSessionOutcomeHash();

  @$internal
  @override
  LastSessionOutcome create() => LastSessionOutcome();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionOutcome? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionOutcome?>(value),
    );
  }
}

String _$lastSessionOutcomeHash() =>
    r'86fe7bc80286c5b312ed0f5d901ca4f90bb09bed';

abstract class _$LastSessionOutcome extends $Notifier<SessionOutcome?> {
  SessionOutcome? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SessionOutcome?, SessionOutcome?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SessionOutcome?, SessionOutcome?>,
        SessionOutcome?,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SelectedSessionType)
final selectedSessionTypeProvider = SelectedSessionTypeProvider._();

final class SelectedSessionTypeProvider
    extends $NotifierProvider<SelectedSessionType, FocusSessionType> {
  SelectedSessionTypeProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'selectedSessionTypeProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$selectedSessionTypeHash();

  @$internal
  @override
  SelectedSessionType create() => SelectedSessionType();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FocusSessionType value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FocusSessionType>(value),
    );
  }
}

String _$selectedSessionTypeHash() =>
    r'640579a1695456633b2cd40118eb87cab5610793';

abstract class _$SelectedSessionType extends $Notifier<FocusSessionType> {
  FocusSessionType build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<FocusSessionType, FocusSessionType>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<FocusSessionType, FocusSessionType>,
        FocusSessionType,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}

/// Staged task/subtask to attach to the *next* session that gets started —
/// set from the Today or Task Detail screens before jumping to the Focus
/// tab, consumed (and cleared) once a session actually starts.
///
/// keepAlive because it's a hand-off: it's written while nothing watches
/// it (the Focus tab may never have been built yet), and an auto-dispose
/// provider could drop the link before the Focus screen reads it (B9).

@ProviderFor(PendingFocusLink)
final pendingFocusLinkProvider = PendingFocusLinkProvider._();

/// Staged task/subtask to attach to the *next* session that gets started —
/// set from the Today or Task Detail screens before jumping to the Focus
/// tab, consumed (and cleared) once a session actually starts.
///
/// keepAlive because it's a hand-off: it's written while nothing watches
/// it (the Focus tab may never have been built yet), and an auto-dispose
/// provider could drop the link before the Focus screen reads it (B9).
final class PendingFocusLinkProvider extends $NotifierProvider<
    PendingFocusLink,
    ({
      String label,
      int? subtaskId,
      int taskId,
    })?> {
  /// Staged task/subtask to attach to the *next* session that gets started —
  /// set from the Today or Task Detail screens before jumping to the Focus
  /// tab, consumed (and cleared) once a session actually starts.
  ///
  /// keepAlive because it's a hand-off: it's written while nothing watches
  /// it (the Focus tab may never have been built yet), and an auto-dispose
  /// provider could drop the link before the Focus screen reads it (B9).
  PendingFocusLinkProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'pendingFocusLinkProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$pendingFocusLinkHash();

  @$internal
  @override
  PendingFocusLink create() => PendingFocusLink();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(
      ({
        String label,
        int? subtaskId,
        int taskId,
      })? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<
          ({
            String label,
            int? subtaskId,
            int taskId,
          })?>(value),
    );
  }
}

String _$pendingFocusLinkHash() => r'9bec4a5989289614ab2a95a07036830d67a7b1fb';

/// Staged task/subtask to attach to the *next* session that gets started —
/// set from the Today or Task Detail screens before jumping to the Focus
/// tab, consumed (and cleared) once a session actually starts.
///
/// keepAlive because it's a hand-off: it's written while nothing watches
/// it (the Focus tab may never have been built yet), and an auto-dispose
/// provider could drop the link before the Focus screen reads it (B9).

abstract class _$PendingFocusLink extends $Notifier<
    ({
      String label,
      int? subtaskId,
      int taskId,
    })?> {
  ({
    String label,
    int? subtaskId,
    int taskId,
  })? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<
        ({
          String label,
          int? subtaskId,
          int taskId,
        })?,
        ({
          String label,
          int? subtaskId,
          int taskId,
        })?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<
            ({
              String label,
              int? subtaskId,
              int taskId,
            })?,
            ({
              String label,
              int? subtaskId,
              int taskId,
            })?>,
        ({
          String label,
          int? subtaskId,
          int taskId,
        })?,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(FocusTimerViewModel)
final focusTimerViewModelProvider = FocusTimerViewModelProvider._();

final class FocusTimerViewModelProvider
    extends $NotifierProvider<FocusTimerViewModel, void> {
  FocusTimerViewModelProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'focusTimerViewModelProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$focusTimerViewModelHash();

  @$internal
  @override
  FocusTimerViewModel create() => FocusTimerViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$focusTimerViewModelHash() =>
    r'02e95c397bbf9dd533b38a0210780d113ae018aa';

abstract class _$FocusTimerViewModel extends $Notifier<void> {
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
