# Next Agent

Do not restart from scratch. Do not re-audit merged phases.

## Load First

1. `STATE.yaml`  2. `HANDOVER.md`  3. `CURRENT_STATE.md`  4. `PENDING.md`
Then `CLAUDE.md` (rules) and `docs/05-atomic-assist-plan.md` §36 only.

## Verify Repo Position

```bash
git status --short
git branch --show-current          # must be claude/fervent-shannon-79dcim
git log --oneline -3               # expect the H.3 + handover commit(s) on top of ddf13fc
git fetch origin main && git log --oneline origin/main -1
```
If `main` moved past `ddf13fc`, rebase the branch onto it before pushing.

## First Objective

`TASK-001`: verify and ship H.3.

## Execute

1. Toolchain: Flutter 3.47.5 (CI pin). `dart run build_runner build --delete-conflicting-outputs`; `flutter gen-l10n`.
2. `dart format --output=none --set-exit-if-changed $(git ls-files -co --exclude-standard '*.dart')`
3. `flutter analyze` (must print "No issues found!").
4. `timeout 580 flutter test -j 2`, then the NY subset (TESTING.md).
5. Push, open the PR (body: what, tests, not done; PR footer per PROJECT_CONTEXT), subscribe to PR activity.
6. When all three checks are green and `mergeable_state` is clean, merge (method `merge`, full 40-char head SHA).
7. Report progress % (overall and Phase H) to the user, then start `TASK-002`.
8. Update this folder by delta (STATE.yaml, CURRENT_STATE.md, CHANGES.md, PENDING.md); don't regenerate it.

## Do Not Repeat

- ISS-002's cause: never let CI use a lockfile re-resolved by `flutter create`.
- FA-001…FA-009 in `ISSUES.md` before writing widget tests.
- Don't call device behaviour VERIFIED from tests or CI.

## Definition of Done (per slice, CLAUDE.md)

- [ ] tests for the change (bug fix: a test that fails without it)
- [ ] format clean, analyze clean, all tests pass
- [ ] `PROJECT_OVERVIEW.md` + `docs/05` §36 updated
- [ ] commit `type(scope): summary` + why
- [ ] PR merged with CI green
