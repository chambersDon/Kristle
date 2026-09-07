# Phase 0 Research: Automated Test & Play Store Deployment Pipeline

No `NEEDS CLARIFICATION` markers remain in the Technical Context — all decisions below were
resolvable from the existing repository (`android/app/build.gradle.kts`, `android/.gitignore`,
`pubspec.yaml`) and established, stable patterns for Flutter/Android CI. Each is recorded here
with its rationale and the alternatives considered.

## 1. CI platform and trigger model

**Decision**: A single GitHub Actions workflow, `.github/workflows/ci-cd.yml`, with two jobs:
`test` (runs on every push and pull request) and `build_and_deploy` (runs only on push to
`main`, gated on `needs: test`).

**Rationale**: The repository is hosted on GitHub (confirmed via `git remote -v`), so GitHub
Actions requires no new external account or billing setup. A single workflow with two jobs
keeps the "tests always run, deploy only follows on `main`" rule (FR-001, FR-002, FR-013)
enforced structurally by `needs:` rather than by conditional logic scattered through one big
job.

**Alternatives considered**: A separate workflow file per job (rejected — splitting them means
GitHub's UI no longer shows one coherent run per commit, and coordinating "only deploy if the
other workflow's test run passed" requires extra plumbing `needs:` already gives for free
within one workflow). A third-party CI provider (CircleCI, Travis) — rejected, no reason to
introduce a new external dependency when the repo is already on GitHub.

## 2. Setting up Flutter and Java in the runner

**Decision**: Use `subosito/flutter-action@v2` pinned to the stable channel (matching the
maintainer's local `Flutter 3.41.9 • channel stable`), and `actions/setup-java@v4` with
`distribution: temurin`, `java-version: '17'` (matching `JavaVersion.VERSION_17` already
required in `android/app/build.gradle.kts`). GitHub's `ubuntu-latest` runner image ships with
the Android SDK and command-line tools preinstalled, including pre-accepted licenses, so no
separate Android SDK install step or `flutter doctor --android-licenses` step is needed.

**Rationale**: Both actions are the de facto standard, widely used, actively maintained
solutions for this exact setup step in the Flutter community; hand-rolling SDK installation
would add maintenance burden for no benefit. Pinning Java to 17 avoids a version mismatch
against the Gradle config's `sourceCompatibility`/`targetCompatibility`/`kotlinOptions.jvmTarget`.

**Alternatives considered**: Using the JBR bundled with Android Studio (not present on the
runner image — Android Studio itself isn't installed, only the SDK) — rejected. Building inside
a custom Docker image with Flutter preinstalled — rejected as unnecessary upfront complexity for
a single-target pipeline; can be revisited later if cold-start time becomes a real problem.

## 3. Removing hardcoded signing credentials from `build.gradle.kts`

**Decision**: Replace the current hardcoded `signingConfigs { create("release") { ... } }` block
with one that loads `android/key.properties` (a gitignored file — already covered by the
existing `key.properties` / `*.jks` / `*.keystore` entries in `android/.gitignore`) if present,
falling back to environment variables (`ANDROID_KEYSTORE_PATH`, `ANDROID_KEYSTORE_PASSWORD`,
`ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`) if it is not — which is the case in CI. A committed
`android/key.properties.example` documents the four keys a local `key.properties` must define,
with placeholder values, so a new developer machine can be set up without guessing the format.

**Rationale**: This is the standard, widely documented Flutter pattern for Android release
signing (the `key.properties` approach used in Flutter's own "Build and release an Android app"
guide), so it's a well-understood shape rather than a bespoke scheme. It satisfies FR-005–FR-007
directly: nothing sensitive is committed, and the same `build.gradle.kts` logic serves both local
developer builds and CI without duplication.

**Alternatives considered**: Passing all four values as Gradle project properties
(`-Pandroid.injected.signing.store.file=...`) on the `flutter build appbundle` command line —
rejected, since command-line arguments containing secrets are more likely to leak into shell
history or process-list snapshots than environment variables scoped to the CI job. Committing an
encrypted keystore blob with a separately-supplied decryption key — rejected as unnecessary
complexity when GitHub Actions' own encrypted secrets already provide equivalent protection.

## 4. Reconstructing the keystore file in CI from a secret

**Decision**: Store the keystore as a base64 string in the `ANDROID_KEYSTORE_BASE64` secret
(already created by the maintainer). A step early in `build_and_deploy` decodes it to a file
inside the job's temporary workspace (e.g. `$RUNNER_TEMP/upload-keystore.jks`), and
`ANDROID_KEYSTORE_PATH` is set to that path for the Gradle build step to consume.

**Rationale**: GitHub Actions secrets are string values; a binary `.jks` file must be
text-encoded to travel through a secret. Writing it to `$RUNNER_TEMP` (not the checked-out
workspace) means it never risks being accidentally `git add`ed and is discarded when the runner
is torn down after the job.

**Alternatives considered**: Committing the keystore file in encrypted form to the repo and
decrypting with a secret key in CI — rejected as an unnecessary extra credential (the decryption
key) to manage versus just storing the whole thing as one secret. Using GitHub's (paid,
org-level) encrypted file storage feature — rejected as unnecessary given a plain secret already
satisfies FR-005–FR-009 for a single-file, single-environment use case.

## 5. Publishing to Google Play from CI

**Decision**: Use `r0adkll/upload-google-play@v1`, passing the already-created
`PLAY_STORE_SERVICE_ACCOUNT_JSON` secret via its `serviceAccountJsonPlainText` input, the built
`.aab` via `releaseFiles`, and `track: production` (per the maintainer's explicit choice,
recorded in the spec).

**Rationale**: This action is a widely used, actively maintained wrapper around Google's
official `google-api-python-client`/Play Developer API publishing flow, purpose-built for
exactly this GitHub Actions use case, and accepts the JSON key as an inline secret string rather
than requiring it as a checked-out file — matching how the maintainer already stored it.

**Alternatives considered**: `fastlane supply` — a heavier dependency (full Ruby/fastlane
toolchain) for a single publish step; rejected in favor of a purpose-built GitHub Action with no
extra runtime to install. Calling the Play Developer API directly via `gcloud`/raw HTTP requests
— rejected as needlessly low-level for a well-covered, standard operation.

## 6. Versioning for each automatic deployment (FR-016)

**Decision**: Keep `versionName` as the value in `pubspec.yaml` (`0.0.1` today), but override
`versionCode` at build time using the GitHub Actions run number:
`flutter build appbundle --release --build-number=${{ github.run_number }}`. `github.run_number`
is a strictly increasing integer maintained by GitHub per-workflow, starting at 1 and
incrementing on every run — guaranteeing each Production submission has a higher `versionCode`
than the last, satisfying Google Play's requirement that every upload have a strictly increasing
version code.

**Rationale**: This requires no extra state to track (no file to bump, no tag to read back) and
cannot collide as long as the workflow itself isn't renamed (which would reset the counter — an
accepted, documented GitHub Actions behavior, and not expected for this single, stable
workflow).

