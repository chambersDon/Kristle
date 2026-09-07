# Contract: `.github/workflows/ci-cd.yml`

This is the "interface" this feature exposes: the workflow's triggers, jobs, required secrets,
and observable outcomes. Downstream consumers are the maintainer (reading run results) and
Google Play (receiving submissions) — there is no programmatic API consumer.

## Triggers

| Event | Effect |
|---|---|
| `push` to `main` | Runs `test`, then (if `test` passes) runs `build_and_deploy` targeting the Production track. |
| `push` to any other branch | Runs `test` only. No `build_and_deploy` job runs (FR-013). |
| `pull_request` targeting `main` | Runs `test` only, against the PR's merge commit. No deployment (FR-013). |

## Jobs

### `test`

- **Runs on**: every trigger above.
- **Steps**: checkout → set up Flutter (stable channel) → `flutter pub get` → `flutter test`.
- **Success**: exit code 0 from `flutter test`, i.e. every test in `test/` passes.
- **Failure**: any non-zero exit from `flutter test`; the job (and workflow) is marked failed,
  and — critically — `build_and_deploy` never starts (`needs: test`).

### `build_and_deploy`

- **Runs on**: `push` to `main` only, and only `needs: test` having succeeded.
- **Required secrets** (must all be present in the repository's Actions secrets):
  - `ANDROID_KEYSTORE_BASE64`
  - `ANDROID_KEYSTORE_PASSWORD`
  - `ANDROID_KEY_PASSWORD`
  - `ANDROID_KEY_ALIAS`
  - `PLAY_STORE_SERVICE_ACCOUNT_JSON`
- **Steps** (in order):
  1. Checkout, set up Flutter + Java 17.
  2. Decode `ANDROID_KEYSTORE_BASE64` to a temporary `.jks` file.
  3. `flutter build appbundle --release --build-number=${{ github.run_number }}`, with
     `ANDROID_KEYSTORE_PATH`/`ANDROID_KEYSTORE_PASSWORD`/`ANDROID_KEY_ALIAS`/`ANDROID_KEY_PASSWORD`
     exported as environment variables for `android/app/build.gradle.kts` to read.
  4. Upload the resulting `.aab` to Google Play's `production` track via
     `r0adkll/upload-google-play`, authenticating with `PLAY_STORE_SERVICE_ACCOUNT_JSON`.
- **Concurrency**: grouped (`concurrency: play-store-deploy`, `cancel-in-progress: false`) so a
  second push's deploy queues rather than racing an in-flight one (FR-014).
- **Success**: the Play Developer API accepts the submission; the app-release.aab is live on the
  Production track.
- **Failure modes and required behavior**:
  - Any required secret missing/empty → the step that needs it must fail explicitly (e.g. a
    decode or build step erroring on an empty value), not silently proceed with a debug/unsigned
    build (FR-009).
  - Invalid/expired service account credentials → the upload step fails with the Play API's
    error surfaced in the step log (FR-012).
  - `versionCode` collision (should not occur given `github.run_number` is monotonic, but if the
    workflow itself is ever recreated and the counter resets) → the upload step fails with Play's
    "version code already used" error surfaced in the step log (per spec Edge Cases).

## Non-goals of this contract

- No iOS/App Store job — out of scope per spec Assumptions.
- No manual approval/gate step before Production — out of scope per the maintainer's explicit
  choice recorded in the spec.
- No Slack/email notification integration — out of scope per Decision 8 in `research.md`.
