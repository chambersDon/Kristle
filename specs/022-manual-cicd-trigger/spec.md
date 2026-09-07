# Feature Specification: Manually Triggerable CI/CD Pipeline

**Feature Branch**: `022-manual-cicd-trigger`

**Created**: 2026-09-07

**Status**: Draft

**Input**: User description: "I should be able to manually kick of the CI/CD action"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Manually run the pipeline on demand (Priority: P1)

As the maintainer, I want to start the CI/CD pipeline myself at any time, without needing a new commit or pull request, so that I can re-run verification or trigger a release when I choose to (for example, after rotating a secret, recovering from an infrastructure hiccup, or wanting to re-publish the current main line without changing code).

**Why this priority**: This is the entire feature — everything else is a detail of how the manual run behaves once it can be started.

**Independent Test**: From the CI/CD platform's interface (or equivalent command), start a pipeline run without pushing a commit or opening a pull request, and confirm a new run begins and executes the test suite.

**Acceptance Scenarios**:

1. **Given** the maintainer is viewing the pipeline in the CI/CD platform, **When** they choose to manually start a run, **Then** a new pipeline run begins immediately without requiring a code push.
2. **Given** a manually started run, **When** it executes, **Then** it runs the full automated test suite the same as a push-triggered run.
3. **Given** a manually started run whose tests all pass, **When** the maintainer chooses to include deployment for that run, **Then** the app is built, signed, and published to the Google Play Store exactly as a push-triggered run would.
4. **Given** a manually started run, **When** the maintainer did not choose to include deployment, **Then** the run verifies the tests only and does not publish anything to the Google Play Store.

---

### Edge Cases

- What happens if a manually started run is launched while a push-triggered run (or another manual run) is already deploying? The deployment stage must not run concurrently with another deployment — a second deployment waits for the first to finish, consistent with existing pipeline behavior.
- What happens if the maintainer manually triggers a run from a branch other than the main line? The test suite runs; deployment is only performed when the manual run is against the main line, consistent with how push-triggered deployment is already restricted to the main line.
- What happens if the maintainer manually triggers a run intending only to re-verify tests? They must be able to do so without accidentally publishing a new release.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The CI/CD pipeline MUST support being started manually by the maintainer, independent of any code push or pull request event.
- **FR-002**: A manually started run MUST execute the full automated test suite, identically to a push-triggered run.
- **FR-003**: The maintainer MUST be able to choose, at the time of manually starting a run, whether that run may proceed to build and publish to the Google Play Store if tests pass, or whether it should stop after verification.
- **FR-004**: When a manually started run is configured to deploy and its tests pass, it MUST build, sign, and publish the app to the Google Play Store using the same process and credentials as the existing push-triggered deployment.
- **FR-005**: Deployment from a manually started run MUST respect the same single-flight (non-concurrent) deployment protection already in place for push-triggered deployments.
- **FR-006**: Manually starting a run MUST NOT change or weaken the existing behavior of automatic runs triggered by pushes or pull requests.
- **FR-007**: Only maintainers with write access to the repository MUST be able to manually start a run (consistent with the CI/CD platform's standard access control).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The maintainer can start a pipeline run on demand in under 1 minute without making any code change.
- **SC-002**: 100% of manually started runs execute the same test suite as automatic runs, with no reduction in verification coverage.
- **SC-003**: The maintainer can choose to manually re-publish the current main line to the Google Play Store without needing to create an empty commit or other workaround.
- **SC-004**: Zero unintended deployments occur from manually started runs that were not explicitly configured to deploy.

## Assumptions

- The project's CI/CD platform (GitHub Actions) natively supports manual run triggers, so no new external tooling is required.
- "Manually kick off" refers to starting a run of the existing pipeline on demand, not to replacing or duplicating the existing push/pull-request triggers.
- Access to manually trigger the pipeline follows the same repository permissions already governing who can push to the repository, without introducing a separate approval workflow.
- The choice of whether a manual run deploys is made at the time the run is started (e.g., via an input/parameter), not through a separate follow-up action.
