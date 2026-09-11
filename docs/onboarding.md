# Welcome screen versions

The illustrated three-page welcome is the default. All existing entry points still
use `WelcomeScreen`; the account and signed-in navigation destinations are unchanged.

The original UI is preserved in
`lib/screens/welcome/legacy_welcome_screen.dart`. Only the class name changed.

## Restore the original UI

Add this flag to your usual Flutter run or build command:

```sh
flutter run --dart-define=USE_LEGACY_ONBOARDING=true
flutter build apk --dart-define=USE_LEGACY_ONBOARDING=true
flutter build ipa --dart-define=USE_LEGACY_ONBOARDING=true
```

Remove the flag (or set it to `false`) to use the illustrated version again.
Changing a compile-time flag requires stopping and restarting the app, or rebuilding
the release; hot reload does not switch versions. Include the same flag in CI release
builds when shipping the original UI.

To make the original version the default for everyone, set `defaultValue: true` in
`lib/screens/welcome/welcome_screen.dart` instead. No other files need to change.

The new artwork lives in `assets/images/onboarding/` and is independent of the old
welcome background. No onboarding-completed preference is added, so the existing
startup behavior is preserved.

## Brand palette and dark mode

The illustrated welcome follows the app's active `ThemeData` (system light/dark
mode in the main app). Backgrounds, text, buttons, progress indicators, disabled
states and system bars use the app's warm neutral palette. Each scene has matching
`-light.png` and `-dark.png` artwork so dark mode does not show a bright image panel.
Changing theme preserves the current onboarding page. The legacy screen is untouched.

Render both themes and run navigation/contrast checks with:

```sh
flutter test test/welcome_screen_test.dart --dart-define=CAPTURE_ONBOARDING=true
```

Previews are saved as `build/onboarding-light-1.png` through `-3.png` and
`build/onboarding-dark-1.png` through `-3.png`.
