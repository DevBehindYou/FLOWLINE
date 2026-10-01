import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The Settings entry on every tab's app bar (spec §3, D5).
class SettingsAction extends StatelessWidget {
  const SettingsAction({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.settings_outlined),
      tooltip: 'Settings',
      onPressed: () => context.push('/settings'),
    );
  }
}
