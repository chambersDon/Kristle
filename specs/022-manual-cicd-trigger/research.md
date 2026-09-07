# Phase 0 Research: Manually Triggerable CI/CD Pipeline

## Decision: Use GitHub Actions' native `workflow_dispatch` trigger

**Rationale**: GitHub Actions natively supports manual runs via `on.workflow_dispatch`, which appears as a "Run workflow" button in the Actions UI and is also invokable via `gh workflow run` or the REST API. This satisfies FR-001 (manual start independent of push/PR) and FR-007 (access control) with zero new tooling, since `workflow_dispatch` runs are already gated by the same repository write-access permissions GitHub enforces for all workflow triggers.

**Alternatives considered**:
- *Third-party trigger service / webhook*: Rejected — unnecessary complexity and a new external dependency for something the CI platform already provides natively.
- *`repository_dispatch` (API-only trigger)*: Rejected — requires a separate authenticated API call and doesn't offer a UI "Run workflow" button, making it less convenient for the maintainer's stated need ("kick off... manually").

## Decision: Gate deployment behind a `workflow_dispatch` boolean `input`, combined with the existing branch check

**Rationale**: FR-003 requires the maintainer to choose, at trigger time, whether a manual run may deploy. `workflow_dispatch` supports typed `inputs` (including `boolean`), surfaced as a checkbox in the "Run workflow" UI, defaulting to a safe value. The `build_and_deploy` job's existing `if` condition (`github.ref == 'refs/heads/main' && github.event_name == 'push'`) can be extended with an `||` branch for `workflow_dispatch` that additionally requires the input to be `true`, preserving all existing push-triggered behavior unchanged (FR-006) while adding the new manual path (FR-004).

**Alternatives considered**:
- *Always deploy on any manual run*: Rejected — violates FR-003/SC-004 (maintainer must be able to run tests only, without risking an unintended deploy) and edge case "maintainer intending only to re-verify tests."
- *Separate workflow file for manual deploy-only runs*: Rejected — duplicates the build/sign/publish steps and signing-secret usage, increasing maintenance burden and drift risk versus a single source of truth for the deploy job.

## Decision: Default the deploy input to `false`

**Rationale**: SC-004 ("zero unintended deployments") and the edge case about accidental publishing mean the safer default is "verify only." A maintainer who wants to deploy must explicitly opt in when starting the run, which matches how GitHub renders boolean `workflow_dispatch` inputs (an explicit checkbox the operator must toggle).

**Alternatives considered**:
- *Default to `true`*: Rejected — a maintainer who just wants to re-run tests (the edge case in the spec) could accidentally publish a release by forgetting to uncheck a box.

## Decision: No changes to concurrency group or job dependency structure

**Rationale**: FR-005 requires manual deploys to respect the existing single-flight `concurrency: group: play-store-deploy` protection already on `build_and_deploy`. Because the manual trigger only adds a new way to *reach* the same job (via an extended `if` condition), the existing `needs: test` dependency and `concurrency` block apply unchanged to manually triggered runs with no modification needed.

**Alternatives considered**: N/A — this is confirmation that no new mechanism is required, not a choice between alternatives.

All unknowns from the Technical Context are resolved; no `NEEDS CLARIFICATION` markers remain.
