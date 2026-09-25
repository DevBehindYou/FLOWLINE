# Flowline — Phase 1 + Phase 2 + Phase 3 + Phase 4 + Phase 5 + Export
# (Foundation, Task/Schedule, Focus Timer, AI Assistant, Schedule
# Conflict Detection, Insights, PDF/CSV/JSON Export)

Real, complete Dart/Flutter source for Phases 1–5 plus Export of the
Flowline build plan. This was written in a sandbox with **no Flutter
SDK and no network access**, so it has not been compiled or run. Read
"Before you build" before assuming something is broken — the setup
steps below are the usual reason.

**Planning docs, scope, architecture, DFD, and the original UI/UX
brief live in [`docs/`](docs/README.md)** — that file also maps each of
those to the others and notes the few places the code ended up
adjusting what the docs originally planned.

## What's implemented (real, not stubbed)
Phase 1:
- Local-first Drift/SQLite database: Tasks, Subtasks, Schedule Blocks
- Full CRUD: create/edit/delete tasks, subtasks, and schedule blocks
- Today screen: day switcher, timeline of schedule blocks with nested
  tasks, unscheduled backlog, per-block "add task," swipe-to-complete and
  swipe-to-delete with a confirmation dialog
- Task Detail screen with a live, editable subtask checklist
- Dark + light theme built from the delivered Flowline design tokens
- 4-tab navigation shell (`go_router` `StatefulShellRoute`)

Phase 2:
- Focus Timer: Focus (25m) / Short break (5m) / Long break (15m), with
  Start/Pause/Resume/End/+5min controls
- Wall-clock-safe countdown — correct even after the app is backgrounded
  or the process is killed and relaunched mid-session
- Local notification when a session ends (inexact scheduling)
- Sessions link to a task or subtask; completing one increments that
  subtask's logged-pomodoro count
- "Today's Focus" summary on the Focus tab

Phase 3 (new):
- **Multi-provider AI chat** — Anthropic (Claude), OpenAI (GPT), Google
  Gemini, and a local/LAN Ollama server, all behind one `AIClient`
  Strategy interface (`domain/repositories/ai_client.dart`) with a real
  HTTP implementation per vendor
- **Settings → AI Providers**: add/edit an API key and model per vendor,
  pick which one is active. Keys are written *only* to
  `flutter_secure_storage` (Android Keystore-backed) — never to Drift,
  never logged
- **Assistant tab**: a real chat screen against whichever provider is
  active, with conversation history persisted locally, and an inline
  error bubble (not a crash) for a bad key, a rate limit, or a network
  failure
- Deliberately **not** in this pass: the Task Breakdown Engine, "Add to
  Today's Timeline," and a full conversation-history list — those are
  genuinely separable features on top of this same `AIRepository`, and
  cramming them into the same unverified pass as four new vendor HTTP
  integrations was more risk than the phase needed. Next up.

Phase 4 (new):
- **Schedule conflict detection**: saving a schedule block that overlaps
  an existing one no longer just silently succeeds — it opens a Conflict
  sheet with three ways out: ask the AI for a specific non-overlapping
  time, go back and edit the times by hand, or save the overlap anyway
- **AI-assisted resolution**: a tightly-format-constrained one-shot AI
  request (`AIRepository.completeOnce` — no conversation, nothing added
  to the visible Assistant chat) asks for an exact replacement time.
  Parsing is defensive on purpose: a model that ignores the requested
  format (a real risk, especially with a small local Ollama model) falls
  back to showing its raw text with no one-tap "Apply," rather than
  guessing
- Overlaps that get saved anyway are still visible afterward — the
  Today timeline flags any block currently overlapping another with a
  warning icon and red outline

Deliberately **not** in this pass, same reasoning as Phase 3's split:
- **Google Calendar sync** — this needs the user's own Google Cloud
  project, OAuth client ID, and the app's release-keystore SHA-1
  fingerprint registered with it. None of that can be done from here;
  it's a "you" step, not a "more code" step, so building the sync logic
  ahead of having real credentials to test it against would be exactly
  the unverifiable-in-the-dark work this project has been avoiding
- **Weekly drift analysis** ("Friday Post-Lunch Collapse"-style pattern
  detection + auto-apply) — a distinct, more complex AI feature that
  needs real focus-session history to be worth anything; better suited
  to its own pass once there's usage data to analyze
- **Drag-based manual timeline adjuster** — the delivered mockups show a
  full drag-to-reorder collision UI; the simpler "edit times / save
  anyway" flow above covers the same practical need without a
  gesture-heavy custom UI I can't verify by inspection. Worth revisiting
  once the app is actually running on a device

Phase 5 (new):
- **Insights dashboard**, replacing the placeholder: three stat cards
  (today's focus time, current day-streak, this week's total), and a
  7-day bar chart of daily focus minutes (`fl_chart`)
- **Streak and daily-totals logic lives in a pure domain service**
  (`domain/services/focus_stats_calculator.dart`, no Flutter/Drift
  imports) — same reasoning as the Phase 4 conflict checker: this is
  real logic worth being able to unit-test on its own, not something to
  bury inside a widget's build method
- Deliberately counts an ended-early focus session toward a day's streak
  (showing up partway still counts for consistency), which is a
  different, more lenient rule than Phase 2's "only a full session counts
  toward a subtask's logged pomodoros" — both are documented inline where
  the distinction actually matters

**The one piece of this phase I'd most want you to sanity-check first**:
`fl_chart`'s `BarChart`/`FlTitlesData`/`AxisTitles` API, in
`insights_screen.dart`. I'm confident in the shape from training, but a
charting library's API is exactly the kind of thing that drifts between
versions in ways a written-blind pass like this can't catch — if
`flutter analyze` flags anything in this project, this file is the most
likely place.

