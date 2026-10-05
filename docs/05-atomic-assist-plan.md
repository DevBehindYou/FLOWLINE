# Atomic Assist (AA) — Personal Assistant & Atomic UI Plan

**Version 1.0 · 2026-10-04 · branch `claude/eloquent-pasteur-3lciys`**
**Owner:** Ashutosh Sharma (DevBehindYou)
**Status:** forward plan. Supersedes the *order* of the open phases in
`04-build-and-optimization-plan.md` (Phases 4–7). Its rules R1–R21, its
defect register and its finished phases stay in force and are referenced
here, not repeated.

This document answers three requests:

1. **"An app that feels like our personal assistant — it listens to us and
   does our tasks, whether we say them or not."** Part I researches what a
   personal secretary actually does, Part II decides which of those duties
   an Android app can do honestly and safely, and Parts III–V specify how,
   down to tables, functions and components.
2. **Rebrand to Atomic Assist (AA), including the package name.** Done in
   commit `aaf9fbf` (§0.2).
3. **A complete UI/UX reconstruction on the Atomic Design System.** Part VI
   extracts the system from `design-system/atomic-design-system.md`, audits
   the current UI against it, and specifies tokens, components, every
   screen, navigation, motion, accessibility, responsiveness, performance
   and the migration.

Part VII sequences all of it into phases with exit gates.

---

## Contents

- **0.** Where things stand
- **Part I — Research**
  - 1. What a personal secretary does
  - 2. What AI secretaries do today
  - 3. The hard constraints (Android, Play policy, law)
- **Part II — Analysis**
  - 4. The duty catalogue, mapped to Atomic Assist
  - 5. "Said or not said": how AA notices work you didn't ask for
  - 6. The trust model: autonomy, undo, consent
- **Part III — Architecture**
  - 7. System overview
  - 8. The AI contract, v3: tools
  - 9. The assistant core: orchestrator, tools, policy, ledger
  - 10. Data model (schema v8–v12)
- **Part IV — Capabilities, one by one**
  - 11. Capture and the Inbox
  - 12. Time: calendar, scheduling, focus protection
  - 13. Reminders and follow-ups
  - 14. Communication drafts and hand-offs
  - 15. People and dates
  - 16. Meetings
  - 17. Lists, errands, household
  - 18. Money: bills and receipts
  - 19. Travel and logistics
  - 20. Memory and documents
  - 21. The daily rhythm: briefing, check-in, shutdown, weekly review
- **Part V — Voice**
  - 22. Listening modes, engines, the foreground service
- **Part VI — The Atomic UI/UX reconstruction**
  - 23. What the design system says (extraction)
  - 24. Audit of the current UI
  - 25. Decisions where the app and the system meet
  - 26. Tokens as code
  - 27. The component library
  - 28. Information architecture and navigation
  - 29. Every screen, specified
  - 30. Responsive behaviour
  - 31. Motion
  - 32. Accessibility
  - 33. Performance
  - 34. Iconography and brand assets
  - 35. Migration, cleanup and guard rails
- **Part VII — Delivery**
  - 36. Phases and exit gates
  - 37. Testing strategy additions
  - 38. Risks
  - 39. Decisions needed from the owner
  - 40. Sources

---

## 0. Where things stand

### 0.1 The app today (as built, verified by CI run #24–#26)

Local-first Flutter app: tasks with subtasks, time blocks (including
repeating blocks), a wall-clock focus timer with session summaries, a
bring-your-own-key AI chat that streams from Anthropic, OpenAI, Gemini or a
local Ollama server, conflict help for overlapping blocks, insights, PDF/CSV/JSON
export, onboarding, settings, l10n scaffolding, adaptive layout, 32 golden
images, an Android-emulator integration test. Drift schema v7, 465 tests.
Details: `PROJECT_OVERVIEW.md`.

What it is **not** yet: an assistant. It waits to be opened, it doesn't
listen, it can't act on anything except through the chat's text, and it
never notices anything on its own. That gap is the subject of this plan.

### 0.2 The rebrand (done)

| Item | Before | After |
|---|---|---|
| Product name | Flowline | **Atomic Assist** (short: **AA**) |
| Dart package | `flowline` | `atomic_assist` |
| Android application id | `com.devbehindyou.flowline` | **`com.devbehindyou.atomicassist`** (patched in `tool/ci/android_patches.dart`; CI fails any APK with another id) |
| Kotlin namespace | `com.devbehindyou.flowline` | `com.devbehindyou.atomic_assist` (as generated) |
| Launcher label | `flowline` | `Atomic Assist` |
| Database file / key prefix | `flowline.sqlite` / `flowline_ai_api_key_` | `atomic_assist.sqlite` / `atomic_assist_ai_api_key_` |
| Drift schema dir | `drift_schemas/flowline/` | `drift_schemas/atomic_assist/` (history kept) |
| CI artifacts | `flowline-*.apk` | `atomic-assist-*.apk` |

A new application id is a new app on Android: it installs next to an old
Flowline build and starts empty. That is acceptable now (nothing has been
published) and is why the storage names could move without a migration.
**The id is permanent from the first Play upload.**

Not renamed: the GitHub repository (`DevBehindYou/FLOWLINE`); renaming it
is the owner's call and doesn't affect the app.

---

# Part I — Research

## 1. What a personal secretary does

Job descriptions for personal secretaries, personal assistants (PAs) and
executive assistants (EAs) converge on the same duties. The list below
merges them (sources in §40), grouped by what the work is *about*.

| # | Domain | Duties found in the sources |
|---|---|---|
| D1 | **Calendar and time** | Manage the diary and appointments; schedule and reschedule meetings; resolve conflicts; protect time; send reminders; keep a family/personal schedule alongside the work one |
| D2 | **Communication** | Answer and screen calls; read, triage and reply to email; draft correspondence "on behalf of"; follow up on messages that got no answer |
| D3 | **Gatekeeping** | Control access to the person; filter distractions; decide what reaches them now, later, or never |
| D4 | **Meetings** | Prepare agendas and briefs; take minutes; extract decisions and action items; send follow-ups |
| D5 | **Travel and logistics** | Research and book flights, hotels, cars; build itineraries; plan around travel time |
| D6 | **Errands and household** | Run errands; manage household tasks and suppliers; pick up and drop off; keep the home running |
| D7 | **Personal occasions** | Remember birthdays and anniversaries; buy gifts; send flowers; plan family events |
| D8 | **Money admin** | Pay bills on time; track expenses; keep receipts; budget |
| D9 | **Documents and records** | File and find documents; maintain records; prepare reports and presentations |
| D10 | **Projects and tasks** | Track what's pending, chase it, prioritise; anticipate needs before they're voiced |
| D11 | **Information** | Research, summarise, answer questions, brief before decisions |
| D12 | **Discretion** | Handle sensitive information confidentially; act with judgement within delegated authority |

Two qualities appear in nearly every source and matter more than any single
duty: **anticipation** ("anticipate needs and proactively address potential
issues") and **discretion** (confidentiality, judgement, delegated
authority). The first is the user's "say or not say"; the second is what
makes it acceptable.

## 2. What AI secretaries do today

The 2026 AI-assistant products split the secretary's job between them
(sources in §40):

| Product | What it does well | What AA takes from it |
|---|---|---|
| **Lindy** | Inbox triage, meeting briefs with attendee context, notes and action items after meetings, follow-up drafts, scheduling and rescheduling | Meeting prep briefs; action items into tasks; drafted follow-ups |
| **Motion** | Auto-schedules tasks into free time, defends focus time, rebuilds the day when it changes | A planner that places tasks into the day and re-plans |
| **Reclaim** | Habits, focus blocks that flex around meetings instead of disappearing | Flexible focus blocks; habits as repeating, movable blocks |

All three are cloud services with server-side access to email and calendar.
AA is local-first with a bring-your-own key and no backend, so it can't copy
their architecture. It copies their **behaviours**, built on data the phone
already holds and on the documented ways Android lets one app hand work to
another.

## 3. The hard constraints

These decide the architecture. Each is sourced in §40.

### 3.1 Android: the microphone

- **`RECORD_AUDIO` is a while-in-use permission.** A background app can't
  open the microphone. Since Android 14 a microphone foreground service
  must be *started while the app is visible*, declare
  `foregroundServiceType="microphone"` and hold `FOREGROUND_SERVICE_MICROPHONE`
  plus `RECORD_AUDIO`; otherwise the system throws `SecurityException`.
- **Consequence:** "always listening" is possible only as a user-started,
  visibly running service with a persistent notification and the system's
  green microphone indicator. AA can't silently listen, and it won't try.
- **Phone calls can't be recorded** by third-party apps on modern Android.
  AA never offers it.

### 3.2 Android: speech recognition

| Engine | Where it runs | Fit |
|---|---|---|
| Platform `SpeechRecognizer` (via `speech_to_text`) | Often streams to a server; `createOnDeviceSpeechRecognizer` (API 31+) is on-device but "narrower, lower-quality" and not on every device | Short commands; not meant for continuous recognition |
| **Vosk** (`vosk_flutter_service`) | Fully on-device, small models (incl. Indian English), low latency | Offline commands, conversation mode |
| **Whisper** (`whisper_kit`, whisper.cpp) | Fully on-device, larger and slower, high accuracy, multilingual | Meeting notes and long dictation, after the fact |
| ML Kit GenAI speech | On-device, Flow-based API, no silent cloud fallback | Candidate to replace the platform recognizer (**Verify** device coverage) |

### 3.3 Android: wake word

**openWakeWord** (Apache-2.0, ONNX, a maintained Kotlin port) runs fully
on-device and supports custom wake words. **Porcupine** is open source but
needs a Picovoice access key and a commercial licence for custom words
(**Verify** terms before choosing it). AA plans on openWakeWord.

### 3.4 Google Play policy: no "do it for me" agents through Accessibility

Google Play's 2026 Accessibility policy (enforced from 2026-01-28) prohibits
using `AccessibilityService` for an app "to autonomously initiate, plan, and
execute actions or decisions", and lists "LLM agents that book, buy, message
or change settings" and "'do it for me' assistants" among the prohibited
uses. Android 17's Advanced Protection mode also blocks non-accessibility
apps from the API.

**Consequence, and the core design decision of this plan:** AA does the
secretary's work **on its own data** (tasks, blocks, reminders, lists,
people, notes) and **hands everything outside the app to the user through
Android's documented intents and providers**: dial, compose a message,
compose an email, add a calendar event, navigate, set an alarm. The user
presses the final button in the other app. AA never drives another app's
screen. This is also the right trust boundary for a secretary that acts
"on behalf of": it drafts and prepares, and you sign.

### 3.5 Law: recording other people

- **India:** one-party consent for your own conversations; recording a
  conversation you aren't part of is unlawful (Telecommunications Act 2023).
- **United States:** federal one-party consent; about 12 states (for
  example California, Florida, Illinois, Pennsylvania, Washington) require
  every party's consent.
- **EU:** GDPR requires informed, explicit consent for recordings, and
  some member states (for example Germany) require all parties to agree.

**Consequence:** AA's meeting mode is an explicit, per-meeting action with
a consent step and an on-screen and spoken notice. Transcripts stay on the
device. AA never records by default, and never records anything it isn't
part of.

---

# Part II — Analysis

## 4. The duty catalogue, mapped to Atomic Assist

Every duty from §1, with what AA does about it. **Mode** says who does the
final step:

- **AA** — AA does it inside the app (reversible, logged, undoable).
- **Hand-off** — AA prepares it completely and opens the right app; you
  press the last button.
- **Remind** — AA can't do it, but makes sure it isn't forgotten.
- **No** — out of scope, with the reason.

| Duty | AA capability | Mode | Section |
|---|---|---|---|
| D1 Manage the diary | Today timeline with blocks and tasks; two-way sync with the phone's calendars (Calendar Provider) | AA | §12 |
| D1 Schedule / reschedule | "Move my 3pm to tomorrow", find free time, re-plan the day when something slips | AA (own blocks) / Hand-off (shared invites) | §12 |
| D1 Resolve conflicts | Existing conflict checker + AI suggestion, now proactive | AA | §12 |
| D1 Protect time | Focus blocks that flex; Do Not Disturb during focus (with notification-policy access) | AA | §12.5 |
| D1 Reminders | Time, before-event, and follow-up reminders with notification actions | AA | §13 |
| D2 Answer/screen calls | Not possible for a regular app (call screening needs the default-dialer role) | No | §3 |
| D2 Draft replies | Drafts in your tone from what you dictate; opens WhatsApp/SMS/email with the draft | Hand-off | §14 |
| D2 Chase unanswered messages | "Follow up with Ravi if he hasn't replied by Friday" → a follow-up reminder with the draft ready | Remind + Hand-off | §13.4 |
| D3 Gatekeeping | Focus mode DND; Inbox decides what reaches you now vs at the daily check-in | AA | §11, §12.5 |
| D4 Meeting prep | Brief from the calendar event, related tasks, people notes and past meeting notes | AA | §16 |
| D4 Minutes and action items | Consent-based meeting mode; on-device transcript; decisions and action items proposed as tasks | AA (with consent) | §16 |
| D4 Follow-ups | Drafted follow-up message per attendee | Hand-off | §16 |
| D5 Book travel | Booking needs payment and other apps' screens | No (policy §3.4) | — |
| D5 Itineraries | Paste or share a confirmation → a trip with legs, times and departure reminders | AA | §19 |
| D5 Travel time | "Leave by 17:10" reminders from a stated travel time (no live traffic) | Remind | §19 |
| D6 Errands | Lists (shopping, errands, packing) by voice: "add milk" | AA | §17 |
| D6 Household tasks | Repeating chores as repeating tasks/blocks | AA | §17 |
| D7 Birthdays, anniversaries | People with dates; reminders 7 days and 1 day before; gift-idea notes | AA | §15 |
| D7 Buy gifts / flowers | Payment and other apps | Remind + Hand-off (opens a link you saved) | §15 |
| D8 Pay bills | AA never moves money | Remind (bills with due dates) | §18 |
| D8 Track expenses / receipts | Capture from text, share, or a photo (on-device OCR) | AA | §18 |
| D9 File and find documents | A document index of files you share to AA, searchable, with expiry reminders (passport, insurance) | AA | §20 |
| D9 Reports | Weekly review; export (PDF/CSV/JSON) | AA | §21 |
| D10 Track and chase work | Tasks, follow-ups, the Inbox, the evening shutdown | AA | §11, §21 |
| D10 Anticipate needs | Commitments noticed in what you say; patterns; calendar gaps; overdue drift | AA (proposes) | §5 |
| D11 Research / answers | The chat, with your context; no web browsing without an API (owner decision §39) | AA | §9 |
| D12 Discretion | Local-first storage, keys in the Keystore, consent, the ledger, retention settings, "what AA knows" | AA | §6 |

**Result:** 22 of 27 duty lines can be done or prepared by AA; 2 can only be
reminded; 3 are out of scope on Android for a Play-distributed app. That is
the honest shape of the product.

## 5. "Said or not said": how AA notices work you didn't ask for

The user asked for an assistant that does tasks "whether we say them or
not". AA gets there through four sources, from most to least explicit.
Every source ends in the same place: an action AA takes (if allowed, §6) or
a **proposal** in the Inbox that you accept with one tap.

| Source | Example | How AA notices | Default outcome |
|---|---|---|---|
| **S1 Said, as a request** | "Remind me to call Mum at 7" | The orchestrator gets a tool call from the model (§9) | Done, with Undo |
| **S2 Said, as a commitment** | In the chat or a voice note: "I told Priya I'd send the deck by Friday" | Commitment detector (§5.1) | Proposal: task "Send deck to Priya", due Friday 17:00 |
| **S3 Not said: context** | A meeting tomorrow with no prep block; a birthday in 6 days; a task overdue twice; a bill due in 3 days; a free 90-minute gap | Context scanners on a schedule (§5.2) | Proposal or a line in the next briefing |
| **S4 Not said: patterns** | You move "Gym" from 7:00 to 19:00 every Monday; you always add milk on Sundays | Pattern miner over the ledger (§5.3) | Proposal to change the routine, once; never repeated if dismissed |

What AA never uses as a source: other people's speech without consent,
other apps' screens, other apps' notifications (deferred, §39), your
location history (AA keeps none).

### 5.1 The commitment detector (S2)

Two stages, so most messages never reach a model:

1. **On-device pre-filter** (pure Dart, `domain/assistant/commitment_filter.dart`):
   first-person future intent ("I'll", "I will", "I need to", "I have to",
   "I promised", "remind me", "don't let me forget", Hindi "mujhe … karna
   hai", "kal") **and** a time or person cue (date/time words, a weekday, a
   name in People). Fast and conservative: it only decides whether to ask
   the model.
2. **Structured extraction** with the active provider, `format: json` and a
   schema, returning zero or more commitments. Output is untrusted (R16):
   each is validated (due date in the future and within 2 years, text
   non-empty, person resolved against People or left as text), de-duplicated
   against open tasks and reminders, and turned into a proposal.

```dart
// domain/assistant/commitment.dart — pure Dart.
final class Commitment {
  const Commitment({
    required this.what,
    this.due,
    this.personName,
    required this.confidence,
    required this.sourceText,
  });
  final String what;
  final DateTime? due;
  final String? personName;
  /// 0..1 from the model; only >= 0.6 becomes a proposal.
  final double confidence;
  /// The sentence it came from, shown on the proposal ("You said: …").
  final String sourceText;
}

/// Stage 1. True when [text] is worth sending to stage 2.
bool mightContainCommitment(String text, {required Set<String> knownNames}) {
  final t = text.toLowerCase();
  const intent = [
    "i'll", 'i will', 'i need to', 'i have to', 'i must', 'i promised',
    'remind me', "don't let me forget", 'karna hai', 'yaad dila',
  ];
  const timeCues = [
    'today', 'tonight', 'tomorrow', 'kal', 'next week', 'by ', 'before ',
    'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday',
    'sunday', ' am', ' pm', ':',
  ];
  final hasIntent = intent.any(t.contains);
  final hasCue = timeCues.any(t.contains) ||
      knownNames.any((n) => t.contains(n.toLowerCase()));
  return hasIntent && hasCue;
}
```

