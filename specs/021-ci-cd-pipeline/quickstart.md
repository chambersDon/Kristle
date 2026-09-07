# Quickstart: Validating the CI/CD Pipeline

Prerequisites: all five GitHub Actions repository secrets already exist (confirmed done —
`ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_PASSWORD`,
`ANDROID_KEY_ALIAS`, `PLAY_STORE_SERVICE_ACCOUNT_JSON`), and the service account has Release
Manager-equivalent access to the Kristle app in Play Console (confirmed done).

## Scenario 1 — Tests run automatically, no deploy on a feature branch

1. Create a branch off `main`, make any small commit, push it.
2. Open the repo's **Actions** tab.
3. **Expected**: a workflow run appears for that push; only the `test` job runs; `build_and_deploy`
   is absent from the run (not just skipped-looking — it should not be scheduled at all, since
   the trigger condition excludes non-`main` pushes). Confirms FR-001, FR-002, FR-013.

## Scenario 2 — A failing test blocks deployment

1. On a branch, deliberately break an assertion in any file under `test/` (e.g. flip an expected
   value in `game_engine_test.dart`).
2. Open a pull request targeting `main`, or push directly to `main` if working solo.
3. **Expected**: the `test` job fails, its log identifies the specific failing test, and
   `build_and_deploy` does not run. Confirms FR-002–FR-004, FR-013, SC-003.
4. Revert the deliberate breakage.

## Scenario 3 — Full green path deploys to Production

1. Merge or push a normal, passing commit to `main`.
2. Watch the Actions run: `test` passes, then `build_and_deploy` starts.
3. **Expected**: `build_and_deploy` completes successfully; its final step's log shows a
   successful Play Developer API response. Confirms FR-010–FR-012, FR-016, FR-017.
4. In Play Console → Kristle → **Production**, confirm a new release appears with a version code
   equal to that run's GitHub Actions run number (visible in the Actions run URL / UI, e.g. run
   `#12` → versionCode `12`).

## Scenario 4 — Secrets never appear in source control or logs

1. After Scenario 3 completes, open the `build_and_deploy` job's full log.
2. **Expected**: no keystore password, key password, or service-account JSON content appears
   anywhere in the log output (GitHub Actions automatically masks registered secrets as `***`,
   but confirm no step deliberately echoes one). Confirms FR-008.
3. Run a repository-wide search (e.g. GitHub's code search, or a local `grep -r` across a fresh
   clone) for the rotated keystore password and for the literal string `keystore.jks` combined
   with a hardcoded local path. **Expected**: zero matches in tracked files (the local path and
   old password may still exist in old git history commits — that's a separate, out-of-scope
   follow-up per the spec's Assumptions). Confirms SC-006.

## Scenario 5 — Overlapping pushes don't double-submit

1. Push two commits to `main` in quick succession (within seconds of each other).
2. **Expected**: two workflow runs start, but their `build_and_deploy` jobs do not execute
   concurrently — the second visibly waits (queued) for the first to finish, per the
   `concurrency` group. Confirms FR-014.

## Rollback / one-time setup notes (not part of automated validation)

- Local development builds (`flutter run --release`) require a local `android/key.properties`
  (see `android/key.properties.example`) with the maintainer's own keystore path and the rotated
  passwords — this file must never be committed (already covered by `android/.gitignore`).
