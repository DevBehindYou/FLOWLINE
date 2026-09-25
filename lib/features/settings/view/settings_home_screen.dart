import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsHomeScreen extends StatelessWidget {
  const SettingsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.smart_toy_outlined),
            title: const Text('AI Providers'),
            subtitle: const Text('Connect Anthropic, OpenAI, Gemini, or a local Ollama server'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/ai-providers'),
          ),
        ],
      ),
    );
  }
}
