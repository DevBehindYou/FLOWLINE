// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_intelligence_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// No state of its own — this is a thin orchestration surface over
/// `ScheduleRepository` + `AIRepository` + the pure domain services in
/// `domain/services/`. It's the first ViewModel in the app to read from
/// two repositories, which is exactly the "genuinely cross-repository
/// orchestration" case the earlier phases' READMEs said would justify
/// stepping past a plain repository call — still not a full Use Case
/// class, since there's only one call site (the conflict sheet) so far.
// keepAlive (rule R11): an action surface whose methods use `ref` after
// an `await`. Auto-dispose would let it be disposed mid-action (the sheet
// or screen that called it closes), and Riverpod 3 throws on any use of a
// disposed Ref.

@ProviderFor(ScheduleIntelligenceViewModel)
final scheduleIntelligenceViewModelProvider =
    ScheduleIntelligenceViewModelProvider._();

/// No state of its own — this is a thin orchestration surface over
/// `ScheduleRepository` + `AIRepository` + the pure domain services in
/// `domain/services/`. It's the first ViewModel in the app to read from
/// two repositories, which is exactly the "genuinely cross-repository
/// orchestration" case the earlier phases' READMEs said would justify
/// stepping past a plain repository call — still not a full Use Case
/// class, since there's only one call site (the conflict sheet) so far.
// keepAlive (rule R11): an action surface whose methods use `ref` after
// an `await`. Auto-dispose would let it be disposed mid-action (the sheet
// or screen that called it closes), and Riverpod 3 throws on any use of a
// disposed Ref.
final class ScheduleIntelligenceViewModelProvider
    extends $NotifierProvider<ScheduleIntelligenceViewModel, void> {
  /// No state of its own — this is a thin orchestration surface over
  /// `ScheduleRepository` + `AIRepository` + the pure domain services in
  /// `domain/services/`. It's the first ViewModel in the app to read from
  /// two repositories, which is exactly the "genuinely cross-repository
  /// orchestration" case the earlier phases' READMEs said would justify
  /// stepping past a plain repository call — still not a full Use Case
  /// class, since there's only one call site (the conflict sheet) so far.
// keepAlive (rule R11): an action surface whose methods use `ref` after
// an `await`. Auto-dispose would let it be disposed mid-action (the sheet
// or screen that called it closes), and Riverpod 3 throws on any use of a
// disposed Ref.
  ScheduleIntelligenceViewModelProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'scheduleIntelligenceViewModelProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$scheduleIntelligenceViewModelHash();

  @$internal
  @override
  ScheduleIntelligenceViewModel create() => ScheduleIntelligenceViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$scheduleIntelligenceViewModelHash() =>
    r'41a78d6b6341462fbd53eb77750db162bb00ac6e';

/// No state of its own — this is a thin orchestration surface over
/// `ScheduleRepository` + `AIRepository` + the pure domain services in
/// `domain/services/`. It's the first ViewModel in the app to read from
/// two repositories, which is exactly the "genuinely cross-repository
/// orchestration" case the earlier phases' READMEs said would justify
/// stepping past a plain repository call — still not a full Use Case
/// class, since there's only one call site (the conflict sheet) so far.
// keepAlive (rule R11): an action surface whose methods use `ref` after
// an `await`. Auto-dispose would let it be disposed mid-action (the sheet
// or screen that called it closes), and Riverpod 3 throws on any use of a
// disposed Ref.

abstract class _$ScheduleIntelligenceViewModel extends $Notifier<void> {
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
