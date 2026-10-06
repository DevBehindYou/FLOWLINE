import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../assistant/assistant_providers.dart';
import '../../../assistant/reminder_sync.dart';
import '../../../core/providers.dart';
import '../../../domain/entities/reminder.dart';
import '../../../domain/services/reminder_actions.dart';

part 'reminders_view_model.g.dart';

@riverpod
Stream<List<Reminder>> openReminders(Ref ref) =>
    ref.watch(reminderRepositoryProvider).watchOpen();

// keepAlive (R11): uses ref after awaits.
@Riverpod(keepAlive: true)
class RemindersActions extends _$RemindersActions {
  @override
  void build() {}

  /// The same path as the notification's buttons: a tool call with a
  /// ledger row (so it shows in Activity, with undo), then the alert.
  Future<void> act(ReminderAction action, int reminderId) async {
    final touched = await applyReminderAction(
      actionId: action.name,
      reminderId: reminderId,
      reminders: ref.read(reminderRepositoryProvider),
      registry: ref.read(toolRegistryProvider),
      executor: ref.read(toolExecutorProvider),
    );
    if (touched == null) return;
    try {
      await ref.read(reminderSyncProvider).sync(touched);
    } catch (_) {
      // The change is saved; an alert that can't be scheduled must not
      // make it look failed (the next start's top-up tries again).
    }
  }
}
