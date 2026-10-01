// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'focus_timer_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activeFocusSessionHash() =>
    r'ee71950e0aca9853b959c84ec38c3620eda4f2f7';

/// See also [activeFocusSession].
@ProviderFor(activeFocusSession)
final activeFocusSessionProvider =
    AutoDisposeStreamProvider<FocusSession?>.internal(
  activeFocusSession,
  name: r'activeFocusSessionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeFocusSessionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveFocusSessionRef = AutoDisposeStreamProviderRef<FocusSession?>;
String _$todaysFocusSummaryHash() =>
    r'b144a5355400521e543ccf3fd706736731785da4';

/// See also [todaysFocusSummary].
@ProviderFor(todaysFocusSummary)
final todaysFocusSummaryProvider =
    AutoDisposeStreamProvider<({int totalSeconds, int sessionCount})>.internal(
  todaysFocusSummary,
  name: r'todaysFocusSummaryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todaysFocusSummaryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodaysFocusSummaryRef
    = AutoDisposeStreamProviderRef<({int totalSeconds, int sessionCount})>;
String _$selectedSessionTypeHash() =>
    r'640579a1695456633b2cd40118eb87cab5610793';

/// See also [SelectedSessionType].
@ProviderFor(SelectedSessionType)
final selectedSessionTypeProvider =
    AutoDisposeNotifierProvider<SelectedSessionType, FocusSessionType>.internal(
  SelectedSessionType.new,
  name: r'selectedSessionTypeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedSessionTypeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedSessionType = AutoDisposeNotifier<FocusSessionType>;
String _$pendingFocusLinkHash() => r'9bec4a5989289614ab2a95a07036830d67a7b1fb';

/// Staged task/subtask to attach to the *next* session that gets started —
/// set from the Today or Task Detail screens before jumping to the Focus
/// tab, consumed (and cleared) once a session actually starts.
///
/// keepAlive because it's a hand-off: it's written while nothing watches
/// it (the Focus tab may never have been built yet), and an auto-dispose
/// provider could drop the link before the Focus screen reads it (B9).
///
/// Copied from [PendingFocusLink].
@ProviderFor(PendingFocusLink)
final pendingFocusLinkProvider = NotifierProvider<PendingFocusLink,
    ({int taskId, int? subtaskId, String label})?>.internal(
  PendingFocusLink.new,
  name: r'pendingFocusLinkProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pendingFocusLinkHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PendingFocusLink
    = Notifier<({int taskId, int? subtaskId, String label})?>;
String _$focusTimerViewModelHash() =>
    r'f0598b797dc17a0ad0f25fd3d8cf8e4a00c25738';

/// See also [FocusTimerViewModel].
@ProviderFor(FocusTimerViewModel)
final focusTimerViewModelProvider =
    AutoDisposeNotifierProvider<FocusTimerViewModel, void>.internal(
  FocusTimerViewModel.new,
  name: r'focusTimerViewModelProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$focusTimerViewModelHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FocusTimerViewModel = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
