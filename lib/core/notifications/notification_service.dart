import 'dart:async';

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
  bool _permissionRequested = false;
  final _taps = StreamController<void>.broadcast();
  final _reminderActions =
      StreamController<({String action, int reminderId})>.broadcast();

  /// A reminder notification's button, pressed while the app is running
  /// (DONE, SNOOZE 10 MIN, TOMORROW; docs/05 §13).
  Stream<({String action, int reminderId})> get reminderActions =>
      _reminderActions.stream;

  /// Fires when the user taps a session notification while the app is
  /// running or in the background (B24).
  Stream<void> get taps => _taps.stream;

  static const _sessionNotificationId = 1001;
  static const _channelId = 'focus_session';
  static const _reminderChannelId = 'reminders';

  /// Set at startup to a top-level function: a button pressed while the
  /// app isn't running runs it in a background isolate.
  static void Function(NotificationResponse)? backgroundResponseHandler;

  /// The payload of a reminder notification: `reminder:<id>`.
  static const reminderPayloadPrefix = 'reminder:';

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    tz.setLocalLocation(await _resolveLocalLocation());

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      settings: const InitializationSettings(android: androidSettings),
      onDidReceiveNotificationResponse: _onResponse,
      onDidReceiveBackgroundNotificationResponse: backgroundResponseHandler,
    );

    _initialized = true;
  }

  void _onResponse(NotificationResponse response) {
    final reminderId = reminderIdOf(response.payload);
    final action = response.actionId;
    if (reminderId != null && action != null && action.isNotEmpty) {
      _reminderActions.add((action: action, reminderId: reminderId));
      return;
    }
    _taps.add(null);
  }

  /// The reminder id in a notification payload, or null.
  static int? reminderIdOf(String? payload) =>
      payload != null && payload.startsWith(reminderPayloadPrefix)
          ? int.tryParse(payload.substring(reminderPayloadPrefix.length))
          : null;

  /// Schedules (or moves: the id is stable) one reminder's notification,
  /// with its buttons. Inexact, like the session alert: no exact-alarm
  /// permission, so it may arrive a few minutes late (docs/05 §13).
  Future<void> scheduleReminder({
    required int notificationId,
    required int reminderId,
    required DateTime fireAt,
    required String title,
    required String channelName,
    required String channelDescription,
    required List<({String id, String label})> actions,
  }) =>
      _plugin.zonedSchedule(
        id: notificationId,
        title: title,
        scheduledDate: tz.TZDateTime.from(fireAt, tz.local),
        payload: '$reminderPayloadPrefix$reminderId',
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _reminderChannelId,
            channelName,
            channelDescription: channelDescription,
            importance: Importance.high,
            priority: Priority.high,
            actions: [
              for (final a in actions) AndroidNotificationAction(a.id, a.label),
            ],
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );

  Future<void> cancel(int notificationId) => _plugin.cancel(id: notificationId);

  /// Asks for POST_NOTIFICATIONS (Android 13+) at most once per process,
  /// on the first session start rather than at launch (spec §5.2).
  Future<void> requestPermission() async {
    if (_permissionRequested) return;
    _permissionRequested = true;
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Whether this launch came from tapping a session notification while
  /// the app wasn't running.
  Future<bool> launchedFromNotification() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    return details?.didNotificationLaunchApp ?? false;
  }

  /// The device's IANA zone, or UTC when the platform reports one the
  /// bundled tz database doesn't know (old OEM aliases, a failing
  /// plugin). Scheduling still works under UTC because `fireAt` is an
  /// absolute instant; only the zone label differs.
  static Future<tz.Location> _resolveLocalLocation() async {
    try {
      // v5's getLocalTimezone() returns a TimezoneInfo, not a bare String.
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      return tz.getLocation(timezoneInfo.identifier);
    } catch (_) {
      return tz.UTC;
    }
  }

  Future<void> scheduleSessionComplete({
    required DateTime fireAt,
    required String title,
    required String body,
  }) async {
    await _plugin.zonedSchedule(
      id: _sessionNotificationId,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(fireAt, tz.local),
      notificationDetails: const NotificationDetails(
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
    );
  }

  Future<void> cancelSessionNotification() =>
      _plugin.cancel(id: _sessionNotificationId);
}
