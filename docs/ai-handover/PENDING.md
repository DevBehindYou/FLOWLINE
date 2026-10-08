# Pending

Phase scope: `docs/05` §36 table. Tick §36 with deviations on every merge.

## P0

### TASK-001: Finish H.3 (plan my day + re-plan)
Status: OPEN (code committed with this handover; CI not yet run)
Why: the slice is complete but unverified as a whole.
Files: see `CURRENT_STATE.md` § H.3.
Action:
1. `dart format` check, `flutter analyze`, `flutter test -j 2`, the NY subset.
2. Fix anything red; if goldens fail, regenerate and look at them.
3. Push; open PR "Plan my day and re-plan (Phase H.3)"; subscribe; merge when the three checks are green and the PR is mergeable (ISS-001: re-run once on a pub.dev network failure).
Done when: PR merged; `docs/05` H.3 ticked (already written in the tree).

## P1

### TASK-002: H.4 phone calendar, focus DND, flexible blocks (docs/05 §12.1, §12.5)
Status: OPEN
Action:
1. `CalendarAdapter` (domain interface) + Kotlin `MethodChannel('aa/calendar')` written by `android_patches` (READ_CALENDAR, `CalendarContract.Instances`), with patch tests.
2. Schema v15: `external_events` (+ migration + data test); `SyncPhoneCalendar` copies the next 14 days on resume; Today shows them as locked blocks; the conflict checker, `findFreeSlots`, `planDay` and scanners see them as busy.
3. Focus DND: Kotlin `aa/dnd` (`NotificationManager.setInterruptionFilter`, needs notification-policy access granted in system settings); toggle during focus sessions; Settings switch.
4. `is_flexible` on blocks (same v15) + moving a flexible focus block when an event lands on it, logged as a ledger row.
Done when: tests + CI green; device check documented (calendar events appear as locked blocks).

### TASK-003: Rest of Phase H scope
Status: OPEN
- Commitment detector (§5.1): "I'll send it Friday" → proposal (model-backed, opt-in, R16).
- Check-in (13:00, off by default) and weekly review (Sunday 18:00) with their own sections.
- Pattern miner (§5.3): same edit 3 weeks running / same list item same weekday ×3 → one proposal.
- Per-scanner switches, quiet hours, settable briefing times; background pass (WorkManager).
Done when: Phase H exit gate in §36 met (scanner tests with fixed clocks ✓, kill switch test ✓, device: calendar events as locked blocks).

## P2

### TASK-004: Phase I (memory, money, travel, documents): schema, FTS5, share target, OCR, bills/expenses, trips, documents + expiry, hand-offs. See docs/05 §18–§20.
### TASK-005: Phase J (voice 2): wake-word spike first (docs/05 §22.5).
### TASK-006: Release track: `ANDROID_*` signing secrets (owner, GitHub repo secrets; values never in repo), AAB, targetSdk, Play data-safety for microphone/calendar.

## Owner-only

- Run `docs/voice-device-check.md` on a CI APK (Phase G gate: ≥ 18/20).
- One real AI vendor round trip per key (Phase D note).
