import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Atomic design rules (docs/05 §35). Everything visual comes from
/// lib/design/; features compose its tokens and components.
///
/// A ratchet until the screen migration (docs/05 Phase C) is done: each
/// rule records how many offending lines exist today. More fails (no new
/// violations); fewer also fails, asking for the baseline to be lowered,
/// so progress is locked in. Phase C ends with every baseline at 0.
///
/// A line that is a deliberate exception carries `// design-ok: <why>`.
class _Rule {
  const _Rule(this.name, this.pattern, this.fix);
  final String name;
  final RegExp pattern;
  final String fix;

  int get baseline => _baselines[name]!;
}

/// Offending lines allowed today, per rule. Only ever lowered.
const _baselines = {
  'no colour literals': 0,
  'no radius literals': 10,
  'no spacing literals': 129,
  'no raw Material buttons': 35,
  'no spinners on content': 20,
  'icons come from AtomicIcons': 90,
  'no raw durations': 0,
  'no bouncy motion': 0,
  'no font names outside the tokens': 0,
  'no typed capitals in features': 0,
};

final _rules = [
  _Rule('no colour literals', RegExp(r'Color\(0x|Colors\.(?!transparent)'),
      'Use a palette role: context.atomic.palette.*'),
  _Rule('no radius literals', RegExp(r'circular\(\s*\d'), 'Use AtomicRadius.*'),
  _Rule(
      'no spacing literals',
      RegExp(r'EdgeInsets\.(all|symmetric|only|fromLTRB)\([^)]*\d|'
          r'SizedBox\(\s*(height|width):\s*\d'),
      'Use AtomicSpace.* (or a component that owns the spacing)'),
  _Rule(
      'no raw Material buttons',
      RegExp(r'\b(ElevatedButton|FilledButton|OutlinedButton|TextButton|'
          r'FloatingActionButton)\b'),
      'Use AtomicButton (Phase B)'),
  _Rule('no spinners on content', RegExp(r'CircularProgressIndicator'),
      'Use AtomicLoading (system §9.9)'),
  _Rule('icons come from AtomicIcons', RegExp(r'\bIcons\.'),
      'Name the meaning in lib/design/foundation/atomic_icons.dart'),
  _Rule('no raw durations', RegExp(r'Duration\(milliseconds:'),
      'Use AtomicMotion / AtomicDurations'),
  _Rule(
      'no bouncy motion',
      RegExp(r'Curves\.(elastic|bounce)|SpringSimulation'),
      'Atomic motion eases; it never bounces (§8)'),
  _Rule('no font names outside the tokens', RegExp(r'fontFamily:'),
      'Use AtomicType / AtomicText'),
  _Rule('no typed capitals in features', RegExp(r'\.toUpperCase\(\)'),
      'AtomicText upper-cases for the eye and keeps words for TalkBack'),
];

void main() {
  final sources =
      Directory('lib').listSync(recursive: true).whereType<File>().where((f) {
    final path = f.path.replaceAll(r'\', '/');
    return path.endsWith('.dart') &&
        !path.endsWith('.g.dart') &&
        !path.startsWith('lib/design/') &&
        !path.startsWith('lib/l10n/app_localizations') &&
        // Data and domain have no widgets; the repository's stream throttle
        // is not motion.
        (path.startsWith('lib/features/') ||
            path.startsWith('lib/shared_widgets/') ||
            path.startsWith('lib/core/') ||
            path == 'lib/app.dart');
  }).toList();

  for (final rule in _rules) {
    test(rule.name, () {
      final hits = <String>[];
      for (final file in sources) {
        for (final (i, raw) in file.readAsLinesSync().indexed) {
          final line = raw.trimLeft();
          if (line.startsWith('//') || raw.contains('// design-ok')) continue;
          if (rule.pattern.hasMatch(line)) {
            hits.add('${file.path}:${i + 1}: $line');
          }
        }
      }
      if (hits.length > rule.baseline) {
        fail('${hits.length} > baseline ${rule.baseline}. ${rule.fix}.\n'
            '${hits.join('\n')}');
      }
      expect(hits.length, rule.baseline,
          reason: 'Fewer violations than the baseline: lower it to '
              '${hits.length} in ${'test/code_rules/design_rules_test.dart'}.');
    });
  }
}
