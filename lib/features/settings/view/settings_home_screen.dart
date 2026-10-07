import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../design/atomic.dart';
import '../../../l10n/l10n.dart';

/// Settings (docs/05 §29.23): Display titles, a body hint, the accent
/// arrow, hairlines between rows.
class SettingsHomeScreen extends StatelessWidget {
  const SettingsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    Widget row(IconData icon, String title, String subtitle, String path) =>
        AtomicSettingsRow(
          leading: icon,
          title: title,
          subtitle: subtitle,
          onTap: () => context.push(path),
        );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          row(AtomicIcons.ai, l10n.settingsAiProviders,
              l10n.settingsAiProvidersHint, '/settings/ai-providers'),
          row(AtomicIcons.focus, l10n.settingsFocusTimer,
              l10n.settingsFocusTimerHint, '/settings/focus'),
          row(AtomicIcons.notifications, l10n.settingsNotifications,
              l10n.notificationsSessionAlerts, '/settings/notifications'),
          row(AtomicIcons.mic, l10n.settingsVoice, l10n.settingsVoiceHint,
              '/settings/voice'),
          row(AtomicIcons.appearance, l10n.settingsAppearance,
              l10n.settingsAppearanceHint, '/settings/appearance'),
          row(AtomicIcons.privacy, l10n.settingsDataPrivacy,
              l10n.settingsDataPrivacyHint, '/settings/data'),
        ],
      ),
    );
  }
}
