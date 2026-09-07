# Phase 1 Data Model: Automated Test & Play Store Deployment Pipeline

This feature has no application data model — it introduces no `lib/models/` types, no
persisted state, and no database. The "entities" below (carried over from the spec's Key
Entities section) describe pipeline *concepts*, realized entirely as GitHub Actions run
metadata and Google Play Console records — nothing this feature owns or serializes itself.

## Pipeline Run

Represents one execution of `.github/workflows/ci-cd.yml`, triggered by a push.

| Field | Realized as | Notes |
|---|---|---|
| Commit / branch | `github.sha`, `github.ref` (built-in GitHub Actions context) | No custom storage; GitHub records this per run natively. |
| Test-stage result | The `test` job's pass/fail status, with per-test detail in its `flutter test` step log | Visible in the Actions "Checks" UI for the commit. |
| Deployment-stage result (when applicable) | The `build_and_deploy` job's pass/fail status | Only exists for runs triggered by a push to `main` where `test` succeeded (`needs: test`). |

## Release Build

The packaged, versioned Android App Bundle (`.aab`) produced by a passing `build_and_deploy`
job.

| Field | Realized as | Notes |
|---|---|---|
| Version name | `pubspec.yaml`'s `version` (name portion, e.g. `0.0.1`) | Unchanged by this feature; maintainer still bumps it manually for user-visible version naming. |
| Version code | `github.run_number` passed as `--build-number` to `flutter build appbundle` | Strictly increasing per Decision 6 in `research.md`; this is the only per-build artifact identity this feature manages. |
| Artifact | `build/app/outputs/bundle/release/app-release.aab` | Ephemeral — exists only within the job's workspace; not retained as a GitHub Actions artifact unless a future enhancement adds that (out of scope here). |

## Play Store Submission

The record of one `r0adkll/upload-google-play` action invocation.

| Field | Realized as | Notes |
|---|---|---|
| Track | Hardcoded `production` in the workflow step (per the maintainer's explicit choice in the spec) | Not user-configurable data; a workflow constant. |
| Outcome | The upload step's exit status + logged response from the Play Developer API | Surfaced in the same job's step log per Decision 8 in `research.md`. |

## Signing Credential Secret

The keystore file and its password, held outside source control.

| Field | Realized as | Notes |
|---|---|---|
| Keystore file | `ANDROID_KEYSTORE_BASE64` GitHub Actions secret, decoded to `$RUNNER_TEMP` at build time | Never written to the checked-out workspace; discarded when the runner is destroyed. |
| Store / key password | `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_PASSWORD` GitHub Actions secrets | Equal in value, since the keystore is PKCS12 (see conversation history — PKCS12 requires store and key password to match). |
| Key alias | `ANDROID_KEY_ALIAS` GitHub Actions secret (value: `upload`) | Not sensitive itself, but kept alongside the others for consistency. |
| Play Console service account | `PLAY_STORE_SERVICE_ACCOUNT_JSON` GitHub Actions secret | The full downloaded service-account key JSON, used directly by `r0adkll/upload-google-play`. |

No relationships, validation rules, or state transitions apply beyond what's captured in the
Functional Requirements (FR-005–FR-009) already in `spec.md` — these are configuration values
consumed once per run, not records that change state over time within the app.
