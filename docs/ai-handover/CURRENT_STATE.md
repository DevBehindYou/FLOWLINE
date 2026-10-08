# Current State

Last updated: 2026-10-08
Verified against commit: `ddf13fc` (main)
Confidence: HIGH

## Git

Branch: `claude/fervent-shannon-79dcim` (== `main` at `ddf13fc` before the H.3 commit)
Working tree at handover start: H.3 changes uncommitted (listed below). The
handover commit also commits H.3 so nothing is lost; its CI has not run.

## H.3 (plan my day + re-plan): IMPLEMENTED_UNTESTED

Files:
- new `lib/domain/assistant/day_planner.dart`: pure `planDay(now, tasks, blocks, rules)`
- new `lib/features/plan/view/plan_day_sheet.dart`, `lib/features/plan/viewmodel/plan_day_view_model.dart` (+ `.g.dart`)
- `lib/domain/assistant/scanners.dart`: `BlockEndedFinding` + `blockEndedWithOpenTasks`, added to `runScanners`
- `lib/domain/assistant/proposal.dart`: `ProposalReason.blockEnded` (appended, R1)
- `lib/assistant/scanner_runner.dart`: maps `BlockEndedFinding` to a `schedule_task` proposal
- `lib/features/schedule/view/today_screen.dart`: PLAN MY DAY icon in the app bar (today only)
- `lib/features/briefing/view/briefing_screen.dart`: morning primary is now PLAN MY DAY; OPEN INBOX became a ghost button
- l10n: `planMyDay`, `planIntro`, `planNothing`, `planApply`, `planDone`, `loadingPlan`, `reasonBlockEnded` (+ regenerated `app_localizations*.dart`)
- tests: new `test/domain/assistant/day_planner_test.dart` (7), new `test/features/plan/plan_day_sheet_test.dart` (2), 2 cases added to `test/domain/assistant/scanners_test.dart`
- goldens regenerated and looked at: `today*`, `today_empty*`, `briefing_morning_*_1x`
- docs: `PROJECT_OVERVIEW.md` (Plan my day paragraph), `docs/05` §36 H.3 line

Evidence: analyze clean; the tests above pass; golden update ran green
(40). **Not run:** full suite, the America/New_York run, a `dart format`
check after the last edits, CI.

## Features (merged)

| Feature | Status | Note |
|---|---|---|
| Assistant core (25 tools, ledger, undo, orchestrator) | VERIFIED | tests + CI |
| Inbox / Activity / 5-tab shell | VERIFIED | |
| Reminders + notification buttons | IMPLEMENTED | background-isolate button handler UNVERIFIED on device |
| Lists, people/dates/follow-ups | VERIFIED | |
| Repeating tasks (schema v14) | VERIFIED | |
| Assist without a provider (local grammar) | VERIFIED | also in the emulator test |
| Voice push-to-talk, TTS, Settings → Voice | IMPLEMENTED | platform STT/TTS UNVERIFIED on device |
| QS tile + launcher shortcut (Kotlin, deep link) | IMPLEMENTED | Kotlin compiles in CI; tap UNVERIFIED |
| Context scanners + kill switch + Settings → Assistant | VERIFIED | |
| Morning/shutdown briefings + daily notifications | VERIFIED (logic) | notification delivery UNVERIFIED on device |

## Schema

`schemaVersion = 14`; migrations v1→v14 with data tests in `test/drift/`;
snapshots in `drift_schemas/`.

## Unknown

- Real behaviour on a phone (all features).
- Real AI vendor round trips (Phase D still owes one per vendor key).

## Open Blockers

None for code work. Gates that need the owner's phone: G (voice script),
H (calendar events as locked blocks).
