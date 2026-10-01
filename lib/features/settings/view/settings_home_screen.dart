import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/l10n.dart';

class SettingsHomeScreen extends StatelessWidget {
  const SettingsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    Widget row(IconData icon, String title, String subtitle, String path) =>
        ListTile(
          leading: Icon(icon),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push(path),
        );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          row(Icons.smart_toy_outlined, l10n.settingsAiProviders,
              l10n.settingsAiProvidersHint, '/settings/ai-providers'),
          row(Icons.timer_outlined, l10n.settingsFocusTimer,
              l10n.settingsFocusTimerHint, '/settings/focus'),
          row(Icons.notifications_outlined, l10n.settingsNotifications,
              l10n.notificationsSessionAlerts, '/settings/notifications'),
          row(Icons.palette_outlined, l10n.settingsAppearance,
              l10n.settingsAppearanceHint, '/settings/appearance'),
          row(Icons.shield_outlined, l10n.settingsDataPrivacy,
              l10n.settingsDataPrivacyHint, '/settings/data'),
        ],
      ),
    );
  }
}
