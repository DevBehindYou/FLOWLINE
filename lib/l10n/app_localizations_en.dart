// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Atomic Assist';

  @override
  String get errorNetwork =>
      'Couldn\'t reach the server — check your connection.';

  @override
  String get errorStorage => 'Couldn\'t read your data on this phone.';

  @override
  String get errorGeneric => 'Something went wrong.';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get confirmSheetLabel => 'Confirm';

  @override
  String get settings => 'Settings';

  @override
  String get navToday => 'Today';

  @override
  String get navFocus => 'Focus';

  @override
  String get navAssistant => 'Assistant';

  @override
  String get navInsights => 'Insights';

  @override
  String get onboardingSaveFailed =>
      'Couldn\'t save your progress — please try again.';

  @override
  String get onboardingWelcomeTitle =>
      'Plan the day. Focus. See where time went.';

  @override
  String get onboardingWelcomeBody =>
      'Atomic Assist keeps your tasks, time blocks and focus sessions on this phone. No account, no sync, nothing leaves the device unless you export it.';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingNotificationsTitle => 'Know when a session ends';

  @override
  String get onboardingNotificationsBody =>
      'Atomic Assist uses notifications only for focus session and break alerts, so you can put the phone down. You can change this any time in Settings.';

  @override
  String get onboardingAllowNotifications => 'Allow notifications';

  @override
  String get onboardingNotNow => 'Not now';

  @override
  String get onboardingAiTitle => 'Connect an AI assistant (optional)';

  @override
  String get onboardingAiBody =>
      'Bring your own API key from OpenAI, Anthropic, Gemini, or run Ollama locally. Keys are stored in the Android Keystore and never backed up. Everything else works without one.';

  @override
  String get onboardingConnectProvider => 'Connect a provider';

  @override
  String get onboardingSkipForNow => 'Skip for now';

  @override
  String onboardingStep(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get settingSaveFailed =>
      'Couldn\'t save the setting — please try again.';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get appearanceTheme => 'Theme';

  @override
  String get appearanceSystem => 'System';

  @override
  String get appearanceLight => 'Light';

  @override
  String get appearanceDark => 'Dark';

  @override
  String get appearanceSystemHint =>
      'System follows your phone’s dark mode setting.';

  @override
  String get settingsFocusTimer => 'Focus timer';

  @override
  String get sessionFocus => 'Focus';

  @override
  String get sessionShortBreak => 'Short break';

  @override
  String get sessionLongBreak => 'Long break';

  @override
  String get focusSettingsLongBreakAfter => 'Long break after';

  @override
  String focusSessionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count focus sessions',
      one: '1 focus session',
    );
    return '$_temp0';
  }

  @override
  String get focusSettingsHint =>
      'New lengths apply to the next session you start.';

  @override
  String minutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String decreaseSetting(String setting) {
    return 'Decrease $setting';
  }

  @override
  String increaseSetting(String setting) {
    return 'Increase $setting';
  }

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get notificationsSessionAlerts => 'Session alerts';

  @override
  String get notificationsSessionAlertsHint =>
      'A notification when a focus session or break ends';

  @override
  String get clearAllDataTitle => 'Clear all data?';

  @override
  String get clearAllDataMessage =>
      'Deletes every task, block, focus session, conversation and saved API key on this phone. This can’t be undone.';

  @override
  String get clearAllDataConfirm => 'Clear everything';

  @override
  String get clearAllDataFailed =>
      'Couldn\'t clear your data — please try again.';

  @override
  String get settingsDataPrivacy => 'Data & privacy';

  @override
  String get dataWhereTitle => 'Where your data lives';

  @override
  String get dataWhereBody =>
      'Everything you create is stored only on this phone. There is no Atomic Assist account, server or analytics.\n\nAPI keys are kept in Android’s secure Keystore and are only ever sent to the AI provider they belong to. When you use the Assistant, your message and the conversation so far go directly from this phone to the provider you chose.\n\nYour Android backup includes your Atomic Assist data but never your API keys.';

  @override
  String get clearAllData => 'Clear all data';

  @override
  String get openSourceLicences => 'Open-source licences';

  @override
  String get allDataCleared => 'All data cleared';

  @override
  String removeKeyTitle(String provider) {
    return 'Remove $provider key?';
  }

  @override
  String get removeKeyMessage =>
      'The key is deleted from this phone. Your saved conversations stay, but new messages won\'t work until you add a key again.';

  @override
  String get remove => 'Remove';

  @override
  String get saveFailed => 'Couldn\'t save — please try again.';

  @override
  String get apiKey => 'API key';

  @override
  String get apiKeySavedHint => 'A key is saved. Leave empty to keep it.';

  @override
  String get apiKeyStorageHint =>
      'Stored only on this phone, in the Android Keystore.';

  @override
  String get showKey => 'Show key';

  @override
  String get hideKey => 'Hide key';

  @override
  String get serverUrl => 'Server URL';

  @override
  String get serverUrlHint =>
      'On a phone, \"localhost\" means the phone itself — use your computer\'s LAN IP if Ollama runs there.';

  @override
  String get model => 'Model';

  @override
  String get save => 'Save';

  @override
  String get removeKey => 'Remove key';

  @override
  String get aiFieldModelEmpty => 'Enter a model name';

  @override
  String get aiFieldModelHasSpaces => 'Model names have no spaces';

  @override
  String get aiFieldUrlNeedsScheme =>
      'Start with http:// or https://, e.g. http://192.168.1.20:11434';

  @override
  String get aiFieldUrlNeedsHost => 'Add the computer\'s address after http://';

  @override
  String get aiFieldUrlHasPath =>
      'Use only the server address, e.g. http://192.168.1.20:11434';

  @override
  String get aiFieldKeyEmpty => 'Paste your API key';

  @override
  String get aiFieldKeyHasSpaces => 'The key contains spaces — paste it again';

  @override
  String get settingsAiProviders => 'AI Providers';

  @override
  String get settingsAiProvidersHint =>
      'Connect Anthropic, OpenAI, Gemini, or a local Ollama server';

  @override
  String get settingsFocusTimerHint => 'Session and break lengths';

  @override
  String get settingsAppearanceHint => 'Light, dark or system';

  @override
  String get settingsDataPrivacyHint => 'Where your data lives, clear all data';

  @override
  String providerConnected(String model) {
    return 'Connected • $model';
  }

  @override
  String get providerNotConnected => 'Not connected';

  @override
  String get providerStatusUnknown => 'Unknown';

  @override
  String get edit => 'Edit';

  @override
  String get assistantNoProviderTitle => 'Connect an AI provider';

  @override
  String get assistantNoProviderMessage =>
      'Add an API key in Settings to start chatting.';

  @override
  String get assistantGoToProviders => 'Go to AI Providers';

  @override
  String get assistantSendFailed =>
      'Couldn\'t send — your message is back in the box.';

  @override
  String get assistantEmptyTitle => 'Ask me anything';

  @override
  String get assistantEmptyMessage =>
      'Try asking about your schedule, or just say hello.';

  @override
  String get assistantInputHint => 'Ask the assistant…';

  @override
  String get send => 'Send';

  @override
  String get assistantWaiting => 'Waiting for a reply';

  @override
  String get assistantThinking => 'Thinking…';

  @override
  String get todayEmptyTitle => 'No tasks yet';

  @override
  String get todayEmptyMessage =>
      'Add your first task to start planning today.';

  @override
  String get addTask => 'Add Task';

  @override
  String get previousDay => 'Previous day';

  @override
  String get jumpToToday => 'Jump to today';

  @override
  String get loadingTask => 'Loading the task…';

  @override
  String get loadingDay => 'Loading the day…';

  @override
  String get nextDay => 'Next day';

  @override
  String get addScheduleBlock => 'Add schedule block';

  @override
  String get unscheduled => 'Unscheduled';

  @override
  String timeRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String get blockOptions => 'Block options';

  @override
  String get editBlock => 'Edit block';

  @override
  String get deleteBlock => 'Delete block';

  @override
  String get addTaskToBlock => 'Add task to this block';

  @override
  String get overlapsAnotherBlock => 'Overlaps another block';

  @override
  String get blockEmpty => 'No tasks in this block yet.';

  @override
  String get priorityLow => 'Low';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get priorityHigh => 'High';

  @override
  String get statusTodo => 'Todo';

  @override
  String get statusInProgress => 'In Progress';

  @override
  String get statusDone => 'Done';

  @override
  String get deleteTaskFailed =>
      'Couldn\'t delete the task — please try again.';

  @override
  String get markNotDone => 'Mark as not done';

  @override
  String get markDone => 'Mark as done';

  @override
  String get startFocusSession => 'Start focus session';

  @override
  String markedDone(String title) {
    return 'Marked \"$title\" done';
  }

  @override
  String get undo => 'Undo';

  @override
  String priorityOption(String priority) {
    return 'Priority: $priority';
  }

  @override
  String get deleteTaskTitle => 'Delete task?';

  @override
  String deleteTaskMessage(String title) {
    return '\"$title\" will be removed permanently.';
  }

  @override
  String dueOverdue(String date) {
    return 'Overdue · $date';
  }

  @override
  String dueToday(String time) {
    return 'Due today $time';
  }

  @override
  String dueOn(String date) {
    return 'Due $date';
  }

  @override
  String get taskTitle => 'Task';

  @override
  String get editTask => 'Edit task';

  @override
  String get deleteTask => 'Delete task';

  @override
  String get deleteTaskWithSubtasksMessage =>
      'This removes the task and its subtasks permanently.';

  @override
  String get taskMissing => 'This task no longer exists.';

  @override
  String get startFocusSessionButton => 'Start Focus Session';

  @override
  String get subtasks => 'Subtasks';

  @override
  String get addSubtask => 'Add subtask';

  @override
  String get focusHistory => 'Focus history';

  @override
  String get newSubtask => 'New subtask';

  @override
  String get titleField => 'Title';

  @override
  String get add => 'Add';

  @override
  String get subtasksEmpty => 'No subtasks yet.';

  @override
  String subtaskSprints(int completed, int planned) {
    return '$completed of $planned pomodoros logged';
  }

  @override
  String get deleteSubtask => 'Delete subtask';

  @override
  String get deleteSubtaskTitle => 'Delete subtask?';

  @override
  String deleteSubtaskMessage(String title) {
    return '\"$title\" and its logged pomodoro count will be removed.';
  }

  @override
  String get focusHistoryEmpty => 'No focus sessions yet.';

  @override
  String focusHistorySummary(int count, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions',
      one: '1 session',
    );
    return '$_temp0 · $minutes min total';
  }

  @override
  String dateTime(String date, String time) {
    return '$date $time';
  }

  @override
  String minutesEndedEarly(int minutes) {
    return '$minutes min · ended early';
  }

  @override
  String dueOverdueAt(String date, String time) {
    return 'Overdue · $date $time';
  }

  @override
  String dueAt(String date, String time) {
    return 'Due $date $time';
  }

  @override
  String get titleRequired => 'Title is required';

  @override
  String get saveTaskFailed => 'Couldn\'t save the task — please try again.';

  @override
  String deleteTaskAndSubtasksMessage(String title) {
    return '\"$title\" and its subtasks will be removed permanently.';
  }

  @override
  String get editTaskTitle => 'Edit Task';

  @override
  String get notesField => 'Notes';

  @override
  String get priorityField => 'Priority';

  @override
  String get statusField => 'Status';

  @override
  String get formStatusTodo => 'To do';

  @override
  String get formStatusDoing => 'Doing';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get saving => 'Saving…';

  @override
  String get deleteTaskButton => 'Delete task';

  @override
  String get scheduleBlockField => 'Schedule block';

  @override
  String get keepCurrentBlock => 'Keep current block';

  @override
  String blockOption(String title, String time) {
    return '$title · $time';
  }

  @override
  String get noDueDate => 'No due date';

  @override
  String get removeDueDate => 'Remove due date';

  @override
  String get unlinkTask => 'Unlink task';

  @override
  String get start => 'Start';

  @override
  String get timerPaused => 'PAUSED';

  @override
  String get end => 'End';

  @override
  String get skip => 'Skip';

  @override
  String get resume => 'Resume';

  @override
  String get pause => 'Pause';

  @override
  String get addFiveMinutes => '+5 min';

  @override
  String get timerLabelFocus => 'FOCUS';

  @override
  String get timerLabelShortBreak => 'SHORT BREAK';

  @override
  String get timerLabelLongBreak => 'LONG BREAK';

  @override
  String selectorFocus(int minutes) {
    return 'Focus (${minutes}m)';
  }

  @override
  String selectorShortBreak(int minutes) {
    return 'Short (${minutes}m)';
  }

  @override
  String selectorLongBreak(int minutes) {
    return 'Long (${minutes}m)';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String durationMinutes(int minutes) {
    return '${minutes}m';
  }

  @override
  String get todaysFocus => 'Today\'s Focus';

  @override
  String focusFooterSummary(String duration, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions',
      one: '1 session',
    );
    return '$duration • $_temp0';
  }

  @override
  String get summaryEndedEarly => 'Session ended early';

  @override
  String get summaryBreakSkipped => 'Break skipped';

  @override
  String get summaryFocusComplete => 'Focus session complete';

  @override
  String get summaryBreakOver => 'Break over';

  @override
  String summaryLoggedEarly(int minutes) {
    return '$minutes min of focus logged. Every bit counts.';
  }

  @override
  String summaryLogged(int minutes) {
    return '$minutes min of focus logged.';
  }

  @override
  String summaryOnTask(String title) {
    return 'On: $title';
  }

  @override
  String summarySessionsToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count focus sessions today',
      one: '1 focus session today',
    );
    return '$_temp0';
  }

  @override
  String startFocusMinutes(int minutes) {
    return 'Start focus session (${minutes}m)';
  }

  @override
  String startShortBreakMinutes(int minutes) {
    return 'Start short break (${minutes}m)';
  }

  @override
  String startLongBreakMinutes(int minutes) {
    return 'Start long break (${minutes}m)';
  }

  @override
  String get backToToday => 'Back to Today';

  @override
  String get timer => 'Timer';

  @override
  String timerRemaining(int minutes, int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes',
      one: '1 minute',
    );
    String _temp1 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds seconds',
      one: '1 second',
    );
    return '$_temp0 $_temp1 remaining';
  }

  @override
  String get exportThisWeek => 'Export this week';

  @override
  String get insightsEmptyTitle => 'Complete a session to see stats';

  @override
  String get insightsEmptyMessage =>
      'Focus-time trends and streaks show up here once you’ve logged a session.';

  @override
  String get dayStreak => 'Day streak';

  @override
  String get thisWeek => 'This week';

  @override
  String get last7Days => 'Last 7 days';

  @override
  String weekSessionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count focus sessions this week',
      one: '1 focus session this week',
    );
    return '$_temp0';
  }

  @override
  String get exportFailed => 'Couldn\'t create the export — please try again.';

  @override
  String get exportDescription =>
      'Focus session history for the last 7 days, generated on-device — nothing is sent anywhere to produce it.';

  @override
  String get exportPdf => 'PDF summary';

  @override
  String get exportCsv => 'CSV (spreadsheet)';

  @override
  String get exportJson => 'JSON (raw data)';

  @override
  String get saveBlockFailed => 'Couldn\'t save the block — please try again.';

  @override
  String get scheduleConflict => 'Schedule conflict';

  @override
  String conflictOverlaps(String title, String start, String end) {
    return '\"$title\" ($start – $end) overlaps:';
  }

  @override
  String conflictItem(String title, String start, String end) {
    return '• \"$title\" ($start – $end)';
  }

  @override
  String get applySuggestedTime => 'Apply suggested time';

  @override
  String get asking => 'Asking…';

  @override
  String get askAiToHelp => 'Ask AI to help';

  @override
  String get aiCouldNotHelp => 'AI couldn\'t help';

  @override
  String get askAgain => 'Ask again';

  @override
  String get editTimes => 'Edit times';

  @override
  String get saveAnyway => 'Save anyway (overlap allowed)';

  @override
  String suggestedTime(String start, String end) {
    return 'Suggested: $start – $end';
  }

  @override
  String cantApply(String reason) {
    return 'Can\'t apply: $reason';
  }

  @override
  String get aiRawTextIntro =>
      'Couldn\'t turn that into a specific time automatically:';

  @override
  String get problemEndNotAfterStart =>
      'The suggested end time is not after its start.';

  @override
  String get problemNotSameDay => 'The suggested time is not on the same day.';

  @override
  String problemLengthChanged(int got, int wanted) {
    return 'The suggestion changes the length to $got min (expected $wanted min).';
  }

  @override
  String problemStillOverlaps(String title) {
    return 'That time still overlaps \"$title\".';
  }

  @override
  String get endAfterStart => 'End time must be after start time';

  @override
  String get checkScheduleFailed =>
      'Couldn\'t check your schedule — please try again.';

  @override
  String get editScheduleBlock => 'Edit Schedule Block';

  @override
  String get addScheduleBlockTitle => 'Add Schedule Block';

  @override
  String get blockTitleField => 'Block title';

  @override
  String startAt(String time) {
    return 'Start: $time';
  }

  @override
  String endAt(String time) {
    return 'End: $time';
  }

  @override
  String get addBlock => 'Add Block';

  @override
  String deleteBlockTitle(String title) {
    return 'Delete \"$title\"?';
  }

  @override
  String get deleteBlockMessage => 'Its tasks stay and move to Unscheduled.';

  @override
  String get deleteBlockFailed =>
      'Couldn\'t delete the block — please try again.';

  @override
  String get notifyFocusComplete => 'Focus session complete';

  @override
  String get notifyShortBreakOver => 'Short break over';

  @override
  String get notifyLongBreakOver => 'Long break over';

  @override
  String get notifyBody => 'Tap to see what\'s next.';

  @override
  String get showMore => 'Show more';

  @override
  String showCompleted(int count) {
    return 'Show completed ($count)';
  }

  @override
  String hideCompleted(int count) {
    return 'Hide completed ($count)';
  }

  @override
  String get repeat => 'Repeat';

  @override
  String get repeatNone => 'Does not repeat';

  @override
  String get repeatDaily => 'Every day';

  @override
  String get repeatWeekdays => 'Every weekday (Mon–Fri)';

  @override
  String get repeatWeekly => 'Weekly on…';

  @override
  String get editRepeatingTitle => 'Edit repeating block';

  @override
  String get editThisOccurrence => 'Only this day';

  @override
  String get editAllOccurrences => 'All days';

  @override
  String get deleteRepeatingTitle => 'Delete repeating block';

  @override
  String get deleteThisOccurrence => 'Only this day';

  @override
  String get deleteThisAndFollowing => 'This day and all after it';

  @override
  String get repeatingBlock => 'Repeating block';

  @override
  String get reorderSubtask => 'Drag to reorder';

  @override
  String get aiProviderGeneric => 'the AI provider';

  @override
  String aiErrorInvalidKey(String vendor) {
    return 'That API key was rejected by $vendor.';
  }

  @override
  String aiErrorRateLimited(String vendor) {
    return '$vendor rate-limited this request — try again shortly.';
  }

  @override
  String aiErrorServer(String vendor, int status) {
    return '$vendor returned an error (HTTP $status).';
  }

  @override
  String aiErrorUnreachable(String vendor) {
    return 'Couldn\'t reach $vendor — check your connection.';
  }

  @override
  String aiErrorOllamaUnreachable(String url) {
    return 'Couldn\'t reach Ollama at $url. If it\'s running on a computer, use that computer\'s LAN IP here, not \"localhost\" — on a phone, localhost means the phone itself.';
  }

  @override
  String aiErrorEmpty(String vendor) {
    return '$vendor returned an empty response.';
  }

  @override
  String aiErrorModelNotFound(String model) {
    return 'Ollama responded, but that model isn\'t pulled yet. Run: ollama pull $model';
  }

  @override
  String aiErrorMissingKey(String vendor) {
    return 'No API key saved for $vendor yet — add one in Settings.';
  }

  @override
  String get aiErrorNoProvider =>
      'No AI provider is active — connect one in Settings.';

  @override
  String get aiStopped => 'Stopped.';

  @override
  String get aiErrorInterrupted =>
      'No reply — Atomic Assist was closed before it arrived. Send your message again.';

  @override
  String aiErrorUnknown(String vendor) {
    return 'Something went wrong talking to $vendor. Please try again.';
  }

  @override
  String get testConnection => 'Test connection';

  @override
  String get chooseModel => 'Choose a model';

  @override
  String connectionOk(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count models',
      one: '1 model',
    );
    return 'Connected — $_temp0 available.';
  }

  @override
  String modelNotListed(String vendor) {
    return 'Not in $vendor\'s list for this key. It may be retired; pick one from the list.';
  }

  @override
  String get stop => 'Stop';
}
