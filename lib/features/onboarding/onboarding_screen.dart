import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/async/run_action.dart';
import '../../core/providers.dart';
import '../../design/atomic.dart';
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
          icon: AtomicIcons.block,
          title: l10n.onboardingWelcomeTitle,
          body: l10n.onboardingWelcomeBody,
          primaryLabel: l10n.onboardingNext,
          onPrimary: _next,
        ),
      1 => _Step(
          key: const ValueKey(1),
          icon: AtomicIcons.notificationsOn,
          title: l10n.onboardingNotificationsTitle,
          body: l10n.onboardingNotificationsBody,
          primaryLabel: l10n.onboardingAllowNotifications,
          onPrimary: _allowNotifications,
          secondaryLabel: l10n.onboardingNotNow,
          onSecondary: _next,
        ),
      _ => _Step(
          key: const ValueKey(2),
          icon: AtomicIcons.ai,
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
        // "STEP 1 OF 3" in mono (system §10.4 numbered steps); screen
        // readers hear the words.
        title: AtomicText.mono(l10n.onboardingStep(_step + 1, _stepCount),
            style: AtomicType.label
                .copyWith(color: context.atomic.palette.accentText)),
        actions: [
          if (_step < _stepCount - 1)
            AtomicButton(
              label: l10n.onboardingSkip,
              variant: AtomicButtonVariant.text,
              onPressed: _busy ? null : () => _finish(connectAi: false),
            ),
          const SizedBox(width: AtomicSpace.xs),
        ],
      ),
      body: SafeArea(
        child: AbsorbPointer(
          absorbing: _busy,
          child: AnimatedSwitcher(
            duration: context.atomicMotion.enter,
            child: step,
          ),
        ),
      ),
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
    final p = context.atomic.palette;
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.all(AtomicSpace.xl),
        child: ConstrainedBox(
          constraints: BoxConstraints(
              minHeight: constraints.maxHeight - 2 * AtomicSpace.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AtomicSpace.xl),
                  Icon(icon, size: AtomicSize.heroMark, color: p.accentText),
                  const SizedBox(height: AtomicSpace.xl),
                  Semantics(
                    header: true,
                    child: AtomicText.display(title,
                        style: AtomicType.pushedTitle),
                  ),
                  const SizedBox(height: AtomicSpace.s),
                  AtomicText.body(body, style: AtomicType.bodyLarge),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: AtomicSpace.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AtomicButton(
                        label: primaryLabel,
                        expand: true,
                        onPressed: onPrimary),
                    if (secondaryLabel != null) ...[
                      const SizedBox(height: AtomicSpace.s),
                      AtomicButton(
                        label: secondaryLabel!,
                        variant: AtomicButtonVariant.ghost,
                        expand: true,
                        onPressed: onSecondary,
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
