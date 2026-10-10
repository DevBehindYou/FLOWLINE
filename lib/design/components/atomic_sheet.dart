import 'package:flutter/material.dart';

import '../foundation/atomic_text.dart';
import '../theme/atomic_theme.dart';
import '../tokens/atomic_metrics.dart';
import '../tokens/atomic_type.dart';
import 'atomic_button.dart';
import 'atomic_labels.dart';

/// Opens an Atomic bottom sheet (§9.7): paper, 28 dp top corners, drag
/// handle, 54% scrim (all from the theme). Content scrolls and follows
/// the keyboard. [label] is the Signal mono caps title over an ink rule.
Future<T?> showAtomicSheet<T>({
  required BuildContext context,
  required String label,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useSafeArea: true,
    builder: (context) =>
        AtomicSheetFrame(label: label, child: builder(context)),
  );
}

/// The inside of an Atomic sheet: label + rule, then the content, padded,
/// capped at reading width on wide windows, above the keyboard.
class AtomicSheetFrame extends StatelessWidget {
  const AtomicSheetFrame({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = context.atomic.palette;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AtomicSize.readingWidth),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
                AtomicSpace.m, 0, AtomicSpace.m, AtomicSpace.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  header: true,
                  child: AtomicText.mono(label,
                      style: AtomicType.label.copyWith(color: p.accentText)),
                ),
                const SizedBox(height: AtomicSpace.xs),
                const AtomicRule(),
                const SizedBox(height: AtomicSpace.m),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The destructive confirmation (§9.9): a sheet that states the effect
/// plainly, with a destructive CONFIRM and a ghost CANCEL. Returns true
/// only on an explicit confirm.
Future<bool> showAtomicConfirm({
  required BuildContext context,
  required String label,
  required String title,
  required String message,
  required String confirmLabel,
  required String cancelLabel,
}) async {
  final confirmed = await showAtomicSheet<bool>(
    context: context,
    label: label,
    builder: (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        AtomicText.display(title, style: AtomicType.cardTitle),
        const SizedBox(height: AtomicSpace.xs),
        AtomicText.body(message),
        const SizedBox(height: AtomicSpace.xl),
        AtomicButton(
          label: confirmLabel,
          variant: AtomicButtonVariant.destructive,
          expand: true,
          onPressed: () => Navigator.pop(context, true),
        ),
        const SizedBox(height: AtomicSpace.s),
        AtomicButton(
          label: cancelLabel,
          variant: AtomicButtonVariant.ghost,
          expand: true,
          onPressed: () => Navigator.pop(context, false),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
