import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../assistant/assistant_providers.dart';
import '../../../assistant/direct_action.dart';
import '../../../core/providers.dart';
import '../../../data/assistant/tool_executor.dart';
import '../../../domain/entities/person.dart';

part 'people_view_model.g.dart';

@riverpod
Stream<List<Person>> people(Ref ref) =>
    ref.watch(peopleRepositoryProvider).watchPeople();

@riverpod
Future<Person?> person(Ref ref, int id) =>
    ref.watch(peopleRepositoryProvider).getPerson(id);

@riverpod
Stream<List<PersonDate>> personDates(Ref ref, int personId) =>
    ref.watch(peopleRepositoryProvider).watchDates(personId);

@riverpod
Stream<List<FollowUp>> personFollowUps(Ref ref, int personId) =>
    ref.watch(peopleRepositoryProvider).watchFollowUps(personId);

// keepAlive (R11): uses ref after awaits.
@Riverpod(keepAlive: true)
class PeopleActions extends _$PeopleActions {
  @override
  void build() {}

  /// "Replied": the same tool the assistant uses, so it's logged and can
  /// be undone.
  Future<ExecutionResult> replied(int followUpId) => runDirectAction(
        registry: ref.read(toolRegistryProvider),
        executor: ref.read(toolExecutorProvider),
        tool: 'complete_follow_up',
        args: {'follow_up_id': followUpId},
      );
}
