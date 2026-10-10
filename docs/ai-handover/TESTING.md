# Testing

Last CI-verified commit: `4119647` (PR #9 head), run 37670886998: all three jobs green after one re-run (ISS-001).

| Check | Status | Evidence |
|---|---|---|
| Format (`dart format --set-exit-if-changed`) | VERIFIED at 4119647 | CI |
| Analyze (strict) | VERIFIED at 4119647 | CI |
| Unit + widget + goldens | VERIFIED: 1188 pass | CI + local at H.2 |
| `TZ=America/New_York` subset | VERIFIED: 665 pass | local at H.2 |
| Emulator integration (`integration_test/app_flow_test.dart`) | VERIFIED | CI: onboarding, task, focus, Assist command → Activity → UNDO |
| Release APK | VERIFIED | CI artifact |
| H.3 working tree | PARTIAL | analyze clean; planner 7/7, plan sheet 2/2, scanners incl. blockEnded pass; goldens updated (40 green); full suite + NY + format check NOT run |
| Physical device | NOT RUN | ISS-004 |

## Commands (local)

```bash
export PATH=<flutter 3.47.5>/bin:$PATH      # this container had it under the session scratchpad
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
dart format --output=none --set-exit-if-changed $(git ls-files -co --exclude-standard '*.dart')
flutter analyze
timeout 580 flutter test -j 2
TZ=America/New_York flutter test -j 2 test/domain test/core test/data/repositories test/assistant
flutter test --update-goldens test/goldens   # then look at the changed PNGs
```
