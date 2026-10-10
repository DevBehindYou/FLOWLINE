import '../domain/assistant/autonomy.dart';
import '../domain/assistant/proposal.dart';
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

/// Names for the assistant's enums (docs/05 §5, §6).
extension L10nAssistantLabels on AppLocalizations {
  String proposalReasonName(ProposalReason r) => switch (r) {
        ProposalReason.commitment => reasonCommitment,
        ProposalReason.meetingWithoutPrep => reasonMeetingWithoutPrep,
        ProposalReason.upcomingDate => reasonUpcomingDate,
        ProposalReason.overdueDrift => reasonOverdueDrift,
        ProposalReason.billDue => reasonBillDue,
        ProposalReason.freeGapForTasks => reasonFreeGapForTasks,
        ProposalReason.dayOverbooked => reasonDayOverbooked,
        ProposalReason.followUpDue => reasonFollowUpDue,
        ProposalReason.documentExpiring => reasonDocumentExpiring,
        ProposalReason.pattern => reasonPattern,
        ProposalReason.blockEnded => reasonBlockEnded,
      };

  String originName(ActionOrigin o) => switch (o) {
        ActionOrigin.said => originSaid,
        ActionOrigin.commitment => originCommitment,
        ActionOrigin.context => originContext,
        ActionOrigin.pattern => originPattern,
        ActionOrigin.routine => originRoutine,
      };
}
