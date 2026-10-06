// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_day.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Local midnight of the current day, and the one thing every "today"
/// window in the app watches (rule R9).
///
/// Tabs stay mounted in the shell, so a value computed once when a
/// provider was first built would keep showing yesterday after midnight
/// for as long as the app stays open (K7). This rolls over on its own at
/// the next local midnight, and [refresh] is called on app resume because
/// a suspended app's timers don't fire on time.

@ProviderFor(CurrentDay)
final currentDayProvider = CurrentDayProvider._();

/// Local midnight of the current day, and the one thing every "today"
/// window in the app watches (rule R9).
///
/// Tabs stay mounted in the shell, so a value computed once when a
/// provider was first built would keep showing yesterday after midnight
/// for as long as the app stays open (K7). This rolls over on its own at
/// the next local midnight, and [refresh] is called on app resume because
/// a suspended app's timers don't fire on time.
final class CurrentDayProvider extends $NotifierProvider<CurrentDay, DateTime> {
  /// Local midnight of the current day, and the one thing every "today"
  /// window in the app watches (rule R9).
  ///
  /// Tabs stay mounted in the shell, so a value computed once when a
  /// provider was first built would keep showing yesterday after midnight
  /// for as long as the app stays open (K7). This rolls over on its own at
  /// the next local midnight, and [refresh] is called on app resume because
  /// a suspended app's timers don't fire on time.
  CurrentDayProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'currentDayProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currentDayHash();

  @$internal
  @override
  CurrentDay create() => CurrentDay();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$currentDayHash() => r'42517299919e4263f386165c625db3144d7dfa50';

/// Local midnight of the current day, and the one thing every "today"
/// window in the app watches (rule R9).
///
/// Tabs stay mounted in the shell, so a value computed once when a
/// provider was first built would keep showing yesterday after midnight
/// for as long as the app stays open (K7). This rolls over on its own at
/// the next local midnight, and [refresh] is called on app resume because
/// a suspended app's timers don't fire on time.

abstract class _$CurrentDay extends $Notifier<DateTime> {
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
