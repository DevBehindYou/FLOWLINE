# Flowline

A local-first Android app for focused work: time-blocked planning, a
Pomodoro focus timer that stays correct across backgrounding and process
death, and a bring-your-own-key AI assistant (Anthropic, OpenAI, Google
Gemini, or a local Ollama server). No account, no backend, no telemetry —
your data stays in an on-device SQLite database and your API keys in the
Android Keystore.

Built with Flutter, Riverpod, Drift and go_router.

## Status

Phases 1–5 and Export are built; see
[`PROJECT_OVERVIEW.md`](PROJECT_OVERVIEW.md) for exactly what the app does
today, what's verified by CI and what's still unverified on a device.
What's next, in order, is in
[`docs/04-build-and-optimization-plan.md`](docs/04-build-and-optimization-plan.md).

| Doc | What it's for |
|---|---|
| [`PROJECT_OVERVIEW.md`](PROJECT_OVERVIEW.md) | As-built architecture, data model, screens, known issues |
| [`docs/04-build-and-optimization-plan.md`](docs/04-build-and-optimization-plan.md) | Forward plan: phases, engineering rules, defect register |
| [`docs/README.md`](docs/README.md) | Index of the planning docs, UX spec and design tokens |
| [`docs/history.md`](docs/history.md) | The original phase-by-phase build log |

## Getting an APK

CI (`.github/workflows/ci.yml`) is the build environment: every push to
`main` and every pull request runs format, analyze, tests, and a release
APK build. Download `flowline-arm64-v8a-release-<sha>.apk` from the run's
**Artifacts** (`flowline-release-apks-<sha>`) and install it on the phone.

Each build has a higher `versionCode` (the CI run number), so a newer APK
installs over an older one **as long as both are signed with the same
key** — see the next section.

## Release signing

Android only lets a new APK replace an installed one when both are signed
with the same key. If the key changes, the only way to install is to
uninstall first, which **deletes the app's local data**.

CI signs release APKs with the key stored in these repository secrets
(*Settings → Secrets and variables → Actions*):

| Secret | Value |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | The `.jks` keystore, base64-encoded on one line |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password |
| `ANDROID_KEY_ALIAS` | Key alias |
| `ANDROID_KEY_PASSWORD` | Key password |

CI checks every APK's certificate against
[`tool/ci/release_cert_sha256.txt`](tool/ci/release_cert_sha256.txt) and
fails if they don't match. When the secrets are missing (forks, or before
they're added), CI signs with a throwaway key and says so in the run
summary: those APKs are for testing and won't update an existing install.

Keep the keystore and its password in a password manager. If they're lost,
installed copies can only be replaced by uninstalling.

## Building locally (optional)

CI does all of this; you only need it to build outside CI. Use the Flutter
version pinned in `ci.yml` (`FLUTTER_VERSION`; see the comment there for
why it's pinned).

```sh
# android/ is generated, not committed: create it next to this checkout
flutter create --platforms android --org com.devbehindyou .
dart run tool/ci/patch_android.dart android   # permissions, receivers, backup rules, signing
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test
flutter run
```

`tool/ci/android_patches.dart` documents each change applied to the
generated Android project and why (release `INTERNET` permission,
notification receivers, core library desugaring, cleartext for Ollama,
Auto Backup rules, release signing). For a signed local release build,
put a `key.properties` with `storeFile`, `storePassword`, `keyAlias` and
`keyPassword` in `android/`.

## License

See [`LICENSE`](LICENSE).
