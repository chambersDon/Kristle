# Phase 0 Research: Android Package Rename

## Decision: Rename `namespace`/`applicationId` together

- **Decision**: Set both `namespace` and `applicationId` in `build.gradle.kts` to the
  same real package name.
- **Rationale**: Satisfies FR-001/SC-001 — Android's Kotlin/Java `namespace` (used for
  generated `R` class resolution) and its `applicationId` (the on-device package
  identity) are conventionally kept identical for a straightforward app; splitting them
  would only be needed for advanced multi-flavor scenarios this project doesn't have.
- **Alternatives considered**: Renaming only `applicationId` and leaving `namespace` at
  the template default — rejected; it would leave a confusing mismatch between the
  app's real identity and its generated code's package.

## Decision: Physically move the Kotlin source file

- **Decision**: Move `MainActivity.kt` to a new directory path matching the real
  package (e.g. `android/app/src/main/kotlin/<company>/<app>/MainActivity.kt`), update
  its `package` declaration to match, and delete the now-empty old template directory.
- **Rationale**: Satisfies FR-002/FR-003/SC-002 — Kotlin/Android convention expects a
  class's file path to match its package declaration; leaving the old directory in
  place (even if unused) would be a stale, confusing leftover reference to the template
  package.
- **Alternatives considered**: Only editing the `package` line in-place without moving
  the file — rejected as it would leave the file at a path that no longer matches its
  declared package, which most Android tooling flags as inconsistent.

## Decision: No automated tests for this feature

- **Decision**: This feature has no `flutter test` coverage; verification is by
  building the Android target and inspecting the project's manifest/Gradle/Kotlin files
  for any remaining reference to the old template package.
- **Rationale**: Matches item 19's reasoning — this is Android build configuration and
  file layout, not Dart application logic, and outside Constitution Principle II's
  listed TDD scope.
- **Alternatives considered**: A shell script that greps the Android project for the old
  package string as a "test" — rejected as unnecessary tooling for a one-time,
  manually-verified rename; a plain grep is already how such a check would be performed
  ad hoc during verification.
