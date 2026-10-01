import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsHomeScreen extends StatelessWidget {
  const SettingsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Widget row(IconData icon, String title, String subtitle, String path) =>
        ListTile(
          leading: Icon(icon),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push(path),
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          row(
              Icons.smart_toy_outlined,
              'AI Providers',
              'Connect Anthropic, OpenAI, Gemini, or a local Ollama server',
              '/settings/ai-providers'),
          row(Icons.timer_outlined, 'Focus timer', 'Session and break lengths',
              '/settings/focus'),
          row(Icons.notifications_outlined, 'Notifications', 'Session alerts',
              '/settings/notifications'),
          row(Icons.palette_outlined, 'Appearance', 'Light, dark or system',
              '/settings/appearance'),
          row(Icons.shield_outlined, 'Data & privacy',
              'Where your data lives, clear all data', '/settings/data'),
        ],
      ),
    );
  }
}
