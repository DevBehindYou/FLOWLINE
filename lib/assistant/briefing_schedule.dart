import '../core/notifications/notification_service.dart';
import '../domain/assistant/briefing.dart';
import '../l10n/l10n.dart';

/// The daily briefing notifications (docs/05 §21): morning at 07:30 and
/// shutdown at 18:30. Each opens its BriefingScreen.
const briefingTimes = <BriefingKind, ({int id, int hour, int minute})>{
  BriefingKind.morning: (id: 2001, hour: 7, minute: 30),
  BriefingKind.shutdown: (id: 2002, hour: 18, minute: 30),
};

/// Schedules both when [enabled], cancels both otherwise. Idempotent.
Future<void> syncBriefingNotifications(NotificationService service,
    {required bool enabled, required AppLocalizations l10n}) async {
  for (final MapEntry(key: kind, value: t) in briefingTimes.entries) {
    if (!enabled) {
      await service.cancel(t.id);
      continue;
    }
    await service.scheduleDailyBriefing(
      notificationId: t.id,
      kind: kind.name,
      hour: t.hour,
      minute: t.minute,
      title: kind == BriefingKind.morning
          ? l10n.briefingNotificationMorning
          : l10n.briefingNotificationShutdown,
      body: l10n.briefingNotificationBody,
      channelName: l10n.briefingChannel,
      channelDescription: l10n.briefingChannelDescription,
    );
  }
}
