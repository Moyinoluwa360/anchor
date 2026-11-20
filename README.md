# Anchor

A calm, local-only productivity app for iOS: one thing at a time, tiny first
steps, energy-aware plans, and progress that is celebrated, never shamed.

- Spec (source of truth): [docs/SPEC.md](docs/SPEC.md)
- Build plan and progress: [docs/BUILD_PLAN.md](docs/BUILD_PLAN.md)
- Codemagic / TestFlight setup (one time): [docs/CODEMAGIC_SETUP.md](docs/CODEMAGIC_SETUP.md)

## Stack

Flutter · Riverpod · go_router · Drift (SQLite) · flutter_local_notifications ·
audioplayers · home_widget · live_activities. No server, no accounts, no
analytics; the only permission requested is notifications.

## Folders

```
lib/
  models/      enums, date helpers
  data/        Drift database, repositories, seed data
  providers/   Riverpod providers (data, settings, UI state)
  services/    timer, planner, notifications, streaks …
  screens/     now, today, week, goals, done, shell, settings …
  widgets/     glass bar, streak bubble, shared pieces
  theme/       colour tokens, type scale, ThemeData
assets/        bundled fonts, alarm sound
ios/           native files (no Xcode needed: Codemagic builds them)
tool/          build scripts used by Codemagic
test/          unit + widget tests
test_screens/  renders every screen to PNG for a visual check on Windows
```

## Everyday commands (Windows, from this folder)

```powershell
flutter pub get                       # after pulling or changing pubspec.yaml
dart run build_runner build           # after changing lib/data/database.dart
flutter analyze                       # must say "No issues found!"
flutter test                          # must say "All tests passed!"
flutter test test_screens --update-goldens   # screenshots → test_screens/out/
```

## Ship a TestFlight build

```powershell
git add -A
git commit -m "Describe the change"
git push
```

Every push to `main` makes Codemagic analyze, test, build, sign and upload a new
TestFlight build (build number = latest TestFlight build + 1). Install it from
the TestFlight app on the iPhone.
