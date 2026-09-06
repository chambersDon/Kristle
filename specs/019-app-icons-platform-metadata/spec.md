# Feature Specification: App Icons & Platform Metadata

**Feature Branch**: `019-app-icons-platform-metadata`

**Created**: 2026-09-06

**Status**: Draft

**Input**: User description: "App icons & platform metadata: generate/configure per-platform app icons and app display name across all six build targets."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - The app shows its own icon and name on every platform (Priority: P2)

Wherever a platform surfaces an app icon or display name (home screen, taskbar, browser
tab, dock, app switcher), it shows Kristle's own icon and the name "Kristle" — not a
generic default icon or a placeholder project name.

**Why this priority**: This is an identity/polish concern for how the app appears
outside its own window; it doesn't affect in-app gameplay.

**Independent Test**: Can be fully tested by building/inspecting each of the six
platform targets and confirming the icon and display name are correct for that
platform's surface (launcher icon, window title, tab title, etc.).

**Acceptance Scenarios**:

1. **Given** the Android build target, **When** it is installed, **Then** its launcher
   icon is Kristle's icon and its display name is "Kristle."
2. **Given** the iOS build target, **When** it is installed, **Then** its home-screen
   icon is Kristle's icon and its display name is "Kristle."
3. **Given** the web build target, **When** it is opened in a browser, **Then** its tab
   icon and title reflect Kristle's branding.
4. **Given** the Windows, macOS, or Linux build target, **When** it is run, **Then** its
   window/taskbar/dock icon and title reflect Kristle's branding.

### Edge Cases

- What happens on a platform where an adaptive/foreground-background icon split is
  supported (Android)? Both layers MUST be configured so the icon renders correctly
  across different launcher icon shapes.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Every one of the six configured build targets MUST use Kristle's icon
  wherever that platform surfaces an app icon.
- **FR-002**: Every one of the six configured build targets MUST use "Kristle" wherever
  that platform surfaces an app/window/tab display name.
- **FR-003**: The Android target's adaptive icon MUST have both a background and a
  foreground layer configured from Kristle's icon artwork.

### Key Entities

*(none — this feature is platform build configuration and static assets, not
application data)*

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of the six build targets show Kristle's icon on their platform's icon
  surface.
- **SC-002**: 100% of the six build targets show "Kristle" on their platform's display-
  name surface.

## Assumptions

- The icon artwork itself is a fixed design asset, not an open design choice for this
  feature.
- This feature is platform build configuration (icon generation tooling, per-platform
  metadata files) rather than application (Dart) logic — it has no unit- or
  widget-testable behavior of its own; verification is by building/inspecting each
  platform target, not by `flutter test`.
