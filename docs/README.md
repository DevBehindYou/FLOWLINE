# Atomic Assist — Documentation Index

> The product was called **Flowline** until 2026-10-04. Documents written
> before then (`01`–`04`, `history.md`, `history/design-tokens/`) keep the old
> name; they are records of what was planned and decided at the time.

Everything that was produced before and alongside the code, colocated
with it so the repo is self-contained. Mapped below to the categories
originally asked for.

| Category | Where |
|---|---|
| **Architecture** | `01-architecture.md` (MVVM + Clean layering, folder structure, component breakdown, Riverpod/Drift design) and `03-scope-architecture-dfd-v2.md` §5 (the modules added after the UI/UX was delivered: Schedule Intelligence, Calendar Sync, Export, AI Monitoring) |
| **Scope** | `03-scope-architecture-dfd-v2.md` §1 (Confirmed Project Scope) |
| **Context (diagram)** | `03-scope-architecture-dfd-v2.md` §2 (System Context Diagram) |
| **DFD** | `03-scope-architecture-dfd-v2.md` §3 (Level 1 Data Flow Diagram), plus the per-flow sequence diagrams in `01-architecture.md` §6 |
| **Framework** | `01-architecture.md` §2 (why MVVM/Riverpod/Drift/go_router) and §14 (package list) |
| **Development** | the top-level `../README.md` — the actual as-built record, phase by phase, including every deliberate scope cut and its reasoning. `03-scope-architecture-dfd-v2.md` §10 is the roadmap as originally *planned*; the top-level README is what actually shipped and how it differs |
| **Providers / dependencies** | `03-scope-architecture-dfd-v2.md` §7 (confirmed AI provider & model matrix) and §8 (full dependency list); `../pubspec.yaml` is the source of truth for exact versions actually used |
| **Forward plan (current)** | `05-atomic-assist-plan.md` — the personal-assistant product (research, capabilities, autonomy and privacy model, architecture with code) and the complete Atomic UI/UX rebuild |
| **Atomic design system** | `design-system/atomic-design-system.md` — the DevBehindYou Atomic visual language; the source of truth for every screen. It replaces the Flowline token files, now in `history/design-tokens/` |
| **Build & optimization plan** | `04-build-and-optimization-plan.md` — what to build next, in what order, and the rules (R1–R21) that keep it future-proof and bug-proof |
| **UI/UX design** | `02-ux-ui-spec.md` (the original design brief — pages, components, flows) and `history/design-tokens/` (superseded; the three `DESIGN.md` token files pulled from the design team's delivery: dark early pass, dark system/final, light). The full delivered mockups (`Flowline_app_ui_ux_design.zip`, screenshots + HTML per screen) aren't duplicated here since you already have that file — drop it in `docs/design/` yourself if you want everything in one place |

## Reading order, if you want one

1. `02-ux-ui-spec.md` — what was asked for, page by page
2. `01-architecture.md` — how v1 of the app was designed to satisfy that
3. `03-scope-architecture-dfd-v2.md` — what changed once real UI/UX came
   back, plus the AI Monitoring (voice) design
4. `../README.md` — what was actually built, phase by phase, against
   all of the above
5. `../PROJECT_OVERVIEW.md` — the as-built description and known issues
6. `04-build-and-optimization-plan.md` — the forward plan: phased
   roadmap, engineering rules, a second defect register (B1–B30),
   optimization budgets, testing strategy and release track

## A note on drift between these docs and the code

`01-architecture.md` and `03-scope-architecture-dfd-v2.md` were written
*before* implementation, as planning documents — a couple of things were
adjusted once actual code got written (documented at the point they
happened, in the top-level README):

- The Use Case layer both docs describe was deliberately dropped for
  everything shipped so far — plain CRUD and single-repository
  orchestration don't need it; it was never reached because Calendar
  Sync (the first genuinely cross-repository case) hasn't been built yet
- `TaskRepository`/`ScheduleRepository`/`FocusSessionRepository` grew a
  few methods beyond what's sketched here as features needed them
  (`incrementSubtaskCompletedSprints`, `watchSessionsInRange`, etc.)

None of this changes the shape of the system these docs describe — the
top-level README is the place to check for "did this part actually end
up matching the plan."
