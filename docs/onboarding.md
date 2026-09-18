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

The illustrated welcome now uses the **Golden Stillness** direction from
`../design/mandala-light-concepts/golden-stillness.png` (the selected
`output/mandala-light-concepts/01-golden-stillness.png` reference).

All three steps use the global `AppBackground` from
`lib/common/widgets/app_scaffold.dart`, including its existing light/dark cloud
textures (`assets/images/app-background-light.png` and `app-background-dark.png`)
and the shared theme surface color. The background covers the complete screen,
including the safe areas, and stays fixed while the onboarding pages swipe.

The mandala uses `assets/images/onboarding/golden-stillness-petals.png`, a
transparent PNG containing only the gold petals. The background disc, dotted
halo and outer circle have been removed. Light mode uses `golden-stillness-petals-light.png`, cleaned of residual
background haze. Dark mode keeps `golden-stillness-petals.png`. Clouds remain
visible between the petals in both appearances.
Light-mode onboarding applies `textureContrast: 1.6` to the shared background
to make its pale clouds clearer. Other screens retain the default contrast.
The older source crop and generated halo variants are retained as references.

The UI follows the system appearance through the existing app `ThemeData`;
dark mode uses a champagne-gold primary button and indicators. Changing system
appearance preserves the current page.

Skip, Next, Back, swiping, and Start keep their existing behavior. Large text
and short/landscape displays can scroll the content while the action stays
reachable. The previous beach artwork and legacy screen remain available in
the repository.

Render both themes and run navigation/contrast checks with:

```sh
flutter test test/welcome_screen_test.dart --dart-define=CAPTURE_ONBOARDING=true
```

Previews are saved as `build/onboarding-light-1.png` through `-3.png` and
`build/onboarding-dark-1.png` through `-3.png`.
