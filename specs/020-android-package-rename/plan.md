# Implementation Plan: Android Package Rename

**Branch**: `020-android-package-rename` | **Date**: 2026-09-06 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/020-android-package-rename/spec.md`

## Summary

Set `namespace` and `applicationId` in `android/app/build.gradle.kts` to the real
package name, move the generated Kotlin `MainActivity.kt` to a directory path matching
that package (deleting the old `com/example/my_wordle/` directory), and update the
package declaration inside `MainActivity.kt` and any manifest/Gradle references
accordingly. This plan implements the rename across
`android/app/build.gradle.kts`, `android/app/src/main/AndroidManifest.xml`, and
`android/app/src/main/kotlin/` per ROADMAP.md item 20.

## Technical Context

**Language/Version**: N/A — Android build configuration and Kotlin file layout, not
Dart application code

**Primary Dependencies**: Android Gradle Plugin (via the Flutter Android build)

**Testing**: N/A — no unit/widget-testable behavior; verified by building the Android
target and inspecting project files (per spec's Assumptions)

**Target Platform**: Android only (the other five targets are unaffected)

**Constraints**: The real package name itself is a fixed decision, not an open choice
for this feature

**Scale/Scope**: `android/app/build.gradle.kts`'s `namespace`/`applicationId`, the
Kotlin source directory path, and any manifest reference to the old package

## Constitution Check

- **I–III** — N/A. No application code, no widgets, no persisted models.
- **IV. Single Codebase, All Platforms** — PASS. This change is entirely confined to
  the Android platform runner directory, per Constitution Principle IV's guidance that
  platform-specific content belongs there.
- **V. Local-First, No Backend** — PASS. No network calls.
- **VI. Lint-Clean, Analyzer-Enforced Style** — N/A. No Dart source changes.

No violations.

## Project Structure

```text
android/app/build.gradle.kts                                  # namespace / applicationId
android/app/src/main/AndroidManifest.xml                       # package references
android/app/src/main/kotlin/<new/package/path>/MainActivity.kt # moved Kotlin source
```

**Structure Decision**: No new directories beyond the renamed Kotlin package path
itself; the old `com/example/my_wordle/` directory is removed.

## Complexity Tracking

*No violations — table not applicable.*
