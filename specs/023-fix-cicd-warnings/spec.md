# Feature Specification: Resolve CI/CD Deprecation Warnings

**Feature Branch**: `023-fix-cicd-warnings`

**Created**: 2026-09-08

**Status**: Draft

**Input**: User description: "Fix this warnings, commit and push" (referring to 4 GitHub Actions annotation warnings shown on a completed CI/CD run: Node.js 20 deprecation on `Run test suite` and `Build, sign, and publish to Play Store`, a `'track' is deprecated, migrate to 'tracks'` warning from the Play Store publish step, and a `setup-java v4 is deprecated` warning)

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A clean, warning-free pipeline run (Priority: P1)

As the maintainer, I want the CI/CD workflow run to complete without deprecation warnings cluttering the Annotations panel, so that I can trust the "warnings" indicator to flag real, actionable problems instead of noise I already know about and have to mentally filter out every time.

**Why this priority**: This is the entire scope of the request — there is one outcome (no more of these four warnings) and everything else is a means to it.

**Independent Test**: Trigger the workflow (push or manual run) and inspect the run's Annotations panel; confirm none of the four previously-seen warnings (Node.js 20 deprecation ×2, `track` deprecation, `setup-java v4` deprecation) appear, and the run still completes successfully (tests pass, build succeeds, Play Store publish succeeds).

**Acceptance Scenarios**:

1. **Given** the CI/CD workflow runs (via push or manual trigger), **When** the run completes, **Then** the Annotations panel shows no "Node.js 20 is deprecated" warning for any job.
2. **Given** the `build_and_deploy` job runs and publishes to Google Play, **When** it completes, **Then** no "'track' is deprecated... migrate to 'tracks'" warning appears.
3. **Given** the `build_and_deploy` job sets up Java, **When** it completes, **Then** no "setup-java v4 is deprecated" warning appears.
4. **Given** all four warnings are resolved, **When** the workflow runs, **Then** the pipeline's actual behavior (tests run, build succeeds, versioning logic from the prior feature still applies, deployment gating and concurrency protection still apply) is unchanged — this is a maintenance fix, not a behavior change.

### Edge Cases

- What happens if pinning a newer action version introduces a breaking change to its inputs/outputs? The workflow must still function identically (same job behavior, same success/failure criteria) — any input/output changes required by the newer version must be applied so behavior is preserved.
- What happens if the underlying warning is caused by an action GitHub itself forces onto a newer Node runtime regardless of the action's declared version (rather than something a version bump alone fixes)? Document that this class of warning may not be fully eliminable by the maintainer and note it as a known limitation rather than leaving it unaddressed silently.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The workflow MUST NOT produce a "Node.js 20 is deprecated" warning for the `Run test suite` job.
- **FR-002**: The workflow MUST NOT produce a "Node.js 20 is deprecated" warning for the `Build, sign, and publish to Play Store` job.
- **FR-003**: The Play Store publish step MUST NOT produce a "'track' is deprecated... migrate to 'tracks'" warning.
- **FR-004**: The Java setup step MUST NOT produce a "setup-java v4 is deprecated" warning.
- **FR-005**: Resolving these warnings MUST NOT change the pipeline's observable behavior: the test job must still run `flutter test` and gate deployment on its success; the deploy job must still build, sign, and publish the same artifact to the same Google Play track under the same trigger conditions (push to `main`, or manual run with `deploy` opted in); the existing versioning scheme (major.minor.build naming and auto-incrementing Play Store versionCode) and the single-flight deploy concurrency protection must remain intact.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A CI/CD run completed after this change shows 0 of the 4 previously-observed deprecation warnings in its Annotations panel.
- **SC-002**: 100% of existing pipeline behavior (test gating, build/sign/publish steps, versioning, deploy concurrency) is preserved — a deploy run still successfully publishes to Google Play Production exactly as before.

## Assumptions

- The Node.js 20 warnings are resolved by updating the pinned action versions (e.g. `actions/checkout`, `actions/setup-java`) to versions that run on a supported Node runtime, since these actions' own runtime is what GitHub is warning about — not something the workflow's own YAML configures directly.
- The `'track' is deprecated` warning is resolved by migrating the Play Store publish step's `track` input to the newer `tracks` input, per the action's own migration guidance, without changing which Play Store track (production) is targeted.
- The `setup-java v4` warning is resolved by upgrading to the next stable major version of `actions/setup-java` while keeping the same Java distribution and version (Temurin 17).
- No functional/behavioral change to the release process is intended or in scope beyond what's needed to silence these specific warnings.
