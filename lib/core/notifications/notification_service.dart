import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Thin wrapper around a single scheduled "session complete" notification.
/// Deliberately minimal: one fixed notification id, reused for whichever
/// session is currently active — there is only ever one active focus
/// session at a time (see FocusSessionRepository), so there is never more
/// than one of these in flight, and starting a new one implicitly
/// replaces the last.
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _sessionNotificationId = 1001;
  static const _channelId = 'focus_session';

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    // v5's getLocalTimezone() returns a TimezoneInfo, not a bare String
    // (pinned constraint was ^1.1.0, which no longer resolves on pub.dev).
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin
        .initialize(const InitializationSettings(android: androidSettings));

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  Future<void> scheduleSessionComplete({
    required DateTime fireAt,
    required String title,
    required String body,
  }) async {
    await _plugin.zonedSchedule(
      _sessionNotificationId,
      title,
      body,
      tz.TZDateTime.from(fireAt, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Focus sessions',
          channelDescription: 'Alerts when a focus or break session ends',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      // Inexact scheduling deliberately avoids needing the
      // SCHEDULE_EXACT_ALARM / USE_EXACT_ALARM permission — that gets
      // real Play Store scrutiny for most apps, and a session-end alert
      // doesn't need split-second timing to still be useful.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      // Required by v17's signature (iOS-only semantics); fireAt is an
      // absolute instant, not a wall-clock time to re-interpret.
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelSessionNotification() =>
      _plugin.cancel(_sessionNotificationId);
}
