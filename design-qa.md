# Bottom navigation visual QA

Source: User-attached 582 × 182 reference image, showing a five-tab frosted bar inside a phone frame.
Implementation: /tmp/app-tab-bar.png, 780 × 226 pixels, rendered from AppTabBar at 2× density (390 × 113 logical pixels including 34-pixel bottom safe area).
State: Profile selected. Existing four destinations intentionally retained: Home, Community, Track, Profile.

The component preview shows rounded top corners, pale blue translucent material, blue icons above labels, and a darker selected Profile tab. The supplied reference remains visible in the conversation. A normalized combined reference/implementation image was not available, and the complete running app was not captured in this pass.

Comparison history: The initial test capture lacked the Material icon font and showed missing-glyph squares. Loaded the real MaterialIcons font in the capture harness and recaptured; all four icons now render correctly.

Verification: Two widget tests passed for destination callbacks, light/dark layouts, narrow width, large text, and bottom safe area. Targeted source analysis passed. Subscription gating logic remains in MainScreen.

Remaining verification: Full-app rendering of translucency and page bottom insets, and normalized combined image comparison. No claim of a full-app visual QA pass.

final result: blocked
