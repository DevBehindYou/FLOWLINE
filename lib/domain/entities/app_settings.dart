import '../assistant/autonomy.dart';
import 'focus_session.dart';

/// User preferences, stored as key/value text rows (see
/// `AppSettingsRepository`). Parsing never throws: a missing, unknown or
/// out-of-range value falls back to its default, so a corrupted or
/// newer-version row can't break app start.
enum AppThemeMode { system, light, dark }

/// When AA reads its replies aloud (docs/05 §22.4). Stored by name.
enum SpeakReplies { off, whenISpoke, always }

class AppSettings {
  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.focusMinutes = defaultFocusMinutes,
    this.shortBreakMinutes = defaultShortBreakMinutes,
    this.longBreakMinutes = defaultLongBreakMinutes,
    this.longBreakEvery = defaultLongBreakEvery,
    this.sessionAlerts = true,
    this.onboardingDone = false,
    this.autonomy = AutonomyPreset.balanced,
    this.speakReplies = SpeakReplies.whenISpoke,
    this.speechRatePercent = defaultSpeechRatePercent,
    this.keepListening = false,
    this.suggestions = true,
  });

  static const defaultSpeechRatePercent = 50;
  static const minSpeechRatePercent = 20;
  static const maxSpeechRatePercent = 100;

  static const defaultFocusMinutes = 25;
  static const defaultShortBreakMinutes = 5;
  static const defaultLongBreakMinutes = 15;
  static const defaultLongBreakEvery = 4;

  /// Bounds for every duration setting, in minutes.
  static const minMinutes = 1;
  static const maxMinutes = 180;

  final AppThemeMode themeMode;
  final int focusMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;

  /// A long break is suggested after this many completed focus sessions.
  final int longBreakEvery;

  /// Whether a notification is scheduled for the end of a session.
  final bool sessionAlerts;

  final bool onboardingDone;

  /// "How much can AA do on its own?" (docs/05 §6.2).
  final AutonomyPreset autonomy;

  final SpeakReplies speakReplies;

  /// The voice's speed, 20–100 (the platform's 0.2–1.0; 50 is normal).
  final int speechRatePercent;

  /// Conversation mode (docs/05 §22.1): listen again after each reply.
  final bool keepListening;

  /// The kill switch (docs/05 §6.6): off pauses every scanner; nothing
  /// already stored is lost.
  final bool suggestions;

  int minutesFor(FocusSessionType type) => switch (type) {
        FocusSessionType.focus => focusMinutes,
        FocusSessionType.shortBreak => shortBreakMinutes,
        FocusSessionType.longBreak => longBreakMinutes,
      };

  AppSettings copyWith({
    AppThemeMode? themeMode,
    int? focusMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    int? longBreakEvery,
    bool? sessionAlerts,
    bool? onboardingDone,
    AutonomyPreset? autonomy,
    SpeakReplies? speakReplies,
    int? speechRatePercent,
    bool? keepListening,
    bool? suggestions,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      focusMinutes: _clampMinutes(focusMinutes ?? this.focusMinutes),
      shortBreakMinutes:
          _clampMinutes(shortBreakMinutes ?? this.shortBreakMinutes),
      longBreakMinutes:
          _clampMinutes(longBreakMinutes ?? this.longBreakMinutes),
      longBreakEvery: (longBreakEvery ?? this.longBreakEvery).clamp(2, 12),
      sessionAlerts: sessionAlerts ?? this.sessionAlerts,
      onboardingDone: onboardingDone ?? this.onboardingDone,
      autonomy: autonomy ?? this.autonomy,
      speakReplies: speakReplies ?? this.speakReplies,
      speechRatePercent:
          _clampRate(speechRatePercent ?? this.speechRatePercent),
      keepListening: keepListening ?? this.keepListening,
      suggestions: suggestions ?? this.suggestions,
    );
  }

  // Storage keys. Never rename one: it would silently reset the setting
  // for every existing user (the same rule as enum indexes, R1).
  static const _kThemeMode = 'theme_mode';
  static const _kFocus = 'focus_minutes';
  static const _kShort = 'short_break_minutes';
  static const _kLong = 'long_break_minutes';
  static const _kLongEvery = 'long_break_every';
  static const _kAlerts = 'session_alerts';
  static const _kOnboarding = 'onboarding_done';
  static const _kAutonomy = 'autonomy_preset';
  static const _kSpeakReplies = 'speak_replies';
  static const _kSpeechRate = 'speech_rate_percent';
  static const _kKeepListening = 'voice_keep_listening';
  static const _kSuggestions = 'proactive_suggestions';

  Map<String, String> toStorage() => {
        _kThemeMode: themeMode.name,
        _kFocus: '$focusMinutes',
        _kShort: '$shortBreakMinutes',
        _kLong: '$longBreakMinutes',
        _kLongEvery: '$longBreakEvery',
        _kAlerts: '$sessionAlerts',
        _kOnboarding: '$onboardingDone',
        _kAutonomy: autonomy.name,
        _kSpeakReplies: speakReplies.name,
        _kSpeechRate: '$speechRatePercent',
        _kKeepListening: '$keepListening',
        _kSuggestions: '$suggestions',
      };

  factory AppSettings.fromStorage(Map<String, String> values) {
    const defaults = AppSettings();
    int minutes(String key, int fallback) {
      final parsed = int.tryParse(values[key] ?? '');
      return parsed == null ? fallback : _clampMinutes(parsed);
    }

    bool flag(String key, bool fallback) => switch (values[key]) {
          'true' => true,
          'false' => false,
          _ => fallback,
        };

    return AppSettings(
      themeMode: AppThemeMode.values
              .where((m) => m.name == values[_kThemeMode])
              .firstOrNull ??
          defaults.themeMode,
      focusMinutes: minutes(_kFocus, defaults.focusMinutes),
      shortBreakMinutes: minutes(_kShort, defaults.shortBreakMinutes),
      longBreakMinutes: minutes(_kLong, defaults.longBreakMinutes),
      longBreakEvery:
          (int.tryParse(values[_kLongEvery] ?? '') ?? defaults.longBreakEvery)
              .clamp(2, 12),
      sessionAlerts: flag(_kAlerts, defaults.sessionAlerts),
      onboardingDone: flag(_kOnboarding, defaults.onboardingDone),
      autonomy: AutonomyPreset.values
              .where((a) => a.name == values[_kAutonomy])
              .firstOrNull ??
          defaults.autonomy,
      speakReplies: SpeakReplies.values
              .where((v) => v.name == values[_kSpeakReplies])
              .firstOrNull ??
          defaults.speakReplies,
      speechRatePercent: _clampRate(int.tryParse(values[_kSpeechRate] ?? '') ??
          defaults.speechRatePercent),
      keepListening: flag(_kKeepListening, defaults.keepListening),
      suggestions: flag(_kSuggestions, defaults.suggestions),
    );
  }

  static int _clampMinutes(int value) => value.clamp(minMinutes, maxMinutes);
  static int _clampRate(int value) =>
      value.clamp(minSpeechRatePercent, maxSpeechRatePercent);

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.themeMode == themeMode &&
      other.focusMinutes == focusMinutes &&
      other.shortBreakMinutes == shortBreakMinutes &&
      other.longBreakMinutes == longBreakMinutes &&
      other.longBreakEvery == longBreakEvery &&
      other.sessionAlerts == sessionAlerts &&
      other.onboardingDone == onboardingDone &&
      other.autonomy == autonomy &&
      other.speakReplies == speakReplies &&
      other.speechRatePercent == speechRatePercent &&
      other.keepListening == keepListening &&
      other.suggestions == suggestions;

  @override
  int get hashCode => Object.hash(
      themeMode,
      focusMinutes,
      shortBreakMinutes,
      longBreakMinutes,
      longBreakEvery,
      sessionAlerts,
      onboardingDone,
      autonomy,
      speakReplies,
      speechRatePercent,
      keepListening,
      suggestions);
}