Stage-2 schema (sent as the request's JSON format and repeated in the
system prompt for vendors without schema enforcement):

```json
{
  "type": "object",
  "properties": {
    "commitments": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "what": { "type": "string", "maxLength": 140 },
          "due": { "type": ["string", "null"], "description": "ISO 8601 local date-time, or null" },
          "person": { "type": ["string", "null"] },
          "confidence": { "type": "number", "minimum": 0, "maximum": 1 }
        },
        "required": ["what", "confidence"]
      }
    }
  },
  "required": ["commitments"]
}
```

### 5.2 Context scanners (S3)

Pure functions in `domain/assistant/scanners/`, run by the trigger
scheduler (§9.6) at the briefing times and after relevant writes. Each
returns `List<ProposalDraft>`; none calls a model.

| Scanner | Rule | Proposal |
|---|---|---|
| `meetingWithoutPrep` | Calendar event with ≥ 2 attendees in the next 36 h and no prep block or note | "Prep for *Kickoff* (15 min before?)" |
| `upcomingDates` | Person date in 7 days, and again in 1 day | "Priya's birthday is Thursday. Gift idea from your notes: *pottery class*" |
| `overdueDrift` | Task overdue, or moved ≥ 2 times | "Break *Write report* into steps?" (Task Breakdown) or "Drop it?" |
| `billDue` | Bill due in ≤ 3 days and not marked paid | "Electricity due 2026-10-07 (₹1,840)" |
| `freeGapForTasks` | A gap ≥ 45 min today and high-priority unscheduled tasks | "Use 14:00–15:30 for *Draft Q2 plan*?" |
| `dayOverbooked` | Planned load ≥ 90% of working hours | "Today is full. Move *Admin* to tomorrow?" |
| `followUpDue` | A follow-up's wait time passed with no "done" | "Ravi hasn't been marked as replied. Draft a nudge?" |
| `documentExpiring` | A document with an expiry in 60/30/7 days | "Passport expires 2026-12-01" |

### 5.3 Pattern miner (S4)

Runs nightly (or at the evening shutdown) over the action ledger (§9.4).
Two patterns in v1, both conservative: **the same manual edit 3 weeks
running** (move, retime, rename of a repeating block) and **the same list
item added on the same weekday 3 times**. It proposes a change once. A
dismissed pattern is remembered and never proposed again.

## 6. The trust model: autonomy, undo, consent

A secretary is useful in proportion to how much you can delegate, and safe
in proportion to how well you can see and reverse what they did. AA makes
both explicit.

### 6.1 Risk classes

Every tool (§9.2) declares one (stored by index, append-only, R1):

| Class | Meaning | Examples |
|---|---|---|
| `read` | Changes nothing | Search tasks, read the agenda, find free time |
| `reversible` | Changes AA's own data; one-tap undo restores it exactly | Create/complete/move a task, add a reminder, add a list item |
| `handOff` | Prepares something in another app; the user completes it | Compose an SMS, an email, a WhatsApp message; dial; navigate; add to a shared calendar |
| `destructive` | Deletes or overwrites the user's data | Delete a task, clear a list |
| `forbidden` | Never, by any path | Send without the user, pay, record others, change system settings beyond DND |

### 6.2 Autonomy levels and the policy

```dart
// domain/assistant/autonomy.dart — pure Dart.
enum ActionRisk { read, reversible, handOff, destructive, forbidden } // R1

enum ActionOrigin { said, commitment, context, pattern, routine } // R1

/// What the user chose in Settings → Assistant → "How much can AA do on
/// its own?". Stored as a setting; default [balanced].
enum AutonomyPreset { careful, balanced, handsOff } // R1

enum Decision { execute, executeWithUndo, propose, confirm, refuse }

Decision decide({
  required ActionRisk risk,
  required ActionOrigin origin,
  required AutonomyPreset preset,
}) {
  switch (risk) {
    case ActionRisk.forbidden:
      return Decision.refuse;
    case ActionRisk.read:
      return Decision.execute;
    case ActionRisk.destructive:
      // Always an explicit confirmation stating exactly what goes (§9.9
      // of the design system), even when you asked for it.
      return origin == ActionOrigin.said ? Decision.confirm : Decision.propose;
    case ActionRisk.handOff:
      // The other app shows its own Send/Call button; AA just opens it.
      // Unasked hand-offs are only ever proposed.
      return origin == ActionOrigin.said ? Decision.execute : Decision.propose;
    case ActionRisk.reversible:
      return switch ((origin, preset)) {
        (ActionOrigin.said, AutonomyPreset.careful) => Decision.confirm,
        (ActionOrigin.said, _) => Decision.executeWithUndo,
        (ActionOrigin.routine, _) => Decision.executeWithUndo,
        (_, AutonomyPreset.handsOff) => Decision.executeWithUndo,
        _ => Decision.propose,
      };
  }
}
```

This one function is the whole policy. It is exhaustively unit-tested
(5 risks × 5 origins × 3 presets = 75 cases, a table test).

### 6.3 The ledger: everything AA did, and Undo

