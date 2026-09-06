# Phase 0 Research: Branding Pass

## Decision: `Image.asset` directly as the app bar title

- **Decision**: The app bar's `title` widget is `Image.asset('assets/kristle_header.png',
  key: Key('header-image'), fit: BoxFit.contain, height: 80)` when the answer isn't
  revealed (item 17 swaps it for text when revealed).
- **Rationale**: Satisfies FR-001/SC-001 with the simplest possible approach — no custom
  widget needed, and the fixed `Key` gives tests (and item 17's reveal toggle) a stable
  way to find it.
- **Alternatives considered**: A `Text` title alongside a small logo icon — rejected as
  not matching the spec's "swap the plain title for the header image" description.

## Decision: A plain, unwrapped `Container` for the placeholder bar

- **Decision**: The bottom placeholder is a `Container` with a border/background/rounded
  corners and a centered `Text`, with no `GestureDetector`/`InkWell`/`onTap` wrapping it.
- **Rationale**: Satisfies FR-003 — a plain `Container` has no gesture recognizer at all,
  so it is inert by construction; there's nothing to accidentally wire up later without a
  deliberate code change.
- **Alternatives considered**: Wrapping it in a disabled button — rejected as
  unnecessarily implying future interactivity the spec doesn't call for.

## Decision: Testing approach

- **Decision**: `flutter_test` widget tests asserting `find.byKey(const
  Key('header-image'))` finds exactly one `Image` widget with the expected asset path,
  and that the placeholder bar's text is present with no tappable ancestor
  (`GestureDetector`/`InkWell`) between it and the screen.
- **Rationale**: Directly verifies FR-001/FR-002/FR-003 without needing golden-image
  comparison.
- **Alternatives considered**: Golden-image tests for the exact visual appearance —
  rejected as overkill; this project has no golden-test precedent (per item 1's own
  research) and structural assertions are sufficient here.
