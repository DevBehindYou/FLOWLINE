import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers.dart';
import '../../../domain/entities/schedule_block.dart';

part 'add_edit_schedule_block_view_model.g.dart';

// keepAlive (rule R11): an action surface whose methods use `ref` after
// an `await`. Auto-dispose would let it be disposed mid-action (the sheet
// or screen that called it closes), and Riverpod 3 throws on any use of a
// disposed Ref.
@Riverpod(keepAlive: true)
class AddEditScheduleBlockViewModel extends _$AddEditScheduleBlockViewModel {
  @override
  void build() {}

  Future<void> createBlock({
    required String title,
    required DateTime startTime,
    required DateTime endTime,
  }) {
    return ref.read(scheduleRepositoryProvider).createBlock(
          title: title,
          startTime: startTime,
          endTime: endTime,
        );
  }

  Future<void> updateBlock(ScheduleBlock block) {
    return ref.read(scheduleRepositoryProvider).updateBlock(block);
  }

  /// Deletes the block; its tasks become unscheduled (foreign key
  /// ON DELETE SET NULL, and the repository does it explicitly too).
  Future<void> deleteBlock(int id) {
    return ref.read(scheduleRepositoryProvider).deleteBlock(id);
  }
}
