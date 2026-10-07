import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/async/run_action.dart';
import '../../../core/providers.dart';
import '../../../design/atomic.dart';
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
        padding: const EdgeInsets.all(AtomicSpace.screenMargin),
        children: [
          AtomicSectionLabel(context.l10n.appearanceTheme),
          const SizedBox(height: AtomicSpace.m),
          SegmentedButton<AppThemeMode>(
            segments: [
              ButtonSegment(
                  value: AppThemeMode.system,
                  icon: const Icon(AtomicIcons.systemMode),
                  label: Text(context.l10n.appearanceSystem)),
              ButtonSegment(
                  value: AppThemeMode.light,
                  icon: const Icon(AtomicIcons.lightMode),
                  label: Text(context.l10n.appearanceLight)),
              ButtonSegment(
                  value: AppThemeMode.dark,
                  icon: const Icon(AtomicIcons.darkMode),
                  label: Text(context.l10n.appearanceDark)),
            ],
            selected: {mode},
            onSelectionChanged: (s) =>
                _update(context, ref, (c) => c.copyWith(themeMode: s.first)),
          ),
          const SizedBox(height: AtomicSpace.xs),
          AtomicText.body(context.l10n.appearanceSystemHint,
              style: AtomicType.bodySmall
                  .copyWith(color: context.atomic.palette.textMuted)),
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
            padding: const EdgeInsets.all(AtomicSpace.screenMargin),
            child: AtomicText.body(
              context.l10n.focusSettingsHint,
              style: AtomicType.bodySmall
                  .copyWith(color: context.atomic.palette.textMuted),
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
    // A stepper (system §9.5): the value in mono between two square
    // buttons, each with its own name for screen readers.
    return AtomicSettingsRow(
      title: label,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AtomicIconButton(
            icon: AtomicIcons.remove,
            semanticLabel: context.l10n.decreaseSetting(label),
            style: AtomicIconButtonStyle.ink,
            onPressed: onMinus,
          ),
          ConstrainedBox(
            constraints:
                const BoxConstraints(minWidth: AtomicSize.controlSecondary),
            child: AtomicText.mono(valueText,
                style: AtomicType.counter, textAlign: TextAlign.center),
          ),
          AtomicIconButton(
            icon: AtomicIcons.add,
            semanticLabel: context.l10n.increaseSetting(label),
            style: AtomicIconButtonStyle.ink,
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

/// docs/05 §22.4: when AA speaks, how fast, and conversation mode.
class VoiceSettingsScreen extends ConsumerWidget {
  const VoiceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final s = _settings(ref);
    const step = 10;
    final rate = s.speechRatePercent;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsVoice)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AtomicSpace.s),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AtomicSpace.screenMargin),
            child: AtomicText.mono(l10n.voiceSpeakReplies),
          ),
          const SizedBox(height: AtomicSpace.xs),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AtomicSpace.screenMargin),
            child: SegmentedButton<SpeakReplies>(
              segments: [
                ButtonSegment(
                    value: SpeakReplies.off, label: Text(l10n.speakRepliesOff)),
                ButtonSegment(
                    value: SpeakReplies.whenISpoke,
                    label: Text(l10n.speakRepliesWhenISpoke)),
                ButtonSegment(
                    value: SpeakReplies.always,
                    label: Text(l10n.speakRepliesAlways)),
              ],
              selected: {s.speakReplies},
              onSelectionChanged: (v) => _update(
                  context, ref, (c) => c.copyWith(speakReplies: v.first)),
            ),
          ),
          const SizedBox(height: AtomicSpace.s),
          _StepperTile(
            label: l10n.voiceSpeechRate,
            valueText: l10n.percentValue(rate),
            onMinus: rate > AppSettings.minSpeechRatePercent
                ? () => _update(context, ref,
                    (c) => c.copyWith(speechRatePercent: rate - step))
                : null,
            onPlus: rate < AppSettings.maxSpeechRatePercent
                ? () => _update(context, ref,
                    (c) => c.copyWith(speechRatePercent: rate + step))
                : null,
          ),
          SwitchListTile(
            title: Text(l10n.voiceKeepListening),
            subtitle: Text(l10n.voiceKeepListeningHint),
            value: s.keepListening,
            onChanged: (v) =>
                _update(context, ref, (c) => c.copyWith(keepListening: v)),
          ),
          Padding(
            padding: const EdgeInsets.all(AtomicSpace.screenMargin),
            child: AtomicText.body(l10n.voicePrivacyNote,
                style: AtomicType.bodySmall),
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
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsDataPrivacy)),
      body: ListView(
        padding: const EdgeInsets.all(AtomicSpace.screenMargin),
        children: [
          AtomicSectionLabel(l10n.dataWhereTitle),
          const SizedBox(height: AtomicSpace.s),
          AtomicText.body(l10n.dataWhereBody),
          const SizedBox(height: AtomicSpace.xxl),
          AtomicSettingsRow(
            leading: AtomicIcons.document,
            title: l10n.openSourceLicences,
            onTap: () => showLicensePage(
              context: context,
              applicationName: l10n.appTitle,
            ),
          ),
          const SizedBox(height: AtomicSpace.xxl),
          // Two-key danger (system §10.4): a warning sentence, then a
          // confirmation that states what goes.
          AtomicDangerZone(
            label: l10n.dangerZone,
            warning: l10n.clearAllDataWarning,
            children: [
              AtomicButton(
                label: l10n.clearAllData,
                icon: AtomicIcons.delete,
                variant: AtomicButtonVariant.destructive,
                expand: true,
                busy: _clearing,
                busyLabel: l10n.clearingData,
                onPressed: _clearAll,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
