import 'package:flutter/material.dart';

import '../foundation/atomic_text.dart';
import '../theme/atomic_theme.dart';
import '../tokens/atomic_metrics.dart';
import '../tokens/atomic_type.dart';

/// Signal mono caps label above a section title ("HOW IT WORKS"), §4.4.2.
class AtomicEyebrow extends StatelessWidget {
  const AtomicEyebrow(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => AtomicText.mono(text,
      style: AtomicType.eyebrow
          .copyWith(color: context.atomic.palette.accentText));
}

/// A 1 dp rule: ink (rules that matter) or hairline (between rows).
class AtomicRule extends StatelessWidget {
  const AtomicRule({super.key, this.hairline = false});
  final bool hairline;

  @override
  Widget build(BuildContext context) {
    final p = context.atomic.palette;
    return Divider(
      height: AtomicStroke.rule,
      thickness: AtomicStroke.rule,
      color: hairline ? p.hairline : p.rule,
    );
  }
}

/// Section label row: mono label (with an optional count) on the left,
/// an optional action on the right, then an ink rule (§5.3).
class AtomicSectionLabel extends StatelessWidget {
  const AtomicSectionLabel(this.label, {super.key, this.count, this.action});

  final String label;
  final int? count;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final shown = count == null ? label : '$label · $count';
    return Semantics(
      header: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            Expanded(child: AtomicText.mono(shown)),
            if (action != null) action!,
          ]),
          const SizedBox(height: AtomicSpace.xs),
          const AtomicRule(),
        ],
      ),
    );
  }
}

/// A top-level screen's title row: Display title left, a mono counter on
/// its baseline right ("8 / 50"), then an ink rule (§5.3).
class AtomicTitleRow extends StatelessWidget {
  const AtomicTitleRow(this.title, {super.key, this.counter});

  final String title;
  final String? counter;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                  child: AtomicText.display(title,
                      style: AtomicType.screenTitle, maxLines: 2)),
              if (counter != null)
                AtomicText.mono(counter!, style: AtomicType.counter),
            ],
          ),
          const SizedBox(height: AtomicSpace.xs),
          const AtomicRule(),
        ],
      ),
    );
  }
}

/// Two-beat headline, the second beat in the accent (§4.4.1).
class AtomicSplitHeadline extends StatelessWidget {
  const AtomicSplitHeadline(this.first, this.second, {super.key, this.style});

  final String first;
  final String second;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final p = context.atomic.palette;
    final base = (style ?? AtomicType.pushedTitle).copyWith(color: p.text);
    return Text.rich(
      TextSpan(children: [
        TextSpan(text: '$first '),
        TextSpan(text: second, style: TextStyle(color: p.accentText)),
      ]),
      style: base,
    );
  }
}

/// A definition row: mono label left, value right, hairline below
/// (fact sheet, §9.3). Stacks when the text is large.
class AtomicFactRow extends StatelessWidget {
  const AtomicFactRow({super.key, required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    final stacked = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    final labelText = AtomicText.mono(label, style: AtomicType.caption);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AtomicSpace.s),
          child: stacked
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    labelText,
                    const SizedBox(height: AtomicSpace.xxs),
                    value
                  ],
                )
              : Row(children: [
                  Expanded(child: labelText),
                  const SizedBox(width: AtomicSpace.s),
                  Flexible(flex: 2, child: value),
                ]),
        ),
        const AtomicRule(hairline: true),
      ],
    );
  }
}
