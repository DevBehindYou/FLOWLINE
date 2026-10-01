// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_intelligence_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$scheduleIntelligenceViewModelHash() =>
    r'c066bd5ae1bde101600bfb7048893c8ca65bac89';

/// No state of its own — this is a thin orchestration surface over
/// `ScheduleRepository` + `AIRepository` + the pure domain services in
/// `domain/services/`. It's the first ViewModel in the app to read from
/// two repositories, which is exactly the "genuinely cross-repository
/// orchestration" case the earlier phases' READMEs said would justify
/// stepping past a plain repository call — still not a full Use Case
/// class, since there's only one call site (the conflict sheet) so far.
///
/// Copied from [ScheduleIntelligenceViewModel].
@ProviderFor(ScheduleIntelligenceViewModel)
final scheduleIntelligenceViewModelProvider =
    AutoDisposeNotifierProvider<ScheduleIntelligenceViewModel, void>.internal(
  ScheduleIntelligenceViewModel.new,
  name: r'scheduleIntelligenceViewModelProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$scheduleIntelligenceViewModelHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ScheduleIntelligenceViewModel = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
