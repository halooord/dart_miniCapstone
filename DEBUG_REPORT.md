# Court IQ - Source Audit and Debug Report

**Audit target:** The original `CourtIQ_Flutter_CC302_Project.zip` supplied earlier in this conversation. The revised package preserves the five-tab basketball app and its features.

## What was checked

- Inspected every original `lib/` Dart file, `pubspec.yaml`, Android manifest, setup batch file, and existing tests.
- Checked navigation, state updates, JSON parsing, storage, form validation, delete confirmation, timers and API fallbacks.
- Added regression tests for NBA API success/HTTP failure/bad JSON structure and preference corruption.
- Verified revised ZIP contents, source references, asset presence and structured file configuration.

**Validation limitation:** Flutter/Dart is not installed in this workspace. This is a *static source audit*, not a successful Android compilation or emulator test. You must run `flutter analyze`, `flutter test`, and `flutter run -d emulator-5554` on your Windows laptop. Also validate the real ESPN endpoint at presentation time.

## Changes and why

| Area | Original risk | Revision |
|---|---|---|
| Android setup | ZIP had just a manifest, not a full Gradle Android project; earlier Android-v1 embedding/build errors. | New ZIP intentionally has NO partial `android/` directory; `setup_windows.bat` runs `flutter create` and patches generated main AndroidManifest with network permission. |
| Windows path | Windows batch/Gradle failed from path containing `CC(dart)`. | README and setup warn to use simple path such as `C:\FlutterProjects\CourtIQ`. |
| Drill add/edit sheet | `TextEditingController`s disposed immediately after the route returned; pop animation can still reference them. | Extracted `_DrillFormSheet` into its own `StatefulWidget` and disposes controllers in widget `dispose()`. |
| Profile name dialog | Same premature controller disposal risk; missing visible validation. | `_NameDialog` StatefulWidget owns its controller, has a `Form` validator. |
| Local preferences | One corrupted JSON list wiped both saved records and drills; `load()` could duplicate records if called twice. | Load each list independently, clear before loading, and keep other list when one fails. |
| Storage write failures | State already changed even if disk write failed. | Rollback in-memory changes and notify listeners when saves throw/return false. Screens show failure SnackBars. |
| Countdown | Counting callback ticks can lag when the app is backgrounded. | Record an end-time (`endsAt`), calculate remaining duration from the clock, resynchronize when Android resumes the app. |
| API testability | Real network was the only way to exercise API logic. | Accept an injectable `http.Client` and add mock-client tests for 200, 503 and malformed JSON. |
| Navigation labels | Small label text. | Increased floating-ribbon height and label size modestly. |

## Expected behavior and remaining limitations

- **Manual completion:** The user may press "Complete & save workout" before the timer reaches zero. This is intentionally a manual training log, **not** proof of physically finishing a drill. Explain this if asked.
- **No cloud account or login:** `shared_preferences` saves data on one device. Uninstalling/reinstalling or clearing app data may delete records. It is not synchronized across phones.
- **News API is third-party:** It can be slow, unavailable or change format. Retry, timeout, error states and clearly labeled offline tips provide recovery; offline tips do **not** satisfy live API demonstration.
- **Data changes must be tested on device:** In particular test form keyboard overlap, navigation tapping, save/delete, app restart, and the API response.
- **iPhone-style look vs device support:** The UI follows an iPhone-like floating ribbon, but the provided Windows build procedure targets Android. Building for iOS requires macOS/Xcode.

## Essential Windows commands

1. Extract updated ZIP to `C:\FlutterProjects\CourtIQ` (NOT a folder path containing parentheses). Open the **new** folder in VS Code.
2. In CMD:

```cmd
cd /d C:\FlutterProjects\CourtIQ
setup_windows.bat
flutter analyze
flutter test
flutter devices
flutter run -d emulator-5554
```

The new ZIP excludes generated Android/Web folders; the script regenerates them for your locally installed Flutter SDK. If you prefer manual setup, run `flutter create --project-name court_iq --platforms=android,web .`, then `powershell -NoProfile -ExecutionPolicy Bypass -File tools\configure_android.ps1`, then `flutter pub get`.

## Hands-on test checklist (do on emulator)

- [ ] Home loads, hero image displays, floating five tabs fit and are tappable.
- [ ] Train search and category filter work, with appropriate empty message.
- [ ] Create a custom drill; invalid title/description and duration are rejected.
- [ ] Edit the custom drill, open it, pause/reset timer, save workout.
- [ ] Progress count and chart update; delete session (Cancel then Confirm) updates stats.
- [ ] Force-close/reopen app and check workouts, drills, name and goal persisted.
- [ ] Profile name and weekly-goal changes reflect on Home; clear data confirmation works.
- [ ] Community loads live API; airplane mode triggers error; retry works when connected.
- [ ] Tap offline tips and verify they say **not live news**.
- [ ] Run `flutter analyze` and `flutter test` and fix anything they actually report.
