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
states and system bars use the app's warm neutral palette. The sunrise and sunset
mascots use transparent watercolor artwork that blends into either theme without
a bright image panel. Theme and step select the artwork independently:

| Step | Light mode | Dark mode | Expression |
| --- | --- | --- | --- |
| Find your calm | `sunrise.png` | `sunset.png` | Calm, gentle smile |
| Make room for rest | `sunrise-rest.png` | `sunset-rest.png` | Sleepy, relaxed yawn |
| Feel more connected | `sunrise-connected.png` | `sunset-connected.png` | Happy, welcoming smile |

All images live in `assets/images/onboarding/`. Sunrise appears only in light
mode and sunset only in dark mode. Changing theme preserves the current step
and its expression. Expression variants were made with the built-in imagegen
tool; prompts are recorded in `docs/onboarding-artwork-prompts.md`.
The shared `BeachIllustration` widget frames each sun image with a sandy
shoreline and two muted palm trees. Its scenery adapts to light and dark mode
and scales with the illustration area.
Changing theme preserves the current onboarding page. The legacy screen is untouched.

Render both themes and run navigation/contrast checks with:

```sh
flutter test test/welcome_screen_test.dart --dart-define=CAPTURE_ONBOARDING=true
```

Previews are saved as `build/onboarding-light-1.png` through `-3.png` and
`build/onboarding-dark-1.png` through `-3.png`.
