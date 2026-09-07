---

description: "Task list template for feature implementation"
---

# Tasks: Automated Test & Play Store Deployment Pipeline

**Input**: Design documents from `/specs/021-ci-cd-pipeline/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md), [data-model.md](./data-model.md), [contracts/ci-cd-pipeline.md](./contracts/ci-cd-pipeline.md), [quickstart.md](./quickstart.md)

**Tests**: This feature's "tests" are the five end-to-end quickstart scenarios (pushing real commits and observing pipeline behavior) rather than unit tests — there is no app logic to unit-test here. Each scenario is included as a validation task within the story phase it proves.

**Organization**: Tasks are grouped by user story (P1–P4 from spec.md) to enable independent implementation and validation of each.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3, US4)
- File paths are given exactly, relative to the repository root

## Path Conventions

Single project, infra-only change. All edits touch `.github/workflows/ci-cd.yml`,
`android/app/build.gradle.kts`, `android/key.properties.example`, or `README.md` — no `lib/`,
`test/`, or new source directories are introduced (per `plan.md`'s Structure Decision).

---

## Phase 1: Setup

**Purpose**: Create the workflow file skeleton and the local-signing template, with no job logic
yet.

- [X] T001 [P] Create `.github/workflows/ci-cd.yml` with a `name:` and an `on:` block triggering
      on `push` (all branches) and `pull_request` targeting `main`, per
      [contracts/ci-cd-pipeline.md](./contracts/ci-cd-pipeline.md)'s Triggers table. No `jobs:`
      content yet beyond an empty `jobs:` key.
- [X] T002 [P] Create `android/key.properties.example` with placeholder values and comments for
      the four keys a local `android/key.properties` must define: `storePassword`, `keyPassword`,
      `keyAlias`, `storeFile` — matching the shape `android/app/build.gradle.kts` will read per
      [research.md](./research.md) Decision 3.

**Checkpoint**: Workflow file exists and is valid YAML (no jobs); the signing-config template
exists. Neither has behavior yet.

---

## Phase 2: Foundational

**Purpose**: Confirm the one shared prerequisite both US2 and US3 rely on before either touches
signing.

- [X] T003 Verify `android/.gitignore` already ignores `key.properties`, `*.jks`, and `*.keystore`
      (confirmed present from Flutter's default template — this task is a verification, not an
      edit; only edit `android/.gitignore` if one of these three patterns is missing).

**Checkpoint**: Confirmed no local `key.properties` or keystore file created in later phases can
be accidentally committed.

---

## Phase 3: User Story 1 - Automatic verification of every commit (Priority: P1) 🎯 MVP

**Goal**: Every push automatically runs the full `flutter test` suite and reports pass/fail,
with no deployment happening yet.

**Independent Test**: Push a commit with passing tests, then a commit with a deliberately
failing test; confirm the `test` job runs automatically both times and its result reflects each
outcome, with no `build_and_deploy` job present in either run.

### Implementation for User Story 1

- [X] T004 [US1] In `.github/workflows/ci-cd.yml`, add a `test` job running on `ubuntu-latest`
      with named steps: `actions/checkout@v4` → `subosito/flutter-action@v2` (channel: stable) →
      `flutter pub get` → `flutter test`. Name each step descriptively (e.g. "Run test suite")
      per [contracts/ci-cd-pipeline.md](./contracts/ci-cd-pipeline.md)'s `test` job definition.

### Validation for User Story 1

- [ ] T005 [US1] Run [quickstart.md](./quickstart.md) Scenario 1 (push to a non-`main` branch):
      confirm only the `test` job runs and no deployment job is scheduled.
- [ ] T006 [US1] Run [quickstart.md](./quickstart.md) Scenario 2 (deliberately break an assertion
      in a file under `test/`, push/open a PR, then revert it): confirm the `test` job fails with
      the specific failing test identifiable in its log.

**Checkpoint**: User Story 1 is fully functional and independently valuable — every commit is
now automatically tested with no manual step.

---

## Phase 4: User Story 2 - Secrets-free release signing (Priority: P2)

**Goal**: The release keystore file and its passwords are removed from source control entirely;
signing credentials are supplied only via a gitignored local file or externally-injected
environment variables.

**Independent Test**: Inspect `android/app/build.gradle.kts` and confirm it contains no literal
keystore path or password; confirm a local release build still succeeds by supplying credentials
through a local `android/key.properties`.

### Implementation for User Story 2

- [X] T007 [US2] Rewrite the `signingConfigs { create("release") { ... } }` block in
      `android/app/build.gradle.kts` to load a `java.util.Properties` object from
      `android/key.properties` when that file exists (via `FileInputStream`), falling back to
      `System.getenv("ANDROID_KEYSTORE_PATH")`, `System.getenv("ANDROID_KEYSTORE_PASSWORD")`,
      `System.getenv("ANDROID_KEY_ALIAS")`, and `System.getenv("ANDROID_KEY_PASSWORD")` when it
      does not. Remove the hardcoded `keyAlias`, `keyPassword`, `storeFile`, and `storePassword`
      literals entirely — including the local machine path `C:/Users/donch/upload-keystore.jks`.

### Validation for User Story 2

- [ ] T008 [US2] Locally, create `android/key.properties` (gitignored) from
      `android/key.properties.example`, filled in with the maintainer's own keystore path and the
      already-rotated passwords; confirm `flutter build appbundle --release` succeeds using the
      new `build.gradle.kts` logic from T007.
- [X] T009 [US2] Search all tracked files in the repository (e.g. `git grep` across a fresh
      clone, or GitHub's code search) for the old hardcoded local keystore path and for any
      plaintext password string; confirm zero matches remain in tracked files, satisfying SC-006.
      (Old values may still exist in git history — that purge is explicitly out of scope per
      spec.md's Assumptions.)

**Checkpoint**: No signing credential is committed anywhere in the current tree; local builds
still work via a gitignored file. This unblocks User Story 3, which needs working, secrets-free
signing to build a release in CI.

---

## Phase 5: User Story 3 - Automatic deployment on successful verification (Priority: P3)

**Goal**: On a successful test run on `main`, the app is automatically built, signed, and
published to the Google Play Store's Production track.

**Independent Test**: Push a commit with passing tests to `main` and confirm a new release
reaches Play Console's Production track with no manual build/sign/upload step; push a commit
with a failing test and confirm no build or submission occurs.

**Depends on**: User Story 2 (T007) — the deploy job's build step relies on the secrets-based
signing configuration existing before it can produce a valid signed release in CI.

### Implementation for User Story 3

- [X] T010 [US3] In `.github/workflows/ci-cd.yml`, add a `build_and_deploy` job on
      `ubuntu-latest` with `needs: test` and `if: github.ref == 'refs/heads/main' && github.event_name == 'push'`,
      per [contracts/ci-cd-pipeline.md](./contracts/ci-cd-pipeline.md)'s `build_and_deploy`
      trigger rule.
- [X] T011 [US3] Add a `concurrency` block to the `build_and_deploy` job: `group: play-store-deploy`,
      `cancel-in-progress: false`, per [research.md](./research.md) Decision 7.
- [X] T012 [US3] Add named steps to `build_and_deploy`: `actions/checkout@v4` →
      `subosito/flutter-action@v2` (channel: stable) → `actions/setup-java@v4`
      (distribution: temurin, java-version: '17') → `flutter pub get`.
- [X] T013 [US3] Add a named step ("Decode signing keystore") that decodes the
      `secrets.ANDROID_KEYSTORE_BASE64` secret to `$RUNNER_TEMP/upload-keystore.jks` (e.g.
      `echo "${{ secrets.ANDROID_KEYSTORE_BASE64 }}" | base64 -d > $RUNNER_TEMP/upload-keystore.jks`),
      failing the step if the secret is empty.
- [X] T014 [US3] Add a named step ("Build signed App Bundle") running
      `flutter build appbundle --release --build-number=${{ github.run_number }}`, with
      `ANDROID_KEYSTORE_PATH` set to the path from T013 and `ANDROID_KEYSTORE_PASSWORD`,
      `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD` set from their matching
      `secrets.*` values as step-level `env:` entries, consumed by the `build.gradle.kts` logic
      from T007.
- [X] T015 [US3] Add a named step ("Publish to Google Play Production") using
      `r0adkll/upload-google-play@v1` with `serviceAccountJsonPlainText: ${{ secrets.PLAY_STORE_SERVICE_ACCOUNT_JSON }}`,
      `packageName: com.rebustechnologies.kristle`, `releaseFiles: build/app/outputs/bundle/release/app-release.aab`,
      and `track: production`, per [research.md](./research.md) Decision 5.

### Validation for User Story 3

- [ ] T016 [US3] Run [quickstart.md](./quickstart.md) Scenario 3 (push a normal passing commit to
      `main`): confirm `build_and_deploy` succeeds and a new release with the expected version
      code (`github.run_number`) appears in Play Console's Production track.
- [ ] T017 [US3] Run [quickstart.md](./quickstart.md) Scenario 5 (push two commits to `main` in
      quick succession): confirm the second `build_and_deploy` run queues behind the first rather
      than running concurrently.

**Checkpoint**: User Stories 1, 2, and 3 together deliver the full requested pipeline: test on
every commit, deploy automatically on success, with no committed secrets.

---

## Phase 6: User Story 4 - Visibility into pipeline failures (Priority: P4)

**Goal**: When either the test run or the store deployment fails, the maintainer can identify
what failed and why directly from the pipeline's own output.

**Independent Test**: Deliberately cause a test failure and, separately, a deployment failure
(e.g. temporarily invalidate a secret's expected format), and confirm each failure's cause is
visible in the run's output without local reproduction.

### Implementation for User Story 4

- [X] T018 [US4] Review every step added in T004 and T010–T015 in
      `.github/workflows/ci-cd.yml` and ensure each has a clear, descriptive `name:` (e.g. "Run
      test suite", "Decode signing keystore", "Build signed App Bundle", "Publish to Google Play
      Production") so a failure is identifiable from the Actions UI's step list at a glance.

### Validation for User Story 4

- [ ] T019 [US4] Run [quickstart.md](./quickstart.md) Scenario 4 (inspect the `build_and_deploy`
      job's full log after a successful run): confirm no secret value appears unmasked anywhere
      in the log output, satisfying FR-008.

**Checkpoint**: All four user stories are complete; failures at either stage are diagnosable from
the pipeline's own output alone.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Documentation and a final full-pipeline confirmation.

- [X] T020 [P] Add a short "Continuous Deployment" section to `README.md` describing the
      pipeline (tests on every push, auto-deploy to Play Store Production on push to `main`) and
      listing the five required repository secret **names** (`ANDROID_KEYSTORE_BASE64`,
      `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_PASSWORD`, `ANDROID_KEY_ALIAS`,
      `PLAY_STORE_SERVICE_ACCOUNT_JSON`) without their values.
- [ ] T021 Push one final real commit to `main` and confirm all five
      [quickstart.md](./quickstart.md) scenarios hold true end-to-end in the same run/sequence
      before considering this feature complete.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately.
- **Foundational (Phase 2)**: Depends on Setup (T001 must exist for T003 to be meaningful in
  context, though T003 itself only inspects an existing file).
- **User Story 1 (Phase 3)**: Depends on Setup (T001). Fully independent of US2/US3/US4 —
  deliverable and testable on its own (MVP).
- **User Story 2 (Phase 4)**: Depends on Foundational (T003). Independent of US1 and US4;
  independently testable via local builds alone.
- **User Story 3 (Phase 5)**: Depends on User Story 1 (needs the `test` job to gate on) AND User
  Story 2 (needs working secrets-based signing to build a real release). This is the one
  cross-story dependency in this feature, driven by the spec's own ordering (US2's priority
  explicitly precedes US3 because deployment cannot safely/correctly happen without it).
- **User Story 4 (Phase 6)**: Depends on User Story 3 (there must be steps in the deploy job to
  name/verify) and User Story 1 (same, for the test job).
- **Polish (Phase 7)**: Depends on all four user stories being complete.

### Parallel Opportunities

- T001 and T002 (Phase 1) touch different files and can run in parallel.
- T005 and T006 (US1 validation) can be performed in either order or back-to-back; not
  file-conflicting but are sequential in practice (same workflow run observations).
- T020 (Phase 7) can be done in parallel with T021 since it touches `README.md` only.
- All other tasks edit the same two files (`ci-cd.yml`, `build.gradle.kts`) sequentially within
  their phase and are not parallelizable against each other.

---

## Parallel Example: Phase 1

```bash
Task: "Create .github/workflows/ci-cd.yml with name + on: triggers"
Task: "Create android/key.properties.example with placeholder signing values"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001–T002).
2. Complete Phase 2: Foundational (T003).
3. Complete Phase 3: User Story 1 (T004–T006).
4. **STOP and VALIDATE**: every commit now runs the full test suite automatically — this alone
   is a shippable improvement over the current no-CI state.

### Incremental Delivery

1. Setup + Foundational → foundation ready.
2. User Story 1 → tests run automatically on every push (MVP).
3. User Story 2 → signing credentials are no longer committed to source control (a security fix,
   independently valuable even before automatic deployment exists).
4. User Story 3 → automatic deployment to Google Play Production goes live (the pipeline's full
   requested value).
5. User Story 4 → failure diagnostics polish (mostly step-naming, low additional effort given
   GitHub Actions' native UI already does most of this work).
6. Polish → documentation and one full end-to-end confirmation run.

## Notes

- [P] tasks touch different files with no dependencies on incomplete same-phase work.
- This feature has no unit tests to write (it is CI/build configuration); validation is via the
  five `quickstart.md` scenarios, each mapped to the story phase it proves.
- Commit after each task or logical group, consistent with how earlier features in this repo
  were delivered.
- Avoid: re-introducing any literal keystore path, password, or service-account JSON content
  into `android/app/build.gradle.kts`, `.github/workflows/ci-cd.yml`, or any other tracked file —
  the entire point of User Story 2 is that these values only ever exist in GitHub Actions
  secrets or a gitignored local file.
