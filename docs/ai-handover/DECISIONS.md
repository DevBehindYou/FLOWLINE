# Decisions

Only choices that constrain future work. Design-level decisions live in `docs/05`.

## ADR-001: Every AA write is a tool call with a ledger row and undo
Status: ACTIVE. UI taps, proposals, scanners, voice and the planner all go through `ToolExecutor`; multi-step actions share one `groupId` for one UNDO. Revisit: never without replacing Activity/UNDO.

## ADR-002: Scanners return typed findings; the runner words them
Status: ACTIVE. Keeps `lib/domain` free of English (CLAUDE.md). A dedupe key is never re-proposed once stored in any status.

## ADR-003: HANDS-OFF executes reversible context findings directly
Status: ACTIVE. Follows `decide()`; the proposal row is stored then closed as accepted so the key is known.

## ADR-004: "Done today" counts focus sessions, not tasks
Status: ACTIVE. Tasks keep no completion timestamp; counting only tool-path completions would mislead. Revisit when a `completed_at` column is added (needs schema v15 + migration test).

## ADR-005: Tasks have no estimate; the planner uses 30 min and never splits
Status: ACTIVE. Revisit with a task estimate field.

## ADR-006: Device-only exit gates are documented, not faked
Status: ACTIVE. Phase G passes on the owner's phone (`docs/voice-device-check.md`, ≥ 18/20); code slices are merged with UNVERIFIED notes.

## ADR-007: Emulator check uses a list command, not a reminder
Status: ACTIVE. Android 13+ shows a notification-permission system dialog the test can't tap.