Still deliberately deferred, unchanged from the Phase 4 writeup: Google
Calendar sync and weekly AI drift analysis.

Export (new):
- **PDF/CSV/JSON export**, reachable from a share icon on the Insights
  app bar — all three cover the same 7-day window Insights shows, so
  what you export always matches what you were just looking at
- **PDF**: a formatted one-page summary (stat row, daily breakdown table,
  full session log) built with the `pdf` package, shared via
  `Printing.sharePdf`
- **CSV**: hand-rolled, not the `csv` package — every column is a date,
  time, enum label, number, or boolean, which is provably comma-free, so
  the usual reason to need a real CSV encoder (escaping free-text like a
  task title) doesn't apply yet. Worth revisiting the moment a free-text
  column gets added
- **JSON**: a raw structured dump of the same session data, for anyone
  who wants to process it themselves
- Everything is generated on-device and handed to the OS share sheet via
  `share_plus` — no upload step, no server, consistent with the rest of
  the app

**Two more spots worth a first look if `flutter analyze` complains**,
same honest-uncertainty reasoning as `fl_chart` in Phase 5: the `pdf`
package's widget API (`pw.Document`/`pw.Table.fromTextArray`/etc.) in
`weekly_pdf_exporter.dart`, and `share_plus`'s newer
`SharePlus.instance.share(ShareParams(...))` surface in
`export_service.dart` — I picked that over the older static
`Share.shareXFiles(...)` because it matches the `share_plus` version
pinned in `pubspec.yaml`, but a share-sheet package's API is exactly the
kind of thing that shifts between majors.

## What's intentionally a placeholder
Nothing left on the bottom nav — all four tabs are real now. One small
known rough edge from Phase 4: tapping "Edit times" on the conflict sheet
just closes it — it doesn't reopen the form pre-filled yet, so you'd tap
"Add schedule block" again. Left as-is rather than adding a second
context-passing path for a fairly minor convenience.

## Architectural note vs. the v1 architecture doc
The Use Case layer described in `docs/01-architecture.md` is still
deliberately skipped, now including Phase 3: `AssistantViewModel` and
`AiProvidersViewModel` call `AIRepository` directly, the same as Phase 1's
CRUD. The orchestration for a chat send (fetch history, persist the user
message, resolve the active provider, dispatch to the right vendor client,
persist the reply or a clear error) is real, but it's *single-repository*
orchestration, so it lives in `AIRepositoryImpl` itself rather than a
`SendAIMessageUseCase` that would just forward one call. The Use Case
layer's first real justification is Phase 4 (Schedule Intelligence), where
conflict detection needs to read from both `ScheduleRepository` and a
future `CalendarRepository` in one operation — that's genuinely
cross-repository logic with nowhere honest to live except a Use Case.

## Before you build

Two one-time setup steps, both standard for any Drift + Riverpod-codegen
project (not specific to this one):

1. **Generate the native platform folders.** Hand-writing Gradle/AGP files
   without a way to verify current version numbers risks exactly the kind
   of version mismatch this project is trying to avoid, so they're not
   included. Run this in an *empty* directory:
   ```
   flutter create --platforms android --org com.devbehindyou .
   ```
   Then copy `lib/`, `pubspec.yaml`, and `analysis_options.yaml` from this
   archive into it, overwriting the generated defaults.

2. **Install packages and generate code.** Drift's database implementation
   and Riverpod's provider code are both `build_runner`-generated:
   ```
   flutter pub get
   dart run build_runner build --delete-conflicting-outputs
   ```

3. **Add two manifest permissions.** In
   `android/app/src/main/AndroidManifest.xml`, inside the `<manifest>` tag
   (as a sibling of `<application>`, not inside it):
   ```xml
   <uses-permission android:name="android.permission.INTERNET"/>
   <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
   ```
   `flutter create`'s template only adds `INTERNET` to the **debug** and
   **profile** manifests, not the release one — `flutter run` (debug)
   would work fine while every AI-provider request silently failed in a
   release APK, since Anthropic/OpenAI/Gemini/Ollama all go over HTTP(S).
   `POST_NOTIFICATIONS` is for Phase 2's session-complete notification
   (Android 13+/API 33+) — the runtime permission prompt itself is
   triggered in code, the first time a focus session starts.
   `flutter_local_notifications` merges its own manifest requirements in
   automatically as a plugin; these two lines are on the app, not it.

   CI applies both of these automatically — see
   `tool/ci/patch_android_manifest.dart` and `.github/workflows/ci.yml` —
   so this step is only needed if you generate `android/` by hand.

4. **Allow cleartext traffic, for Phase 3's Ollama support.** Android
   blocks plain HTTP by default (API 28+) — fine for Anthropic/OpenAI/
   Gemini, which are all HTTPS, but Ollama's local server is plain HTTP.
   In the same manifest, add the attribute to the `<application>` tag:
   ```xml
   <application
       android:usesCleartextTraffic="true"
       ...>
   ```
   This is a blanket allow (simplest correct fix, and the honest one to
   ship rather than a network-security-config that only *looks* scoped
   to "local" traffic — Android's XML config can't express private-IP
   ranges, only fixed domains). If you don't plan to use Ollama, this
   step is skippable — the other three providers don't need it.

5. Then:
   ```
   flutter run
   ```

## Design tokens
Colors in `lib/core/theme/app_theme.dart` are transcribed from the design
team's `DESIGN.md` files. Fonts are left as the Flutter default (Roboto)
for now — Space Grotesk/Inter need to be added as bundled font assets,
which weren't fabricated without the actual font files.

## After setup
Run `flutter analyze` — this code was written without a compiler in the
loop, so that command (not this README) is the actual verification step.
