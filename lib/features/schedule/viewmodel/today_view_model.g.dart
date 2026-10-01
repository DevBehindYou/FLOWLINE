// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tasksForBlockHash() => r'5152f0be77b83e99d5503b1837dbe284ae708be5';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [tasksForBlock].
@ProviderFor(tasksForBlock)
const tasksForBlockProvider = TasksForBlockFamily();

/// See also [tasksForBlock].
class TasksForBlockFamily extends Family<AsyncValue<List<Task>>> {
  /// See also [tasksForBlock].
  const TasksForBlockFamily();

  /// See also [tasksForBlock].
  TasksForBlockProvider call(
    int blockId,
  ) {
    return TasksForBlockProvider(
      blockId,
    );
  }

  @override
  TasksForBlockProvider getProviderOverride(
    covariant TasksForBlockProvider provider,
  ) {
    return call(
      provider.blockId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'tasksForBlockProvider';
}

/// See also [tasksForBlock].
class TasksForBlockProvider extends AutoDisposeStreamProvider<List<Task>> {
  /// See also [tasksForBlock].
  TasksForBlockProvider(
    int blockId,
  ) : this._internal(
          (ref) => tasksForBlock(
            ref as TasksForBlockRef,
            blockId,
          ),
          from: tasksForBlockProvider,
          name: r'tasksForBlockProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$tasksForBlockHash,
          dependencies: TasksForBlockFamily._dependencies,
          allTransitiveDependencies:
              TasksForBlockFamily._allTransitiveDependencies,
          blockId: blockId,
        );

  TasksForBlockProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.blockId,
  }) : super.internal();

  final int blockId;

  @override
  Override overrideWith(
    Stream<List<Task>> Function(TasksForBlockRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TasksForBlockProvider._internal(
        (ref) => create(ref as TasksForBlockRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        blockId: blockId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Task>> createElement() {
    return _TasksForBlockProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TasksForBlockProvider && other.blockId == blockId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, blockId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TasksForBlockRef on AutoDisposeStreamProviderRef<List<Task>> {
  /// The parameter `blockId` of this provider.
  int get blockId;
}

class _TasksForBlockProviderElement
    extends AutoDisposeStreamProviderElement<List<Task>> with TasksForBlockRef {
  _TasksForBlockProviderElement(super.provider);

  @override
  int get blockId => (origin as TasksForBlockProvider).blockId;
}

String _$unscheduledTasksHash() => r'eb6903f9791f909da8764e2b6eb98d10b90bc385';

/// See also [unscheduledTasks].
@ProviderFor(unscheduledTasks)
final unscheduledTasksProvider = AutoDisposeStreamProvider<List<Task>>.internal(
  unscheduledTasks,
  name: r'unscheduledTasksProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unscheduledTasksHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnscheduledTasksRef = AutoDisposeStreamProviderRef<List<Task>>;
String _$scheduleBlocksForSelectedDateHash() =>
    r'b2e586367956a369cbb28d6f4273594de059ad69';

/// See also [scheduleBlocksForSelectedDate].
@ProviderFor(scheduleBlocksForSelectedDate)
final scheduleBlocksForSelectedDateProvider =
    AutoDisposeStreamProvider<List<ScheduleBlock>>.internal(
  scheduleBlocksForSelectedDate,
  name: r'scheduleBlocksForSelectedDateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$scheduleBlocksForSelectedDateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ScheduleBlocksForSelectedDateRef
    = AutoDisposeStreamProviderRef<List<ScheduleBlock>>;
String _$selectedDateHash() => r'138fa5c6799b8449922bd2176390773d1f7934ee';

/// See also [SelectedDate].
@ProviderFor(SelectedDate)
final selectedDateProvider =
    AutoDisposeNotifierProvider<SelectedDate, DateTime>.internal(
  SelectedDate.new,
  name: r'selectedDateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$selectedDateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedDate = AutoDisposeNotifier<DateTime>;
String _$todayActionsHash() => r'23b04fb065798abffc5aa4d04e53646a31fccbfd';

/// Action surface for the Today screen. The View calls through here
/// rather than touching repositories directly, keeping the MVVM boundary
/// even though there's no separate state to hold beyond the streams
/// above — see the README for why a full Use Case layer isn't here yet.
///
/// Copied from [TodayActions].
@ProviderFor(TodayActions)
final todayActionsProvider =
    AutoDisposeNotifierProvider<TodayActions, void>.internal(
  TodayActions.new,
  name: r'todayActionsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$todayActionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TodayActions = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
