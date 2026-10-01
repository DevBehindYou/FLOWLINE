import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Flowline'**
  String get appTitle;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach the server — check your connection.'**
  String get errorNetwork;

  /// No description provided for @errorStorage.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read your data on this phone.'**
  String get errorStorage;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get errorGeneric;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @navToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get navToday;

  /// No description provided for @navFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get navFocus;

  /// No description provided for @navAssistant.
  ///
  /// In en, this message translates to:
  /// **'Assistant'**
  String get navAssistant;

  /// No description provided for @navInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get navInsights;

  /// No description provided for @onboardingSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your progress — please try again.'**
  String get onboardingSaveFailed;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan the day. Focus. See where time went.'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Flowline keeps your tasks, time blocks and focus sessions on this phone. No account, no sync, nothing leaves the device unless you export it.'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Know when a session ends'**
  String get onboardingNotificationsTitle;

  /// No description provided for @onboardingNotificationsBody.
  ///
  /// In en, this message translates to:
  /// **'Flowline uses notifications only for focus session and break alerts, so you can put the phone down. You can change this any time in Settings.'**
  String get onboardingNotificationsBody;

  /// No description provided for @onboardingAllowNotifications.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get onboardingAllowNotifications;

  /// No description provided for @onboardingNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get onboardingNotNow;

  /// No description provided for @onboardingAiTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect an AI assistant (optional)'**
  String get onboardingAiTitle;

  /// No description provided for @onboardingAiBody.
  ///
  /// In en, this message translates to:
  /// **'Bring your own API key from OpenAI, Anthropic, Gemini, or run Ollama locally. Keys are stored in the Android Keystore and never backed up. Everything else works without one.'**
  String get onboardingAiBody;

  /// No description provided for @onboardingConnectProvider.
  ///
  /// In en, this message translates to:
  /// **'Connect a provider'**
  String get onboardingConnectProvider;

  /// No description provided for @onboardingSkipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get onboardingSkipForNow;

  /// No description provided for @onboardingStep.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String onboardingStep(int current, int total);

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @settingSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the setting — please try again.'**
  String get settingSaveFailed;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @appearanceTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get appearanceTheme;

  /// No description provided for @appearanceSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get appearanceSystem;

  /// No description provided for @appearanceLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get appearanceLight;

  /// No description provided for @appearanceDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get appearanceDark;

  /// No description provided for @appearanceSystemHint.
  ///
  /// In en, this message translates to:
  /// **'System follows your phone’s dark mode setting.'**
  String get appearanceSystemHint;

  /// No description provided for @settingsFocusTimer.
  ///
  /// In en, this message translates to:
  /// **'Focus timer'**
  String get settingsFocusTimer;

  /// No description provided for @sessionFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get sessionFocus;

  /// No description provided for @sessionShortBreak.
  ///
  /// In en, this message translates to:
  /// **'Short break'**
  String get sessionShortBreak;

  /// No description provided for @sessionLongBreak.
  ///
  /// In en, this message translates to:
  /// **'Long break'**
  String get sessionLongBreak;

  /// No description provided for @focusSettingsLongBreakAfter.
  ///
  /// In en, this message translates to:
  /// **'Long break after'**
  String get focusSettingsLongBreakAfter;

  /// No description provided for @focusSessionCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 focus session} other{{count} focus sessions}}'**
  String focusSessionCount(int count);

  /// No description provided for @focusSettingsHint.
  ///
  /// In en, this message translates to:
  /// **'New lengths apply to the next session you start.'**
  String get focusSettingsHint;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String minutesShort(int minutes);

  /// No description provided for @decreaseSetting.
  ///
  /// In en, this message translates to:
  /// **'Decrease {setting}'**
  String decreaseSetting(String setting);

  /// No description provided for @increaseSetting.
  ///
  /// In en, this message translates to:
  /// **'Increase {setting}'**
  String increaseSetting(String setting);

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @notificationsSessionAlerts.
  ///
  /// In en, this message translates to:
  /// **'Session alerts'**
  String get notificationsSessionAlerts;

  /// No description provided for @notificationsSessionAlertsHint.
  ///
  /// In en, this message translates to:
  /// **'A notification when a focus session or break ends'**
  String get notificationsSessionAlertsHint;

  /// No description provided for @clearAllDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear all data?'**
  String get clearAllDataTitle;

  /// No description provided for @clearAllDataMessage.
  ///
  /// In en, this message translates to:
  /// **'Deletes every task, block, focus session, conversation and saved API key on this phone. This can’t be undone.'**
  String get clearAllDataMessage;

  /// No description provided for @clearAllDataConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear everything'**
  String get clearAllDataConfirm;

  /// No description provided for @clearAllDataFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t clear your data — please try again.'**
  String get clearAllDataFailed;

  /// No description provided for @settingsDataPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Data & privacy'**
  String get settingsDataPrivacy;

  /// No description provided for @dataWhereTitle.
  ///
  /// In en, this message translates to:
  /// **'Where your data lives'**
  String get dataWhereTitle;

  /// No description provided for @dataWhereBody.
  ///
  /// In en, this message translates to:
  /// **'Everything you create is stored only on this phone. There is no Flowline account, server or analytics.\n\nAPI keys are kept in Android’s secure Keystore and are only ever sent to the AI provider they belong to. When you use the Assistant, your message and the conversation so far go directly from this phone to the provider you chose.\n\nYour Android backup includes your Flowline data but never your API keys.'**
  String get dataWhereBody;

  /// No description provided for @clearAllData.
  ///
  /// In en, this message translates to:
  /// **'Clear all data'**
  String get clearAllData;

  /// No description provided for @openSourceLicences.
  ///
  /// In en, this message translates to:
  /// **'Open-source licences'**
  String get openSourceLicences;

  /// No description provided for @allDataCleared.
  ///
  /// In en, this message translates to:
  /// **'All data cleared'**
  String get allDataCleared;

  /// No description provided for @removeKeyTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {provider} key?'**
  String removeKeyTitle(String provider);

  /// No description provided for @removeKeyMessage.
  ///
  /// In en, this message translates to:
  /// **'The key is deleted from this phone. Your saved conversations stay, but new messages won\'t work until you add a key again.'**
  String get removeKeyMessage;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save — please try again.'**
  String get saveFailed;

  /// No description provided for @apiKey.
  ///
  /// In en, this message translates to:
  /// **'API key'**
  String get apiKey;

  /// No description provided for @apiKeySavedHint.
  ///
  /// In en, this message translates to:
  /// **'A key is saved. Leave empty to keep it.'**
  String get apiKeySavedHint;

  /// No description provided for @apiKeyStorageHint.
  ///
  /// In en, this message translates to:
  /// **'Stored only on this phone, in the Android Keystore.'**
  String get apiKeyStorageHint;

  /// No description provided for @showKey.
  ///
  /// In en, this message translates to:
  /// **'Show key'**
  String get showKey;

  /// No description provided for @hideKey.
  ///
  /// In en, this message translates to:
  /// **'Hide key'**
  String get hideKey;

  /// No description provided for @serverUrl.
  ///
  /// In en, this message translates to:
  /// **'Server URL'**
  String get serverUrl;

  /// No description provided for @serverUrlHint.
  ///
  /// In en, this message translates to:
  /// **'On a phone, \"localhost\" means the phone itself — use your computer\'s LAN IP if Ollama runs there.'**
  String get serverUrlHint;

  /// No description provided for @model.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get model;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @removeKey.
  ///
  /// In en, this message translates to:
  /// **'Remove key'**
  String get removeKey;

  /// No description provided for @aiFieldModelEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter a model name'**
  String get aiFieldModelEmpty;

  /// No description provided for @aiFieldModelHasSpaces.
  ///
  /// In en, this message translates to:
  /// **'Model names have no spaces'**
  String get aiFieldModelHasSpaces;

  /// No description provided for @aiFieldUrlNeedsScheme.
  ///
  /// In en, this message translates to:
  /// **'Start with http:// or https://, e.g. http://192.168.1.20:11434'**
  String get aiFieldUrlNeedsScheme;

  /// No description provided for @aiFieldUrlNeedsHost.
  ///
  /// In en, this message translates to:
  /// **'Add the computer\'s address after http://'**
  String get aiFieldUrlNeedsHost;

  /// No description provided for @aiFieldUrlHasPath.
  ///
  /// In en, this message translates to:
  /// **'Use only the server address, e.g. http://192.168.1.20:11434'**
  String get aiFieldUrlHasPath;

  /// No description provided for @aiFieldKeyEmpty.
  ///
  /// In en, this message translates to:
  /// **'Paste your API key'**
  String get aiFieldKeyEmpty;

  /// No description provided for @aiFieldKeyHasSpaces.
  ///
  /// In en, this message translates to:
  /// **'The key contains spaces — paste it again'**
  String get aiFieldKeyHasSpaces;

  /// No description provided for @settingsAiProviders.
  ///
  /// In en, this message translates to:
  /// **'AI Providers'**
  String get settingsAiProviders;

  /// No description provided for @settingsAiProvidersHint.
  ///
  /// In en, this message translates to:
  /// **'Connect Anthropic, OpenAI, Gemini, or a local Ollama server'**
  String get settingsAiProvidersHint;

  /// No description provided for @settingsFocusTimerHint.
  ///
  /// In en, this message translates to:
  /// **'Session and break lengths'**
  String get settingsFocusTimerHint;

  /// No description provided for @settingsAppearanceHint.
  ///
  /// In en, this message translates to:
  /// **'Light, dark or system'**
  String get settingsAppearanceHint;

  /// No description provided for @settingsDataPrivacyHint.
  ///
  /// In en, this message translates to:
  /// **'Where your data lives, clear all data'**
  String get settingsDataPrivacyHint;

  /// No description provided for @providerConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected • {model}'**
  String providerConnected(String model);

  /// No description provided for @providerNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get providerNotConnected;

  /// No description provided for @providerStatusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get providerStatusUnknown;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @assistantNoProviderTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect an AI provider'**
  String get assistantNoProviderTitle;

  /// No description provided for @assistantNoProviderMessage.
  ///
  /// In en, this message translates to:
  /// **'Add an API key in Settings to start chatting.'**
  String get assistantNoProviderMessage;

  /// No description provided for @assistantGoToProviders.
  ///
  /// In en, this message translates to:
  /// **'Go to AI Providers'**
  String get assistantGoToProviders;

  /// No description provided for @assistantSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send — your message is back in the box.'**
  String get assistantSendFailed;

  /// No description provided for @assistantEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Ask me anything'**
  String get assistantEmptyTitle;

  /// No description provided for @assistantEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Try asking about your schedule, or just say hello.'**
  String get assistantEmptyMessage;

  /// No description provided for @assistantInputHint.
  ///
  /// In en, this message translates to:
  /// **'Ask the assistant…'**
  String get assistantInputHint;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @assistantWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for a reply'**
  String get assistantWaiting;

  /// No description provided for @assistantThinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking…'**
  String get assistantThinking;

  /// No description provided for @todayEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet'**
  String get todayEmptyTitle;

  /// No description provided for @todayEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add your first task to start planning today.'**
  String get todayEmptyMessage;

  /// No description provided for @addTask.
  ///
  /// In en, this message translates to:
  /// **'Add Task'**
  String get addTask;

  /// No description provided for @previousDay.
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get previousDay;

  /// No description provided for @jumpToToday.
  ///
  /// In en, this message translates to:
  /// **'Jump to today'**
  String get jumpToToday;

  /// No description provided for @nextDay.
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get nextDay;

  /// No description provided for @addScheduleBlock.
  ///
  /// In en, this message translates to:
  /// **'Add schedule block'**
  String get addScheduleBlock;

  /// No description provided for @unscheduled.
  ///
  /// In en, this message translates to:
  /// **'Unscheduled'**
  String get unscheduled;

  /// No description provided for @timeRange.
  ///
  /// In en, this message translates to:
  /// **'{start} – {end}'**
  String timeRange(String start, String end);

  /// No description provided for @blockOptions.
  ///
  /// In en, this message translates to:
  /// **'Block options'**
  String get blockOptions;

  /// No description provided for @editBlock.
  ///
  /// In en, this message translates to:
  /// **'Edit block'**
  String get editBlock;

  /// No description provided for @deleteBlock.
  ///
  /// In en, this message translates to:
  /// **'Delete block'**
  String get deleteBlock;

  /// No description provided for @addTaskToBlock.
  ///
  /// In en, this message translates to:
  /// **'Add task to this block'**
  String get addTaskToBlock;

  /// No description provided for @overlapsAnotherBlock.
  ///
  /// In en, this message translates to:
  /// **'Overlaps another block'**
  String get overlapsAnotherBlock;

  /// No description provided for @blockEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tasks in this block yet.'**
  String get blockEmpty;

  /// No description provided for @priorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// No description provided for @priorityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get priorityMedium;

  /// No description provided for @priorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHigh;

  /// No description provided for @statusTodo.
  ///
  /// In en, this message translates to:
  /// **'Todo'**
  String get statusTodo;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get statusInProgress;

  /// No description provided for @statusDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get statusDone;

  /// No description provided for @deleteTaskFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete the task — please try again.'**
  String get deleteTaskFailed;

  /// No description provided for @markNotDone.
  ///
  /// In en, this message translates to:
  /// **'Mark as not done'**
  String get markNotDone;

  /// No description provided for @markDone.
  ///
  /// In en, this message translates to:
  /// **'Mark as done'**
  String get markDone;

  /// No description provided for @startFocusSession.
  ///
  /// In en, this message translates to:
  /// **'Start focus session'**
  String get startFocusSession;

  /// No description provided for @markedDone.
  ///
  /// In en, this message translates to:
  /// **'Marked \"{title}\" done'**
  String markedDone(String title);

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @priorityOption.
  ///
  /// In en, this message translates to:
  /// **'Priority: {priority}'**
  String priorityOption(String priority);

  /// No description provided for @deleteTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete task?'**
  String get deleteTaskTitle;

  /// No description provided for @deleteTaskMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" will be removed permanently.'**
  String deleteTaskMessage(String title);

  /// No description provided for @dueOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue · {date}'**
  String dueOverdue(String date);

  /// No description provided for @dueToday.
  ///
  /// In en, this message translates to:
  /// **'Due today {time}'**
  String dueToday(String time);

  /// No description provided for @dueOn.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String dueOn(String date);

  /// No description provided for @taskTitle.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get taskTitle;

  /// No description provided for @editTask.
  ///
  /// In en, this message translates to:
  /// **'Edit task'**
  String get editTask;

  /// No description provided for @deleteTask.
  ///
  /// In en, this message translates to:
  /// **'Delete task'**
  String get deleteTask;

  /// No description provided for @deleteTaskWithSubtasksMessage.
  ///
  /// In en, this message translates to:
  /// **'This removes the task and its subtasks permanently.'**
  String get deleteTaskWithSubtasksMessage;

  /// No description provided for @taskMissing.
  ///
  /// In en, this message translates to:
  /// **'This task no longer exists.'**
  String get taskMissing;

  /// No description provided for @startFocusSessionButton.
  ///
  /// In en, this message translates to:
  /// **'Start Focus Session'**
  String get startFocusSessionButton;

  /// No description provided for @subtasks.
  ///
  /// In en, this message translates to:
  /// **'Subtasks'**
  String get subtasks;

  /// No description provided for @addSubtask.
  ///
  /// In en, this message translates to:
  /// **'Add subtask'**
  String get addSubtask;

  /// No description provided for @focusHistory.
  ///
  /// In en, this message translates to:
  /// **'Focus history'**
  String get focusHistory;

  /// No description provided for @newSubtask.
  ///
  /// In en, this message translates to:
  /// **'New subtask'**
  String get newSubtask;

  /// No description provided for @titleField.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleField;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @subtasksEmpty.
  ///
  /// In en, this message translates to:
  /// **'No subtasks yet.'**
  String get subtasksEmpty;

  /// No description provided for @subtaskSprints.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {planned} pomodoros logged'**
  String subtaskSprints(int completed, int planned);

  /// No description provided for @deleteSubtask.
  ///
  /// In en, this message translates to:
  /// **'Delete subtask'**
  String get deleteSubtask;

  /// No description provided for @deleteSubtaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete subtask?'**
  String get deleteSubtaskTitle;

  /// No description provided for @deleteSubtaskMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" and its logged pomodoro count will be removed.'**
  String deleteSubtaskMessage(String title);

  /// No description provided for @focusHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No focus sessions yet.'**
  String get focusHistoryEmpty;

  /// No description provided for @focusHistorySummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 session} other{{count} sessions}} · {minutes} min total'**
  String focusHistorySummary(int count, int minutes);

  /// No description provided for @dateTime.
  ///
  /// In en, this message translates to:
  /// **'{date} {time}'**
  String dateTime(String date, String time);

  /// No description provided for @minutesEndedEarly.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min · ended early'**
  String minutesEndedEarly(int minutes);

  /// No description provided for @dueOverdueAt.
  ///
  /// In en, this message translates to:
  /// **'Overdue · {date} {time}'**
  String dueOverdueAt(String date, String time);

  /// No description provided for @dueAt.
  ///
  /// In en, this message translates to:
  /// **'Due {date} {time}'**
  String dueAt(String date, String time);

  /// No description provided for @titleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get titleRequired;

  /// No description provided for @saveTaskFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the task — please try again.'**
  String get saveTaskFailed;

  /// No description provided for @deleteTaskAndSubtasksMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" and its subtasks will be removed permanently.'**
  String deleteTaskAndSubtasksMessage(String title);

  /// No description provided for @editTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Task'**
  String get editTaskTitle;

  /// No description provided for @notesField.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesField;

  /// No description provided for @priorityField.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priorityField;

  /// No description provided for @statusField.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusField;

  /// No description provided for @formStatusTodo.
  ///
  /// In en, this message translates to:
  /// **'To do'**
  String get formStatusTodo;

  /// No description provided for @formStatusDoing.
  ///
  /// In en, this message translates to:
  /// **'Doing'**
  String get formStatusDoing;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @deleteTaskButton.
  ///
  /// In en, this message translates to:
  /// **'Delete task'**
  String get deleteTaskButton;

  /// No description provided for @scheduleBlockField.
  ///
  /// In en, this message translates to:
  /// **'Schedule block'**
  String get scheduleBlockField;

  /// No description provided for @keepCurrentBlock.
  ///
  /// In en, this message translates to:
  /// **'Keep current block'**
  String get keepCurrentBlock;

  /// No description provided for @blockOption.
  ///
  /// In en, this message translates to:
  /// **'{title} · {time}'**
  String blockOption(String title, String time);

  /// No description provided for @noDueDate.
  ///
  /// In en, this message translates to:
  /// **'No due date'**
  String get noDueDate;

  /// No description provided for @removeDueDate.
  ///
  /// In en, this message translates to:
  /// **'Remove due date'**
  String get removeDueDate;

  /// No description provided for @unlinkTask.
  ///
  /// In en, this message translates to:
  /// **'Unlink task'**
  String get unlinkTask;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @timerPaused.
  ///
  /// In en, this message translates to:
  /// **'PAUSED'**
  String get timerPaused;

  /// No description provided for @end.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get end;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @addFiveMinutes.
  ///
  /// In en, this message translates to:
  /// **'+5 min'**
  String get addFiveMinutes;

  /// No description provided for @timerLabelFocus.
  ///
  /// In en, this message translates to:
  /// **'FOCUS'**
  String get timerLabelFocus;

  /// No description provided for @timerLabelShortBreak.
  ///
  /// In en, this message translates to:
  /// **'SHORT BREAK'**
  String get timerLabelShortBreak;

  /// No description provided for @timerLabelLongBreak.
  ///
  /// In en, this message translates to:
  /// **'LONG BREAK'**
  String get timerLabelLongBreak;

  /// No description provided for @selectorFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus ({minutes}m)'**
  String selectorFocus(int minutes);

  /// No description provided for @selectorShortBreak.
  ///
  /// In en, this message translates to:
  /// **'Short ({minutes}m)'**
  String selectorShortBreak(int minutes);

  /// No description provided for @selectorLongBreak.
  ///
  /// In en, this message translates to:
  /// **'Long ({minutes}m)'**
  String selectorLongBreak(int minutes);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String durationHoursMinutes(int hours, int minutes);

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String durationMinutes(int minutes);

  /// No description provided for @todaysFocus.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Focus'**
  String get todaysFocus;

  /// No description provided for @focusFooterSummary.
  ///
  /// In en, this message translates to:
  /// **'{duration} • {count, plural, =1{1 session} other{{count} sessions}}'**
  String focusFooterSummary(String duration, int count);

  /// No description provided for @summaryEndedEarly.
  ///
  /// In en, this message translates to:
  /// **'Session ended early'**
  String get summaryEndedEarly;

  /// No description provided for @summaryBreakSkipped.
  ///
  /// In en, this message translates to:
  /// **'Break skipped'**
  String get summaryBreakSkipped;

  /// No description provided for @summaryFocusComplete.
  ///
  /// In en, this message translates to:
  /// **'Focus session complete'**
  String get summaryFocusComplete;

  /// No description provided for @summaryBreakOver.
  ///
  /// In en, this message translates to:
  /// **'Break over'**
  String get summaryBreakOver;

  /// No description provided for @summaryLoggedEarly.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min of focus logged. Every bit counts.'**
  String summaryLoggedEarly(int minutes);

  /// No description provided for @summaryLogged.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min of focus logged.'**
  String summaryLogged(int minutes);

  /// No description provided for @summaryOnTask.
  ///
  /// In en, this message translates to:
  /// **'On: {title}'**
  String summaryOnTask(String title);

  /// No description provided for @summarySessionsToday.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 focus session today} other{{count} focus sessions today}}'**
  String summarySessionsToday(int count);

  /// No description provided for @startFocusMinutes.
  ///
  /// In en, this message translates to:
  /// **'Start focus session ({minutes}m)'**
  String startFocusMinutes(int minutes);

  /// No description provided for @startShortBreakMinutes.
  ///
  /// In en, this message translates to:
  /// **'Start short break ({minutes}m)'**
  String startShortBreakMinutes(int minutes);

  /// No description provided for @startLongBreakMinutes.
  ///
  /// In en, this message translates to:
  /// **'Start long break ({minutes}m)'**
  String startLongBreakMinutes(int minutes);

  /// No description provided for @backToToday.
  ///
  /// In en, this message translates to:
  /// **'Back to Today'**
  String get backToToday;

  /// No description provided for @timer.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get timer;

  /// No description provided for @timerRemaining.
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, =1{1 minute} other{{minutes} minutes}} {seconds, plural, =1{1 second} other{{seconds} seconds}} remaining'**
  String timerRemaining(int minutes, int seconds);

  /// No description provided for @exportThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Export this week'**
  String get exportThisWeek;

  /// No description provided for @insightsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete a session to see stats'**
  String get insightsEmptyTitle;

  /// No description provided for @insightsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Focus-time trends and streaks show up here once you’ve logged a session.'**
  String get insightsEmptyMessage;

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'Day streak'**
  String get dayStreak;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get last7Days;

  /// No description provided for @weekSessionCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 focus session this week} other{{count} focus sessions this week}}'**
  String weekSessionCount(int count);

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create the export — please try again.'**
  String get exportFailed;

  /// No description provided for @exportDescription.
  ///
  /// In en, this message translates to:
  /// **'Focus session history for the last 7 days, generated on-device — nothing is sent anywhere to produce it.'**
  String get exportDescription;

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'PDF summary'**
  String get exportPdf;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'CSV (spreadsheet)'**
  String get exportCsv;

  /// No description provided for @exportJson.
  ///
  /// In en, this message translates to:
  /// **'JSON (raw data)'**
  String get exportJson;

  /// No description provided for @saveBlockFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the block — please try again.'**
  String get saveBlockFailed;

  /// No description provided for @scheduleConflict.
  ///
  /// In en, this message translates to:
  /// **'Schedule conflict'**
  String get scheduleConflict;

  /// No description provided for @conflictOverlaps.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" ({start} – {end}) overlaps:'**
  String conflictOverlaps(String title, String start, String end);

  /// No description provided for @conflictItem.
  ///
  /// In en, this message translates to:
  /// **'• \"{title}\" ({start} – {end})'**
  String conflictItem(String title, String start, String end);

  /// No description provided for @applySuggestedTime.
  ///
  /// In en, this message translates to:
  /// **'Apply suggested time'**
  String get applySuggestedTime;

  /// No description provided for @asking.
  ///
  /// In en, this message translates to:
  /// **'Asking…'**
  String get asking;

  /// No description provided for @askAiToHelp.
  ///
  /// In en, this message translates to:
  /// **'Ask AI to help'**
  String get askAiToHelp;

  /// No description provided for @askAgain.
  ///
  /// In en, this message translates to:
  /// **'Ask again'**
  String get askAgain;

  /// No description provided for @editTimes.
  ///
  /// In en, this message translates to:
  /// **'Edit times'**
  String get editTimes;

  /// No description provided for @saveAnyway.
  ///
  /// In en, this message translates to:
  /// **'Save anyway (overlap allowed)'**
  String get saveAnyway;

  /// No description provided for @suggestedTime.
  ///
  /// In en, this message translates to:
  /// **'Suggested: {start} – {end}'**
  String suggestedTime(String start, String end);

  /// No description provided for @cantApply.
  ///
  /// In en, this message translates to:
  /// **'Can\'t apply: {reason}'**
  String cantApply(String reason);

  /// No description provided for @aiRawTextIntro.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t turn that into a specific time automatically:'**
  String get aiRawTextIntro;

  /// No description provided for @problemEndNotAfterStart.
  ///
  /// In en, this message translates to:
  /// **'The suggested end time is not after its start.'**
  String get problemEndNotAfterStart;

  /// No description provided for @problemNotSameDay.
  ///
  /// In en, this message translates to:
  /// **'The suggested time is not on the same day.'**
  String get problemNotSameDay;

  /// No description provided for @problemLengthChanged.
  ///
  /// In en, this message translates to:
  /// **'The suggestion changes the length to {got} min (expected {wanted} min).'**
  String problemLengthChanged(int got, int wanted);

  /// No description provided for @problemStillOverlaps.
  ///
  /// In en, this message translates to:
  /// **'That time still overlaps \"{title}\".'**
  String problemStillOverlaps(String title);

  /// No description provided for @endAfterStart.
  ///
  /// In en, this message translates to:
  /// **'End time must be after start time'**
  String get endAfterStart;

  /// No description provided for @checkScheduleFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t check your schedule — please try again.'**
  String get checkScheduleFailed;

  /// No description provided for @editScheduleBlock.
  ///
  /// In en, this message translates to:
  /// **'Edit Schedule Block'**
  String get editScheduleBlock;

  /// No description provided for @addScheduleBlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Schedule Block'**
  String get addScheduleBlockTitle;

  /// No description provided for @blockTitleField.
  ///
  /// In en, this message translates to:
  /// **'Block title'**
  String get blockTitleField;

  /// No description provided for @startAt.
  ///
  /// In en, this message translates to:
  /// **'Start: {time}'**
  String startAt(String time);

  /// No description provided for @endAt.
  ///
  /// In en, this message translates to:
  /// **'End: {time}'**
  String endAt(String time);

  /// No description provided for @addBlock.
  ///
  /// In en, this message translates to:
  /// **'Add Block'**
  String get addBlock;

  /// No description provided for @deleteBlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"?'**
  String deleteBlockTitle(String title);

  /// No description provided for @deleteBlockMessage.
  ///
  /// In en, this message translates to:
  /// **'Its tasks stay and move to Unscheduled.'**
  String get deleteBlockMessage;

  /// No description provided for @deleteBlockFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete the block — please try again.'**
  String get deleteBlockFailed;

  /// No description provided for @notifyFocusComplete.
  ///
  /// In en, this message translates to:
  /// **'Focus session complete'**
  String get notifyFocusComplete;

  /// No description provided for @notifyShortBreakOver.
  ///
  /// In en, this message translates to:
  /// **'Short break over'**
  String get notifyShortBreakOver;

  /// No description provided for @notifyLongBreakOver.
  ///
  /// In en, this message translates to:
  /// **'Long break over'**
  String get notifyLongBreakOver;

  /// No description provided for @notifyBody.
  ///
  /// In en, this message translates to:
  /// **'Tap to see what\'s next.'**
  String get notifyBody;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get showMore;

  /// No description provided for @showCompleted.
  ///
  /// In en, this message translates to:
  /// **'Show completed ({count})'**
  String showCompleted(int count);

  /// No description provided for @hideCompleted.
  ///
  /// In en, this message translates to:
  /// **'Hide completed ({count})'**
  String hideCompleted(int count);

  /// No description provided for @repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// No description provided for @repeatNone.
  ///
  /// In en, this message translates to:
  /// **'Does not repeat'**
  String get repeatNone;

  /// No description provided for @repeatDaily.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get repeatDaily;

  /// No description provided for @repeatWeekdays.
  ///
  /// In en, this message translates to:
  /// **'Every weekday (Mon–Fri)'**
  String get repeatWeekdays;

  /// No description provided for @repeatWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly on…'**
  String get repeatWeekly;

  /// No description provided for @editRepeatingTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit repeating block'**
  String get editRepeatingTitle;

  /// No description provided for @editThisOccurrence.
  ///
  /// In en, this message translates to:
  /// **'Only this day'**
  String get editThisOccurrence;

  /// No description provided for @editAllOccurrences.
  ///
  /// In en, this message translates to:
  /// **'All days'**
  String get editAllOccurrences;

  /// No description provided for @deleteRepeatingTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete repeating block'**
  String get deleteRepeatingTitle;

  /// No description provided for @deleteThisOccurrence.
  ///
  /// In en, this message translates to:
  /// **'Only this day'**
  String get deleteThisOccurrence;

  /// No description provided for @deleteThisAndFollowing.
  ///
  /// In en, this message translates to:
  /// **'This day and all after it'**
  String get deleteThisAndFollowing;

  /// No description provided for @repeatingBlock.
  ///
  /// In en, this message translates to:
  /// **'Repeating block'**
  String get repeatingBlock;

  /// No description provided for @reorderSubtask.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder'**
  String get reorderSubtask;

  /// No description provided for @aiProviderGeneric.
  ///
  /// In en, this message translates to:
  /// **'the AI provider'**
  String get aiProviderGeneric;

  /// No description provided for @aiErrorInvalidKey.
  ///
  /// In en, this message translates to:
  /// **'That API key was rejected by {vendor}.'**
  String aiErrorInvalidKey(String vendor);

  /// No description provided for @aiErrorRateLimited.
  ///
  /// In en, this message translates to:
  /// **'{vendor} rate-limited this request — try again shortly.'**
  String aiErrorRateLimited(String vendor);

  /// No description provided for @aiErrorServer.
  ///
  /// In en, this message translates to:
  /// **'{vendor} returned an error (HTTP {status}).'**
  String aiErrorServer(String vendor, int status);

  /// No description provided for @aiErrorUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach {vendor} — check your connection.'**
  String aiErrorUnreachable(String vendor);

  /// No description provided for @aiErrorOllamaUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach Ollama at {url}. If it\'s running on a computer, use that computer\'s LAN IP here, not \"localhost\" — on a phone, localhost means the phone itself.'**
  String aiErrorOllamaUnreachable(String url);

  /// No description provided for @aiErrorEmpty.
  ///
  /// In en, this message translates to:
  /// **'{vendor} returned an empty response.'**
  String aiErrorEmpty(String vendor);

  /// No description provided for @aiErrorModelNotFound.
  ///
  /// In en, this message translates to:
  /// **'Ollama responded, but that model isn\'t pulled yet. Run: ollama pull {model}'**
  String aiErrorModelNotFound(String model);

  /// No description provided for @aiErrorMissingKey.
  ///
  /// In en, this message translates to:
  /// **'No API key saved for {vendor} yet — add one in Settings.'**
  String aiErrorMissingKey(String vendor);

  /// No description provided for @aiErrorNoProvider.
  ///
  /// In en, this message translates to:
  /// **'No AI provider is active — connect one in Settings.'**
  String get aiErrorNoProvider;

  /// No description provided for @aiStopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped.'**
  String get aiStopped;

  /// No description provided for @aiErrorInterrupted.
  ///
  /// In en, this message translates to:
  /// **'No reply — Flowline was closed before it arrived. Send your message again.'**
  String get aiErrorInterrupted;

  /// No description provided for @aiErrorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong talking to {vendor}. Please try again.'**
  String aiErrorUnknown(String vendor);

  /// No description provided for @testConnection.
  ///
  /// In en, this message translates to:
  /// **'Test connection'**
  String get testConnection;

  /// No description provided for @chooseModel.
  ///
  /// In en, this message translates to:
  /// **'Choose a model'**
  String get chooseModel;

  /// No description provided for @connectionOk.
  ///
  /// In en, this message translates to:
  /// **'Connected — {count, plural, =1{1 model} other{{count} models}} available.'**
  String connectionOk(int count);

  /// No description provided for @modelNotListed.
  ///
  /// In en, this message translates to:
  /// **'Not in {vendor}\'s list for this key. It may be retired; pick one from the list.'**
  String modelNotListed(String vendor);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