Every executed action writes a ledger row *in the same transaction* as the
change, carrying what's needed to reverse it (§9.4). The **Activity**
screen lists them ("2026-10-04 09:12 · CREATED TASK · Send deck to Priya ·
UNDO"); a snackbar offers Undo right after; the evening shutdown summarises
the day's automatic actions. Nothing AA does is invisible.

### 6.4 Consent and privacy, as product features

| Topic | Rule |
|---|---|
| Listening | Off by default. Push-to-talk first; conversation mode and wake word are separate opt-ins, each explaining battery and privacy cost (§22) |
| Audio | Never stored by default. Optional "keep audio of voice notes" setting, local only |
| Transcripts | Stored locally; retention 7 / 30 / 90 days / forever (default 30); deletable one by one or all |
| Other people | Meeting mode only, explicit consent step, visible notice; never automatic |
| What leaves the phone | Only what is sent to the AI provider *you* configured, with your key, for the request you made or the scan you enabled. The privacy screen shows exactly which data each feature sends. Ollama keeps it on your network |
| Redaction | Before any cloud request: phone numbers, emails and card-like numbers in *context* (not in what you typed) are replaced with placeholders unless the tool needs them |
| Memory | "What AA knows about you": every remembered fact, its source and date, editable and deletable |
| Kill switch | One toggle pauses all proactive behaviour (scanners, pattern miner, commitment detection) without losing data |

---

# Part III — Architecture

## 7. System overview

```
┌─ Surfaces ────────────────────────────────────────────────────────────┐
│ TODAY · INBOX · ASSIST (chat + voice) · FOCUS · LIBRARY · Settings    │
│ Notification actions · Quick Settings tile · Share target · Briefings │
└───────────────┬──────────────────────────────────────▲────────────────┘
                │ Utterance / tap (typed)               │ watch streams
┌─ Assistant core ──────────────────────────────────────┴───────────────┐
│ CaptureService → Orchestrator → ToolRegistry → decide() → Ledger      │
│ QuickParser (local grammar) · CommitmentDetector · Scanners · Miner   │
│ TriggerScheduler (app resume, writes, briefing times, background)     │
└──────┬─────────────────────┬──────────────────────┬───────────────────┘
       │                     │                      │
  Repositories (Drift)   AIClient v3 (tools)   Platform adapters
  tasks, blocks,         Anthropic, OpenAI,    Calendar Provider, intents,
  reminders, people,     Gemini, Ollama        speech in/out, notifications,
  lists, memory, ledger                        contact picker, OCR
```

**One path for every input.** Typed text, speech, a share, a notification
reply and a scanner's finding all become an `Utterance` or a
`ProposalDraft` and pass through the same orchestrator, the same tools, the
same policy (§6.2) and the same ledger. Voice is *only* a new input; it
adds no new way to change data.

**Where the code goes** (existing layering kept: `domain/` is pure Dart):

| Directory | Contents |
|---|---|
| `lib/domain/assistant/` | `autonomy.dart`, `commitment.dart`, `commitment_filter.dart`, `tool.dart` (tool interface, typed previews/outcomes), `proposal.dart`, `ledger.dart` (entries, undo recipes), `quick_parse.dart`, `time_phrase.dart`, `scanners/*.dart`, `pattern_miner.dart`, `briefing.dart`, `voice_state.dart` |
| `lib/domain/usecases/` | The use-case layer docs/04 planned for Phase 6, introduced here: `AssistantOrchestrator`, `AcceptProposal`, `UndoAction`, `RunScanners`, `PlanDay`, `SyncPhoneCalendar` |
| `lib/domain/repositories/` | New interfaces: `LedgerRepository`, `ProposalRepository`, `ReminderRepository`, `PeopleRepository`, `ListRepository`, `MemoryRepository`, `MoneyRepository`, `TripRepository`, `DocumentRepository`, `CalendarCacheRepository`, `UtteranceRepository` |
| `lib/data/repositories/` | Drift implementations; every write that a tool makes takes a `LedgerWriter` and runs in one transaction with its ledger row |
| `lib/data/platform/` | `calendar_adapter.dart`, `hand_off_launcher.dart`, `speech/` (engines), `tts.dart`, `contact_picker.dart`, `ocr.dart`, `dnd.dart` |
| `lib/assistant/tools/` | One file per tool (`create_task_tool.dart`, …) and `tool_registry.dart` |
| `lib/design/` | Tokens, theme, and the Atomic component library (Part VI) |
| `lib/features/` | New: `inbox/`, `activity/`, `assist/` (renamed from `ai_assistant/`), `voice/`, `briefing/`, `library/`, `people/`, `lists/`, `money/`, `trips/`, `documents/`, `memory/`, `review/` (replaces `insights/`), `meeting/` |

**Background work.** The scanners are pure and cheap, so the primary
trigger is *the app being opened or resumed* (debounced to once per 10
minutes) and *a relevant write*. Timed moments (briefings, reminders,
bills) are scheduled local notifications, which fire with the app closed.
A periodic background pass (`workmanager`, about every 3 h, **Verify** the
maintained package) refreshes scanners and the calendar cache so the
morning briefing is current; it is an improvement, never a dependency.

### 7.1 One request, end to end

"Remind me to call Mum at 7" (spoken, 16:40):

1. `VoiceController` → `SpeechEngine` → final text, confidence 0.93.
2. `CaptureService.capture(Utterance(text, source: voice))` stores the
   utterance (retention §6.4) and calls the orchestrator.
3. `QuickParser` matches *remind me to {what} at {time}* →
   `ToolCall('create_reminder', {title: 'Call Mum', at: '…T19:00'})`.
   `parseTimePhrase('at 7', now: 16:40)` resolves to 19:00 today (§9.8).
   No model call.
4. Registry: parse → validate (future time, title non-empty) →
   `decide(reversible, said, balanced)` = `executeWithUndo`.
5. `ReminderRepository.create` + ledger row in one transaction; the
   notification is scheduled after commit.
6. UI: snackbar "Reminder set · 19:00 · UNDO"; speech reply "Done. I'll
   remind you at 7." (both from l10n, built from the typed outcome).

If the quick parser doesn't match, step 3 becomes a model call with tools
(§8–9); steps 4–6 don't change.

## 8. The AI contract, v3: tools

v2 (shipped) already has the extension points docs/04 §4.1 reserved. v3
adds tools without changing any existing call site.

```dart
// lib/domain/ai/ai_contract.dart — additions (pure Dart).

/// A function the model may call. [parameters] is a JSON Schema object,
/// kept to the subset every vendor accepts: type, properties, required,
/// enum, items, description, minimum/maximum, maxLength (§8.2).
final class AIToolSpec {
  const AIToolSpec({
    required this.name,
    required this.description,
    required this.parameters,
  });
  final String name; // ^[a-z][a-z0-9_]{0,63}$
  final String description;
  final Map<String, Object?> parameters;
}

enum AIToolChoice { auto, none, required }

/// Turns inside one assistant request, after [AIRequest.prompt]: the
/// model's tool calls and our results, replayed on the next round.
sealed class AITurn {
  const AITurn();
}

final class AIAssistantTurn extends AITurn {
  const AIAssistantTurn({this.text = '', this.toolCalls = const []});
  final String text;
  final List<AIToolCall> toolCalls;
}

final class AIToolResultTurn extends AITurn {
  const AIToolResultTurn({
    required this.callId,
    required this.name,
    required this.json,
    this.isError = false,
  });
  final String callId;
  final String name;
  /// Compact JSON the tool returned (validated, size-capped: §9.3).
  final String json;
  final bool isError;
}

/// Emitted once per complete call; clients assemble streamed argument
/// fragments themselves. [argumentsJson] is raw model output (R16): the
/// orchestrator parses and validates it, the client never does.
final class AIToolCall extends AIEvent {
  const AIToolCall({
    required this.id,
    required this.name,
    required this.argumentsJson,
  });
  final String id;
  final String name;
  final String argumentsJson;
}

// AIRequest gains three optional fields (defaults keep v2 behaviour):
//   final List<AIToolSpec> tools;        // const []
//   final AIToolChoice toolChoice;       // AIToolChoice.auto
//   final List<AITurn> continuation;     // const []
//
// Append-only enum growth (R1):
//   AIStopReason: ..., other, toolUse
//   AIFailureKind: ..., interrupted, toolsUnsupported
```

### 8.1 Vendor mapping

| | Request | Streamed call | Result turn |
|---|---|---|---|
| **Anthropic** Messages | `tools: [{name, description, input_schema}]`, `tool_choice: {type: auto\|none\|any}` | `content_block_start` (type `tool_use`, id, name) → `input_json_delta.partial_json` fragments → `content_block_stop`; `stop_reason: tool_use` | user message with `{type: tool_result, tool_use_id, content, is_error}` |
| **OpenAI** Chat Completions | `tools: [{type: function, function: {name, description, parameters}}]`, `tool_choice` | `delta.tool_calls[i]` with `id`, `function.name`, then `function.arguments` fragments keyed by `index`; `finish_reason: tool_calls` | `{role: tool, tool_call_id, content}` |
| **Gemini** generateContent | `tools: [{functionDeclarations: [{name, description, parameters}]}]`, `toolConfig.functionCallingConfig.mode` | `parts[].functionCall {name, args}` arrives whole; id synthesised when absent (**Verify** whether current models send `id`) | `parts[].functionResponse {name, response}` |
| **Ollama** `/api/chat` | `tools` in the OpenAI function format | `message.tool_calls[].function {name, arguments}` (an object, whole) | `{role: tool, content, tool_name}` (**Verify** field name per version) |

Every row is **Verify** against the vendor docs on the day it's built, and
pinned by recorded fixtures in `client_contract_test.dart` (one call; two
parallel calls; text then a call; malformed argument JSON; a call cut off
mid-stream → `AIFailure(interrupted)`; a 400 that rejects tools →
`AIFailure(toolsUnsupported)`).

### 8.2 Schema subset and the fallback

Gemini accepts an OpenAPI subset of JSON Schema and small Ollama models call
tools unreliably. Two rules keep one tool definition working everywhere:

1. Tool schemas use only the subset listed in `AIToolSpec`. A unit test
   walks every registered schema and fails on any other keyword.
2. **JSON-plan fallback.** When a provider answers `toolsUnsupported`, or
   the user marks a model as "no tools" in Settings, the orchestrator sends
   the same tool list inside the system prompt and asks for
   `format: json` matching:

```json
{ "reply": "string", "actions": [ { "tool": "string", "args": {} } ] }
```

Both paths produce the same `ToolCall` values, so the rest of the core
cannot tell them apart.

## 9. The assistant core

### 9.1 The tool interface

```dart
// lib/domain/assistant/tool.dart — pure Dart.

/// What the core knows about now, for validation and previews.
final class AssistantContext {
  const AssistantContext({required this.now, required this.snapshot});
  final DateTime now;
  final StateSnapshot snapshot; // ids/titles the tools may reference
}

sealed class ToolValidation {
  const ToolValidation();
}
final class Valid extends ToolValidation {
  const Valid();
}
final class Invalid extends ToolValidation {
  const Invalid(this.reason, [this.detail]);
  final InvalidReason reason; // enum: notFound, inPast, tooFar, empty,
  final String? detail;       // duplicate, conflict, outOfRange, …
}

abstract interface class AssistantTool<A> {
  /// Stable snake_case id; stored in the ledger and proposals.
  String get name;
  /// For the model only (English, never shown in the UI).
  String get description;
  Map<String, Object?> get parameters;
  ActionRisk get risk;

  /// Throws [ToolArgumentError] on a shape error.
  A parse(Map<String, Object?> json);
  ToolValidation validate(A args, AssistantContext context);
  /// Typed description of the effect, which the UI words with l10n:
  /// proposal cards, confirm sheets, the ledger, spoken replies.
  ActionPreview preview(A args, AssistantContext context);
  /// Runs the effect and returns how to undo it. Implementations write
  /// through repositories that join the caller's transaction.
  Future<ToolOutcome> run(A args, ToolRun run);
}

final class ToolOutcome {
  const ToolOutcome({required this.result, this.undo, this.handOff});
  /// Compact JSON for the model's next round (read tools return data).
  final Map<String, Object?> result;
  final UndoRecipe? undo;       // null for read and hand-off tools
  final HandOff? handOff;       // opened after the transaction commits
}
```

`ActionPreview` is a sealed class per effect (`CreateTaskPreview(title,
due)`, `MoveBlockPreview(title, from, to)`, `DeletePreview(kind, count,
titles)`, …). It is the single source for every sentence AA says about an
action, so the chat, the Inbox, the ledger and the voice reply never
disagree.

### 9.2 The tool catalogue (v1)

| Tool | Risk | Arguments | Undo |
|---|---|---|---|
| `get_agenda` | read | `day` | — |
| `find_free_time` | read | `day`, `minutes`, `between?` | — |
| `search_tasks` | read | `query`, `status?` | — |
| `search_memory` | read | `query` | — |
| `get_person` | read | `name` | — |
| `list_items` | read | `list` | — |
| `create_task` | reversible | `title`, `due?`, `priority?`, `notes?` | delete row |
| `update_task` | reversible | `task_id`, changed fields | restore fields |
| `complete_task` | reversible | `task_id` | restore status |
| `schedule_task` | reversible | `task_id`, `start`, `minutes` | restore block id; delete created block |
| `create_block` | reversible | `title`, `start`, `end`, `repeat?` | delete row |
| `move_block` | reversible | `block_id`, `start`, `end` | restore times (stored occurrence: `storeOccurrence` first, undo deletes it and its exception) |
| `create_reminder` | reversible | `title`, `at`, `repeat?`, `link?` | delete row + cancel notification |
| `snooze_reminder` | reversible | `reminder_id`, `until` | restore fire time |
| `create_follow_up` | reversible | `person`, `about`, `wait_until`, `channel?` | delete row |
| `add_list_items` | reversible | `list`, `items[]` | delete rows |
| `check_list_item` | reversible | `item_id`, `checked` | restore |
| `remember` | reversible | `fact`, `person?` | delete row |
| `add_person_date` | reversible | `person`, `kind`, `month`, `day`, `year?` | delete row |
| `add_bill` / `mark_bill_paid` | reversible | payee, amount, due, repeat / `bill_id` | delete / restore |
| `log_expense` | reversible | `amount`, `category?`, `note?`, `at?` | delete row |
| `start_focus` | reversible | `task_id?`, `minutes?` | stop session (no history row if < 1 min) |
| `create_trip` | reversible | `title`, `legs[]` | delete trip (cascade) |
| `compose_message` | handOff | `channel` (sms/whatsapp/email), `to`, `body`, `subject?` | — |
| `call` | handOff | `person` or `number` | — |
| `navigate` | handOff | `destination` | — |
| `add_to_phone_calendar` | handOff | `title`, `start`, `end`, `location?` | — |
| `set_phone_alarm` | handOff | `time`, `label?` | — |
| `open_link` | handOff | `url` (https only, from saved data) | — |
| `delete_task` / `delete_block` | destructive | id(s) | restore rows (kept 30 days) |
| `clear_checked` | destructive | `list` | restore rows |
| `forget` | destructive | `memory_id` | restore row |

There are **no** forbidden tools to register: the registry rejects unknown
names, so "pay", "send", "record" don't exist as capabilities at all.

### 9.3 The orchestrator

```dart
// lib/domain/usecases/assistant_orchestrator.dart — pure Dart.
final class AssistantOrchestrator {
  AssistantOrchestrator({
    required this.registry,
    required this.ai,           // AIRepository: completeWithTools(...)
    required this.contextBuilder,
    required this.executor,     // runs a call in a transaction + ledger
    required this.settings,     // AutonomyPreset, kill switch
  });

  static const maxRounds = 4;
  static const maxCallsPerTurn = 8;
  static const turnTimeout = Duration(seconds: 30);

  Future<TurnResult> handle(Utterance u) async {
    final now = clock.now();
    final local = quickParse(u.text, now: now, names: await _names());
    if (local != null) return _act([local], u, now, rounds: 0);

    final turns = <AITurn>[];
    final done = <ActedCall>[];
    for (var round = 0; round < maxRounds; round++) {
      final reply = await ai.completeWithTools(
        system: await contextBuilder.systemPrompt(now),
        prompt: u.text,
        tools: registry.specs,
        continuation: turns,
      ).timeout(turnTimeout);
      if (reply.failure != null) return TurnResult.failed(reply.failure!);
      if (reply.calls.isEmpty) return TurnResult.answered(reply.text, done);
      if (done.length + reply.calls.length > maxCallsPerTurn) {
        return TurnResult.tooManyActions(done);
      }
      final acted = await _act(reply.calls, u, now, rounds: round + 1);
      done.addAll(acted.calls);
      if (acted.needsUser) return acted; // confirm/propose ends the turn
      turns
        ..add(AIAssistantTurn(text: reply.text, toolCalls: reply.calls))
        ..addAll(acted.resultTurns);
    }
    return TurnResult.roundLimit(done);
  }
}
```

`_act` does, for each call: look up the tool (unknown → error result) →
`parse` (shape error → error result for the model to correct) → `validate`
against a fresh snapshot → `decide(risk, origin, preset)` →

| Decision | What happens |
|---|---|
| `execute` / `executeWithUndo` | `executor.run` (transaction + ledger), result fed back to the model |
| `propose` | A proposal row (§9.5); the model is told "proposed to user" |
| `confirm` | The turn stops with a confirm sheet built from `preview`; on CONFIRM the call runs as `said` |
| `refuse` | Error result "not allowed"; AA says so plainly |

Read-tool results are capped (20 rows, 4 KB) before they go back to the
model. All tool calls of one turn share a `groupId`, so one UNDO reverses
the whole turn.

### 9.4 The ledger

```dart
// lib/domain/assistant/ledger.dart — pure Dart.
enum LedgerStatus { done, undone, failed, handedOff } // R1

/// How to reverse one action. Serialised as JSON in the ledger row.
sealed class UndoRecipe {
  const UndoRecipe();
}
final class DeleteRows extends UndoRecipe {
  const DeleteRows(this.table, this.ids);
  final UndoTable table; // enum of the tables tools may touch
  final List<int> ids;
}
final class RestoreRows extends UndoRecipe {
  const RestoreRows(this.table, this.rows); // full rows as JSON
  final UndoTable table;
  final List<Map<String, Object?>> rows;
}
final class RestoreFields extends UndoRecipe {
  const RestoreFields(this.table, this.id, {required this.before, required this.after});
  final UndoTable table;
  final int id;
  final Map<String, Object?> before;
  /// Undo refuses if the row no longer matches [after] (the user changed
  /// it since); the UI says "Changed since. Not undone."
  final Map<String, Object?> after;
}
final class UndoAll extends UndoRecipe {
  const UndoAll(this.steps); // applied in reverse order
  final List<UndoRecipe> steps;
}
```

`UndoAction` runs the recipe in one transaction, re-schedules or cancels
notifications after commit, and marks the row `undone`. Undo is offered
until the end of the next day in the snackbar and Activity screen, and
for 30 days from Activity. Deleted rows are restorable for 30 days because
the recipe holds them.

### 9.5 Proposals

A proposal is a tool call that hasn't run. It stores the tool name, the
JSON arguments, the origin (§5), a typed reason (`ProposalReason` enum +
JSON arguments, worded by l10n), the source text when there is one ("You
said: …"), a `dedupeKey` (e.g. `upcomingDates:person:12:2026-10-09`) and
an expiry. ACCEPT re-validates against the current state (things change)
and runs it with `origin: said` (a tap is consent). DISMISS stores the key;
"Don't suggest this again" stores the *pattern* key, which the scanners and
the miner check before creating anything.

### 9.6 Trigger scheduler

| Trigger | Runs |
|---|---|
| App start / resume (debounced 10 min) | Calendar cache sync, all scanners, expire old proposals, top up scheduled notifications |
| Write to tasks/blocks/reminders/bills | Only the scanners that read that table |
| Briefing times (default 07:30, 13:00, 18:30) | A local notification; opening it builds the briefing (§21) |
| Background pass (~3 h, best effort) | Same as resume, without UI |
| Chat message or voice note | Commitment detector (if enabled) |
| Nightly / shutdown | Pattern miner |

Every proactive path checks the kill switch first.

### 9.7 Context for the model

`AssistantContextBuilder.systemPrompt(now)` builds a compact, bounded
prompt (target ≤ 3,000 tokens, measured in tests with a 4-chars-per-token
estimate): the role and rules (act only through tools, ask when unsure,
never invent ids); now in ISO with the time zone; the user's work hours;
today's and tomorrow's agenda (≤ 20 items with ids); open tasks (≤ 20, by
due then priority, with ids); people names (≤ 50); list names; the top 10
memory facts for the utterance (FTS5 rank); the autonomy preset. Redaction
(§6.4) runs over everything except the user's own words.

### 9.8 The local grammar (QuickParser)

Most daily requests are a handful of shapes. Parsing them on the phone
makes them instant, free, offline and private.

| Shape (en + Hinglish) | Tool |
|---|---|
| remind me (to) X (at/in/on/tomorrow…) · *X yaad dila(na)* | `create_reminder` |
| add X(, Y and Z) to (the) L (list) · *L mein X daal do* | `add_list_items` |
| (add a) task X (by/due D) | `create_task` |
| start (a) focus (for N min) (on X) | `start_focus` |
| what's on today / tomorrow / on Friday · *aaj kya hai* | `get_agenda` |
| move X to T | `move_block` (fuzzy title match, ≥ 0.8 similarity, else model) |
| mark X done · X ho gaya | `complete_task` |
| call / text / whatsapp P (saying M) | `call` / `compose_message` |
| note: X · remember (that) X | `remember` |
| spent N on C · *N ka C* | `log_expense` |

```dart
// lib/domain/assistant/time_phrase.dart — pure Dart.
sealed class TimePhrase { const TimePhrase(); }
final class AtInstant extends TimePhrase { const AtInstant(this.at); final DateTime at; }
final class OnDay extends TimePhrase { const OnDay(this.day); final DateTime day; }

/// "at 7", "7pm", "19:00", "in 20 minutes", "tomorrow morning", "tonight",
/// "on Friday", "next Monday", "kal", "parso", "2026-10-09".
/// A bare hour means the next one in the future: at 16:40, "at 7" is 19:00
/// today; at 06:10 it is 07:00. "Morning" 09:00, "afternoon" 14:00,
/// "evening" 18:00, "tonight" 20:00 (settings can change these).
/// "kal" in a future-intent sentence is tomorrow.
TimePhrase? parseTimePhrase(String text, {required DateTime now});
```

Day arithmetic goes through `addDays`/`startOfDay` (R8), so DST and the
New York CI run are covered. The parser ships with a table test of at
least 150 phrases (§37).

### 9.9 Riverpod wiring

`assistantOrchestratorProvider`, `toolRegistryProvider`,
`voiceControllerProvider` and `proposalActionsProvider` are **keepAlive**
(R11: they use `ref` after awaits). Screens watch stream providers
(`inboxProvider`, `ledgerProvider(day)`) and call actions through
`runAction` with a busy flag (R12).

## 10. Data model (schema v8–v12)

One schema version per delivery phase, each with a step-by-step migration
and a migration test with data (R2). Invariants as SQL `CHECK`s and
partial unique indexes (R3). Money is integer minor units plus an ISO 4217
code. Calendar days are stored as local midnight, like `occurrence_date`.

| Version | Phase | Tables |
|---|---|---|
| v8 | E | `assistant_actions` (ledger), `proposals`, `utterances` |
| v9 | F | `reminders`, `follow_ups`; `tasks.recurrence`, `tasks.recurrence_anchor` |
| v10 | F | `people`, `person_dates`, `lists`, `list_items` |
| v11 | H/I | `external_events` (phone calendar cache), `memories` + `memories_fts`, `documents` + `documents_fts`, `meetings` |
| v12 | I | `bills`, `expenses`, `trips`, `trip_legs` |

```dart
// lib/data/local/drift/tables/assistant_actions_table.dart
@DataClassName('AssistantActionRow')
class AssistantActions extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get at => dateTime()();
  /// All calls from one turn share it: one UNDO for the turn.
  TextColumn get groupId => text()();
  TextColumn get toolName => text()();
  TextColumn get argsJson => text()();
  IntColumn get origin => integer()();   // ActionOrigin index (R1)
  IntColumn get decision => integer()(); // Decision index (R1)
  IntColumn get status => integer()();   // LedgerStatus index (R1)
  TextColumn get undoJson => text().nullable()();
  IntColumn get utteranceId =>
      integer().nullable().references(Utterances, #id, onDelete: KeyAction.setNull)();

  @override
  List<String> get customConstraints => ['CHECK (origin BETWEEN 0 AND 4)'];
}

// lib/data/local/drift/tables/proposals_table.dart
@DataClassName('ProposalRow')
class Proposals extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get expiresAt => dateTime().nullable()();
  TextColumn get toolName => text()();
  TextColumn get argsJson => text()();
  IntColumn get origin => integer()();
  IntColumn get reason => integer()();     // ProposalReason index (R1)
  TextColumn get reasonJson => text()();
  TextColumn get sourceText => text().nullable()();
  TextColumn get dedupeKey => text()();
  IntColumn get status => integer()();     // open, accepted, dismissed, expired
}
// Migration adds: CREATE UNIQUE INDEX proposals_open_key
//   ON proposals(dedupe_key) WHERE status = 0;

// lib/data/local/drift/tables/reminders_table.dart
@DataClassName('ReminderRow')
class Reminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  /// The instant it fires (UTC). For floating reminders ("7pm wherever I
  /// am") also [wallClock], and a time-zone change re-schedules them.
  DateTimeColumn get fireAt => dateTime()();
  TextColumn get wallClock => text().nullable()(); // "19:00"
  TextColumn get recurrence => text().nullable()(); // RecurrenceRule.format
  IntColumn get kind => integer()();   // plain, beforeBlock, followUp, bill,
                                       // personDate, departure, document (R1)
  IntColumn get status => integer()(); // scheduled, fired, done, cancelled
  IntColumn get snoozeCount => integer().withDefault(const Constant(0))();
  IntColumn get taskId => integer().nullable().references(Tasks, #id, onDelete: KeyAction.setNull)();
  IntColumn get blockId => integer().nullable().references(ScheduleBlocks, #id, onDelete: KeyAction.setNull)();
  IntColumn get personId => integer().nullable()();
  /// Stable notification id, so re-scheduling replaces, never duplicates.
  IntColumn get notificationId => integer().unique()();
}

// lib/data/local/drift/tables/people_tables.dart
@DataClassName('PersonRow')
class People extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  TextColumn get relation => text().nullable()();  // "sister", "client"
  TextColumn get phone => text().nullable()();     // from the contact picker only
  TextColumn get email => text().nullable()();
  TextColumn get contactLookupKey => text().nullable()();
}

@DataClassName('PersonDateRow')
class PersonDates extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get personId => integer().references(People, #id, onDelete: KeyAction.cascade)();
  IntColumn get kind => integer()(); // birthday, anniversary, other (R1)
  IntColumn get month => integer().check(month.isBetweenValues(1, 12))();
  IntColumn get day => integer().check(day.isBetweenValues(1, 31))();
  IntColumn get year => integer().nullable()();
  TextColumn get label => text().nullable()();
}

// lib/data/local/drift/tables/list_tables.dart
@DataClassName('ListRow')
class Lists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 60).unique()();
  IntColumn get kind => integer()(); // shopping, errands, packing, custom (R1)
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
}

@DataClassName('ListItemRow')
class ListItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get listId => integer().references(Lists, #id, onDelete: KeyAction.cascade)();
  TextColumn get text => text().withLength(min: 1, max: 200)();
  TextColumn get quantity => text().nullable()();
  BoolColumn get checked => boolean().withDefault(const Constant(false))();
  IntColumn get position => integer()();
  DateTimeColumn get addedAt => dateTime()();
  DateTimeColumn get checkedAt => dateTime().nullable()();
}
```

**Full-text search (v11).** Created in the migration with
`customStatement`, kept in sync by triggers, queried with `MATCH` and
`bm25()`:

```sql
CREATE VIRTUAL TABLE memories_fts USING fts5(
  text, content='memories', content_rowid='id', tokenize='unicode61');
CREATE TRIGGER memories_ai AFTER INSERT ON memories BEGIN
  INSERT INTO memories_fts(rowid, text) VALUES (new.id, new.text); END;
CREATE TRIGGER memories_ad AFTER DELETE ON memories BEGIN
  INSERT INTO memories_fts(memories_fts, rowid, text)
  VALUES ('delete', old.id, old.text); END;
CREATE TRIGGER memories_au AFTER UPDATE ON memories BEGIN
  INSERT INTO memories_fts(memories_fts, rowid, text)
  VALUES ('delete', old.id, old.text);
  INSERT INTO memories_fts(rowid, text) VALUES (new.id, new.text); END;
```

The SQLite bundled by `sqlite3` 3.x must include FTS5 (**Verify**; a probe test creates `CREATE VIRTUAL TABLE t USING fts5(x)`
in an in-memory database and fails CI otherwise).

Other v11–v12 tables, in brief: `external_events` (calendar id, event id,
instance start/end, title, location, attendee count, all-day; unique on
event id + instance start; rebuilt per sync window), `memories` (text,
kind, person id, sensitive flag, source utterance, pinned), `documents`
(title, file name in app storage, MIME type, kind, `expires_on`, OCR text),
`meetings` (title, event or block id, consent time, start/end, transcript
utterance id, summary JSON), `bills` (payee, `amount_minor CHECK >= 0`,
currency, due day, recurrence, paid on, link), `expenses` (time, amount,
currency, category, note, receipt document id), `trips` and `trip_legs`
(kind, depart/arrive, from/to, reference, document id).

---

# Part IV — Capabilities, one by one

Each capability lists what the user says, the functions, the components,
the autonomy default and the tests. "Components" name the Atomic library
pieces from §27.

## 11. Capture and the Inbox

**Capture surfaces:** the ASSIST composer (text or mic); long-press on the
ASSIST tab (push-to-talk straight away); a **Quick Settings tile**
(`TileService`, Kotlin via `android_patches`, opens `/assist?listen=1`);
the **share target** (`ACTION_SEND` text, image, PDF); an inline **reply
action** on the briefing notification (`RemoteInput`, supported by
`flutter_local_notifications`).

```dart
abstract interface class CaptureService {
  /// Stores the utterance, then runs the orchestrator. Anything not
  /// actionable lands in the Inbox as CAPTURED, and goes to the
  /// commitment detector (§5.1) if that is enabled.
  Future<TurnResult> capture(Utterance utterance);
}

final class Utterance {
  const Utterance(this.text, {required this.source, this.language, this.confidence});
  final String text;
  final UtteranceSource source; // typed, voice, share, notificationReply (R1)
  final String? language;       // BCP 47, e.g. en-IN
  final double? confidence;     // speech only
}
```

**The Inbox** is the secretary's desk: everything that needs you, in one
place, in this order:

1. **NEEDS YOU** — confirmations that stopped a turn (destructive).
2. **SUGGESTED** — open proposals, newest first, grouped by source.
3. **CAPTURED** — notes and shares not yet turned into anything.
4. **DONE BY AA · TODAY** — today's ledger rows, each with UNDO.

Functions: `watchInbox() → Stream<InboxState>`, `acceptProposal(id)`,
`dismissProposal(id, {bool never = false})`, `snoozeProposal(id, until)`,
`convertCapture(id, as: CaptureTarget)`.

Components: `ProposalCard`, `ActivityRow`, `SourceQuote` ("YOU SAID ·
09:12"), `AtomicSectionLabel` with counts, `AtomicEmptyState`.

**Gatekeeping (D3):** proposals don't notify one by one. The INBOX tab
shows a Signal count; proposals with a deadline today raise one grouped
notification at most every 2 hours, never inside quiet hours (default
21:30–07:30) or during focus.

Tests: accept re-validates (a deleted task makes the proposal fail with
"No longer possible"); dedupe keys block duplicates; "never" stops the
scanner from proposing it again.

## 12. Time: calendar, scheduling, focus protection

**12.1 Phone calendars.** AA reads the calendars already synced on the
phone through Android's Calendar Provider (`CalendarContract.Instances`),
which needs `READ_CALENDAR` and no OAuth, cloud project or server. This
**replaces docs/04 Phase 6** (Google OAuth): it works with any account the
phone syncs (Google, Exchange, Samsung) and removes the owner's
credentials prerequisite.

```dart
abstract interface class CalendarAdapter {
  Future<List<PhoneCalendar>> calendars();
  Future<List<PhoneEvent>> instances({
    required DateTime from, required DateTime to, required Set<int> calendarIds});
  /// Opens the phone calendar's own editor (no write permission needed).
  Future<void> insertViaIntent(EventDraft draft);
}
```

Implementation: a small Kotlin `MethodChannel('aa/calendar')` added by
`android_patches` (fewer dependencies), or `device_calendar_plus`
(**Verify** maintenance and its open issue on `READ_CALENDAR` for the
create modal). `SyncPhoneCalendar` copies the next 14 days into
`external_events` on resume; Today shows them as locked blocks; the
conflict checker sees them.

**12.2 Free time.** `findFreeSlots({day, busy, workHours, minMinutes})` →
`List<TimeSlot>` (pure; busy = blocks + events + focus sessions).

**12.3 Plan my day.** `planDay(tasks, slots, rules) → DayPlan`: greedy by
due date, then priority, then age; estimates from the task (default 30
min); never splits a task below 25 min; leaves a 10-minute buffer after
meetings. Output is a preview list (ASSIST or the morning briefing);
APPLY creates blocks and assigns tasks as one ledger group; one UNDO.

**12.4 Re-plan when the day slips.** When a block ends with open tasks,
the `blockEndedWithOpenTasks` scanner proposes "Move *Draft Q2 plan* to
16:00?" using the next free slot; at the evening shutdown, "Move 3
unfinished tasks to tomorrow?".

**12.5 Protect focus.** During a focus session AA can switch Do Not
Disturb on and off (`NotificationManager.setInterruptionFilter`, which
needs the user to grant notification-policy access in system settings;
Kotlin channel `aa/dnd`). Focus blocks can be **flexible** (a new
`is_flexible` column, v9): when an event lands on one, AA moves it inside
its allowed window, as Reclaim does, and logs it.

Autonomy: moves and plans of AA's own blocks are `reversible`; anything in
a shared calendar is a hand-off (the phone's calendar editor opens).

## 13. Reminders and follow-ups

**Scheduling:** `flutter_local_notifications` `zonedSchedule`. Exact
timing needs `SCHEDULE_EXACT_ALARM`, which is off by default on Android 14+
for new installs; AA asks once with a reason and falls back to
`inexactAllowWhileIdle` (and says "may be a few minutes late") if refused.
`USE_EXACT_ALARM` is reserved by Play for alarm and calendar apps
(**Verify** whether AA qualifies before using it). Only the next 14 days
(at most 64 notifications) are scheduled; the rest are topped up on
resume, which also covers OEM limits.

**Actions on the notification:** DONE · SNOOZE 10 MIN · TOMORROW · OPEN.
They run in the background isolate (`onDidReceiveBackgroundNotificationResponse`,
a top-level function that opens the database, applies the change with a
ledger row and closes). The handler is a pure function of (action,
reminder) → writes, unit-tested without a device.

**Reboots and time zones:** the plugin's boot receiver restores scheduled
notifications; a time-zone change re-schedules *floating* reminders (§10).

**13.4 Follow-ups (D2 "chase").** "Follow up with Ravi on the invoice if
he hasn't replied by Friday" → `create_follow_up(person: Ravi, about:
invoice, wait_until: Fri 10:00, channel: whatsapp)`. At that time:
notification "Ravi · invoice · no reply marked" with **DRAFT NUDGE**
(opens §14's draft sheet) and **REPLIED** (closes it). Shutdown lists open
follow-ups.

Components: `ReminderRow`, `FollowUpCard`, `AtomicTimestamp`,
`SnoozePicker` (segmented: 10M · 1H · TONIGHT · TOMORROW).

## 14. Communication drafts and hand-offs

```dart
// lib/domain/assistant/hand_off.dart — pure Dart.
sealed class HandOff { const HandOff(); }
final class ComposeSms extends HandOff { const ComposeSms(this.to, this.body); final String to, body; }
final class ComposeEmail extends HandOff {
  const ComposeEmail(this.to, this.subject, this.body);
  final String to, subject, body;
}
final class ComposeWhatsApp extends HandOff { const ComposeWhatsApp(this.phone, this.text); final String phone, text; }
final class Dial extends HandOff { const Dial(this.number); final String number; }
final class Navigate extends HandOff { const Navigate(this.query); final String query; }
final class InsertPhoneEvent extends HandOff { const InsertPhoneEvent(this.draft); final EventDraft draft; }
final class SetPhoneAlarm extends HandOff {
  const SetPhoneAlarm(this.hour, this.minute, this.label);
  final int hour, minute; final String label;
}
final class OpenLink extends HandOff { const OpenLink(this.uri); final Uri uri; }
```

| Hand-off | Android mechanism | Permission |
|---|---|---|
| SMS | `smsto:<n>?body=` (`ACTION_SENDTO`) | none |
| Email | `mailto:` with subject/body | none |
| WhatsApp | `https://wa.me/<digits>?text=` | none |
| Call | `tel:` with `ACTION_DIAL` (never `ACTION_CALL`) | none |
| Navigate | `geo:0,0?q=` | none |
| Phone calendar | `ACTION_INSERT` on `CalendarContract.Events` with extras | none |
| Alarm | `AlarmClock.ACTION_SET_ALARM` | `SET_ALARM` (normal) |

URI hand-offs use `url_launcher`; extras-based ones use a Kotlin channel
(`aa/intents`) or `android_intent_plus` (**Verify**). Android 11+ package
visibility needs `<queries>` entries for `smsto`, `mailto`, `tel`, `geo`,
`https` — added by `android_patches`, with a test.

**Drafts in your voice:** `draftMessage(intent, person, tone)` sends the
request plus up to 3 *approved* samples of the user's own writing (saved
in Memory as `writingSample`, never collected silently). The draft opens
in `DraftSheet`: editable text, channel segmented control, recipient row,
primary button "OPEN IN WHATSAPP" (the verb names the app). The ledger
records `handedOff`; there is nothing to undo because nothing was sent.

## 15. People and dates

People come from manual entry or **one contact at a time** through the
system contact picker (`ACTION_PICK`, no `READ_CONTACTS` permission).
A person has: name, relation, phone/email (from the picker), dates,
notes (memories with `person_id`), gift ideas (a list per person), open
follow-ups and last contact (from hand-offs).

Dates: reminders 7 days and 1 day before at 09:00 (configurable); the
`upcomingDates` scanner adds the gift idea and two hand-offs: DRAFT WISHES
and OPEN GIFT LINK (a link the user saved). Feb 29 birthdays fire on
Feb 28 in non-leap years (tested).

Components: `PersonCard`, `PersonHeader` (pixel-style initials tile, per
the design's square avatars), `DateRow`, `GiftIdeaList`.

## 16. Meetings

**Prep.** `meetingWithoutPrep` → proposal: a 15-minute prep block before
the meeting and a **brief**: `MeetingBrief.build(event, tasks, people,
memories, pastMeetings)` (pure): time, place, attendees matched to People
by name/email, related open tasks (FTS on title words), notes about the
attendees, last meeting with the same title and its action items. An AI
summary of the brief is optional.

**Meeting mode (consent first).**

1. User taps START NOTES on the meeting card.
2. Consent sheet: "Everyone in this meeting knows it's being transcribed"
   (checkbox required), a one-line legal note for the user's region
   (§3.5), and an optional spoken notice AA can play.
3. Foreground service (microphone type) with a persistent notification and
   STOP; on-device live transcription (Vosk); audio not kept unless the
   setting says so; hard stop at 2 hours.
4. On stop: optional Whisper pass for accuracy (on-device), then
   extraction (`format: json`, schema: decisions, action items with owner
   me/other, follow-ups) → proposals: tasks for my items, follow-ups for
   others, a drafted recap message (hand-off).

Tests: consent is required to start (widget test); the extraction parser
rejects items without text and clamps due dates (R16).

## 17. Lists, errands, household

"Add milk, eggs and bread to shopping" → the quick parser splits on
commas and "and"/"aur", trims, and de-duplicates against unchecked items
(case-insensitive). Unknown list names are created only after a
confirmation chip ("Create list *Hardware*?"). Default lists on first run:
SHOPPING, ERRANDS, PACKING.

**Household chores (D6)** are **repeating tasks**: v9 adds
`tasks.recurrence` (the same `RecurrenceRule` blocks use). Completing a
repeating task stores the completion and moves `due_at` to the next
occurrence in one transaction (undo restores both).

Errands appear in the Saturday-morning briefing and the shutdown; AA keeps
no location history, so there are no "when I'm near" triggers.

Components: `ListCard` (title, mono counter "3 / 9"), `ChecklistRow`
(checkbox, strikethrough when done), `QuickAddField`.

## 18. Money: bills and receipts

AA **never moves money** (§6.1). It makes sure nothing is late and keeps
the record.

- **Bills:** payee, amount, currency, due day, repeat (monthly by
  default), an optional link to the biller's page. Reminders 3 days
  before and on the day at 10:00, with **PAID** on the notification.
  `billDue` proposals in the briefing. An optional UPI hand-off is an
  owner decision (§39), default off.
- **Expenses:** "spent 450 on lunch" → `log_expense(45000 minor units,
  INR, food)`; the parser understands `₹`, `rs`, `rupees`, `k`.
- **Receipts:** a photo or share → on-device OCR (ML Kit text recognition,
  `google_mlkit_text_recognition`, **Verify**) → a heuristic parser for
  total, date and merchant → an editable proposal. The image is kept as a
  document (§20).
- **Review:** month totals by category in REVIEW, exported with the
  existing CSV/JSON export (§21).

## 19. Travel and logistics

Paste or share a confirmation (SMS, email text, PDF) → text (OCR or PDF
text) → extraction with a schema (legs: kind, depart, arrive, from, to,
reference) → validation (arrive after depart; within 2 years) → a TRIP
preview → ACCEPT.

**Leave-by reminders:** `leaveBy = depart − buffer(kind) − travelTime`.
Buffers: flight 2 h domestic / 3 h international, train 30 min (Settings).
Travel time comes from what the user tells AA ("it takes me 45 minutes to
the airport", stored as a place preference). No live traffic or flight
status: those need paid APIs (§39). Hand-offs: NAVIGATE, OPEN BOOKING.
Packing: a copy of the PACKING template list per trip.

## 20. Memory and documents

- **Memory:** "remember that Priya is vegetarian" → `remember`. Facts
  have a source and a date and live in **What AA knows** (LIBRARY), where
  each can be edited or forgotten. The model gets only the top 10 relevant
  facts per request (FTS5). Facts flagged **sensitive** (ID-like numbers,
  health, money) are never sent to a cloud provider unless the user
  confirms for that request.
- **Documents:** shared PDFs and images are **copied** into app storage
  (content URIs expire), OCR'd, indexed in `documents_fts`, and scanned for
  "valid until / expiry / expires on" dates → `documentExpiring` reminders
  60/30/7 days before. "Where's my car insurance?" opens it. Documents are
  excluded from Android backup (existing backup rules).
- **At rest:** app-private storage under Android file-based encryption.
  SQLCipher is an owner decision (§39), to revisit before documents ship.

## 21. The daily rhythm

```dart
// lib/domain/assistant/briefing.dart — pure Dart, typed, worded by l10n.
final class Briefing {
  const Briefing({required this.kind, required this.day, required this.sections});
  final BriefingKind kind; // morning, checkIn, shutdown, weekly (R1)
  final DateTime day;
  final List<BriefingSection> sections;
}
sealed class BriefingSection { const BriefingSection(); }
// AgendaSection(events, firstAt), TopTasksSection(tasks), DueSection(bills,
// dates, documents), ProposalsSection(count), DoneSection(tasks, focusMinutes),
// ActionsByAaSection(entries), TomorrowSection(firstEvent, moved), …
Briefing buildBriefing(BriefingKind kind, DayFacts facts);
```

| Moment | Default | Contents | One-tap actions |
|---|---|---|---|
| **Morning** | 07:30 | Day load, first event, top 3 tasks, what's due (bills, dates, documents), proposals count | PLAN MY DAY · OPEN INBOX |
| **Check-in** | 13:00 (off by default) | Done so far, what slipped, next free slot | RE-PLAN AFTERNOON |
| **Shutdown** | 18:30 | Done today, AA's actions today (UNDO each), unfinished → tomorrow, open follow-ups, tomorrow's first event | MOVE UNFINISHED TO TOMORROW |
| **Weekly review** | Sunday 18:00 | Focus stats (existing insights), completed vs planned, slipped twice, pattern proposals, next week's dates and bills | EXPORT · OPEN REVIEW |

Each is a notification that opens a full-screen `BriefingScreen` (§29),
and can be read aloud (TTS, §22.4). Spoken scripts come from the same typed
sections.

---

# Part V — Voice

## 22. Listening modes, engines, the foreground service

### 22.1 Modes (each a separate opt-in)

| Mode | How it starts | When it stops | Needs |
|---|---|---|---|
| **Push-to-talk** (default) | Mic button, long-press ASSIST, QS tile, notification SPEAK | End of speech (VAD) or tap | `RECORD_AUDIO` |
| **Conversation** | Toggle on the ASSIST screen | 30 s of silence, leaving the screen, or tap | same |
| **Hands-free (wake word)** | Settings → Voice, started from the visible app | STOP on the notification, or the toggle | + microphone foreground service, `POST_NOTIFICATIONS` |
| **Meeting notes** | START NOTES on a meeting, after consent (§16) | STOP, or 2 h | + microphone foreground service |

### 22.2 State machine (pure Dart, table-tested)

```dart
// lib/domain/assistant/voice_state.dart
sealed class VoiceState { const VoiceState(); }
final class VoiceIdle extends VoiceState { const VoiceIdle(); }
final class VoiceListening extends VoiceState {
  const VoiceListening({this.partial = '', required this.mode});
  final String partial; final VoiceMode mode;
}
final class VoiceThinking extends VoiceState { const VoiceThinking(this.text); final String text; }
final class VoiceSpeaking extends VoiceState { const VoiceSpeaking(this.reply); final String reply; }
final class VoiceError extends VoiceState { const VoiceError(this.kind); final VoiceErrorKind kind; }
// VoiceErrorKind: noPermission, noEngine, noSpeech, network, busy, modelMissing (R1)

sealed class VoiceEvent { const VoiceEvent(); }
// Start(mode), Partial(text), Final(text, confidence), Silence, Reply(text),
// SpeechDone, Stop, Failed(kind)

VoiceState reduce(VoiceState state, VoiceEvent event);
```

Rules in the reducer: `Final` with confidence < 0.6 (or a destructive
intent) goes to an **edit-before-acting** step showing the transcript; any
tap on the mic during `VoiceSpeaking` stops speech and listens (barge-in);
conversation mode returns to `VoiceListening` after `SpeechDone`.

### 22.3 Speech-to-text engines

```dart
abstract interface class SpeechEngine {
  SpeechEngineId get id; // platform, vosk, whisper (R1)
  Future<bool> isReady(String languageTag);
  Stream<SpeechEvent> listen(SpeechConfig config); // partials, final, errors
  Future<void> stop();
}
```

| Engine | Package | Use | Privacy |
|---|---|---|---|
| Platform recognizer | `speech_to_text` | Default for push-to-talk until an on-device model is downloaded | May send audio to the recognizer's service; disclosed in Settings |
| Vosk | `vosk_flutter_service` (**Verify** maintenance) | On-device live recognition: conversation, hands-free commands, meeting live text | On device |
| Whisper | `whisper_kit` / whisper.cpp (**Verify**) | After-the-fact accuracy pass for meetings and long notes | On device |

Settings → Voice → Recognition: **Private** (on-device only; downloads the
Vosk model for the chosen language on consent, SHA-256 checked) or
**Fastest available**. Models are never bundled in the APK.

### 22.4 Speaking back

`flutter_tts` (platform voices, on-device). "Speak replies": OFF · WHEN I
SPOKE (default) · ALWAYS. Every spoken reply is also shown as text
(captions). Rate and voice in Settings. Short earcons and a haptic tick
mark start and stop of listening.

### 22.5 Hands-free: wake word in a foreground service

Android rules (§3.1) shape it: the service is **started from the visible
app**, declares `foregroundServiceType="microphone"`, shows a persistent
notification ("AA is listening for 'Hey Atomic' · STOP"), and is **not**
sticky: if the system kills it, AA posts "Hands-free stopped. Tap to
resume." instead of trying to restart in the background (which would fail
the while-in-use check).

Two candidate implementations; **Phase J starts with a 2-day spike** that
measures both on a mid-range device and picks one:

| | A. Kotlin service | B. Dart service |
|---|---|---|
| Service | `AaListeningService` written in Kotlin, added by `android_patches` | `flutter_foreground_task` with microphone type (**Verify**) |
| Wake word | openWakeWord Kotlin port + ONNX Runtime | ONNX Runtime from Dart (**Verify** package) |
| After detection | Kotlin records the command, Vosk (Kotlin) transcribes, the text goes to Dart over an `EventChannel` | All in a Dart isolate |
| Trade-off | More native code, best battery | One language, heavier |

Targets for the spike (owner's device): false accepts < 1 per 10 h of TV
audio, misses < 10%, battery < 3%/h idle listening. The wake phrase is an
owner decision (§39); a custom openWakeWord model is trained offline and
shipped as an asset (Apache-2.0).

### 22.6 Languages

v1: **en-IN** with Hinglish keywords in the quick parser (§9.8); hi-IN
recognition through the platform engine or the Vosk Hindi model. The
model prompt states that the user may mix Hindi and English. UI strings
stay English in v1 (l10n is ready for Hindi; Devanagari needs a Noto
fallback font, already noted in docs/04).

### 22.7 Code shape

`VoiceController` (keepAlive notifier) owns the engine, applies `reduce`,
hands finals to `CaptureService`, and drives TTS. The UI watches
`voiceStateProvider` only. Tests inject a `FakeSpeechEngine` that emits
scripted partials and finals, which is also how the emulator integration
test exercises voice without a microphone.

---

# Part VI — The Atomic UI/UX reconstruction

## 23. What the design system says (extraction)

`docs/design-system/atomic-design-system.md` is the source of truth. The
rules AA implements, numbered so code reviews and tests can cite them:

| # | Rule | System § |
|---|---|---|
| U1 | Ink `#15171B` on paper `#F4F5F1`; white cards for things you act on, surface `#EDEEE8` panels for groups and settings | 1, 3.1, 3.7 |
| U2 | **One accent**, Signal `#3A2FF0`, under ~5% of a screen; `#8F88FF` on ink, never Signal text on ink | 1, 3.3, 3.6 |
| U3 | Hard offset shadows, 0 blur (2–8 px); a card has a shadow **or** a priority border, never both | 6.3, 9.3 |
| U4 | Radius 4 by default, 6 for content cards, pill for chips, 28 for sheet tops; nothing in between | 6.1 |
| U5 | Borders: 1 line / 1 ink rule / 1.5 ink structure / 2 ink controls / 2 Signal selected / 2 error danger | 6.2 |
| U6 | Display Bebas Neue UPPERCASE, line-height 0.95–1.05; body Hanken Grotesk; labels JetBrains Mono UPPERCASE with tracking, ≥ 12 sp | 4 |
| U7 | Eyebrow above every section title; split headlines with the accent on the second beat | 4.4 |
| U8 | Numbers that change are monospace; dates ISO `2026-10-04 09:12` | 4.4, 12 |
| U9 | Header with a 1 dp ink divider; bottom bar with **one** ink pill for the active destination | 5.3, 9.6 |
| U10 | One Primary button per view; caps verb + object labels; disabled 40% opacity, no shadow | 9.1 |
| U11 | Loading = mono caps "LOADING…" + optional 2 dp ink bar; no spinners on content | 9.9 |
| U12 | Empty = surface module, one sentence, a next step | 9.9 |
| U13 | Destructive confirm states the effect with the target and numbers | 9.9, 12 |
| U14 | Success = words with real numbers + Signal check; no green | 3.4, 9.9 |
| U15 | Motion 120/150/200/350/500 ms, ease, no bounce, reduced motion respected | 8 |
| U16 | Material Symbols Outlined only; one icon style per surface; no emoji as icons | 7.1 |
| U17 | Touch targets ≥ 48 dp even when the visual is smaller | 5.3, 11 |
| U18 | Uppercase applied by style, not typed caps, so screen readers read words | 11.7 |
| U19 | Never colour alone: pair with text or shape | 11.4 |
| U20 | Dark theme: ink background, `#1E2026` cards, paper text, `signal-light` accent, Signal fills keep white text | 13.9 |

**Where the system is silent** (AA must derive from the principles):
the focus timer dial, the day timeline, chat messages, charts, the voice
listening state, proposal cards. §27 specifies each.

## 24. Audit of the current UI

Measured on the code at `aaf9fbf` (counts from `grep` over
`lib/features`, `lib/shared_widgets`, `lib/app.dart`).

### 24.1 Findings

| Area | Today | Problem against the system | Verdict |
|---|---|---|---|
| Theme (`core/theme/app_theme.dart`) | Flowline Focus tokens: indigo `#3525CD` primary, 30-odd scheme colours, cards radius 16, buttons 12, sheets 24, inputs 8 | Not the Atomic palette; soft radii forbidden by U4 | **Replace** |
| Semantic colours (`AtomicSemanticColors`) | Slate/amber/red priority, slate/indigo/emerald status, indigo/cyan/violet session types, red/green/rose feedback | Seven extra hues break "one accent" (U2) and add green success (U14) | **Replace** with typed tags (§25 DS-4…6) |
| Fonts | Space Grotesk + Inter, bundled | Wrong families (U6) | **Replace** (bundle the Atomic three) |
| Magic numbers | 17 hard-coded radii, 50 `EdgeInsets` literals, 96 `SizedBox` literals, 1 duration | No tokens; drift inevitable | **Refactor** to tokens + guard rails (§35) |
| Buttons | 6 Elevated, 4 Filled, 13 Outlined, 16 Text, 20 Icon, 1 FAB | No primary/secondary hierarchy; no hard shadow, no pressed translate | **Replace** with `AtomicButton` variants |
| Loading | 20 `CircularProgressIndicator`s in 14 files | U11 | **Replace** with `AtomicLoading` |
| Icons | 68 distinct Material Icons; filled (`play_arrow`, `check_circle`, `delete`, `bolt`, `bar_chart`, `local_fire_department`, `auto_awesome`) mixed with 41 outlined and 3 rounded | U16 | **Replace** with an `AtomicIcons` registry, one style |
| Lists | 21 `ListTile`, 1 `SwitchListTile` | Material density and typography | **Refactor** into `AtomicSettingsRow` / `AtomicListRow` |
| Cards | 19 `Card(` | Radius 16, no hierarchy between content and panels | **Refactor** into `AtomicCard` variants |
| Chips | 12 `Chip(`, `ChoiceChip`, `FilterChip`, `PriorityChip`, `StatusChip` | Colour-coded; not mono pills | **Replace** with `AtomicChip`, `AtomicTag`, `AtomicStatusPill` |
| Segmented | 4 `SegmentedButton` | Material shape | **Restyle** via theme → `AtomicSegmented` |
| Dialogs | 2 `AlertDialog`, `confirm_dialog.dart` | Doesn't state numbers or effect consistently | **Redesign** as `AtomicConfirmSheet` (U13) |
| Sheets | 12 `showModalBottomSheet` calls in 9 files, each with its own header and padding | Duplicated structure | **Refactor** into `showAtomicSheet` |
| Motion | One animation; no reduced-motion handling | U15 | **Add** `AtomicMotion` |
| Semantics | 5 `Semantics(` widgets; labels exist on icon buttons (Phase 1.11) | Uppercase will need semantics labels (U18) | **Preserve + extend** via `AtomicText` |
| Navigation | `NavigationBar`: Today · Focus · Assistant · Insights; rail on wider windows; Settings from the header | Material indicator; IA lacks Inbox and Library | **Redesign** (§28) |
| Dates | `formats.dart` locale formats ("Mon, Oct 4") | U8 wants ISO in labels | **Refactor** formats (§25 DS-3) |
| Dark theme | Exists, old palette | U20 | **Replace** |

### 24.2 Preserve (works, keep as is)

MVVM with Riverpod view models; `runAction` + busy flags; `ErrorView`'s
behaviour (retry, typed messages); l10n through `context.l10n`; the
`WindowSizeClass` adaptive layout; the timer and timeline *logic*
(`timer_ring.dart` geometry, `day_timeline.dart` layout maths); the golden
harness (light/dark × 1x/2x text); accessibility labels added in Phase 1.

### 24.3 Duplicated, inconsistent, fragile

- **Duplicated:** sheet headers (9 files); "section title + divider"
  (Today, Insights, Settings, Task detail each build their own); empty
  states (`EmptyState` plus inline variants); priority/status display in
  `task_card.dart`, `task_detail_screen.dart` and the chips.
- **Inconsistent:** primary action style per screen (Elevated on forms,
  Filled on Focus, FAB on Today); padding of 12/16/20/24 around similar
  content; icon styles.
- **Fragile:** colours chosen at call sites via `Theme.of(context)
  .colorScheme.x` with no semantic meaning (a palette change silently
  changes meaning); text sizes set inline in a few widgets, which fails at
  200% text scale; spacing literals inside `Row`s that overflow first at
  large text.

### 24.4 Per-screen verdict

| Screen | Keep | Change |
|---|---|---|
| Today | Timeline logic, unscheduled backlog, filters | Header + title row + day-load bar; blocks as white cards with mono times; tasks with tags not colours |
| Task detail | Sections, subtasks reorder, session history | Display title, fact rows, Atomic checkboxes, danger zone for delete |
| Task / block forms | Validation, recurrence | Labels above, 2 dp ink inputs, one primary |
| Focus | Wall-clock timer, summary sheet | Dial in ink/Signal, Display hero time in mono digits, controls as Atomic buttons |
| Assistant | Streaming, Stop | Becomes ASSIST: chat + voice + tool results as cards |
| Insights | Stats, chart | Becomes REVIEW: stat tiles, restyled chart, weekly review |
| Settings | Groups | Atomic settings rows, "on" cards, danger zone |
| Onboarding | Flow | New content: meet AA, autonomy, voice, provider |

## 25. Decisions where the app and the system meet

| # | Decision | Why |
|---|---|---|
| DS-1 | Keep **Signal `#3A2FF0`** as AA's accent | AA is a family product; §15 allows a swap but nothing requires it (owner may override, §39) |
| DS-2 | **Bundle** Bebas Neue, Hanken Grotesk (400/500/700) and JetBrains Mono (400/500/700) as OFL assets; no `google_fonts` runtime fetch | Local-first, offline, deterministic goldens |
| DS-3 | Labels and timestamps in ISO + 24 h mono (`2026-10-04 · 09:12`); prose may say "Thursday" | U8; a 12 h option is an owner decision |
| DS-4 | **Priority** as a tag, not a colour: HIGH = ink fill + paper text; MED = ink outline; LOW = line outline + slate text | U2, U19 |
| DS-5 | **Status**: todo = empty checkbox; in progress = Signal dot + "NOW"; done = Signal checkbox + slate strikethrough | System §9.5 checkbox spec |
| DS-6 | **Session type**: focus = Signal ring; breaks = ink ring; the label says which | U2 |
| DS-7 | Reuse the **energy bar** as **DAY LOAD** (planned ÷ available minutes): < 10% plum, 10–79% Signal, ≥ 80% orange; the number is always shown | System §9.8 thresholds; "show the real state" |
| DS-8 | Overdue = `error` text + "OVERDUE" tag | U19 |
| DS-9 | Chat: user messages ink cards with paper text, right-aligned; AA messages white cards with a 1 px line border; radius 4; mono timestamps | Derived from cards (U3, U4) |
| DS-10 | Charts (`fl_chart`): Signal bars for focus, ink axes, line grid, mono labels, no gradients or rounded bars | U2, U3 |
| DS-11 | The **atom mark** is AA's listening indicator: electrons orbit while listening (ambient motion); reduced motion = static mark + "LISTENING" | System §2.2, §8 |
| DS-12 | No mascot in v1 (Atomi is Atomic Notes'); owner decision | §39 |
| DS-13 | Material 3 stays the base (`useMaterial3: true`) with every component theme set from tokens; custom widgets only where M3 can't express it (hard shadows, ink pill nav, pressed translate) | Less code, platform behaviours kept |
| DS-14 | App button labels in Display 18–20 sp (system §9.1, app column); small pill buttons in mono | System |
| DS-15 | Mono labels are upper-cased at render time by `AtomicText.mono`, which passes the original string as `semanticsLabel`. Display text is **not** transformed: Bebas Neue's lower-case letters are capital shapes, so it already reads as capitals and screen readers get the words as written | U18 (Flutter has no text-transform). Changed during Phase A |
| DS-16 | Dark theme: Material's `primary` is signal-light with ink on it (6.1:1), because Material uses `primary` for both text and fills and Signal fails as text on ink. Atomic components that need a Signal *fill* with white text read `palette.accent` | U2, U20. Added in Phase A |
| DS-17 | Icons use Flutter's built-in outlined Material Icons behind `AtomicIcons`; the move to Material Symbols (`material_symbols_icons`) is one file when the package is verified | U16. Added in Phase A |

## 26. Tokens as code

All in `lib/design/tokens/`. Nothing outside `lib/design/` may contain a
colour, radius, padding, gap, duration or font literal (§35 guard rails).

```dart
// lib/design/tokens/atomic_colors.dart — raw palette (system §3, §14.3).
abstract final class AtomicColors {
  static const ink = Color(0xFF15171B);
  static const inkDeep = Color(0xFF0B0C0E);
  static const paper = Color(0xFFF4F5F1);
  static const white = Color(0xFFFFFFFF);
  static const surface = Color(0xFFEDEEE8);
  static const raised = Color(0xFFF9FAF4);
  static const textBody = Color(0xFF2B2E34);
  static const slate = Color(0xFF45474B); // slate-app
  static const line = Color(0xFFC6C6CB);
  static const track = Color(0xFFE8E9E3);
  static const signal = Color(0xFF3A2FF0);
  static const signalHover = Color(0xFF2A20C9);
  static const signalDeep = Color(0xFF1D14A0);
  static const signalLight = Color(0xFF8F88FF);
  static const signalMist = Color(0xFFD8D6FF);
  static const error = Color(0xFFBA1A1A);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);
  static const energyHigh = Color(0xFFEB7D00);
  static const energyLow = Color(0xFF601D49);
  static const darkCard = Color(0xFF1E2026); // §13.9
  static const scrim = Color(0x8A000000);    // black 54%
}

// lib/design/tokens/atomic_palette.dart — semantic roles per theme.
// Widgets read roles, never raw colours.
@immutable
final class AtomicPalette {
  const AtomicPalette({
    required this.background, required this.card, required this.panel,
    required this.raised, required this.text, required this.textMuted,
    required this.rule, required this.hairline, required this.accent,
    required this.onAccent, required this.accentText, required this.danger,
    required this.dangerContainer, required this.onDangerContainer,
    required this.shadow, required this.inverse, required this.onInverse,
    required this.track,
  });
  final Color background, card, panel, raised, text, textMuted, rule,
      hairline, accent, onAccent, accentText, danger, dangerContainer,
      onDangerContainer, shadow, inverse, onInverse, track;

  static const light = AtomicPalette(
    background: AtomicColors.paper, card: AtomicColors.white,
    panel: AtomicColors.surface, raised: AtomicColors.raised,
    text: AtomicColors.ink, textMuted: AtomicColors.slate,
    rule: AtomicColors.ink, hairline: AtomicColors.line,
    accent: AtomicColors.signal, onAccent: AtomicColors.white,
    accentText: AtomicColors.signal, danger: AtomicColors.error,
    dangerContainer: AtomicColors.errorContainer,
    onDangerContainer: AtomicColors.onErrorContainer,
    shadow: AtomicColors.ink, inverse: AtomicColors.ink,
    onInverse: AtomicColors.paper, track: AtomicColors.track,
  );

  static const dark = AtomicPalette(
    background: AtomicColors.ink, card: AtomicColors.darkCard,
    panel: AtomicColors.darkCard, raised: AtomicColors.darkCard,
    text: AtomicColors.paper, textMuted: Color(0xFF9FA1A0), // paper 62%
    rule: Color(0x4DF4F5F1), hairline: Color(0x29F4F5F1),  // 30% / 16%
    accent: AtomicColors.signal, onAccent: AtomicColors.white,
    accentText: AtomicColors.signalLight, danger: Color(0xFFFF8A80),
    dangerContainer: AtomicColors.onErrorContainer,
    onDangerContainer: AtomicColors.errorContainer,
    shadow: AtomicColors.signal, // "on dark backgrounds the shadow is Signal"
    inverse: AtomicColors.paper, onInverse: AtomicColors.ink,
    track: Color(0x29F4F5F1),
  );
}

// lib/design/tokens/atomic_space.dart — the bold steps of system §5.1.
abstract final class AtomicSpace {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const s = 12.0;
  static const m = 16.0;
  static const l = 22.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const x3l = 44.0;
  static const x4l = 56.0;
  static const x5l = 74.0;
  // Named uses.
  static const screenMargin = m;
  static const cardPadding = m;
  static const rowGap = s;
  static const chipGap = xs;
  static const iconLabelGap = 6.0; // system: 6–9
}

abstract final class AtomicRadius {
  static const xs = 3.0;
  static const sm = 4.0;
  static const md = 6.0;
  static const lg = 8.0;
  static const sheet = 28.0;
  static const pill = 999.0;
}

abstract final class AtomicStroke {
  static const hair = 1.0;
  static const rule = 1.0;
  static const structure = 1.5;
  static const control = 2.0;
  static const selected = 2.0;
  static const danger = 2.0;
  static const priority = 4.0;
}

/// Hard offset shadows: a solid copy of the shape, no blur (system §6.3).
abstract final class AtomicShadow {
  static const offsets = [0.0, 2.0, 3.0, 4.0, 5.0, 6.0, 8.0];
  static List<BoxShadow> hard(int level, Color color) => [
        BoxShadow(
          color: color,
          offset: Offset(offsets[level], offsets[level]),
          blurRadius: 0,
        ),
      ];
}

abstract final class AtomicSize {
  static const touchTarget = 48.0;
  static const headerHeight = 56.0;
  static const bottomBarHeight = 64.0;
  static const navPill = Size(104, 44);
  static const buttonPrimary = 52.0;
  static const buttonSecondary = 44.0;
  static const chip = 32.0;
  static const iconTile = 40.0;
  static const backButton = 36.0;
  static const icon = 24.0;
  static const iconSmall = 20.0;
  static const unreadDot = 8.0;
  static const progressBar = 8.0;
  static const loadingBar = 2.0;
  static const readingWidth = 640.0;
}

// lib/design/tokens/atomic_type.dart
abstract final class AtomicFonts {
  static const display = 'BebasNeue';
  static const body = 'HankenGrotesk';
  static const mono = 'JetBrainsMono';
}

abstract final class AtomicType {
  static TextStyle _display(double size) => TextStyle(
      fontFamily: AtomicFonts.display, fontSize: size, height: 0.95,
      letterSpacing: 0.5);
  static TextStyle _mono(double size, {double tracking = 1.5, FontWeight w = FontWeight.w500}) =>
      TextStyle(fontFamily: AtomicFonts.mono, fontSize: size,
          letterSpacing: tracking, fontWeight: w);
  static TextStyle _body(double size, {double height = 1.5, FontWeight w = FontWeight.w400}) =>
      TextStyle(fontFamily: AtomicFonts.body, fontSize: size, height: height,
          fontWeight: w);

  // Display (system §4.3, app scale in sp).
  static final hero = _display(48);
  static final screenTitle = _display(40);
  static final pushedTitle = _display(30);
  static final cardTitle = _display(24);
  static final rowTitle = _display(20);
  static final button = _display(20).copyWith(letterSpacing: 0.6);
  // Body.
  static final bodyLarge = _body(16);
  static final body = _body(15);
  static final bodyStrong = _body(15, w: FontWeight.w700);
  // Mono (never below 12 sp, rule U6).
  static final label = _mono(13);
  static final eyebrow = _mono(12, tracking: 2);
  static final caption = _mono(12, tracking: 1);
  static final counter = _mono(12, tracking: 1, w: FontWeight.w400);
  static final number = _mono(16, tracking: 0, w: FontWeight.w700);
}

// lib/design/tokens/atomic_motion.dart
abstract final class AtomicDurations {
  static const press = Duration(milliseconds: 120);
  static const hover = Duration(milliseconds: 150);
  static const toggle = Duration(milliseconds: 200);
  static const enter = Duration(milliseconds: 350);
  static const reveal = Duration(milliseconds: 500);
  static const orbit = Duration(seconds: 34);
  static const reducedFade = Duration(milliseconds: 120);
}

/// Durations for this context: transforms off and short fades only when
/// the OS asks for reduced motion (rule U15).
final class AtomicMotion {
  const AtomicMotion._(this.reduced);
  factory AtomicMotion.of(BuildContext context) =>
      AtomicMotion._(MediaQuery.disableAnimationsOf(context));
  final bool reduced;
  static const curve = Curves.ease;
  Duration get press => reduced ? Duration.zero : AtomicDurations.press;
  Duration get toggle => reduced ? Duration.zero : AtomicDurations.toggle;
  Duration get enter => reduced ? AtomicDurations.reducedFade : AtomicDurations.enter;
  double get slide => reduced ? 0 : AtomicSpace.m; // 16 dp entrance offset
  bool get ambient => !reduced;
}
```

**The theme** (`lib/design/theme/atomic_theme.dart`) builds `ThemeData` for
light and dark from these tokens, following system §14.3 (colour scheme,
text theme, divider, card, filled/outlined buttons, chips, switch, bottom
sheet), and registers an `AtomicThemeData` `ThemeExtension` holding the
palette. Access is `context.atomic.palette`, `context.atomic.motion`.
The old `AppTheme` and `AtomicSemanticColors` are deleted at the end of
Phase C.

A `test/design/contrast_test.dart` computes the WCAG ratio of every
text/background pair the palette allows (both themes) and fails below
4.5:1 (3:1 for display ≥ 24 sp), plus explicit *must-fail* checks that
guard the system's two traps (Signal on ink, orange on paper) from being
used as text roles.

## 27. The component library

`lib/design/components/`, one file per component, each with goldens
(light/dark, 1x/2x text, every state) and a page in a debug-only gallery
route (`/debug/gallery`).

### 27.1 Layers

| Layer | Components |
|---|---|
| **Foundation** | `AtomicThemeData`, `AtomicText` (display/body/mono with semantics), `AtomicIcons` (registry), `HardShadow`, `AtomicPressable` (pressed translate), `AtomicFocusRing`, `AtomicHitTarget` (48 dp), `AtomicGap` (spacing widgets) |
| **Atoms** | `AtomicButton` (primary, solid, ghost, ghostOnDark, lightOnSignal, destructive, text), `AtomicIconButton` (ink square, ghost, signal, destructive), `AtomicChip`, `AtomicTag`, `AtomicStatusPill`, `AtomicBadge`, `AtomicDot`, `AtomicCheckbox`, `AtomicSwitch` (theme), `AtomicTextField`, `AtomicRule` (ink/hair), `AtomicEyebrow`, `AtomicCounter`, `AtomicTimestamp`, `AtomicProgressBar` (thresholds), `AtomicLoadingBar`, `AtomMark` (painter) |
| **Molecules** | `AtomicHeader` (home/pushed), `AtomicTitleRow`, `AtomicSectionLabel`, `AtomicSplitHeadline`, `AtomicSettingsRow`, `AtomicListRow`, `ActivityRow`, `AtomicSegmented`, `AtomicStepper`, `FactRow`, `AtomicEmptyState`, `AtomicErrorState` (`ErrorView` re-skinned), `AtomicWarningBox`, `AtomicLoading`, `UndoSnack` |
| **Organisms** | `AtomicBottomBar`, `AtomicNavRail`, `AtomicSheet` / `showAtomicSheet`, `AtomicInfoSheet`, `AtomicConfirmSheet`, `AtomicDangerZone`, `TaskCard`, `TimelineBlock`, `DayLoadCard`, `ProposalCard`, `BriefingCard`, `TimerDial`, `ChatMessage`, `Composer`, `ListeningPanel`, `PersonCard`, `ListCard`, `ChecklistRow`, `BillRow`, `TripLegRow`, `DocumentTile`, `StatTile`, `ChartFrame`, `DraftSheet` |

### 27.2 Key components in code

```dart
/// Display and mono labels are upper-cased for the eye only: screen
/// readers get the original words (rule U18, decision DS-15).
class AtomicText extends StatelessWidget {
  const AtomicText.display(this.text, {super.key, this.style, this.maxLines})
      : _upper = true, _role = _Role.display;
  const AtomicText.mono(this.text, {super.key, this.style, this.maxLines})
      : _upper = true, _role = _Role.mono;
  const AtomicText.body(this.text, {super.key, this.style, this.maxLines})
      : _upper = false, _role = _Role.body;

  final String text;
  final TextStyle? style;
  final int? maxLines;
  final bool _upper;
  final _Role _role;

  @override
  Widget build(BuildContext context) {
    final base = switch (_role) {
      _Role.display => AtomicType.cardTitle,
      _Role.mono => AtomicType.label,
      _Role.body => AtomicType.body,
    };
    final shown = _upper ? text.toUpperCase() : text;
    return Text(
      shown,
      style: base.merge(style).copyWith(
          color: style?.color ?? context.atomic.palette.text),
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      semanticsLabel: _upper ? text : null,
    );
  }
}

/// A key that goes down when pressed: moves by the shadow's offset and
/// the shadow drops to 0 (system §6.3). Reduced motion: no translate.
class AtomicPressable extends StatefulWidget {
  const AtomicPressable({super.key, required this.child, required this.onTap,
      this.shadowLevel = 2, this.shadowColor, this.radius = AtomicRadius.sm});
  final Widget child;
  final VoidCallback? onTap;
  final int shadowLevel;
  final Color? shadowColor;
  final double radius;
  @override
  State<AtomicPressable> createState() => _AtomicPressableState();
}

class _AtomicPressableState extends State<AtomicPressable> {
  var _down = false;
  @override
  Widget build(BuildContext context) {
    final motion = AtomicMotion.of(context);
    final offset = AtomicShadow.offsets[widget.shadowLevel];
    final enabled = widget.onTap != null;
    final pressed = _down && enabled;
    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _down = true) : null,
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: motion.press,
        curve: AtomicMotion.curve,
        transform: Matrix4.translationValues(
            pressed && !motion.reduced ? offset : 0,
            pressed && !motion.reduced ? offset : 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          boxShadow: !enabled || pressed || widget.shadowLevel == 0
              ? const []
              : AtomicShadow.hard(widget.shadowLevel,
                  widget.shadowColor ?? context.atomic.palette.shadow),
        ),
        child: widget.child,
      ),
    );
  }
}

enum AtomicButtonVariant { primary, solid, ghost, ghostOnDark, lightOnSignal, destructive, text }

class AtomicButton extends StatelessWidget {
  const AtomicButton({super.key, required this.label, required this.onPressed,
      this.variant = AtomicButtonVariant.primary, this.icon, this.busy = false,
      this.expand = true});
  final String label;
  final VoidCallback? onPressed;
  final AtomicButtonVariant variant;
  final IconData? icon;
  /// Shows "WORKING…" and ignores taps (rule R12's busy flag).
  final bool busy;
  final bool expand;
  // build(): fills/borders/shadow from the variant table in system §9.1;
  // height 52 (primary) or 44; Display label 20 sp; 40% opacity when
  // disabled; Semantics(button: true, enabled: …); min 48 dp hit area;
  // focus ring 2 dp Signal (signalLight on ink/Signal fills).
}

/// Section label row: mono label left, optional action right, ink rule.
class AtomicSectionLabel extends StatelessWidget {
  const AtomicSectionLabel(this.label, {super.key, this.count, this.action});
  final String label;
  final int? count;
  final Widget? action;
  @override
  Widget build(BuildContext context) {
    final p = context.atomic.palette;
    return Semantics(
      header: true,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(child: AtomicText.mono(
              count == null ? label : '$label · $count',
              style: AtomicType.label.copyWith(color: p.textMuted))),
          if (action != null) action!,
        ]),
        const SizedBox(height: AtomicSpace.xs),
        Divider(height: AtomicStroke.rule, thickness: AtomicStroke.rule, color: p.rule),
      ]),
    );
  }
}

/// The energy bar, used as DAY LOAD (DS-7). Colour by value; the number
/// is always printed next to it (rule U19).
Color loadColor(double percent) => percent < 10
    ? AtomicColors.energyLow
    : percent >= 80 ? AtomicColors.energyHigh : AtomicColors.signal;
```

`AtomicBottomBar`: paper fill, 1 dp ink top border, four or five
destinations; the active one is an ink pill (104 × 44, radius 4) holding
the icon and a mono caps label in paper; inactive ones are 48 dp icon-only
buttons with `semanticsLabel`; the INBOX icon carries a Signal count
badge; width animates over `motion.toggle`.

`showAtomicSheet({label, child, primary})`: paper fill, 28 dp top corners,
drag handle in slate, 16 dp padding, 54% scrim; Signal mono label + ink
rule → content → full-width primary. All 12 current sheet call sites move
to it.

`ProposalCard`: white card, 1.5 line border, radius 4, no shadow; mono
eyebrow with the source ("FROM YOUR CALENDAR · 2026-10-04 09:12") →
Display title built from the preview ("PREP FOR KICKOFF") → body reason →
optional `SourceQuote` → row: primary-ghost pair "ACCEPT" (solid) and
"DISMISS" (ghost), overflow menu "Don't suggest this again".

### 27.3 Old → new mapping

| Old | New |
|---|---|
| `ElevatedButton` / `FilledButton` (main action) | `AtomicButton.primary` (one per view) |
| `OutlinedButton` | `AtomicButton(variant: ghost)` |
| `TextButton` | `AtomicButton(variant: text)` |
| `IconButton` | `AtomicIconButton` |
| `FloatingActionButton` on Today | Stacked ink "+ TASK" and paper "+ BLOCK" buttons (system §9.6 floating actions) |
| `CircularProgressIndicator` | `AtomicLoading` / `AtomicLoadingBar` |
| `ListTile`, `SwitchListTile` | `AtomicSettingsRow`, `AtomicListRow` |
| `Card` | `AtomicCard.content` / `.panel` / `.dark` / `.selected` |
| `PriorityChip`, `StatusChip`, `Chip` | `AtomicTag`, `AtomicStatusPill`, `AtomicChip` |
| `AlertDialog`, `confirm_dialog.dart` | `AtomicConfirmSheet` |
| `EmptyState` | `AtomicEmptyState` |
| `ErrorView` | `AtomicErrorState` (same API, R14 kept) |
| `NavigationBar` / `NavigationRail` | `AtomicBottomBar` / `AtomicNavRail` |
| `TimerRing` | `TimerDial` (same geometry) |

## 28. Information architecture and navigation

**Today:** four tabs (Today · Focus · Assistant · Insights); Settings from
a header icon. **AA:** five destinations, ordered by how often a
secretary's day uses them:

```
TODAY · INBOX · ASSIST · FOCUS · LIBRARY          (bottom bar, one ink pill)
  │       │        │       │        └ People, Lists, Money, Trips, Documents,
  │       │        │       │          What AA knows, Review
  │       │        │       └ Timer, session summary
  │       │        └ Chat + voice, conversations
  │       └ Needs you, Suggested, Captured, Done by AA → Activity
  └ Day load, timeline, backlog, task/block detail
Header (every top-level screen): listening pill when active · bell (briefings) · settings
```

Why: INBOX gets its own tab because proposals are the "not said" half of
the product; ASSIST sits in the middle (thumb reach, long-press to talk);
Insights becomes **Review** inside LIBRARY plus the weekly notification,
because it's weekly, not hourly.

**Routes** (`go_router`, `StatefulShellRoute` kept):

| Route | Screen |
|---|---|
| `/onboarding` | Onboarding |
| `/today`, `/today/task/:id`, `/today/block/:id` | Today, Task detail, Block detail |
| `/inbox`, `/inbox/activity`, `/inbox/proposal/:id` | Inbox, Activity, Proposal detail |
| `/assist`, `/assist/c/:id`, `/assist/conversations` | Assist (`?listen=1` starts push-to-talk) |
| `/focus` | Focus |
| `/library`, `/library/people[/:id]`, `/library/lists[/:id]`, `/library/money`, `/library/trips[/:id]`, `/library/documents`, `/library/memory`, `/library/review` | Library and its screens |
| `/briefing/:kind` | Briefing (morning, checkin, shutdown, weekly) |
| `/meeting/:id` | Meeting notes |
| `/settings`, `/settings/{assistant,voice,privacy,ai-providers,focus,notifications,appearance,briefings}` | Settings |

Notification deep links map to these routes (the B24 pattern). Predictive
back is on; every pushed screen has the ink back button (36 dp visual, 48
dp hit area).

## 29. Every screen, specified

Template per the brief: **Purpose · Primary user · Primary action ·
Secondary · Layout · Components · States · Navigation · Responsive ·
Motion · Accessibility.** "Standard states" means: loading =
`AtomicLoading` with a specific mono line; empty = `AtomicEmptyState`;
error = `AtomicErrorState` with retry (R14); success = `UndoSnack` with
real numbers. Primary user for every screen is the app's one user, the
owner of the phone; where a screen serves a narrower moment, it says so.

### 29.1 Launch / splash
- **Purpose:** show the brand while the database opens. **Primary action:** none.
- **Layout:** paper background, atom mark centred (Android 12 splash API, patched), nothing else.
- **States:** a migration taking > 1 s shows mono "UPDATING DATA…" under the mark.
- **Motion:** none (system splash). **A11y:** the mark is decorative.

### 29.2 Onboarding (4 steps)
- **Purpose:** explain what AA does and set trust before it acts.
- **Primary action:** CONTINUE (one per step); last step START.
- **Secondary:** SKIP (text action) on optional steps (voice, provider).
- **Layout:** mono "STEP 1 OF 4 · MEET AA" → split headline ("Tell it once. **AA does the rest.**") → body → step content → full-width primary at the bottom.
  1. Meet AA: three fact rows (local-first, acts with undo, you press send).
  2. How much can AA do: `AtomicSegmented` CAREFUL · BALANCED · HANDS-OFF with a live example under it ("You say 'remind me…': AA sets it and shows UNDO").
  3. Voice (optional): microphone permission with the reason; push-to-talk only.
  4. AI provider (optional): pick provider → key → TEST CONNECTION (existing sheet).
- **Components:** `AtomicSplitHeadline`, `FactRow`, `AtomicSegmented`, `AtomicButton`.
- **States:** permission denied → warning box + OPEN SETTINGS; provider test failure → existing typed messages.
- **Navigation:** back between steps; ends at `/today`. **Responsive:** content max 640 dp, centred on tablets.
- **Motion:** step change = fade + 16 dp slide (350 ms); reduced = fade 120 ms.
- **A11y:** step label is a header; segmented options announce their example.

### 29.3 Today
- **Purpose:** what the day holds and what's next. **Primary action:** + TASK. **Secondary:** + BLOCK, PLAN MY DAY, filters, change day.
- **Layout:** home header (ATOMIC eyebrow over Display "TODAY", listening pill, bell, settings) → ink rule → title row: Display date "SAT 04 OCT" with mono counter "3 / 7 DONE" → **DayLoadCard** (dark module: mono "DAY LOAD", Display "72%", bar, mono "5H 10M PLANNED OF 7H 10M") → section TIMELINE (TimelineBlock rows: mono "09:00–10:30", Display title, tasks as ChecklistRows; phone events show a lock icon and the calendar name) → section BACKLOG with `AtomicChip` filters (ALL · HIGH · OVERDUE · NO DATE) → stacked floating buttons.
- **States:** loading "LOADING THE DAY…"; empty day → module "Nothing planned. Add a block or let AA plan from your backlog." + PLAN MY DAY; error → standard; conflict → warning box under the affected block with RESOLVE.
- **Navigation:** task → `/today/task/:id`; block → sheet; PLAN MY DAY → preview sheet.
- **Responsive:** expanded = timeline left, selected task/block detail right.
- **Motion:** bar width 350 ms; checkbox 200 ms. **A11y:** each block reads "09:00 to 10:30, Deep work, 2 tasks, 1 done"; the load bar has a value label.

### 29.4 Task detail
- **Purpose:** everything about one task. **Primary action:** START FOCUS. **Secondary:** edit, mark done, add subtask, delete.
- **Layout:** pushed header ("TASK") → Display title (2 lines) → tags row (priority, status, OVERDUE) → fact rows (DUE, BLOCK, ESTIMATE, REPEATS) → SUBTASKS (reorderable checklist, mono "2 / 5") → SESSIONS (mono rows: date, minutes) → NOTES (body) → danger zone (DELETE TASK → confirm sheet "Delete *Write report* and its 5 subtasks? Undo for 30 days in Activity.").
- **States:** standard; task deleted elsewhere → empty "This task no longer exists." + BACK.
- **Responsive:** right pane on expanded Today. **A11y:** drag handles have labels; reorder also via "move up/down" actions.

### 29.5 Task form (sheet) and 29.6 Block form (sheet + series flow)
- **Purpose:** create/edit. **Primary action:** SAVE TASK / SAVE BLOCK.
- **Layout:** `AtomicSheet` label "NEW TASK" → fields with mono labels above (TITLE, NOTES, PRIORITY segmented, DUE, ESTIMATE stepper, REPEAT) → primary. Block form adds START/END and the existing "this / this and following / all" series flow as a segmented step.
- **States:** inline validation in `error` under the field ("End must be after start."); busy → "SAVING…" in the button.
- **Responsive:** sheet max width 640 on tablets. **A11y:** errors are announced (live region); fields are labelled by their mono labels.

### 29.7 Conflict sheet
- **Purpose:** resolve overlapping blocks. **Primary action:** APPLY SUGGESTION.
- **Layout:** warning box stating the overlap with times → two TimelineBlocks side by side → AA's suggestion as a ProposalCard (existing AI help) → MOVE / SHORTEN / KEEP BOTH.
- **States:** AI unavailable → only manual options, with a one-line reason.

### 29.8 Inbox
- **Purpose:** the secretary's desk (§11). **Primary action:** ACCEPT on the top proposal. **Secondary:** dismiss, snooze, open Activity.
- **Layout:** home header → title row "INBOX" + counter "4" → sections NEEDS YOU, SUGGESTED, CAPTURED, DONE BY AA · TODAY (each with counts; empty sections hidden) → text action "ALL ACTIVITY →".
- **States:** loading "CHECKING…"; empty → "You're clear. AA will put suggestions here." ; proposals paused by the kill switch → warning box "Suggestions are paused." + RESUME.
- **Responsive:** expanded = list + proposal detail. **Motion:** accepted card collapses (200 ms) and an UndoSnack appears.
- **A11y:** each card's actions are exposed as custom semantics actions (accept/dismiss) for TalkBack.

### 29.9 Activity (ledger)
- **Purpose:** everything AA did, with undo. **Primary action:** UNDO on a row.
- **Layout:** pushed header "ACTIVITY" → day groups (mono "2026-10-04") → ActivityRows: icon tile → body title from the preview → mono time and origin ("09:12 · YOU ASKED" / "· FROM CALENDAR") → right: UNDO text action or status ("UNDONE", "HANDED OFF").
- **States:** "Changed since. Not undone." inline on refused undo.

### 29.10 Assist (chat + voice)
- **Purpose:** ask, tell, or talk. **Primary action:** send / hold to talk. **Secondary:** stop, new conversation, provider switch, conversation list.
- **Layout:** header "ASSIST" with provider mono pill ("OLLAMA · LLAMA3") → messages (DS-9); tool results render as compact action cards inside AA's message ("CREATED TASK · Send deck to Priya · DUE FRI 17:00 · UNDO") → Composer: text field (2 dp ink), mic button (ink square; Signal while listening), send (Signal) which becomes STOP while streaming.
- **States:** no provider → info module "Local commands work without AI. Add a provider for the rest." + ADD PROVIDER; streaming → partial text with a 2 dp ink bar; typed AI failures → existing wording + FIX IN SETTINGS; confirmations → AtomicConfirmSheet.
- **Navigation:** conversations list `/assist/conversations`. **Responsive:** expanded = conversation list left.
- **Motion:** new messages fade + 16 dp slide; listening uses DS-11.
- **A11y:** new AA messages announced politely; mic button labelled "Start listening"/"Stop listening".

### 29.11 Listening panel (voice overlay)
- **Purpose:** show that AA hears you and what it understood. **Primary action:** STOP.
- **Layout:** bottom sheet frame on ink (dark module): atom mark (animated) → mono "LISTENING · EN-IN" → live partial transcript in Display 24 → after final: "UNDERSTOOD" + editable transcript when confidence is low → result card.
- **States:** no permission → GRANT MICROPHONE; no speech → "Didn't catch that." + TRY AGAIN; engine missing → DOWNLOAD MODEL (size stated).
- **A11y:** state changes announced; TalkBack users get an earcon and haptic, no visual dependency.

### 29.12 Briefing (morning, check-in, shutdown, weekly)
- **Purpose:** the day's start and end in one screen (§21). **Primary action:** per kind (PLAN MY DAY / RE-PLAN / MOVE UNFINISHED / OPEN REVIEW).
- **Layout:** pushed header → eyebrow "MORNING · 2026-10-04" → split headline ("Five things today. **One that matters.**" from the data) → BriefingCards per section → READ ALOUD (ghost) → primary.
- **States:** nothing to report → one sentence ("A clear day. Nothing due.").

### 29.13 Focus
- **Purpose:** run a focus or break session. **Primary action:** START / PAUSE / RESUME. **Secondary:** skip, stop, pick task, duration.
- **Layout:** home header → mono session label "FOCUS · 1 OF 4" → TimerDial (Signal arc on track, ink ring for breaks) with remaining time in mono digits 56 sp inside → linked task (Display) → controls row: primary + ghost → DND status pill ("DND · ON").
- **States:** idle, running, paused, finished → Session summary sheet; notification permission off → warning box.
- **Responsive:** landscape/expanded = dial left, task and controls right; dial scales (existing).
- **Motion:** arc progress per second without animation (wall-clock truth); reduced motion unaffected.
- **A11y:** remaining time announced each minute, not each second (existing K13 behaviour kept).

### 29.14 Session summary (sheet)
- **Purpose:** record what happened. **Primary action:** SAVE. Fact rows (planned, actual, task), subtask checkboxes, notes.

### 29.15 Library (hub)
- **Purpose:** the long-lived things AA keeps. **Primary action:** open a section.
- **Layout:** title row "LIBRARY" → settings-row list with counts: PEOPLE 12 · LISTS 3 · MONEY · TRIPS 1 · DOCUMENTS 7 · WHAT AA KNOWS 24 · REVIEW.

### 29.16 People and Person detail
- **Purpose:** remember people and dates. **Primary:** + PERSON (picker or manual) / DRAFT MESSAGE.
- **Layout:** list of PersonCards (square initials tile, Display name, mono next date "BIRTHDAY · 10-09"); detail: header, fact rows, DATES, NOTES, GIFT IDEAS, FOLLOW-UPS, hand-off buttons (CALL, MESSAGE).
- **Empty:** "Add the people whose dates you shouldn't miss."

### 29.17 Lists and List detail
- **Primary action:** add item (QuickAddField). **Layout:** ListCards with counters; detail: unchecked first, checked collapsed under "DONE · 4" with CLEAR (destructive confirm stating the count).

### 29.18 Money
- **Primary action:** + BILL / + EXPENSE. **Layout:** segmented BILLS · EXPENSES; bills by due date with tags (DUE IN 3D, PAID); expenses by day with mono amounts "₹ 450.00"; month total stat tile.

### 29.19 Trips and Trip detail
- **Primary action:** ADD FROM CONFIRMATION (paste/share). **Layout:** trip cards; detail with TripLegRows (mono times, Display route "BLR → DEL"), leave-by fact, packing list link, hand-offs.

### 29.20 Documents
- **Primary action:** ADD DOCUMENT (share or pick). **Layout:** search field → DocumentTiles (kind tag, title, mono expiry with OVERDUE/30D tags).

### 29.21 What AA knows (memory)
- **Purpose:** discretion made visible. **Primary action:** edit/forget a fact.
- **Layout:** search → facts grouped by person/kind, each with source and date ("FROM CHAT · 2026-10-02"), SENSITIVE tag where flagged → danger zone FORGET EVERYTHING.

### 29.22 Review (was Insights)
- **Purpose:** how the week went. **Primary action:** EXPORT. **Layout:** segmented WEEK · MONTH → StatTiles (FOCUS 12H 40M, DONE 34 / 41, STREAK 6) → ChartFrame (Signal bars) → SLIPPED list → AA's pattern proposals.

### 29.23 Settings home and sub-screens
- **Layout:** pushed header "SETTINGS" → groups with mono labels: ASSISTANT (autonomy, briefings, suggestions kill switch), VOICE, AI PROVIDERS, FOCUS, NOTIFICATIONS, APPEARANCE, PRIVACY & DATA → AtomicSettingsRows with Signal "→".
- **Assistant:** segmented autonomy with the live example; "On" settings card for SUGGESTIONS with switch; per-scanner switches; quiet hours.
- **Voice:** recognition (PRIVATE / FASTEST), language, speak replies, hands-free (with battery note), wake phrase, model downloads with sizes.
- **Privacy & data:** what each feature sends (fact sheet per feature), transcript retention segmented (7D · 30D · 90D · FOREVER), export, danger zone (DELETE ALL TRANSCRIPTS, DELETE ALL DATA) with effects stated.
- **AI providers / Focus / Notifications / Appearance:** existing behaviour, Atomic components.

### 29.24 Proposal detail / Confirm sheet
- **Purpose:** decide on one action with full context. **Primary:** ACCEPT or the destructive CONFIRM (error-container fill). Shows the preview, the source quote, what changes, and "UNDO AVAILABLE FOR 30 DAYS" when true.

### 29.25 Meeting notes
- **Purpose:** consented transcription and its results (§16). **Primary:** START NOTES → STOP. **Layout:** consent sheet → dark module with timer and live transcript → results: DECISIONS, MY ACTIONS (proposals), FOLLOW-UPS, RECAP DRAFT.
- **A11y:** recording state is always visible and announced; STOP is reachable in one swipe.

### 29.26 Export sheet and Draft sheet
- Export: existing formats as segmented control, date range, EXPORT. Draft: §14.

## 30. Responsive behaviour

| Window class (existing `window_size.dart`) | Navigation | Layout |
|---|---|---|
| Compact < 600 dp | Bottom bar | Single column, 16 dp margins |
| Medium 600–839 | Nav rail with an ink pill (vertical) | Single column, content max 640 dp |
| Expanded ≥ 840 | Nav rail | Two panes: Today ↔ detail, Inbox ↔ proposal, Assist conversations ↔ chat |

Text scale: body follows the OS up to 200% (system §11.6); display styles
clamp at 1.5× so headlines wrap to at most 2 lines instead of one word per
line; rows that hold a title and a trailing control switch to a stacked
layout above 1.3×. Goldens cover 360 × 800 at 1x and 2x text, plus
840 × 1200 for Today, Inbox and Assist.

## 31. Motion

| Token | AA use |
|---|---|
| press 120 | Buttons and pressable cards translate by their shadow offset |
| toggle 200 | Chips, checkboxes, segmented, switch, nav pill width |
| enter 350 | Sheets, page transitions (fade + 16 dp slide), UndoSnack, proposal card insert/remove, DAY LOAD bar width |
| reveal 500 | Briefing cards on first open only |
| ambient 34 s | Atom mark orbit: splash-free, only while listening |

Page transitions use a `CustomTransitionPage` (fade + slide), not
Material's zoom. Reduced motion: `AtomicMotion` removes transforms and
keeps 120 ms fades; the atom is static. A code rule bans
`Curves.elastic*`, `Curves.bounce*` and spring simulations in `lib/`.

## 32. Accessibility

- **Contrast:** the palette test (§26) plus `textContrastGuideline` in
  every screen's widget test.
- **Targets:** `androidTapTargetGuideline` and `labeledTapTargetGuideline`
  in every screen's widget test (48 dp, system §11.3).
- **Uppercase:** `AtomicText` keeps the original words for screen readers
  (U18); a code rule bans `.toUpperCase()` in `lib/features/`.
- **Focus:** keyboard and switch-access focus shows a 2 dp Signal ring
  (`signalLight` on ink/Signal).
- **Not colour alone:** tags carry words; done items are struck through;
  the load bar prints its number.
- **Live regions:** timer (per minute), listening state, streaming reply
  (on completion), UndoSnack.
- **Voice is an accessibility feature:** every action reachable by touch is
  reachable by voice, and the reverse; spoken replies always have captions.
- **Reduced motion and font scale** as above; Android "remove animations"
  respected.

## 33. Performance

Budgets from docs/04 §5.1 stay. Additions:

| Item | Budget / approach |
|---|---|
| Hard shadows | `BoxShadow` with blur 0 draws a rect; no `saveLayer`. A frame test on Today with 30 blocks stays < 8 ms build + raster on CI's profile benchmark (**Verify** device numbers) |
| Fonts | Static weights only (6 files + Bebas); expect ≈ 1 MB added, ≈ 0.6 MB removed (Inter + Space Grotesk) |
| Speech models | Downloaded on demand, never in the APK |
| ONNX Runtime (wake word) | Only if Phase J picks it; adds native size per ABI (**Verify**); release APKs stay split per ABI |
| Orchestrator | Quick parser < 5 ms; context build < 50 ms with 1,000 tasks (benchmark test) |
| Scanners | All scanners < 100 ms with a year of data (indexes on `due_at`, `fire_at`, `status`, `occurrence_date`) |
| Search | FTS5, never `LIKE '%…%'` over memories/documents |
| Background | One pass ≤ 2 s; no wake locks held by AA except the listening service |

## 34. Iconography and brand assets

- **Icons:** Material Symbols **Outlined**, weight 400, grade 0, 24 dp
  optical size, through `material_symbols_icons` (tree-shaken font;
  **Verify** version) behind an `AtomicIcons` registry (`today`, `inbox`,
  `assist`, `mic`, `focus`, `library`, `add`, `send`, `stop`, `back`,
  `close`, `check`, `undo`, `bell`, `settings`, `calendar`, `lock`,
  `person`, `list`, `money`, `trip`, `document`, `memory`, `play`,
  `pause`, `skip`, `edit`, `delete`, `more`, `warning`, `link`, `share`,
  `export`, `call`, `message`, `navigate`). Features may not reference
  `Icons.*` (guard rail).
- **Atom mark:** `AtomMarkPainter` (three Signal ellipses at 0/60/120°,
  ink nucleus, three Signal electrons; stroke widths from tokens); used in
  the splash, the listening state, empty states and the app icon.
- **App icon:** the atom on an ink rounded square; adaptive icon layers
  (foreground atom, ink background) plus a monochrome layer for Android 13
  themed icons. Rendered from the painter by `tool/brand/render_icons.dart`
  (a test-run script writing PNGs) and copied into `res/mipmap-*` by
  `android_patches` (tested).
- **Notification icon:** monochrome atom vector drawable.
- **Wordmark:** "ATOMIC ASSIST" in Bebas Neue; "AA" in small spaces.

## 35. Migration, cleanup and guard rails

**Order:** build `lib/design/` (Phase A), the library and gallery (B),
then migrate screens one per commit, each regenerating its goldens after a
visual review (C). The bottom-bar IA change lands with the Inbox screen
in Phase E (an empty Inbox before the core exists would be dishonest), so
Phase C keeps four tabs re-skinned.

**Guard rails** (`test/code_rules/design_rules_test.dart`), switched from
"report" to "fail" at the end of Phase C. Each scans `lib/` excluding
`lib/design/` and generated files:

| Rule | Banned pattern |
|---|---|
| No colours | `Color(0x`, `Colors.` (except `Colors.transparent`) |
| No radius literals | `circular(` with a number |
| No spacing literals | `EdgeInsets.*(` with a number; `SizedBox(height|width: <number>` |
| No raw buttons | `ElevatedButton`, `FilledButton`, `OutlinedButton`, `TextButton`, `FloatingActionButton` |
| No spinners | `CircularProgressIndicator` |
| No raw icons | `Icons.` |
| No raw durations | `Duration(milliseconds:` |
| No bouncy curves | `Curves.elastic`, `Curves.bounce`, `SpringSimulation` |
| No font names | `fontFamily:` |
| No typed caps | `.toUpperCase()` in `lib/features/` |

```dart
// test/code_rules/design_rules_test.dart (shape)
void main() {
  final files = dartFilesUnder('lib')
      .where((f) => !f.path.startsWith('lib/design/') && !f.path.endsWith('.g.dart'));
  for (final rule in designRules) {
    test(rule.name, () {
      final hits = [
        for (final f in files)
          for (final (i, line) in f.readAsLinesSync().indexed)
            if (rule.pattern.hasMatch(line) && !line.contains('// design-ok'))
              '${f.path}:${i + 1}: $line',
      ];
      expect(hits, isEmpty, reason: rule.fix);
    });
  }
}
```

**Removed or deprecated at the end of Phase C:** `core/theme/app_theme.dart`,
`AtomicSemanticColors`, the interim `AtomicFonts` in `app_theme.dart`
(replaced by the token one), Inter and Space Grotesk assets and their
licence registration, `shared_widgets/priority_chip.dart`,
`status_chip.dart`, `confirm_dialog.dart`, `empty_state.dart` (moved into
the library), `docs/design-tokens/` (moved to `docs/history/`, superseded
by the Atomic system; DECISIONS.md kept there for the record).

---

# Part VII — Delivery

## 36. Phases and exit gates

UI foundation comes first, because every new assistant screen would
otherwise be built twice. Tools come before features, and voice comes after
tools, because voice is only another input. Estimates are for one
developer working with AI help.

| Phase | Scope | Exit gate | Estimate |
|---|---|---|---|
| **A. Design foundation** | Tokens (§26), Atomic theme (light/dark), bundled fonts, `AtomicText`, `AtomicIcons`, `AtomicMotion`, the contrast test, design guard rails in report mode | Contrast test green; all goldens regenerated and reviewed; nothing else changes behaviour | 1 wk |
| **B. Component library** | §27 atoms, molecules and organisms that existing screens need; debug gallery; component goldens | Every component has goldens for all its states, 1x/2x text, light/dark | 1.5 wk |
| **C. Screen migration** | Today, Task detail, forms, conflict sheet, Focus, summary, Assistant chat, Insights → Review, Settings, Onboarding (new content) | Guard rails fail the build; old theme and widgets deleted; accessibility guideline tests on every screen | 2 wk |
| **D. AI contract v3** | Tools, continuation turns, vendor mappings (§8.1), JSON-plan fallback, plus docs/04 4.4 context windowing and B18 cut-off detection | Contract fixtures per vendor (6 cases each) green; one real tool round trip per vendor key the owner has (device) | 1.5 wk |
| **E. Assistant core** | Schema v8; registry with the first 14 tools; orchestrator; quick parser + time phrases; policy (`decide`); ledger + undo; proposals; Inbox, Activity; 5-tab IA | Policy table test (75 cases); undo round-trip test for every tool; 150-phrase parser table; migration v7→v8 with data | 2.5 wk |
| **F. Reminders, lists, people** | Schema v9–v10; reminders with notification actions and exact-alarm flow; follow-ups; lists; people + dates; repeating tasks | Background action handler tests; reboot/tz re-scheduling tests; emulator test: create reminder by text → Activity → UNDO | 2 wk |
| **G. Voice 1** | Push-to-talk (platform STT), TTS, listening panel, QS tile, Hinglish grammar, voice settings | Reducer tests; fake-engine integration test; device check: 20 scripted commands ≥ 90% correct (owner) | 1.5 wk |
| **H. Proactive** | Scanners, commitment detector, briefings + check-in + shutdown + weekly review, phone calendar via Calendar Provider (replaces docs/04 Phase 6), plan/re-plan, focus DND, flexible blocks | Scanner tests with fixed clocks; kill switch test; device: calendar events appear as locked blocks | 2.5 wk |
| **I. Memory, money, travel, documents** | Schema v11–v12; FTS5; share target; OCR; bills/expenses; trips; documents + expiry; hand-offs with package visibility; What AA knows | FTS5 probe test; extraction validators; `android_patches` tests for queries/share target; device: each hand-off opens the right app | 2.5 wk |
| **J. Voice 2** | Wake-word spike (§22.5) then build; Vosk and Whisper engines; conversation mode; meeting notes with consent | Spike report with measured numbers; consent widget test; device: 1 h hands-free battery measured | 3 wk |

**Status** (ticked in the commit that finishes each phase):

- [x] **A. Design foundation** — tokens, Atomic theme (light/dark), fonts bundled (Bebas Neue, Hanken Grotesk, JetBrains Mono; Inter and Space Grotesk removed), `AtomicText`, `AtomicIcons`, `AtomicMotion`, `AtomicTag`, contrast tests, design-rule ratchet, goldens regenerated. The old `AppTheme` and its off-brand semantic colours are already gone (planned for C, done early because nothing needed them)
- [x] **B. Component library** — `AtomicPressable` (pressed-key translate, hard shadow), `AtomicButton` (primary/solid/ghost/destructive/text, busy label, 48 dp target), `AtomicIconButton`, `AtomicCard` (content/panel/raised/dark/selected/danger; dark modules invert the palette for their content), `AtomicChip`, `AtomicTag`, `AtomicEyebrow`, `AtomicRule`, `AtomicSectionLabel`, `AtomicTitleRow`, `AtomicSplitHeadline`, `AtomicFactRow`, `AtomicSettingsRow`, `AtomicDangerZone`, `AtomicLoading`/`AtomicLoadingBar`, `AtomicEmptyState`, `AtomicErrorState`, `AtomicWarningBox`, `showAtomicSheet`/`AtomicSheetFrame`, `showAtomicConfirm`, `AtomicProgressBar` (energy thresholds), `AtomicBottomBar`/`AtomicNavRail` (ink pill, badge), `AtomMark` (orbit only without reduced motion). Tested for behaviour and semantics (each one exposes its tap to TalkBack), with Flutter's tap-target, label and contrast guidelines over a gallery in both themes, and gallery goldens (light/dark × 1x/2x). Deviation: the gallery is a test fixture, not an in-app debug route, so it needs no shipped strings
- [x] **C. Screen migration** — in six batches: shared widgets and the shell (bottom bar/rail with the ink pill), Today, forms + task detail + conflict sheet, Focus (painted ring, mono digits, square controls), Assistant chat + Insights, Settings + Onboarding + Export. Every design rule is at 0 and strict (colour, radius, spacing literals; raw Material buttons; spinners; raw icons; durations; bouncy curves; font names; typed capitals). Fixed along the way: AtomicCard's priority border threw at paint; typed-caps strings in the ARB; subtask titles breaking mid-word at 200%. Old token files moved to `docs/history/design-tokens/`. Deferred to the phases that own them: the 5-tab IA (E, with the Inbox), the new onboarding content (E, autonomy), ISO dates in labels (DS-3; a formats change with its own tests, next)
- [x] **D. AI contract v3** — `AIToolSpec`, `AIToolChoice`, continuation turns, the `AIToolCall` event, `collectToolTurn`; all four vendors map tools, choice and continuation and read calls from their streams; `toolsUnsupported` detection and the JSON-plan fallback in `completeWithTools`; the schema-subset checker; history windowing (K10). 37 contract cases + domain and repository tests. Still owed: a real tool round trip per vendor on a device with the owner's keys (**Verify**), and B18's "cut off" label (schema v8, Phase E)
- [ ] E. Assistant core — in slices:
  - [x] **E.1** policy (`decide`, 75-case table), time phrases and the local grammar (`quick_parse.dart`), English + Hinglish, also under New York and Kolkata time
  - [x] **E.2** schema v8 (`utterances`, `assistant_actions`, `proposals`; partial unique index on open dedupe keys) with the v7→v8 data test and SQL-invariant tests; domain types `LedgerEntry`, `LedgerStatus`, `UndoRecipe` (+ JSON codec that never throws), `Proposal`, `ProposalReason`, `Utterance`. Deviations: the utterance text column is `body` (`text` shadows Drift's builder); no range CHECKs on enum columns (R1 growth would force rebuilds). B18's stop-reason column is not in v8 yet
  - [x] **E.3** tool interface (`tool.dart`), typed previews, `ToolRegistry`, the first 14 tools, `ToolExecutor` (tool + ledger row in one transaction, effects after commit) and `UndoService`, with an undo round-trip test for every writing tool and a guard that fails when a new one has none. Deviations: the 14 are the tools the current schema can back (`get_agenda`, `find_free_time`, `search_tasks`, `get_task`, `create_task`, `update_task`, `complete_task`, `schedule_task`, `break_down_task`, `create_block`, `move_block`, `start_focus`, `delete_task`, `delete_block`); reminders, lists, memory, expenses and the hand-offs wait for their tables (F, I) and package visibility. `validate` is async against fresh repository reads instead of a prebuilt snapshot. Tools accept a task title as well as an id, because the local grammar only has titles. Reads write no ledger row. `delete_block` refuses repeating blocks for now (undoing an exception row is later work)
  - [x] **E.4** `AssistantOrchestrator` (grammar first, then up to 4 model rounds / 8 calls / 30 s; errors fed back; confirmations stop the turn and `confirm()` resumes it in the same undo group), `AssistantContextBuilder` with redaction (§6.4), `ProposalService` (accept re-validates, dedupe, expiry, one-tap guard), `AssistantRepository`, the autonomy preset as a setting, keepAlive providers, the focus alert after commit; B18 (schema **v9**: `ai_messages.stop_reason`, "Cut off" under such replies). Schema numbering shifts by one from here: Phase F's tables are v10–v11, H/I's v12–v13
  - [ ] **E.5** Inbox, Activity, 5-tab IA, new onboarding content
- [ ] F. Reminders, lists, people
- [ ] G. Voice 1
- [ ] H. Proactive
- [ ] I. Memory, money, travel, documents
- [ ] J. Voice 2

Total ≈ 20 weeks. The **release track** from docs/04 (AAB, Play signing,
`targetSdk`, 16 KB pages, data safety form) runs alongside from Phase C;
the Play data-safety form must be updated for microphone, calendar and
documents before Phases G, H and I ship.

**How docs/04's open items fold in:** 4.4–4.6 and 4.9 → D/E; 4.7 Task
Breakdown → E (a tool: `break_down_task`, preview then accept); 4.8 Add to
Today's Timeline → H (`planDay`); Phase 5 → H (Review, drift analysis as
the pattern miner) and C (Review screen); Phase 6 → H (Calendar Provider);
Phase 7 → G/J.

## 37. Testing strategy additions

- **Policy:** the 75-case `decide()` table.
- **Tools:** for every reversible tool, a property-style test: random
  valid args → run → undo → the database equals the snapshot before.
- **Orchestrator:** a scripted fake `AIClient` that emits tool calls;
  tests for unknown tools, malformed args, invalid targets, round and call
  limits, confirmation stops, proposal creation, and redaction of context.
- **Quick parser and time phrases:** ≥ 150 phrases, English and Hinglish,
  run under `TZ=America/New_York` (CI) and `Asia/Kolkata`, across DST.
- **Scanners and briefings:** fixed `clock`, golden-style expectations of
  typed output.
- **Migrations:** v7 → v12 step by step with data (R2), FTS5 triggers.
- **Notification actions:** the background handler as a pure function.
- **Voice:** reducer table; `FakeSpeechEngine` in widget and integration
  tests.
- **UI:** component goldens; screen goldens (phone 1x/2x, tablet subset);
  accessibility guidelines per screen; contrast test; design guard rails.
- **Emulator integration:** onboarding → create a reminder by typing
  "remind me to call Mum at 7" → see it in Activity → UNDO → gone.
- **Owner device checklist** per phase (mic, wake word, DND, calendar,
  exact alarms, OEM battery settings), recorded in the PR.

## 38. Risks

| Risk | Likelihood | Mitigation |
|---|---|---|
| Play policy changes (microphone FGS, exact alarms, accessibility) | Medium | Design already avoids Accessibility; FGS only user-started; exact alarms optional with fallback; re-check policies at each phase (**Verify**) |
| OEM background killing (common on phones sold in India) | High | Primary triggers are app-open and scheduled notifications; a "Keep AA reliable" screen with per-maker steps; no feature depends on the background pass |
| Weak tool calling on small local models | High | Quick parser covers the common requests offline; JSON-plan fallback; validation rejects bad calls (R16) |
| Indian English / Hinglish recognition errors | Medium | Edit-before-acting below 0.6 confidence; on-device models per language; destructive intents always confirm |
| AI cost from proactive features | Medium | Scanners are local; only commitment detection and drafts call a model; a daily request cap in Settings |
| Users feel watched | Medium | Everything opt-in, visible (Activity, What AA knows), reversible, and pausable by one switch |
| Scope (20 weeks solo) | High | Phases ship independently; each exit gate leaves a usable app |
| Abandoned plugins (calendar, STT, FGS, OCR) | Medium | Every platform feature is behind a domain interface; Kotlin channels via `android_patches` as the fallback |
| Data loss from AA's actions | Low | Same-transaction ledger, undo, 30-day restorable deletes, export |

## 39. Decisions needed from the owner

AA will proceed with the default unless told otherwise.

| # | Question | Default |
|---|---|---|
| 1 | Accent: keep Signal, or a sibling accent for AA (system §15)? | Keep Signal |
| 2 | Persona: AA speaks as "AA"; use the Atomi mascot? | "AA", no mascot in v1 |
| 3 | Wake phrase (needs a trained model) | "Hey Atomic", Phase J |
| 4 | Speech default: platform recognizer (may use a server) or on-device first (≈ 40 MB download)? | On-device when downloaded; platform otherwise, disclosed |
| 5 | Distribution: Play only, or also a sideload build with fewer limits? | Play-compliant everywhere |
| 6 | Read other apps' notifications to catch commitments? | No in v1 |
| 7 | Live data (web search, weather, traffic, flight status) needs paid APIs | None in v1 |
| 8 | Time display: ISO + 24 h (system) or follow the phone's 12/24 h? | ISO + 24 h, with a 12 h setting |
| 9 | UPI hand-off for bills | Off |
| 10 | Encrypt the database (SQLCipher)? | No; revisit before Phase I documents |
| 11 | Rename the GitHub repository to `atomic-assist`? | Owner's call; no code impact |
| 12 | Hindi UI strings in v1? | English UI, Hindi/Hinglish understanding |
| 13 | Quiet hours for suggestions | 21:30–07:30 |

## 40. Sources

Researched 2026-10-04. Entries marked **Verify** in the text must be
re-checked against these (or newer) pages when the work is done.

**What a secretary / personal assistant does (§1)**
- [Personal assistant — Wikipedia](https://en.wikipedia.org/wiki/Personal_assistant)
- [Secretary — Wikipedia](https://en.wikipedia.org/wiki/Secretary)
- [Personal Assistant Job Description — Betterteam](https://www.betterteam.com/personal-assistant-job-description)
- [Personal Assistant Job Description — Manatal](https://www.manatal.com/job-description/personal-assistant-job-description)
- [Personal Assistant Job Description — WeCreateProblems](https://www.wecreateproblems.com/job-descriptions/personal-assistant-job-description)
- [Personal Assistant Job Description — Pearl Talent](https://www.pearltalent.com/resources/personal-assistant-job-description)
- [Personal Secretary Job Description — Skima](https://skima.ai/resources/job-descriptions/personal-secretary-job-description)
- [Secretary vs. personal assistant — Athena](https://www.athena.com/blog/posts/secretary-vs-personal-assistant)
- [Executive Assistant vs. Secretary — ProAssisting](https://proassisting.com/resources/articles/executive-assistant-vs-secretary/)
- [What Is a Personal Assistant? — Tiger Recruitment](https://tiger-recruitment.com/business-support/what-is-a-personal-assistant/)
- [Household Personal Assistant Responsibilities — Docean](https://www.doceanhouseholdstaffing.com/post/what-are-the-responsibilities-of-a-household-personal-assistant)
- [25 Tasks to Hand Off to a Personal Assistant — The Middle](https://www.hirethemiddle.com/blog/25-tasks-hand-off-to-a-part-time-personal-assistant)

**AI secretaries (§2)**
- [Lindy — AI Executive Assistant](https://www.lindy.ai/tools/ai-executive-assistant)
- [10 Best AI Executive Assistants in 2026 — Simular](https://www.simular.ai/alternatives/ai-executive-assistants)
- [Best AI Chief of Staff Tools 2026 — Alfred](https://get-alfred.ai/blog/best-ai-chief-of-staff-tools)
- [AI Personal Assistant Apps for Business — Consul](https://consul.so/blog/ai-personal-assistant-apps-business)

**Android constraints (§3, §12, §22)**
- [Foreground service types — Android Developers](https://developer.android.com/develop/background-work/services/fgs/service-types)
- [Foreground service types are required (Android 14)](https://developer.android.com/about/versions/14/changes/fgs-types-required)
- [Restrictions on starting a foreground service from the background](https://developer.android.com/develop/background-work/services/fgs/restrictions-bg-start)
- [Behavior changes: Android 15](https://developer.android.com/about/versions/15/behavior-changes-15)
- [SpeechRecognizer — Android reference](https://developer.android.com/reference/android/speech/SpeechRecognizer)
- [Android SpeechRecognizer vs. ML Kit GenAI Speech Recognition](https://www.pixsterstudio.com/blogs-insights/android-default-speechrecognizer-vs-ml-kit-genai-speech-recognition)
- [Calendar provider overview — Android Developers](https://developer.android.com/identity/providers/calendar-provider)
- [CalendarContract.Events — Android reference](https://developer.android.com/reference/android/provider/CalendarContract.Events)
- [device_calendar_plus — pub.dev](https://pub.dev/packages/device_calendar_plus)

**Speech and wake word (§22)**
- [vosk_flutter_service — pub.dev](https://pub.dev/packages/vosk_flutter_service)
- [whisper_kit — pub.dev](https://pub.dev/packages/whisper_kit)
- [Vosk vs Whisper Local: 2026 guide — Sinologic](https://www.sinologic.net/en/2026-05/vosk-vs-whisper-local-the-ultimate-2026-guide-to-self-hosted-speech-recognition-stt.html)
- [flutter_tts — pub.dev](https://pub.dev/packages/flutter_tts)
- [openwakeword-android-kt — GitHub](https://github.com/IamSanjid/openwakeword-android-kt)
- [Porcupine Wake Word — Picovoice](https://picovoice.ai/products/voice/wake-word/)
- [Wake Word Detection Guide 2026 — Picovoice](https://picovoice.ai/blog/complete-guide-to-wake-word/)

**Play policy (§3.4)**
- [Use of the AccessibilityService API — Play Console Help](https://support.google.com/googleplay/android-developer/answer/10964491?hl=en)
- [Permissions and APIs that Access Sensitive Information — Play Console Help](https://support.google.com/googleplay/android-developer/answer/16558241?hl=en)
- [Android Advanced Protection accessibility restrictions — Android Headlines](https://www.androidheadlines.com/2026/02/android-advanced-protection-accessibility-api-restrictions-customization-automation.html)

**Recording law (§3.5)**
- [Telephone call recording laws — Wikipedia](https://en.wikipedia.org/wiki/Telephone_call_recording_laws)
- [India Recording Laws — RecordingLaw](https://recordinglaw.com/india-recording-laws/)
- [Call Recording Laws: 50-State & Global Consent Guide — Mindtickle](https://www.mindtickle.com/legal/a-guide-to-call-recording-laws-and-regulations/)
