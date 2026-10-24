import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Called only after a first sign-in, once the main screen is mounted.
Future<void> showNewUserWelcome(BuildContext context, String token) async {
  try {
    final accountId = JwtDecoder.decode(token)['userId'];
    if (accountId is! String || accountId.isEmpty) return;
    final preferences = await SharedPreferences.getInstance();
    final key = 'welcome_seen_v1_$accountId';
    if (preferences.getBool(key) == true || !context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => const NewUserWelcomeDialog(),
    );
    await preferences.setBool(key, true);
  } catch (_) {
    // Onboarding must never prevent access to the app if storage is unavailable.
  }
}

class NewUserWelcomeDialog extends StatelessWidget {
  const NewUserWelcomeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 16, 28, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  tooltip: 'Close welcome',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.spa_outlined,
                    size: 40, color: colors.onSecondaryContainer),
              ),
              const SizedBox(height: 24),
              Text('Welcome to\nAnchor into Presence',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600, color: colors.onSurface)),
              const SizedBox(height: 16),
              Text('A little space to pause. A moment to come back to you.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.5, color: colors.onSurfaceVariant)),
              const SizedBox(height: 16),
              Text(
                  'Explore guided practices, build a mindful routine, and take each day at your own pace.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.6, color: colors.onSurfaceVariant)),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 52),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Let’s begin'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
