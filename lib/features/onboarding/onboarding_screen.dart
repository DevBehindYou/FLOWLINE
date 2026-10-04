import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/async/run_action.dart';
import '../../core/providers.dart';
import '../settings/viewmodel/settings_view_model.dart';
import '../../l10n/l10n.dart';

/// First-run flow (spec §5.2): what Atomic Assist does, why it asks for
/// notifications, and an optional AI provider. Every step can be skipped,
/// and a denied permission never blocks the app.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, required this.onFinished});

  /// Called once `onboarding_done` is saved. [connectAi] is true when the
  /// user chose to connect a provider now.
  final void Function(bool connectAi) onFinished;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _stepCount = 3;
  int _step = 0;
  bool _busy = false;

  void _next() => setState(() => _step++);

  Future<void> _allowNotifications() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final service = await ref.read(notificationServiceProvider.future);
      await service.requestPermission();
    } catch (_) {
      // Denied or unavailable: the app works without notifications.
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _step++;
    });
  }

  Future<void> _finish({required bool connectAi}) async {
    if (_busy) return;
    setState(() => _busy = true);
    final saved = await runAction(
      context,
      () async {
        await ref
            .read(settingsViewModelProvider.notifier)
            .update((s) => s.copyWith(onboardingDone: true));
        return true;
      },
      failureMessage: context.l10n.onboardingSaveFailed,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (saved == true) widget.onFinished(connectAi);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final step = switch (_step) {
      0 => _Step(
          key: const ValueKey(0),
          icon: Icons.view_timeline_outlined,
          title: l10n.onboardingWelcomeTitle,
          body: l10n.onboardingWelcomeBody,
          primaryLabel: l10n.onboardingNext,
          onPrimary: _next,
        ),
      1 => _Step(
          key: const ValueKey(1),
          icon: Icons.notifications_active_outlined,
          title: l10n.onboardingNotificationsTitle,
          body: l10n.onboardingNotificationsBody,
          primaryLabel: l10n.onboardingAllowNotifications,
          onPrimary: _allowNotifications,
          secondaryLabel: l10n.onboardingNotNow,
          onSecondary: _next,
        ),
      _ => _Step(
          key: const ValueKey(2),
          icon: Icons.smart_toy_outlined,
          title: l10n.onboardingAiTitle,
          body: l10n.onboardingAiBody,
          primaryLabel: l10n.onboardingConnectProvider,
          onPrimary: () => _finish(connectAi: true),
          secondaryLabel: l10n.onboardingSkipForNow,
          onSecondary: () => _finish(connectAi: false),
        ),
    };

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Semantics(
          label: l10n.onboardingStep(_step + 1, _stepCount),
          child: ExcludeSemantics(child: _StepDots(current: _step)),
        ),
        actions: [
          if (_step < _stepCount - 1)
            TextButton(
              onPressed: _busy ? null : () => _finish(connectAi: false),
              child: Text(l10n.onboardingSkip),
            ),
        ],
      ),
      body: SafeArea(
        child: AbsorbPointer(
          absorbing: _busy,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: step,
          ),
        ),
      ),
    );
  }
}

class _StepDots extends StatelessWidget {
  const _StepDots({required this.current});
  final int current;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < _OnboardingScreenState._stepCount; i++)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == current ? 20 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == current ? scheme.primary : scheme.outlineVariant,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  final IconData icon;
  final String title;
  final String body;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Icon(icon, size: 56, color: theme.colorScheme.primary),
                  const SizedBox(height: 24),
                  Text(title, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  Text(body, style: theme.textTheme.bodyLarge),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FilledButton(
                        onPressed: onPrimary, child: Text(primaryLabel)),
                    if (secondaryLabel != null) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: onSecondary,
                        child: Text(secondaryLabel!),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
