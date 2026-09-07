---

description: "Task list for feature implementation"
---

# Tasks: Manually Triggerable CI/CD Pipeline

**Input**: Design documents from `/specs/022-manual-cicd-trigger/`

**Prerequisites**: plan.md, spec.md, research.md, contracts/workflow-dispatch.md, quickstart.md

**Tests**: No test tasks — this is a CI/CD workflow-configuration-only change (YAML), not application code covered by the project's TDD principle. Validation is via the manual scenarios in quickstart.md.

**Organization**: Single user story (US1), single file change.

## Format: `[ID] [P?] [Story] Description`

## Phase 1: Setup

- [X] T001 Read the current `.github/workflows/ci-cd.yml` in full to confirm the exact existing `on:` block and `build_and_deploy.if` condition text before editing.

---

## Phase 2: Foundational

*No shared infrastructure beyond the single workflow file; nothing blocking to set up separately from US1.*

---

## Phase 3: User Story 1 - Manually run the pipeline on demand (Priority: P1) 🎯 MVP

**Goal**: Let the maintainer start the CI/CD workflow on demand from GitHub, with an opt-in input controlling whether a passing run may deploy to the Play Store.

**Independent Test**: Trigger the workflow via `gh workflow run` (or the Actions UI) without a code push; confirm a run starts, `test` executes, and `build_and_deploy` runs only when `deploy=true` and the ref is `main`.

### Implementation for User Story 1

- [X] T002 [US1] In `.github/workflows/ci-cd.yml`, add a `workflow_dispatch` trigger under the top-level `on:` block with one input `deploy` (`type: boolean`, `description: "Deploy to Google Play Production if tests pass"`, `default: false`), leaving the existing `push` and `pull_request` triggers unchanged (contracts/workflow-dispatch.md — Trigger & Input sections).
- [X] T003 [US1] In `.github/workflows/ci-cd.yml`, extend the `build_and_deploy` job's `if:` condition to also run when `github.event_name == 'workflow_dispatch' && github.ref == 'refs/heads/main' && inputs.deploy == true`, keeping the existing `github.ref == 'refs/heads/main' && github.event_name == 'push'` clause intact via `||` (contracts/workflow-dispatch.md — Job Behavior Contract; spec.md FR-003, FR-004, FR-006).
- [X] T004 [US1] Verify the `build_and_deploy` job's existing `concurrency: group: play-store-deploy, cancel-in-progress: false` block is untouched, so manually triggered deploys still queue behind any in-flight deploy (spec.md FR-005).
- [X] T005 [US1] Validate the edited YAML locally (e.g. `python -c "import yaml,sys; yaml.safe_load(open('.github/workflows/ci-cd.yml'))"` or an equivalent YAML parse) to confirm the file is syntactically valid before committing. (No Python/Node interpreter available in this environment; validated via manual structural review of indentation and block-scalar syntax instead.)

**Checkpoint**: User Story 1 is fully functional — the workflow can be manually started, defaults to test-only, and deploys only when explicitly opted in on `main`.

---

## Phase 4: Polish & Cross-Cutting Concerns

- [ ] T006 Run through quickstart.md Scenarios 1–5 after pushing the branch (manual test-only run, manual deploy run on main, manual run on a non-main branch, a normal push to confirm unchanged behavior, and — if feasible to observe — the concurrency queuing check) and record the observed results.

---

## Dependencies & Execution Order

- **Setup (T001)**: No dependencies.
- **User Story 1 (T002-T005)**: Depends on T001. T002 and T003 touch the same file sequentially (not parallelizable); T004 is a verification step after T003; T005 runs after all edits.
- **Polish (T006)**: Depends on the branch being pushed so workflow runs can actually be observed on GitHub.

## Parallel Opportunities

None — every task edits or validates the same single file (`.github/workflows/ci-cd.yml`), so tasks are sequential.

## Implementation Strategy

Single-story MVP: complete T001–T005, confirm the workflow YAML is valid, then push and validate against quickstart.md (T006) before committing/opening a PR.
