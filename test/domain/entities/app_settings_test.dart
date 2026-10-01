import 'package:flowline/domain/entities/app_settings.dart';
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
    });
    expect(s.themeMode, AppThemeMode.system);
    expect(s.focusMinutes, AppSettings.defaultFocusMinutes);
    expect(s.shortBreakMinutes, AppSettings.minMinutes);
    expect(s.longBreakMinutes, AppSettings.maxMinutes);
    expect(s.longBreakEvery, 2);
    expect(s.sessionAlerts, isTrue);
  });

  test('copyWith clamps too', () {
    expect(const AppSettings().copyWith(focusMinutes: 0).focusMinutes,
        AppSettings.minMinutes);
  });
}
