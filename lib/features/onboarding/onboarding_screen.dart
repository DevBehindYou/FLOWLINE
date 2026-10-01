import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/async/run_action.dart';
import '../../core/providers.dart';
import '../settings/viewmodel/settings_view_model.dart';

/// First-run flow (spec §5.2): what Flowline does, why it asks for
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
      failureMessage: "Couldn't save your progress — please try again.",
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (saved == true) widget.onFinished(connectAi);
  }

  @override
  Widget build(BuildContext context) {
    final step = switch (_step) {
      0 => _Step(
          key: const ValueKey(0),
          icon: Icons.view_timeline_outlined,
          title: 'Plan the day. Focus. See where time went.',
          body: 'Flowline keeps your tasks, time blocks and focus sessions '
              'on this phone. No account, no sync, nothing leaves the device '
              'unless you export it.',
          primaryLabel: 'Next',
          onPrimary: _next,
        ),
      1 => _Step(
          key: const ValueKey(1),
          icon: Icons.notifications_active_outlined,
          title: 'Know when a session ends',
          body: 'Flowline uses notifications only for focus session and break '
              'alerts, so you can put the phone down. You can change this '
              'any time in Settings.',
          primaryLabel: 'Allow notifications',
          onPrimary: _allowNotifications,
          secondaryLabel: 'Not now',
          onSecondary: _next,
        ),
      _ => _Step(
          key: const ValueKey(2),
          icon: Icons.smart_toy_outlined,
          title: 'Connect an AI assistant (optional)',
          body: 'Bring your own API key from OpenAI, Anthropic, Gemini, or '
              'run Ollama locally. Keys are stored in the Android Keystore and '
              'never backed up. Everything else works without one.',
          primaryLabel: 'Connect a provider',
          onPrimary: () => _finish(connectAi: true),
          secondaryLabel: 'Skip for now',
          onSecondary: () => _finish(connectAi: false),
        ),
    };

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Semantics(
          label: 'Step ${_step + 1} of $_stepCount',
          child: ExcludeSemantics(child: _StepDots(current: _step)),
        ),
        actions: [
          if (_step < _stepCount - 1)
            TextButton(
              onPressed: _busy ? null : () => _finish(connectAi: false),
              child: const Text('Skip'),
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
