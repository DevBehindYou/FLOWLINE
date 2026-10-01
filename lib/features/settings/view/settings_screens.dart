import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/async/run_action.dart';
import '../../../core/providers.dart';
import '../../../domain/entities/app_settings.dart';
import '../../../shared_widgets/confirm_dialog.dart';
import '../viewmodel/settings_view_model.dart';

AppSettings _settings(WidgetRef ref) =>
    ref.watch(appSettingsProvider).value ?? const AppSettings();

Future<void> _update(BuildContext context, WidgetRef ref,
        AppSettings Function(AppSettings) change) =>
    runAction(
      context,
      () => ref.read(settingsViewModelProvider.notifier).update(change),
      failureMessage: "Couldn't save the setting — please try again.",
    );

/// Spec §5.16.
class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = _settings(ref).themeMode;
    return Scaffold(
      appBar: AppBar(title: const Text('Appearance')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Theme', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          SegmentedButton<AppThemeMode>(
            segments: const [
              ButtonSegment(
                  value: AppThemeMode.system,
                  icon: Icon(Icons.brightness_auto_outlined),
                  label: Text('System')),
              ButtonSegment(
                  value: AppThemeMode.light,
                  icon: Icon(Icons.light_mode_outlined),
                  label: Text('Light')),
              ButtonSegment(
                  value: AppThemeMode.dark,
                  icon: Icon(Icons.dark_mode_outlined),
                  label: Text('Dark')),
            ],
            selected: {mode},
            onSelectionChanged: (s) =>
                _update(context, ref, (c) => c.copyWith(themeMode: s.first)),
          ),
          const SizedBox(height: 8),
          Text('System follows your phone’s dark mode setting.',
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

/// Session lengths (spec §5.7 "custom duration").
class FocusTimerSettingsScreen extends ConsumerWidget {
  const FocusTimerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = _settings(ref);
    return Scaffold(
      appBar: AppBar(title: const Text('Focus timer')),
      body: ListView(
        children: [
          _MinutesTile(
            label: 'Focus',
            value: s.focusMinutes,
            onChanged: (v) =>
                _update(context, ref, (c) => c.copyWith(focusMinutes: v)),
          ),
          _MinutesTile(
            label: 'Short break',
            value: s.shortBreakMinutes,
            onChanged: (v) =>
                _update(context, ref, (c) => c.copyWith(shortBreakMinutes: v)),
          ),
          _MinutesTile(
            label: 'Long break',
            value: s.longBreakMinutes,
            onChanged: (v) =>
                _update(context, ref, (c) => c.copyWith(longBreakMinutes: v)),
          ),
          _StepperTile(
            label: 'Long break after',
            valueText: '${s.longBreakEvery} focus sessions',
            onMinus: s.longBreakEvery > 2
                ? () => _update(context, ref,
                    (c) => c.copyWith(longBreakEvery: c.longBreakEvery - 1))
                : null,
            onPlus: s.longBreakEvery < 12
                ? () => _update(context, ref,
                    (c) => c.copyWith(longBreakEvery: c.longBreakEvery + 1))
                : null,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'New lengths apply to the next session you start.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _MinutesTile extends StatelessWidget {
  const _MinutesTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    // Steps of 5 above 10 minutes, 1 below, matching how people think
    // about short breaks vs. focus blocks.
    final step = value > 10 ? 5 : 1;
    final down = value > 10 && value - step < 10 ? value - 10 : step;
    return _StepperTile(
      label: label,
      valueText: '$value min',
      onMinus:
          value > AppSettings.minMinutes ? () => onChanged(value - down) : null,
      onPlus: value < AppSettings.maxMinutes
          ? () => onChanged(value + (value >= 10 ? 5 : 1))
          : null,
    );
  }
}

class _StepperTile extends StatelessWidget {
  const _StepperTile({
    required this.label,
    required this.valueText,
    required this.onMinus,
    required this.onPlus,
  });

  final String label;
  final String valueText;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      subtitle: Text(valueText),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Decrease $label',
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: onMinus,
          ),
          IconButton(
            tooltip: 'Increase $label',
            icon: const Icon(Icons.add_circle_outline),
            onPressed: onPlus,
          ),
        ],
      ),
    );
  }
}

/// Spec §5.15.
class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = _settings(ref);
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Session alerts'),
            subtitle:
                const Text('A notification when a focus session or break ends'),
            value: s.sessionAlerts,
            onChanged: (v) =>
                _update(context, ref, (c) => c.copyWith(sessionAlerts: v)),
          ),
        ],
      ),
    );
  }
}

/// Spec §5.17: where data lives, and clearing it.
class DataPrivacyScreen extends ConsumerStatefulWidget {
  const DataPrivacyScreen({super.key});

  @override
  ConsumerState<DataPrivacyScreen> createState() => _DataPrivacyScreenState();
}

class _DataPrivacyScreenState extends ConsumerState<DataPrivacyScreen> {
  bool _clearing = false;

  Future<void> _clearAll() async {
    final confirmed = await confirmDestructive(
      context,
      title: 'Clear all data?',
      message: 'Deletes every task, block, focus session, conversation and '
          'saved API key on this phone. This can’t be undone.',
      confirmLabel: 'Clear everything',
    );
    if (!confirmed || !mounted) return;
    setState(() => _clearing = true);
    final done = await runAction(
      context,
      () async {
        await ref.read(settingsViewModelProvider.notifier).clearAllData();
        return true;
      },
      failureMessage: "Couldn't clear your data — please try again.",
    );
    if (!mounted) return;
    setState(() => _clearing = false);
    if (done == true) {
      ScaffoldMessenger.maybeOf(context)
          ?.showSnackBar(const SnackBar(content: Text('All data cleared')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Data & privacy')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Where your data lives', style: text.titleMedium),
          const SizedBox(height: 8),
          const Text(
            'Everything you create is stored only on this phone. There is no '
            'Flowline account, server or analytics.\n\n'
            'API keys are kept in Android’s secure Keystore and are only '
            'ever sent to the AI provider they belong to. When you use the '
            'Assistant, your message and the conversation so far go '
            'directly from this phone to the provider you chose.\n\n'
            'Your Android backup includes your Flowline data but never your '
            'API keys.',
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: _clearing ? null : _clearAll,
            style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error),
            icon: _clearing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.delete_forever_outlined),
            label: const Text('Clear all data'),
          ),
        ],
      ),
    );
  }
}
