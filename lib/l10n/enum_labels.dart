import '../domain/entities/focus_session.dart';
import '../domain/entities/task.dart';
import 'app_localizations.dart';

/// Display names for domain enums. One place, so a chip, a menu and a
/// sheet can't name the same value differently.
extension L10nEnumLabels on AppLocalizations {
  String priorityName(TaskPriority p) => switch (p) {
        TaskPriority.low => priorityLow,
        TaskPriority.medium => priorityMedium,
        TaskPriority.high => priorityHigh,
      };

  String statusName(TaskStatus s) => switch (s) {
        TaskStatus.todo => statusTodo,
        TaskStatus.inProgress => statusInProgress,
        TaskStatus.done => statusDone,
      };

  String sessionTypeName(FocusSessionType t) => switch (t) {
        FocusSessionType.focus => sessionFocus,
        FocusSessionType.shortBreak => sessionShortBreak,
        FocusSessionType.longBreak => sessionLongBreak,
      };
}
