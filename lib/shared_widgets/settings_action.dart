import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../design/atomic.dart';
import '../l10n/l10n.dart';

/// The Settings entry on every top-level header (spec §3, D5).
class SettingsAction extends StatelessWidget {
  const SettingsAction({super.key});

  @override
  Widget build(BuildContext context) => AtomicIconButton(
        icon: AtomicIcons.settings,
        semanticLabel: context.l10n.settings,
        onPressed: () => context.push('/settings'),
      );
}
