# Implementation Plan: Manually Triggerable CI/CD Pipeline

**Branch**: `022-manual-cicd-trigger` | **Date**: 2026-09-07 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/022-manual-cicd-trigger/spec.md`

## Summary

Add a `workflow_dispatch` trigger to the existing GitHub Actions CI/CD workflow so the maintainer can start a run on demand from the GitHub UI/CLI, with a boolean input controlling whether a passing manual run is allowed to proceed to the Play Store deploy job. No application code changes; this is a workflow-configuration-only change to `.github/workflows/*.yml`.

## Technical Context

**Language/Version**: YAML (GitHub Actions workflow syntax)

**Primary Dependencies**: GitHub Actions (`workflow_dispatch` trigger, existing `test` and `build_and_deploy` jobs)

**Storage**: N/A

**Testing**: Manual verification by triggering the workflow via the GitHub Actions UI/CLI and observing run behavior (test-only vs. test+deploy); existing `flutter test` suite is unaffected and continues to gate deployment

**Target Platform**: GitHub Actions (ubuntu-latest runners)

**Project Type**: Mobile app (Flutter) with CI/CD workflow configuration — this feature touches only the workflow file, not app code

**Performance Goals**: N/A (CI trigger mechanism, not a runtime performance concern)

**Constraints**: Must not weaken or change existing push/pull_request trigger behavior (FR-006); deployment must remain restricted to the main line and to the existing single-flight concurrency group (FR-005)

**Scale/Scope**: Single workflow file (`.github/workflows/ci-cd.yml` or equivalent); one new trigger type and one new job-level condition

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

The project constitution (`.specify/memory/constitution.md`) governs `lib/` application code: layered architecture, TDD, immutable models, single codebase across platforms, local-first/no-backend, and analyzer-enforced style. This feature does not touch `lib/`, does not add application logic, models, or platform-conditional gameplay code, and introduces no backend dependency — it only adds a manual trigger and an input-gated condition to the existing GitHub Actions workflow. No constitution principle applies to CI workflow configuration, so there are no gates to fail.

**Result**: PASS (no violations; not applicable to this change).

## Project Structure

### Documentation (this feature)

```text
specs/022-manual-cicd-trigger/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output (/speckit-plan command)
├── data-model.md         # Phase 1 output (/speckit-plan command) — N/A, documented as such
├── quickstart.md        # Phase 1 output (/speckit-plan command)
├── contracts/           # Phase 1 output (/speckit-plan command) — workflow trigger contract
└── tasks.md             # Phase 2 output (/speckit-tasks command - NOT created by /speckit-plan)
```

### Source Code (repository root)

```text
.github/
└── workflows/
    └── ci-cd.yml         # Existing CI/CD workflow — MODIFIED to add workflow_dispatch trigger
                          # and a deploy input gate on the build_and_deploy job
```

**Structure Decision**: This is a workflow-configuration-only change. The only file touched is the existing GitHub Actions workflow under `.github/workflows/`. No new source directories, no changes to `lib/`, `test/`, or platform runner directories.

## Complexity Tracking

*No constitution violations — this section is not applicable.*
