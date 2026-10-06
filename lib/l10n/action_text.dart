import '../domain/assistant/action_preview.dart';
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
        DeletePreview(kind: DeleteKind.task) => actionDeleteTask,
        DeletePreview(kind: DeleteKind.block) => actionDeleteBlock,
      };

  /// What it applies to ("Walk · 5:00 PM–5:30 PM").
  String actionDetail(ActionPreview p) {
    String range(DateTime a, DateTime b) => '${time(a)}–${time(b)}';
    String join(List<String> parts) =>
        parts.where((s) => s.isNotEmpty).join(' · ');
    return switch (p) {
      ReadPreview() => '',
      CreateTaskPreview(:final title, :final due) =>
        join([title, if (due != null) '${dayShort(due)} ${time(due)}']),
      UpdateTaskPreview(:final title) => title,
      CompleteTaskPreview(:final title) => title,
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
        _ => confirmActionMessage(actionLabel(p), actionDetail(p)),
      };
}
