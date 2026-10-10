import 'package:atomic_assist/domain/assistant/autonomy.dart';
import 'package:flutter_test/flutter_test.dart';

// The policy as a table (docs/05 §6.2): every risk × origin × preset.
// Changing a row here is changing what AA may do without asking.

const _r = ActionRisk.values;
const _o = ActionOrigin.values;
const _p = AutonomyPreset.values;

Decision _expected(
    ActionRisk risk, ActionOrigin origin, AutonomyPreset preset) {
  const said = ActionOrigin.said;
  return switch (risk) {
    ActionRisk.forbidden => Decision.refuse,
    ActionRisk.read => Decision.execute,
    ActionRisk.destructive =>
      origin == said ? Decision.confirm : Decision.propose,
    ActionRisk.handOff => origin == said ? Decision.execute : Decision.propose,
    ActionRisk.reversible => origin == said
        ? (preset == AutonomyPreset.careful
            ? Decision.confirm
            : Decision.executeWithUndo)
        : origin == ActionOrigin.routine || preset == AutonomyPreset.handsOff
            ? Decision.executeWithUndo
            : Decision.propose,
  };
}

void main() {
  test('the table has all 75 cases', () {
    expect(_r.length * _o.length * _p.length, 75);
  });

  for (final risk in _r) {
    for (final origin in _o) {
      for (final preset in _p) {
        test('${risk.name} · ${origin.name} · ${preset.name}', () {
          expect(decide(risk: risk, origin: origin, preset: preset),
              _expected(risk, origin, preset));
        });
      }
    }
  }

  group('invariants that must never change', () {
    test('forbidden is refused whoever asks', () {
      for (final o in _o) {
        for (final p in _p) {
          expect(decide(risk: ActionRisk.forbidden, origin: o, preset: p),
              Decision.refuse);
        }
      }
    });

    test('nothing destructive runs without an explicit confirm', () {
      for (final o in _o) {
        for (final p in _p) {
          expect(decide(risk: ActionRisk.destructive, origin: o, preset: p),
              isNot(anyOf(Decision.execute, Decision.executeWithUndo)));
        }
      }
    });

    test('an unasked hand-off is never opened by itself', () {
      for (final o in _o.where((o) => o != ActionOrigin.said)) {
        for (final p in _p) {
          expect(decide(risk: ActionRisk.handOff, origin: o, preset: p),
              Decision.propose);
        }
      }
    });

    test('everything AA does unasked can be undone', () {
      for (final r in _r) {
        for (final o in _o.where((o) => o != ActionOrigin.said)) {
          for (final p in _p) {
            final d = decide(risk: r, origin: o, preset: p);
            if (d == Decision.execute) expect(r, ActionRisk.read);
          }
        }
      }
    });
  });

  test('stored enums keep their order (R1, append-only)', () {
    expect(ActionRisk.values.map((e) => e.name),
        ['read', 'reversible', 'handOff', 'destructive', 'forbidden']);
    expect(ActionOrigin.values.map((e) => e.name),
        ['said', 'commitment', 'context', 'pattern', 'routine']);
    expect(AutonomyPreset.values.map((e) => e.name),
        ['careful', 'balanced', 'handsOff']);
    expect(Decision.values.map((e) => e.name),
        ['execute', 'executeWithUndo', 'propose', 'confirm', 'refuse']);
  });
}
