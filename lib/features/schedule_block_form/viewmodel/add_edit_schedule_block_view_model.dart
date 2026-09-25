import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers.dart';
import '../../../domain/entities/schedule_block.dart';

part 'add_edit_schedule_block_view_model.g.dart';

@riverpod
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
}
