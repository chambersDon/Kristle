# Quickstart: Validating the Manual CI/CD Trigger

## Prerequisites

- Push the updated workflow file to GitHub (or open a PR from the feature branch — `workflow_dispatch` must exist on the workflow's *default branch* version to appear as an option in the UI for other branches, but can be tested on the feature branch itself via `gh workflow run --ref <branch>`).
- `gh` CLI authenticated with write access to the repository (for CLI-based validation), or a browser session with write access (for UI-based validation).

## Scenario 1 — Manual run, verify-only (default)

1. In GitHub → Actions → CI/CD workflow, click "Run workflow", select a branch, leave `deploy` unchecked, click "Run workflow".
   - CLI equivalent: `gh workflow run <workflow-file> --ref <branch>`
2. **Expected**: The `test` job runs and reports pass/fail. The `build_and_deploy` job does not run (shows as skipped).

## Scenario 2 — Manual run, deploy enabled, on `main`

1. In GitHub → Actions → CI/CD workflow, click "Run workflow", select `main`, check `deploy`, click "Run workflow".
   - CLI equivalent: `gh workflow run <workflow-file> --ref main -f deploy=true`
2. **Expected**: The `test` job runs; if it passes, `build_and_deploy` runs and publishes to Google Play Production, identical to a push-triggered deploy. If `test` fails, `build_and_deploy` does not run.

## Scenario 3 — Manual run, deploy enabled, on a non-`main` branch

1. `gh workflow run <workflow-file> --ref <feature-branch> -f deploy=true`
2. **Expected**: The `test` job runs. `build_and_deploy` does not run (skipped) regardless of the `deploy` input, because the ref is not `main`.

## Scenario 4 — Existing automatic triggers unaffected

1. Push a commit to `main` as before.
2. **Expected**: Behavior is identical to before this feature — `test` runs, and `build_and_deploy` runs on success, gated only by `github.ref == 'refs/heads/main' && github.event_name == 'push'`.

## Scenario 5 — Concurrent deploy protection

1. Start a manual run with `deploy=true` on `main` while a push-triggered deploy is already in progress.
2. **Expected**: The second `build_and_deploy` run queues (per the `play-store-deploy` concurrency group) rather than running in parallel.

Refer to [contracts/workflow-dispatch.md](contracts/workflow-dispatch.md) for the full input/behavior contract.
