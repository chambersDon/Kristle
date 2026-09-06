# Quickstart: Android Package Rename

## Try it

```bash
flutter build apk
```

Inspect the built APK's manifest (e.g. via `aapt dump badging`) and confirm its package
name is the real, final one — not `com.example.my_wordle`.

## Validate

No `flutter test` coverage applies (Android build configuration, not application logic
— see [research.md](research.md)). Verify by building the Android target and grepping
`android/` for any remaining reference to the old template package name.
