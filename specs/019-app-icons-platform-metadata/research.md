# Phase 0 Research: App Icons & Platform Metadata

## Decision: `flutter_launcher_icons` for icon generation

- **Decision**: Use the `flutter_launcher_icons` package, configured in `pubspec.yaml`,
  to generate per-platform icon assets from a single source image.
- **Rationale**: Satisfies FR-001/FR-003/SC-001 without hand-producing every required
  resolution/format for each platform; it's the standard Flutter-ecosystem tool for
  exactly this job.
- **Alternatives considered**: Manually exporting and placing every platform's icon
  files — rejected as tedious and error-prone compared to a generator driven by one
  source asset and one config block.

## Decision: Set the display name once per platform's own metadata format

- **Decision**: Each platform keeps its display name in its own native metadata format
  (Android manifest attribute, iOS plist keys, web manifest/HTML, Windows resource
  file, macOS xcconfig, Linux C++ source) rather than a shared cross-platform config.
- **Rationale**: Satisfies FR-002/SC-002 — there is no single Flutter-level API that sets
  every platform's display name at once; each platform's runner already has its own
  canonical location for this string, per Constitution Principle IV's guidance that
  platform-specific content belongs in the platform runner directories.
- **Alternatives considered**: A build-time script templating all these files from one
  source string — rejected as unnecessary tooling for a name that changes rarely, if
  ever.

## Decision: No automated tests for this feature

- **Decision**: This feature has no `flutter test` coverage; verification is by
  building/inspecting each platform target.
- **Rationale**: Icons and platform metadata are outside Constitution Principle II's
  listed TDD scope (guess scoring, word-list parsing, save/restore, stats, user-visible
  *in-app* interaction) — there is no Dart logic here for `flutter_test` to exercise, and
  a real per-platform icon/name check requires actually building for that platform,
  which is a manual/CI build-verification concern, not a unit or widget test.
- **Alternatives considered**: A test asserting `pubspec.yaml`'s
  `flutter_launcher_icons` config values via file-content parsing — rejected as a
  low-value test of a config file's text rather than of actual behavior.
