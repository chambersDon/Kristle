# Implementation Plan: App Icons & Platform Metadata

**Branch**: `019-app-icons-platform-metadata` | **Date**: 2026-09-06 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/019-app-icons-platform-metadata/spec.md`

## Summary

Configure `flutter_launcher_icons` in `pubspec.yaml` (`image_path`,
`adaptive_icon_background`, `adaptive_icon_foreground`) pointing at
`assets/icon/kristle_icon.png`, run its generator to produce per-platform icon assets,
and set the display name "Kristle" in each platform's metadata file: Android's
`AndroidManifest.xml`, iOS's `Info.plist` (`CFBundleDisplayName`/`CFBundleName`), the
web `manifest.json`/`index.html`, and the Windows/macOS/Linux runner
resource/plist/source files. This plan implements the icon/metadata configuration
across `pubspec.yaml` and the platform runner directories
(`android/`, `ios/`, `web/`, `windows/`, `macos/`, `linux/`) per ROADMAP.md item 19.

## Technical Context

**Language/Version**: N/A — platform build configuration, not Dart application code

**Primary Dependencies**: `flutter_launcher_icons` (dev dependency, icon generation
tooling)

**Testing**: N/A — no unit/widget-testable behavior; verified by building/inspecting
each platform target (per spec's Assumptions)

**Target Platform**: All six configured Flutter targets (Constitution Principle IV)

**Constraints**: Icon artwork and exact metadata strings are fixed design/branding
decisions, not open choices for this feature

**Scale/Scope**: `pubspec.yaml`'s `flutter_launcher_icons` config, generated icon
assets, and one display-name string per platform's metadata file

## Constitution Check

- **I–III** — N/A. No application code, no widgets, no persisted models.
- **IV. Single Codebase, All Platforms** — PASS. Per-platform metadata differences are
  expected/required here (platform build configuration is explicitly the confined,
  acceptable location for platform-specific content per Constitution Principle IV).
- **V. Local-First, No Backend** — PASS. No network calls.
- **VI. Lint-Clean, Analyzer-Enforced Style** — N/A. No Dart source changes.

No violations.

## Project Structure

```text
pubspec.yaml                                   # flutter_launcher_icons config
assets/icon/kristle_icon.png                   # icon source artwork
android/app/src/main/AndroidManifest.xml       # display name
ios/Runner/Info.plist                          # display name
web/manifest.json, web/index.html              # display name / tab title
windows/runner/Runner.rc                       # display name
macos/Runner/Configs/AppInfo.xcconfig          # display name
linux/runner/my_application.cc                 # display name
```

**Structure Decision**: No new directories; existing per-platform runner metadata files
are the target of this feature.

## Complexity Tracking

*No violations — table not applicable.*
