// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insights_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(recentFocusSessions)
final recentFocusSessionsProvider = RecentFocusSessionsProvider._();

final class RecentFocusSessionsProvider extends $FunctionalProvider<
        AsyncValue<List<FocusSession>>,
        List<FocusSession>,
        Stream<List<FocusSession>>>
    with
        $FutureModifier<List<FocusSession>>,
        $StreamProvider<List<FocusSession>> {
  RecentFocusSessionsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'recentFocusSessionsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$recentFocusSessionsHash();

  @$internal
  @override
  $StreamProviderElement<List<FocusSession>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<FocusSession>> create(Ref ref) {
    return recentFocusSessions(ref);
  }
}

String _$recentFocusSessionsHash() =>
    r'b4cfe1579cba40589bd3eda18508ddcb828b902c';

@ProviderFor(weeklyFocusTotals)
final weeklyFocusTotalsProvider = WeeklyFocusTotalsProvider._();

final class WeeklyFocusTotalsProvider extends $FunctionalProvider<
        AsyncValue<List<DailyFocusTotal>>,
        AsyncValue<List<DailyFocusTotal>>,
        AsyncValue<List<DailyFocusTotal>>>
    with $Provider<AsyncValue<List<DailyFocusTotal>>> {
  WeeklyFocusTotalsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'weeklyFocusTotalsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$weeklyFocusTotalsHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<List<DailyFocusTotal>>> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AsyncValue<List<DailyFocusTotal>> create(Ref ref) {
    return weeklyFocusTotals(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<DailyFocusTotal>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<AsyncValue<List<DailyFocusTotal>>>(value),
    );
  }
}

String _$weeklyFocusTotalsHash() => r'c3884034ff739eeb66b8f92359e103cf933d701b';

@ProviderFor(currentStreak)
final currentStreakProvider = CurrentStreakProvider._();

final class CurrentStreakProvider extends $FunctionalProvider<AsyncValue<int>,
    AsyncValue<int>, AsyncValue<int>> with $Provider<AsyncValue<int>> {
  CurrentStreakProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'currentStreakProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currentStreakHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<int>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AsyncValue<int> create(Ref ref) {
    return currentStreak(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<int> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<int>>(value),
    );
  }
}

String _$currentStreakHash() => r'aa7a1680b3ca732cbb3bb4a4a1cc960a97fdfd23';
