# Implementation Plan: Automated Test & Play Store Deployment Pipeline

**Branch**: `021-ci-cd-pipeline` | **Date**: 2026-09-07 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/021-ci-cd-pipeline/spec.md`

## Summary

Add a GitHub Actions pipeline that, on every push to `main`, runs the full `flutter test` suite,
and — only if every test passes — builds a signed Android App Bundle and publishes it directly
to the Google Play Store's **Production** track using a Play Console service account. As part of
the same feature, remove the hardcoded release-signing keystore path and passwords currently
committed in `android/app/build.gradle.kts`, sourcing them instead from a gitignored local
`key.properties` file (developer machines) or CI secrets (GitHub Actions), with the previously
exposed password already rotated by the maintainer.

## Technical Context

**Language/Version**: YAML (GitHub Actions workflow), Kotlin DSL (`build.gradle.kts`), Dart/Flutter (existing app, SDK `^3.11.5`)

**Primary Dependencies**: `subosito/flutter-action` (installs Flutter SDK in CI), `actions/checkout`, `actions/setup-java` (Temurin 17, matching `JavaVersion.VERSION_17` in `android/app/build.gradle.kts`), `r0adkll/upload-google-play` (publishes an AAB to Google Play using a JSON service-account key, no `gcloud`/`gh` CLI required)

**Storage**: N/A (no application data; pipeline consumes GitHub Actions repository secrets only)

**Testing**: `flutter test` (existing suite in `test/`, run unmodified — no new tests are part of this feature's scope; the pipeline consumes the suite, it doesn't add to it)

**Target Platform**: GitHub-hosted `ubuntu-latest` runner (Android SDK preinstalled) building the Android target only; iOS/web/desktop targets are out of scope per the spec's Assumptions

**Project Type**: Mobile app (Flutter/Android) — this feature adds CI/CD infrastructure only, no `lib/` or `test/` changes

**Performance Goals**: N/A — no runtime performance requirement; pipeline wall-clock time is a operational concern, not a spec requirement

**Constraints**: No signing/store credentials may ever appear in a tracked file (FR-005–FR-009); the pipeline must fail closed (explicit failure), never fall back to an unsigned/debug build, when a secret is missing or invalid

**Scale/Scope**: Single repository, single Android app, single deployment track (Production), solo maintainer — no multi-app/multi-environment matrix needed

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

This feature adds `.github/workflows/`, a `key.properties.example` template, and edits
`android/app/build.gradle.kts` and `.gitignore`. It does not touch `lib/`, `test/`, or
`assets/words/`, so the Kristle constitution's principles (layered architecture, TDD for
gameplay logic, immutable state, single codebase, local-first, lint-clean Dart) are not engaged
by this change — there is no gameplay/UI code being added.

The one principle worth calling out explicitly: **Principle II (Test-First Development,
NON-NEGOTIABLE)** governs *changes to app logic*, not the CI plumbing that invokes
`flutter test`. This feature satisfies the *spirit* of that principle by making the existing
test suite a hard, automatic gate for every commit and for every deployment (FR-002, FR-004) —
it doesn't add or modify tests itself, since no gameplay/UI behavior is being changed.

**Result**: PASS. No violations, no Complexity Tracking entries needed.

## Project Structure

### Documentation (this feature)

```text
specs/021-ci-cd-pipeline/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/
│   └── ci-cd-pipeline.md  # Phase 1 output: workflow trigger/job contract
└── tasks.md             # Phase 2 output (/speckit-tasks — not created here)
```

### Source Code (repository root)

```text
.github/
└── workflows/
    └── ci-cd.yml              # NEW: test job (always) + build-and-deploy job (main only, needs: test)

android/
├── .gitignore                 # ALREADY ignores key.properties, *.jks, *.keystore — no change needed
├── key.properties.example     # NEW: documents the 4 keys a local key.properties must define
└── app/
    └── build.gradle.kts       # UPDATED: signingConfigs reads from key.properties (local) or
                                #          System.getenv(...) (CI) instead of hardcoded values
```

No `src/`, `frontend/`, or `backend/` trees apply — per the constitution's Naming section, this
project's application source is `lib/` (untouched by this feature) and its platform runner
directory is `android/` (the only source tree this feature modifies).

**Structure Decision**: Single project, infra-only change. One new workflow file, one new
gitignored-template file, and edits to two existing Android build files. No new app module,
package, or test directory is introduced.

## Complexity Tracking

*No Constitution Check violations — this section is not applicable.*
