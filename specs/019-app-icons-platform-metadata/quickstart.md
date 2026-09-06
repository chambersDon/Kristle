# Quickstart: App Icons & Platform Metadata

## Try it

```bash
dart run flutter_launcher_icons
flutter build apk    # or: ios, web, windows, macos, linux
```

Install/run the built target and confirm its icon and display name are Kristle's, not
the Flutter default.

## Validate

No `flutter test` coverage applies (platform build configuration, not application
logic — see [research.md](research.md)). Verify by building and inspecting each of the
six platform targets per [spec.md](spec.md)'s acceptance scenarios.
