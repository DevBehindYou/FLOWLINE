# Voice device check (Phase G exit gate)

The owner runs this on their phone with a release APK from CI. Phase G
is done when **at least 18 of the 20 commands** (≥ 90%) do the right
thing. Record each result in the table and attach it to the PR that
ticks Phase G in `docs/05` §36.

## Before you start

1. Install the latest `atomic-assist-*.apk` from the CI run on `main`.
2. Open the app once and finish or skip onboarding. Either set up an AI
   provider or don't: every command below works on the phone's own
   grammar.
3. Add one task called **Write report**.
4. Settings → Voice: leave **Speak replies** on WHEN I SPOKE and
   **Keep listening** off.

Speak normally, in a quiet room, about 30 cm from the phone. Tap the mic
in Assist for each command. "Right" means the action card under the
command, the spoken reply and the app's data all match the expected
result. If AA shows the transcript to edit, it heard you uncertainly: tap
DO IT without editing, and count the result on what happens.

## The 20 commands

| # | Say | Expected | Right? |
|---|---|---|---|
| 1 | "Remind me to call Mum at 7" | Reminder "call Mum" at 19:00 today (or tomorrow if it's past 19:00) | |
| 2 | "Remind me to stretch in 20 minutes" | Reminder "stretch" 20 min from now | |
| 3 | "Remind me to pay rent tomorrow" | Reminder "pay rent" tomorrow 09:00 | |
| 4 | "Remind me about the dentist on Friday at 10" | Reminder "the dentist", Friday 10:00 | |
| 5 | "Remind me to take medicine at 9 pm" | Reminder "take medicine" 21:00 | |
| 6 | "Yaad dila dena 5 baje meeting hai" | Reminder "meeting hai" at 17:00 | |
| 7 | "Add milk to shopping" | "milk" on Shopping | |
| 8 | "Add milk, eggs and bread to the shopping list" | eggs and bread added; milk not added twice | |
| 9 | "Put batteries on my errands list" | "batteries" on Errands | |
| 10 | "Add charger and passport to packing" | both on Packing | |
| 11 | "Shopping list mein doodh aur anda daal do" | "doodh" and "anda" on Shopping | |
| 12 | "Add a task to call the bank" | Task "call the bank" | |
| 13 | "Add task submit report tomorrow at 3" | Task "submit report", due tomorrow 15:00 | |
| 14 | "New task send invoice by Friday" | Task "send invoice", due Friday | |
| 15 | "Start focus for 25 minutes on write report" | Focus session, 25 min, linked to Write report | |
| 16 | "Mark write report as done" | Write report done (stop the focus session first if one runs) | |
| 17 | "Done with laundry" | No such task: AA says so (or asks), nothing changes | |
| 18 | "What do I have tomorrow" | With a provider: reads tomorrow's agenda. Without: says it needs an AI provider | |
| 19 | "Start a pomodoro" | Focus session with the default length | |
| 20 | "Remind me to water the plants tonight" | Reminder "water the plants" at 20:00 | |

## Also check (not counted)

- **Quick Settings tile:** edit the tiles, add "Talk to Atomic Assist",
  tap it. The app opens on Assist, listening.
- **Launcher shortcut:** long-press the app icon → "Talk". Same.
- **Barge-in:** while AA is speaking a reply, tap the mic again: it stops
  speaking and listens.
- **Speak replies OFF:** the reply shows as text and isn't spoken.
- **Keep listening ON:** after a reply AA listens again; staying quiet
  ends it.
- **No permission:** deny the microphone once: the panel says AA needs
  the microphone, and GRANT MICROPHONE asks again.
- **Undo:** after command 7, UNDO under it removes the milk; Activity
  shows the action as undone.
- TalkBack on: the panel's state changes are read out.

## Result

| Date | Phone / Android | APK (commit) | Right / 20 | Notes |
|---|---|---|---|---|
| | | | | |
