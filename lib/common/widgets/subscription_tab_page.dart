import 'package:flutter/material.dart';
import '../../utils/color_constants.dart';

/// An invitation within each tab, keeping navigation available to nonmembers.
class SubscriptionTabPage extends StatelessWidget {
  const SubscriptionTabPage({
    super.key,
    required this.tabIndex,
    required this.onSubscribe,
  });

  final int tabIndex;
  final VoidCallback onSubscribe;

  static const _content = [
    (
      title: 'Home',
      tint: ColorCodes.sand,
      subtitle: 'Your daily space to reconnect',
      icon: Icons.wb_sunny_outlined,
      headline: 'Make room for a calmer you.',
      description:
          'Build a daily ritual that brings you back to the present. Your space to pause, reflect, and begin again is here.',
      benefits: [
        'Daily grounding practices',
        'Guided meditations for your day',
        'A space to reflect and grow'
      ],
    ),
    (
      title: 'Community',
      tint: ColorCodes.blush,
      subtitle: 'A little more connected',
      icon: Icons.groups_outlined,
      headline: 'Feel connected on your journey.',
      description:
          'Join a shared space for mindful living. Share reflections and find encouragement in the experiences of others.',
      benefits: [
        'Connect with the community',
        'Share moments and reflections',
        'Support and encourage one another'
      ],
    ),
    (
      title: 'Track',
      tint: ColorCodes.sage,
      subtitle: 'Small steps, meaningful progress',
      icon: Icons.insights_rounded,
      headline: 'See your practice take shape.',
      description:
          'Give yourself a moment to notice how you feel. Reflect on your journey and recognize the small steps along the way.',
      benefits: [
        'Check in with your mood',
        'Reflect on your activity',
        'Follow your mindfulness journey'
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final content = _content[tabIndex];
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    return SafeArea(
      child: SingleChildScrollView(
        key: PageStorageKey('subscription-tab-$tabIndex'),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ANCHOR INTO PRESENCE',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      letterSpacing: 2.4,
                      fontWeight: FontWeight.w700,
                    )),
                const SizedBox(height: 12),
                Text(content.title,
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: colors.onSurface,
                      fontSize: 36,
                      height: 1.15,
                      letterSpacing: -1.2,
                      fontWeight: FontWeight.w800,
                    )),
                const SizedBox(height: 10),
                Text(content.subtitle,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colors.onSurfaceVariant,
                    )),
                const SizedBox(height: 18),
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ColorCodes.rose,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [content.tint, ColorCodes.cream],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: ColorCodes.mauve),
                    boxShadow: [
                      BoxShadow(
                        color: ColorCodes.charcoal
                            .withValues(alpha: dark ? .08 : .07),
                        blurRadius: 28,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: ColorCodes.rose,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(content.icon,
                            size: 40, color: ColorCodes.charcoal),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: ColorCodes.cream,
                          border: Border.all(color: ColorCodes.clay),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('MEMBERSHIP INCLUDES',
                            style: theme.textTheme.labelSmall?.copyWith(
                              letterSpacing: 1.3,
                              fontWeight: FontWeight.w700,
                              color: ColorCodes.charcoal,
                            )),
                      ),
                      const SizedBox(height: 12),
                      Text(content.headline,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: ColorCodes.charcoal,
                          )),
                      const SizedBox(height: 14),
                      Text(content.description,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.5,
                            color: ColorCodes.charcoal,
                          )),
                      const SizedBox(height: 24),
                      for (final benefit in content.benefits)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check_circle_outline_rounded,
                                  size: 21, color: ColorCodes.charcoal),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: Text(benefit,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                              color: ColorCodes.charcoal))),
                            ],
                          ),
                        ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: onSubscribe,
                          style: FilledButton.styleFrom(
                            backgroundColor: ColorCodes.charcoal,
                            foregroundColor: ColorCodes.cream,
                            shape: RoundedRectangleBorder(
                                side: const BorderSide(color: ColorCodes.mauve),
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Text('View subscription plans',
                                textAlign: TextAlign.center),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'One subscription. Access to Home, Community, and Track.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: ColorCodes.charcoal),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
