# Issues

## Open

### ISS-001: Intermittent pub.dev network failure in CI

Status: OPEN (environmental)
Impact: the "Android release APK" or emulator job fails in `flutter create`/`pub get`.
Evidence: `Got socket error trying to find package timezone at https://pub.dev.` exit 69 (run 37670886998, first attempt).
Root cause: runner network, not code (other jobs on the same commit pass).
Action: wait until the whole run finishes, then `rerun_failed_jobs` **once**; comment on the PR. A second failure is real.

### ISS-004: Nothing verified on a physical device

Status: OPEN
Impact: STT/TTS, notification buttons in a background isolate, QS tile, briefing notifications, permission flows are only proven by fakes/CI.
Next: the owner runs `docs/voice-device-check.md` on a CI APK; later the Phase H calendar check.

## Resolved

### ISS-002: build_runner failed in Android CI jobs

Root cause: `flutter create .` re-resolves `pubspec.lock` (picked analyzer 14.5.0, incompatible with build_runner 2.16.1) and rewrites `analysis_options.yaml`.
Fix: `.github/workflows/ci.yml` runs `git checkout -- pubspec.lock analysis_options.yaml` after `flutter create`, then `flutter pub get --enforce-lockfile` (PR #4, 6d529eb).

## Test-writing traps (not bugs; repeated cost if forgotten)

- **FA-001**: awaiting a Drift **watch** stream's `.first` inside a widget test never completes. Use one-shot repository reads (`get…`) in code that tests drive, and a `settle()` loop of `tester.runAsync(Future.delayed(5ms))` + `pump()`, ×10, then `pumpAndSettle()`.
- **FA-002**: building `AIRepositoryImpl` (or a DB) in `setUp` outside the test zone hangs; build it inside the test body.
- **FA-003**: `AtomicText.mono` and `AtomicButtonVariant.text` render UPPERCASE (find `'UNDO'`, `'DONE BY AA'`); other button variants keep the label as written (`'Done'`, `'Apply plan'`).
- **FA-004**: intl formats times with a narrow no-break space before AM/PM; match with a RegExp (`9:00.AM`).
- **FA-005**: pure tests that call `l10n.time()`/`dayShort()` need `initializeDateFormatting('en')` in `setUpAll`.
- **FA-006**: the package SDK floor (>=3.4) has no wildcard variables: `(_, _)` is a duplicate declaration; use `(a, b)`.
- **FA-007**: the full suite can be OOM-killed (exit 137) with default concurrency; run `flutter test -j 2`.
- **FA-008**: appending to `app_en.arb` by re-serializing the whole JSON reorders and reformats it; append new keys textually before the final `}`.
- **FA-009**: the GitHub MCP merge tool needs the full 40-char head SHA.
