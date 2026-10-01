// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_day.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentDayHash() => r'42517299919e4263f386165c625db3144d7dfa50';

/// Local midnight of the current day, and the one thing every "today"
/// window in the app watches (rule R9).
///
/// Tabs stay mounted in the shell, so a value computed once when a
/// provider was first built would keep showing yesterday after midnight
/// for as long as the app stays open (K7). This rolls over on its own at
/// the next local midnight, and [refresh] is called on app resume because
/// a suspended app's timers don't fire on time.
///
/// Copied from [CurrentDay].
@ProviderFor(CurrentDay)
final currentDayProvider = NotifierProvider<CurrentDay, DateTime>.internal(
  CurrentDay.new,
  name: r'currentDayProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$currentDayHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CurrentDay = Notifier<DateTime>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