**Alternatives considered**: Deriving the version code from total commit count
(`git rev-list --count HEAD`) — rejected because it silently resets/changes if history is ever
rewritten (e.g. the maintainer's earlier-discussed option to purge the old exposed password from
history), whereas `github.run_number` is independent of git history entirely. Manually bumping
`pubspec.yaml`'s build number per release — rejected, that's exactly the manual step this feature
is meant to eliminate (FR-016 requires this to be automatic).

## 7. Preventing overlapping/conflicting deployments (FR-014)

**Decision**: Add a top-level `concurrency: { group: play-store-deploy, cancel-in-progress: false }`
to the workflow (or scoped to the `build_and_deploy` job). With `cancel-in-progress: false`,
a second push's deploy job queues behind an in-flight one rather than running concurrently or
cancelling it mid-upload, so two Production submissions can never race.

**Rationale**: This is GitHub Actions' built-in mechanism for exactly this problem — no custom
locking/mutex logic needed. `cancel-in-progress: false` specifically (rather than the more common
`true`, used to cancel superseded CI runs) is chosen because cancelling a deployment mid-upload
could leave the Play Store submission in an inconsistent or partially-applied state; queuing is
safe, cancelling a live deploy is not.

**Alternatives considered**: Relying on Google Play's own API to reject a second concurrent
"edit" transaction — rejected as a fallback-only safety net, not a substitute for preventing the
race at the CI level where it's simpler to reason about.

## 8. Failure visibility (User Story 4 / FR-003, FR-012)

**Decision**: Rely on GitHub Actions' native per-step logs and job summary (each step — test run,
build, sign, upload — is a separately named, separately collapsible step whose failure is
flagged directly in the Checks tab on the commit/PR). No additional custom reporting/notification
mechanism is introduced by this feature.

**Rationale**: `flutter test`'s own failure output (failing test names, assertion diffs) and
`r0adkll/upload-google-play`'s own error output (e.g. Play API rejection reasons) are already
sufficiently detailed; GitHub's UI surfaces both without extra tooling. This satisfies SC-005
without adding a new integration (e.g. Slack/email notifications) that the spec didn't ask for.

**Alternatives considered**: A dedicated notification step (Slack webhook, email on failure) —
out of scope; the spec's User Story 4 only requires the maintainer be able to see the failure
reason when they look, not be proactively pushed a notification. Can be added later as a
separate, small enhancement if desired.
