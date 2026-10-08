# Project Handover

Last updated: 2026-10-08
Verified against commit: `ddf13fc` (main, PR #9 merged) + local H.3 work (see CURRENT_STATE)

## Compact Context

@CTX/2
P:atomic-assist(DevBehindYou/FLOWLINE)
OBJ:docs/05 phases E→J, one PR per slice, auto-merge on green
STACK:flutter3.47.5|riverpod3|drift2.35(v14)|go_router|android
DONE:A,B,C,D,E,F,G(code),H.1,H.2
PEND:H.3(commit+PR),H.4(calendar,DND,flexible),H-gate,G-device-gate,I,J
RULE:CLAUDE.md R1/R2/R7/R8/R11/R12/R16;no-literals;branch=claude/fervent-shannon-79dcim
STAT:ci=V;tests=V(1188);emulator=V;apk=V;device=?;H.3=U
NEXT:full-suite>commit H.3>PR>merge>H.4

## Goal

Atomic Assist (AA) is an Android-first, local-first personal assistant in
Flutter (tasks, time blocks, focus timer, bring-your-own-key AI). The user
asked the agent to keep building the docs/05 plan automatically, one PR
per slice, to merge each PR itself when CI is green with no conflict, and
to report progress in % regularly.

## Current Status

| Area | Status |
|---|---|
| CI on `main` | VERIFIED (run 37670886998) |
| Unit/widget/golden tests | VERIFIED: 1188 pass (H.2) |
| Emulator integration test | VERIFIED in CI |
| Release APK | VERIFIED builds (throwaway signing key) |
| Physical device | UNKNOWN: never run |
| H.3 plan my day | IMPLEMENTED_UNTESTED (targeted tests pass, full suite not run, uncommitted when this handover started) |

## Completed

PRs #1–#9 merged (CHANGES.md): assistant core, Inbox/Activity, reminders,
lists, people and dates, repeating tasks, offline Assist commands, voice
push-to-talk with settings, QS tile and shortcut, context scanners with a
kill switch, morning and shutdown briefings.

## Active Problems

- `ISS-001`: CI's pub.dev fetch occasionally fails on the runner (network). Re-run once.
- No physical-device verification of anything (ISS-004).

## Highest-Priority Work

- `TASK-001` finish H.3 → `TASK-002` H.4.

## Critical Constraints

See `PROJECT_CONTEXT.md` § Rules. Push only to `claude/fervent-shannon-79dcim`.

## Read Next

`CURRENT_STATE.md` → `PENDING.md` → `NEXT_AGENT.md`
