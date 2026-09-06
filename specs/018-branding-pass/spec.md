# Feature Specification: Branding Pass

**Feature Branch**: `018-branding-pass`

**Created**: 2026-09-06

**Status**: Draft

**Input**: User description: "Branding pass (header art + placeholder ad slot): swap the plain title for the Kristle header image in the app bar, and add the inert bottom placeholder bar reserved for a future ad slot."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - The app displays branded header art (Priority: P2)

The app bar shows the Kristle header image (logo/wordmark) instead of a plain text
title, giving the app a distinct, on-brand identity.

**Why this priority**: This is a visual-identity improvement, not core gameplay; it
matters for polish but doesn't affect whether the game is playable.

**Independent Test**: Can be fully tested by rendering the screen and confirming the
header image is present in the app bar in place of a plain text title.

**Acceptance Scenarios**:

1. **Given** the app is displayed, **When** the app bar is inspected, **Then** the
   Kristle header image is shown in place of a plain text title.

---

### User Story 2 - A placeholder ad slot is reserved at the bottom (Priority: P3)

A visually distinct, inert bar reserved for a future ad sits at the bottom of the
screen, so the eventual ad integration has a known, already-designed space to occupy.

**Why this priority**: This reserves layout space for a future integration; it has no
functional behavior of its own and is the lowest-impact part of this feature.

**Independent Test**: Can be fully tested by rendering the screen and confirming a
distinct placeholder bar is present at the bottom, with no interactive behavior.

**Acceptance Scenarios**:

1. **Given** the app is displayed, **When** the bottom of the screen is inspected,
   **Then** a visually distinct placeholder bar is present, taking up space but
   performing no action when interacted with.

### Edge Cases

- What happens if the header image asset fails to load? This feature does not define a
  fallback for the header image (unlike the win-celebration image, item 12, which has
  its own explicit fallback) — the header image is a static branding asset expected to
  always be bundled.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The app bar MUST display the Kristle header image in place of a plain text
  title.
- **FR-002**: The screen MUST include a visually distinct placeholder bar at the bottom,
  reserved for a future ad slot.
- **FR-003**: The placeholder bar MUST be inert — it MUST NOT trigger any action when
  tapped.

### Key Entities

*(none — this feature adds static branding presentation only)*

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of screen renders show the header image in the app bar, with no plain
  text title visible.
- **SC-002**: 100% of screen renders show the placeholder bar at the bottom.

## Assumptions

- The header image and the placeholder bar's exact visual styling (colors, text, sizing)
  are fixed product/design decisions, not open choices for this feature.
- This feature is purely additive presentation on top of the existing screen (item 7 and
  later); it changes no gameplay behavior.
