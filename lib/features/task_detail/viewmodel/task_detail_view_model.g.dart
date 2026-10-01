// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_detail_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$taskByIdHash() => r'997525c1711c312f162c289908f6b053c7e60913';

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

/// See also [taskById].
@ProviderFor(taskById)
const taskByIdProvider = TaskByIdFamily();

/// See also [taskById].
class TaskByIdFamily extends Family<AsyncValue<Task?>> {
  /// See also [taskById].
  const TaskByIdFamily();

  /// See also [taskById].
  TaskByIdProvider call(
    int taskId,
  ) {
    return TaskByIdProvider(
      taskId,
    );
  }

  @override
  TaskByIdProvider getProviderOverride(
    covariant TaskByIdProvider provider,
  ) {
    return call(
      provider.taskId,
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
  String? get name => r'taskByIdProvider';
}

/// See also [taskById].
class TaskByIdProvider extends AutoDisposeStreamProvider<Task?> {
  /// See also [taskById].
  TaskByIdProvider(
    int taskId,
  ) : this._internal(
          (ref) => taskById(
            ref as TaskByIdRef,
            taskId,
          ),
          from: taskByIdProvider,
          name: r'taskByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$taskByIdHash,
          dependencies: TaskByIdFamily._dependencies,
          allTransitiveDependencies: TaskByIdFamily._allTransitiveDependencies,
          taskId: taskId,
        );

  TaskByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.taskId,
  }) : super.internal();

  final int taskId;

  @override
  Override overrideWith(
    Stream<Task?> Function(TaskByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TaskByIdProvider._internal(
        (ref) => create(ref as TaskByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        taskId: taskId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<Task?> createElement() {
    return _TaskByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TaskByIdProvider && other.taskId == taskId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, taskId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TaskByIdRef on AutoDisposeStreamProviderRef<Task?> {
  /// The parameter `taskId` of this provider.
  int get taskId;
}

class _TaskByIdProviderElement extends AutoDisposeStreamProviderElement<Task?>
    with TaskByIdRef {
  _TaskByIdProviderElement(super.provider);

  @override
  int get taskId => (origin as TaskByIdProvider).taskId;
}

String _$subtasksForTaskHash() => r'0c73ce8c4c7ce8d1aeceee1e83976e43578ab0a8';

/// See also [subtasksForTask].
@ProviderFor(subtasksForTask)
const subtasksForTaskProvider = SubtasksForTaskFamily();

/// See also [subtasksForTask].
class SubtasksForTaskFamily extends Family<AsyncValue<List<Subtask>>> {
  /// See also [subtasksForTask].
  const SubtasksForTaskFamily();

  /// See also [subtasksForTask].
  SubtasksForTaskProvider call(
    int taskId,
  ) {
    return SubtasksForTaskProvider(
      taskId,
    );
  }

  @override
  SubtasksForTaskProvider getProviderOverride(
    covariant SubtasksForTaskProvider provider,
  ) {
    return call(
      provider.taskId,
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
  String? get name => r'subtasksForTaskProvider';
}

/// See also [subtasksForTask].
class SubtasksForTaskProvider extends AutoDisposeStreamProvider<List<Subtask>> {
  /// See also [subtasksForTask].
  SubtasksForTaskProvider(
    int taskId,
  ) : this._internal(
          (ref) => subtasksForTask(
            ref as SubtasksForTaskRef,
            taskId,
          ),
          from: subtasksForTaskProvider,
          name: r'subtasksForTaskProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$subtasksForTaskHash,
          dependencies: SubtasksForTaskFamily._dependencies,
          allTransitiveDependencies:
              SubtasksForTaskFamily._allTransitiveDependencies,
          taskId: taskId,
        );

  SubtasksForTaskProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.taskId,
  }) : super.internal();

  final int taskId;

  @override
  Override overrideWith(
    Stream<List<Subtask>> Function(SubtasksForTaskRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SubtasksForTaskProvider._internal(
        (ref) => create(ref as SubtasksForTaskRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        taskId: taskId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Subtask>> createElement() {
    return _SubtasksForTaskProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SubtasksForTaskProvider && other.taskId == taskId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, taskId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SubtasksForTaskRef on AutoDisposeStreamProviderRef<List<Subtask>> {
  /// The parameter `taskId` of this provider.
  int get taskId;
}

class _SubtasksForTaskProviderElement
    extends AutoDisposeStreamProviderElement<List<Subtask>>
    with SubtasksForTaskRef {
  _SubtasksForTaskProviderElement(super.provider);

  @override
  int get taskId => (origin as SubtasksForTaskProvider).taskId;
}

String _$taskDetailActionsHash() => r'1f5d7d385dcfb4f801b6402be86679a617be11c3';

/// See also [TaskDetailActions].
@ProviderFor(TaskDetailActions)
final taskDetailActionsProvider =
    AutoDisposeNotifierProvider<TaskDetailActions, void>.internal(
  TaskDetailActions.new,
  name: r'taskDetailActionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$taskDetailActionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TaskDetailActions = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
