import 'package:atomic_assist/domain/assistant/autonomy.dart';
import 'package:atomic_assist/domain/entities/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('round-trips through storage', () {
    const settings = AppSettings(
      themeMode: AppThemeMode.dark,
      focusMinutes: 50,
      shortBreakMinutes: 10,
      longBreakMinutes: 30,
      longBreakEvery: 3,
      sessionAlerts: false,
      onboardingDone: true,
      autonomy: AutonomyPreset.careful,
      speakReplies: SpeakReplies.always,
      speechRatePercent: 70,
      keepListening: true,
      suggestions: false,
      briefings: false,
    );
    expect(AppSettings.fromStorage(settings.toStorage()), settings);
  });

  test('empty storage gives the defaults', () {
    expect(AppSettings.fromStorage(const {}), const AppSettings());
  });

  test('garbage and out-of-range values fall back or clamp, never throw', () {
    final s = AppSettings.fromStorage(const {
      'theme_mode': 'neon',
      'focus_minutes': 'abc',
      'short_break_minutes': '0',
      'long_break_minutes': '999',
      'long_break_every': '-4',
      'session_alerts': 'maybe',
      'autonomy_preset': 'yolo',
      'speak_replies': 'shout',
      'speech_rate_percent': '400',
      'voice_keep_listening': '1',
    });
    expect(s.speakReplies, SpeakReplies.whenISpoke);
    expect(s.speechRatePercent, AppSettings.maxSpeechRatePercent);
    expect(s.keepListening, isFalse);
    expect(s.themeMode, AppThemeMode.system);
    expect(s.focusMinutes, AppSettings.defaultFocusMinutes);
    expect(s.shortBreakMinutes, AppSettings.minMinutes);
    expect(s.longBreakMinutes, AppSettings.maxMinutes);
    expect(s.longBreakEvery, 2);
    expect(s.sessionAlerts, isTrue);
    expect(s.autonomy, AutonomyPreset.balanced);
  });

  test('copyWith clamps too', () {
    expect(const AppSettings().copyWith(focusMinutes: 0).focusMinutes,
        AppSettings.minMinutes);
  });
}
