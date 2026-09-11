import 'package:flutter/material.dart';

import 'illustrated_welcome_screen.dart';
import 'legacy_welcome_screen.dart';

/// Keep the original welcome available for client review and quick rollback.
/// Run/build with --dart-define=USE_LEGACY_ONBOARDING=true to restore it.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const useLegacyOnboarding = bool.fromEnvironment(
    'USE_LEGACY_ONBOARDING',
    defaultValue: false,
  );

  @override
  Widget build(BuildContext context) => useLegacyOnboarding
      ? const LegacyWelcomeScreen()
      : const IllustratedWelcomeScreen();
}
