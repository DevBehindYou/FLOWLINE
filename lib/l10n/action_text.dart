import '../domain/assistant/action_preview.dart';
import '../domain/entities/person.dart';
import 'app_localizations.dart';
import 'formats.dart';

/// Words for what the assistant did or will do (docs/05 §9.1): one place,
/// so the chat card, Activity and the confirm sheet never disagree.
extension L10nActions on AppLocalizations {
  /// The verb, as a mono label ("Created task").
  String actionLabel(ActionPreview p) => switch (p) {
        ReadPreview() => actionRead,
        CreateTaskPreview() => actionCreateTask,
        UpdateTaskPreview() => actionUpdateTask,
        CompleteTaskPreview() => actionCompleteTask,
        ScheduleTaskPreview() => actionScheduleTask,
        CreateBlockPreview() => actionCreateBlock,
        MoveBlockPreview() => actionMoveBlock,
        StartFocusPreview() => actionStartFocus,
        BreakDownTaskPreview() => actionBreakDown,
        CreateReminderPreview() => actionCreateReminder,
        AddListItemsPreview() => actionAddListItems,
        AddPersonDatePreview(:final kind) => switch (kind) {
            PersonDateKind.birthday => actionAddBirthday,
            PersonDateKind.anniversary => actionAddAnniversary,
            PersonDateKind.other => actionAddPersonDate,
          },
        CreateFollowUpPreview() => actionCreateFollowUp,
        CompleteFollowUpPreview() => actionCompleteFollowUp,
        CheckListItemPreview(:final checked) =>
          checked ? actionCheckListItem : actionUncheckListItem,
        SnoozeReminderPreview() => actionSnoozeReminder,
        CompleteReminderPreview() => actionCompleteReminder,
        DeletePreview(kind: DeleteKind.task) => actionDeleteTask,
        DeletePreview(kind: DeleteKind.block) => actionDeleteBlock,
        DeletePreview(kind: DeleteKind.checkedItems) => actionClearChecked,
      };

  /// What it applies to ("Walk · 5:00 PM–5:30 PM").
  String actionDetail(ActionPreview p) {
    String range(DateTime a, DateTime b) => '${time(a)}–${time(b)}';
    String join(List<String> parts) =>
        parts.where((s) => s.isNotEmpty).join(' · ');
    return switch (p) {
      ReadPreview() => '',
      CreateTaskPreview(:final title, :final due, :final repeat) => join([
          title,
          if (due != null) '${dayShort(due)} ${time(due)}',
          if (repeat != null) repeatText(repeat),
        ]),
      UpdateTaskPreview(:final title) => title,
      CompleteTaskPreview(:final title, :final nextDue) => join([
          title,
          if (nextDue != null)
            repeatNextDue('${dayShort(nextDue)} ${time(nextDue)}'),
        ]),
      ScheduleTaskPreview(:final title, :final start, :final end) =>
        join([title, range(start, end)]),
      CreateBlockPreview(:final title, :final start, :final end) =>
        join([title, range(start, end)]),
      MoveBlockPreview(:final title, :final toStart, :final toEnd) =>
        join([title, range(toStart, toEnd)]),
      StartFocusPreview(:final minutes, :final taskTitle) =>
        join([taskTitle ?? '', actionFocusMinutes(minutes)]),
      BreakDownTaskPreview(:final title, :final steps) =>
        join([title, steps.join(', ')]),
      CreateReminderPreview(:final title, :final at) =>
        join([title, '${dayShort(at)} ${time(at)}']),
      SnoozeReminderPreview(:final title, :final until) =>
        join([title, '${dayShort(until)} ${time(until)}']),
      CompleteReminderPreview(:final title) => title,
      AddPersonDatePreview(:final person, :final month, :final day) =>
        join([person, monthDay(DateTime(2000, month, day))]),
      CreateFollowUpPreview(:final person, :final about, :final waitUntil) =>
        join([person, about, '${dayShort(waitUntil)} ${time(waitUntil)}']),
      CompleteFollowUpPreview(:final person, :final about) =>
        join([person, about]),
      AddListItemsPreview(:final list, :final items) =>
        join([list, items.join(', ')]),
      CheckListItemPreview(:final list, :final text) => join([list, text]),
      DeletePreview(:final titles) => titles.join(', '),
    };
  }

  /// The confirm sheet's message: exactly what goes (system §9.9).
  String confirmMessage(ActionPreview p) => switch (p) {
        DeletePreview(
          kind: DeleteKind.task,
          :final titles,
          :final subtaskCount
        ) =>
          confirmDeleteTaskMessage(subtaskCount, titles.join(', ')),
        DeletePreview(
          kind: DeleteKind.block,
          :final titles,
          :final unscheduledTaskCount
        ) =>
          confirmDeleteBlockMessage(unscheduledTaskCount, titles.join(', ')),
        DeletePreview(
          kind: DeleteKind.checkedItems,
          :final titles,
          :final subtaskCount
        ) =>
          confirmClearCheckedMessage(subtaskCount, titles.join(', ')),
        _ => confirmActionMessage(actionLabel(p), actionDetail(p)),
      };
}
