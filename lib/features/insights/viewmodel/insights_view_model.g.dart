// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insights_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recentFocusSessionsHash() =>
    r'26da8d899a6629c43b7f77e18ef002be462242b5';

/// See also [recentFocusSessions].
@ProviderFor(recentFocusSessions)
final recentFocusSessionsProvider =
    AutoDisposeStreamProvider<List<FocusSession>>.internal(
  recentFocusSessions,
  name: r'recentFocusSessionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recentFocusSessionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecentFocusSessionsRef
    = AutoDisposeStreamProviderRef<List<FocusSession>>;
String _$weeklyFocusTotalsHash() => r'c3884034ff739eeb66b8f92359e103cf933d701b';

/// See also [weeklyFocusTotals].
@ProviderFor(weeklyFocusTotals)
final weeklyFocusTotalsProvider =
    AutoDisposeProvider<AsyncValue<List<DailyFocusTotal>>>.internal(
  weeklyFocusTotals,
  name: r'weeklyFocusTotalsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$weeklyFocusTotalsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WeeklyFocusTotalsRef
    = AutoDisposeProviderRef<AsyncValue<List<DailyFocusTotal>>>;
String _$currentStreakHash() => r'aa7a1680b3ca732cbb3bb4a4a1cc960a97fdfd23';

/// See also [currentStreak].
@ProviderFor(currentStreak)
final currentStreakProvider = AutoDisposeProvider<AsyncValue<int>>.internal(
  currentStreak,
  name: r'currentStreakProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentStreakHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentStreakRef = AutoDisposeProviderRef<AsyncValue<int>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
