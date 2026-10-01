# Working on Flowline

Flutter (Android-first), local-first productivity app: tasks and time
blocks, a wall-clock focus timer, a bring-your-own-key AI assistant.
Riverpod 3 (codegen), Drift 2.35 / SQLite, go_router.

## Environment

- **CI is the source of truth.** `.github/workflows/ci.yml` runs format,
  analyze, tests (also under `TZ=America/New_York`) and builds signed
  release APKs. Don't call anything verified until CI is green on it.
- **Flutter is pinned** (`FLUTTER_VERSION` in `ci.yml`). Move it only
  together with `riverpod_generator`, `drift_dev` and `build_runner`
  (rule R19). Use that same version locally.
- After changing tables or providers: `dart run build_runner build`.
- After any `schemaVersion` bump: `dart run drift_dev make-migrations`,
  then commit `drift_schemas/` and `test/drift/`.
- `android/` is generated, never committed. Every change to it goes into
  `tool/ci/android_patches.dart`, with a test in
  `test/tool/android_patches_test.dart`.

## Where things are written down

Source of truth, highest first: code + CI > `PROJECT_OVERVIEW.md` (as
built) > `docs/04-build-and-optimization-plan.md` (forward plan, rules
R1–R21, defect register B1–B31) > `docs/03-…` > `docs/01-…`/`02-…`
(original plans).

## Rules that bite (full list: docs/04 §2)

- **Enums stored by index are append-only** (R1). Never reorder.
- **Every schema change has a migration and a migration test** (R2), and
  invariants live in SQL where possible (R3).
- **No `DateTime.now()` and no `Duration(days:)` in `lib/`** (R7/R8). Use
  `clock.now()`, `today()`, `addDays()` from
  `lib/domain/time/calendar_day.dart`, and `currentDayProvider`.
  `test/code_rules/` enforces this.
- **`lib/domain/` imports no Flutter, Drift or Riverpod.**
- **Action notifiers that use `ref` after an `await` are keepAlive** (R11).
  Riverpod 3 throws on a disposed `Ref`.
- **Every write the user triggers goes through `runAction` with a busy
  flag** (R12). No raw `$error` in the UI: use `ErrorView` (R14).
- **AI output is untrusted input** (R16). Parse it, validate it against
  current state, and only apply it after a tap.
- **No user-facing string literals in widgets.** Add the string to
  `lib/l10n/app_en.arb` and read it with `context.l10n` (dates and times
  through `lib/l10n/formats.dart`). `lib/domain/` returns typed results
  (enums, sealed classes), never English text. `test/code_rules/`
  enforces the widget side.
- **API keys only go in `SecureKeyStore`.** Never in Drift, logs or URLs.
  `flutter_secure_storage` is held at 10.x on purpose (see
  `secure_key_store.dart`).

## Definition of done

1. Tests for the change. For a bug fix, a test that fails without the fix.
2. `dart format` is clean on tracked files, `flutter analyze` reports
   nothing (strict mode), and all tests pass.
3. `PROJECT_OVERVIEW.md` is updated if behaviour, schema or status changed;
   the checklist in `docs/04` §10 is ticked for finished items.
4. The commit message is `type(scope): summary`, with a body that says
   *why* and names the defect IDs it closes (K…/B…).

## Handover (end of every session)

What changed, what is **verified** (link the CI run), what is
**unverified** (anything that needs a device), and the next step.
