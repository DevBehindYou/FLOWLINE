// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_detail_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(taskById)
final taskByIdProvider = TaskByIdFamily._();

final class TaskByIdProvider
    extends $FunctionalProvider<AsyncValue<Task?>, Task?, Stream<Task?>>
    with $FutureModifier<Task?>, $StreamProvider<Task?> {
  TaskByIdProvider._(
      {required TaskByIdFamily super.from, required int super.argument})
      : super(
          retry: null,
          name: r'taskByIdProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$taskByIdHash();

  @override
  String toString() {
    return r'taskByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Task?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Task?> create(Ref ref) {
    final argument = this.argument as int;
    return taskById(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TaskByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$taskByIdHash() => r'997525c1711c312f162c289908f6b053c7e60913';

final class TaskByIdFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Task?>, int> {
  TaskByIdFamily._()
      : super(
          retry: null,
          name: r'taskByIdProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  TaskByIdProvider call(
    int taskId,
  ) =>
      TaskByIdProvider._(argument: taskId, from: this);

  @override
  String toString() => r'taskByIdProvider';
}

@ProviderFor(subtasksForTask)
final subtasksForTaskProvider = SubtasksForTaskFamily._();

final class SubtasksForTaskProvider extends $FunctionalProvider<
        AsyncValue<List<Subtask>>, List<Subtask>, Stream<List<Subtask>>>
    with $FutureModifier<List<Subtask>>, $StreamProvider<List<Subtask>> {
  SubtasksForTaskProvider._(
      {required SubtasksForTaskFamily super.from, required int super.argument})
      : super(
          retry: null,
          name: r'subtasksForTaskProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$subtasksForTaskHash();

  @override
  String toString() {
    return r'subtasksForTaskProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Subtask>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Subtask>> create(Ref ref) {
    final argument = this.argument as int;
    return subtasksForTask(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SubtasksForTaskProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$subtasksForTaskHash() => r'0c73ce8c4c7ce8d1aeceee1e83976e43578ab0a8';

final class SubtasksForTaskFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Subtask>>, int> {
  SubtasksForTaskFamily._()
      : super(
          retry: null,
          name: r'subtasksForTaskProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  SubtasksForTaskProvider call(
    int taskId,
  ) =>
      SubtasksForTaskProvider._(argument: taskId, from: this);

  @override
  String toString() => r'subtasksForTaskProvider';
}

@ProviderFor(TaskDetailActions)
final taskDetailActionsProvider = TaskDetailActionsProvider._();

final class TaskDetailActionsProvider
    extends $NotifierProvider<TaskDetailActions, void> {
  TaskDetailActionsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'taskDetailActionsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$taskDetailActionsHash();

  @$internal
  @override
  TaskDetailActions create() => TaskDetailActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$taskDetailActionsHash() => r'67fd43bfb8625709d6de0ff12d280d6ecb631689';

abstract class _$TaskDetailActions extends $Notifier<void> {
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
