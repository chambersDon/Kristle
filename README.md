# Kristle

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Continuous Deployment

Every push runs the full `flutter test` suite via `.github/workflows/ci-cd.yml`. When all tests
pass on a push to `main`, the workflow automatically builds a signed Android App Bundle and
publishes it to the Google Play Store's **Production** track — no manual build, sign, or upload
step. Pushes to other branches and pull requests only run the test suite; they never deploy.

Release signing and Play Store publishing require these GitHub Actions repository secrets to be
configured (Settings → Secrets and variables → Actions) — values only, never commit them:

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`
- `PLAY_STORE_SERVICE_ACCOUNT_JSON`

For a local release build (`flutter build appbundle --release` or `flutter run --release`), copy
`android/key.properties.example` to `android/key.properties` (gitignored) and fill in your own
keystore path and passwords.
