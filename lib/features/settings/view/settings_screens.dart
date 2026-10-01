import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/async/run_action.dart';
import '../../../core/providers.dart';
import '../../../domain/entities/app_settings.dart';
import '../../../shared_widgets/confirm_dialog.dart';
import '../viewmodel/settings_view_model.dart';
import '../../../l10n/l10n.dart';

AppSettings _settings(WidgetRef ref) =>
    ref.watch(appSettingsProvider).value ?? const AppSettings();

Future<void> _update(BuildContext context, WidgetRef ref,
        AppSettings Function(AppSettings) change) =>
    runAction(
      context,
      () => ref.read(settingsViewModelProvider.notifier).update(change),
      failureMessage: context.l10n.settingSaveFailed,
    );

/// Spec §5.16.
class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = _settings(ref).themeMode;
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settingsAppearance)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(context.l10n.appearanceTheme,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          SegmentedButton<AppThemeMode>(
            segments: [
              ButtonSegment(
                  value: AppThemeMode.system,
                  icon: const Icon(Icons.brightness_auto_outlined),
                  label: Text(context.l10n.appearanceSystem)),
              ButtonSegment(
                  value: AppThemeMode.light,
                  icon: const Icon(Icons.light_mode_outlined),
                  label: Text(context.l10n.appearanceLight)),
              ButtonSegment(
                  value: AppThemeMode.dark,
                  icon: const Icon(Icons.dark_mode_outlined),
                  label: Text(context.l10n.appearanceDark)),
            ],
            selected: {mode},
            onSelectionChanged: (s) =>
                _update(context, ref, (c) => c.copyWith(themeMode: s.first)),
          ),
          const SizedBox(height: 8),
          Text(context.l10n.appearanceSystemHint,
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
      appBar: AppBar(title: Text(context.l10n.settingsFocusTimer)),
      body: ListView(
        children: [
          _MinutesTile(
            label: context.l10n.sessionFocus,
            value: s.focusMinutes,
            onChanged: (v) =>
                _update(context, ref, (c) => c.copyWith(focusMinutes: v)),
          ),
          _MinutesTile(
            label: context.l10n.sessionShortBreak,
            value: s.shortBreakMinutes,
            onChanged: (v) =>
                _update(context, ref, (c) => c.copyWith(shortBreakMinutes: v)),
          ),
          _MinutesTile(
            label: context.l10n.sessionLongBreak,
            value: s.longBreakMinutes,
            onChanged: (v) =>
                _update(context, ref, (c) => c.copyWith(longBreakMinutes: v)),
          ),
          _StepperTile(
            label: context.l10n.focusSettingsLongBreakAfter,
            valueText: context.l10n.focusSessionCount(s.longBreakEvery),
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
              context.l10n.focusSettingsHint,
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
      valueText: context.l10n.minutesShort(value),
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
            tooltip: context.l10n.decreaseSetting(label),
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: onMinus,
          ),
          IconButton(
            tooltip: context.l10n.increaseSetting(label),
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
      appBar: AppBar(title: Text(context.l10n.settingsNotifications)),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(context.l10n.notificationsSessionAlerts),
            subtitle: Text(context.l10n.notificationsSessionAlertsHint),
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
      title: context.l10n.clearAllDataTitle,
      message: context.l10n.clearAllDataMessage,
      confirmLabel: context.l10n.clearAllDataConfirm,
    );
    if (!confirmed || !mounted) return;
    setState(() => _clearing = true);
    final done = await runAction(
      context,
      () async {
        await ref.read(settingsViewModelProvider.notifier).clearAllData();
        return true;
      },
      failureMessage: context.l10n.clearAllDataFailed,
    );
    if (!mounted) return;
    setState(() => _clearing = false);
    if (done == true) {
      ScaffoldMessenger.maybeOf(context)
          ?.showSnackBar(SnackBar(content: Text(context.l10n.allDataCleared)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settingsDataPrivacy)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(context.l10n.dataWhereTitle, style: text.titleMedium),
          const SizedBox(height: 8),
          Text(context.l10n.dataWhereBody),
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
            label: Text(context.l10n.clearAllData),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.article_outlined),
            title: Text(context.l10n.openSourceLicences),
            onTap: () => showLicensePage(
              context: context,
              applicationName: context.l10n.appTitle,
            ),
          ),
        ],
      ),
    );
  }
}
