# Feature Specification: Android Package Rename

**Feature Branch**: `020-android-package-rename`

**Created**: 2026-09-06

**Status**: Draft

**Input**: User description: "Android package rename: move the Android app's package/applicationId off the Flutter-template default (com.example.my_wordle) onto the real one, including the generated Kotlin MainActivity moving to the new package path."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - The Android app is identified by its real package, not a template default (Priority: P3)

The Android build of the app is installed and identified on-device using its real,
final application ID rather than the placeholder `com.example.*` package every new
Flutter project starts with.

**Why this priority**: This matters before any real Android release (app store
listings, upgrades, package-name collisions), but has no effect on gameplay and is the
lowest-impact, most one-time item in this build-order.

**Independent Test**: Can be fully tested by building the Android target and confirming
its installed package name/application ID matches the real one, not the template
default.

**Acceptance Scenarios**:

1. **Given** the Android build target, **When** it is built, **Then** its
   `applicationId` and package namespace are the real, final package name, not
   `com.example.my_wordle`.
2. **Given** the Android build target, **When** it is built, **Then** the generated
   Kotlin `MainActivity` resolves under the new package's directory path, not the old
   template one.
3. **Given** the Android build has already been renamed once, **When** it is rebuilt
   again later, **Then** no leftover reference to the old template package remains
   anywhere in the Android project (manifest, Gradle config, Kotlin source path).

### Edge Cases

- What happens to a device that already has the app installed under the old package
  name from before this rename? This feature does not define an in-place upgrade path
  from the old package to the new one — that is out of scope, since the app has not yet
  had a real release under the old name.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The Android build's `applicationId` and namespace MUST be the real, final
  package name, not the Flutter template default.
- **FR-002**: The generated Kotlin `MainActivity` MUST live at the directory path
  matching the new package name, with the old template package's directory removed.
- **FR-003**: No file in the Android project (manifest, Gradle build files, Kotlin
  source) MUST reference the old template package name after the rename.

### Key Entities

*(none — this feature is platform build configuration, not application data)*

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of Android build artifacts (APK/AAB metadata, installed package
  name) reflect the real, final package name.
- **SC-002**: 0% of files in the Android project reference the old template package
  name after the rename.

## Assumptions

- The real, final package name itself is a fixed product/business decision, not an open
  choice for this feature.
- This feature is platform build configuration (Android Gradle/manifest/Kotlin source
  layout) rather than application (Dart) logic — it has no unit- or widget-testable
  behavior; verification is by building the Android target and inspecting its project
  files, not by `flutter test`.
