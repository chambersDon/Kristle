# Contract: Manual CI/CD Trigger (`workflow_dispatch`)

## Trigger

- **Event**: `workflow_dispatch`
- **Where started**: GitHub Actions UI "Run workflow" button on the CI/CD workflow, `gh workflow run <workflow-file>`, or the GitHub REST API `POST /repos/{owner}/{repo}/actions/workflows/{workflow_id}/dispatches`.
- **Who can start it**: Anyone with write access to the repository (GitHub's standard `workflow_dispatch` permission model) — satisfies FR-007.
- **Branch/ref**: Selectable at trigger time, same as any `workflow_dispatch` run; deployment behavior still depends on the selected ref being `main` (see Job Behavior below).

## Input

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `deploy` | boolean | no | `false` | When `true` and the run's ref is `main` and tests pass, the run proceeds to build, sign, and publish to the Google Play Store. When `false` (default) or omitted, the run executes only the test job. |

## Job Behavior Contract

- **`test` job**: Runs unconditionally for every `workflow_dispatch` run, identical to push/PR-triggered runs (FR-002). No changes to this job.
- **`build_and_deploy` job**: Runs when `needs.test` succeeds AND:
  - `github.event_name == 'push' && github.ref == 'refs/heads/main'` (existing, unchanged — FR-006), **OR**
  - `github.event_name == 'workflow_dispatch' && github.ref == 'refs/heads/main' && inputs.deploy == 'true'` (new)
- **Concurrency**: `build_and_deploy` keeps its existing `concurrency: group: play-store-deploy, cancel-in-progress: false` — a manually triggered deploy queues behind any in-flight deploy rather than running concurrently (FR-005).
- **Non-main manual runs**: A `workflow_dispatch` run against a branch other than `main` executes `test` only; `build_and_deploy`'s condition evaluates false regardless of the `deploy` input, matching existing push-trigger scoping to `main`.

## Backward Compatibility

- `push` and `pull_request` triggers, their conditions, and their job steps are unmodified — existing automatic behavior is preserved exactly (FR-006).
