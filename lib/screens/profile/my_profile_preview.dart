import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/widgets/app_scaffold.dart';
import '../../common/widgets/custom_appbar.dart';
import '../../helping_widgets/user_provider/user_provider.dart';

/// A preview of upcoming profile features; no achievements or totals are implied.
class MyProfilePreview extends StatelessWidget {
  const MyProfilePreview({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final name = context.watch<UserProvider?>()?.name.trim() ?? '';
    return AppScaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: CustomAppbar(headingTxt: 'My profile', topPadding: 8),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 36,
                                backgroundColor: colors.secondaryContainer,
                                child: name.isEmpty
                                    ? Icon(Icons.person_outline_rounded,
                                        size: 34,
                                        color: colors.onSecondaryContainer)
                                    : Text(name.characters.first.toUpperCase(),
                                        style: theme.textTheme.headlineLarge
                                            ?.copyWith(
                                                color: colors
                                                    .onSecondaryContainer)),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text(
                                        name.isEmpty
                                            ? 'Your mindful journey'
                                            : name,
                                        style: theme.textTheme.headlineSmall
                                            ?.copyWith(
                                                fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 8),
                                    Text('Grow at your own pace.',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                                color:
                                                    colors.onSurfaceVariant)),
                                  ])),
                            ]),
                        const SizedBox(height: 24),
                        Text(
                            'A preview of your personal journey. These features are coming soon; your activity isn’t shown yet.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                                height: 1.5, color: colors.onSurfaceVariant)),
                        const SizedBox(height: 24),
                        const _FeatureCard(
                          title: 'Personal stats',
                          icon: Icons.insights_rounded,
                          description: 'Last 30 days · Preview',
                          child: _MetricPair(
                            firstLabel: 'Total minutes',
                            firstIcon: Icons.schedule_rounded,
                            secondLabel: 'Active days',
                            secondIcon: Icons.calendar_today_outlined,
                          ),
                        ),
                        const _FeatureCard(
                          title: 'Streak',
                          icon: Icons.local_fire_department_outlined,
                          description: 'A little consistency goes a long way.',
                          child: _MetricPair(
                            firstLabel: 'Current streak',
                            firstIcon: Icons.bolt_rounded,
                            secondLabel: 'Longest streak',
                            secondIcon: Icons.local_fire_department_outlined,
                          ),
                        ),
                        _FeatureCard(
                          title: 'Skills',
                          icon: Icons.spa_outlined,
                          description:
                              'Explore the qualities you’ll nurture through practice.',
                          child: Wrap(spacing: 8, runSpacing: 8, children: [
                            for (final skill in [
                              'Awareness',
                              'Focus',
                              'Self-compassion'
                            ])
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                    color: colors.surface,
                                    borderRadius: BorderRadius.circular(20)),
                                child: Text(skill,
                                    style: theme.textTheme.labelMedium),
                              ),
                          ]),
                        ),
                        _FeatureCard(
                          title: 'Badges',
                          icon: Icons.workspace_premium_outlined,
                          description:
                              'Celebrate the little milestones along the way.',
                          child: Row(children: [
                            for (final icon in [
                              Icons.eco_outlined,
                              Icons.wb_sunny_outlined,
                              Icons.auto_awesome_outlined
                            ])
                              Expanded(
                                  child: ExcludeSemantics(
                                      child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                child: Icon(icon,
                                    size: 36, color: colors.onSurfaceVariant),
                              ))),
                          ]),
                        ),
                      ]),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard(
      {required this.title,
      required this.icon,
      required this.description,
      required this.child});
  final String title;
  final IconData icon;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
          border:
              Border.all(color: colors.outlineVariant.withValues(alpha: .4))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 22, color: colors.onSurface),
              const SizedBox(width: 8),
              Flexible(
                  child: Text(title,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600))),
            ]),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  borderRadius: BorderRadius.circular(20)),
              child: Text('Coming soon',
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSecondaryContainer,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(description,
            style: theme.textTheme.bodyMedium
                ?.copyWith(height: 1.5, color: colors.onSurfaceVariant)),
        const SizedBox(height: 20),
        child,
      ]),
    );
  }
}

class _MetricPair extends StatelessWidget {
  const _MetricPair(
      {required this.firstLabel,
      required this.firstIcon,
      required this.secondLabel,
      required this.secondIcon});
  final String firstLabel;
  final IconData firstIcon;
  final String secondLabel;
  final IconData secondIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget metric(String label, IconData icon) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 24, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 10),
              Text('—',
                  semanticsLabel: 'Not available yet',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 8),
            Text(label,
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        );
    return LayoutBuilder(builder: (context, constraints) {
      final first = metric(firstLabel, firstIcon);
      final second = metric(secondLabel, secondIcon);
      if (constraints.maxWidth < 260 ||
          MediaQuery.textScalerOf(context).scale(14) > 21) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [first, const Divider(height: 32), second]);
      }
      return IntrinsicHeight(
          child: Row(children: [
        Expanded(child: first),
        const VerticalDivider(width: 32),
        Expanded(child: second),
      ]));
    });
  }
}
