import 'package:flutter/material.dart';

/// A membership comparison card using the store's localized price strings.
class SubscriptionPlanCard extends StatelessWidget {
  const SubscriptionPlanCard({
    super.key,
    required this.title,
    required this.price,
    required this.period,
    required this.isActive,
    required this.onChoose,
    this.originalPrice,
    this.isFounding = false,
  });

  final String title;
  final String price;
  final String period;
  final String? originalPrice;
  final bool isActive;
  final bool isFounding;
  final VoidCallback onChoose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final annual = period.toLowerCase().contains('year');
    final highlighted = annual || isFounding;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: highlighted
            ? Color.alphaBlend(
                colors.primary.withValues(alpha: .08), colors.surface)
            : colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isActive ? colors.primary : colors.outlineVariant,
            width: isActive ? 1.5 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(title,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w600, height: 1.3)),
              if (isActive || isFounding)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(isActive ? 'Current plan' : 'Founding member',
                      style: theme.textTheme.labelMedium?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w500)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
              annual
                  ? 'Make presence part of the year ahead.'
                  : 'Find your rhythm, one month at a time.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: colors.onSurfaceVariant, height: 1.5)),
          const SizedBox(height: 28),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(price,
                      style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: -1,
                          height: 1.2)),
                ),
              ),
              Text(period,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: colors.onSurfaceVariant)),
            ],
          ),
          if (originalPrice != null) ...[
            const SizedBox(height: 6),
            Text(originalPrice!,
                style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    decoration: TextDecoration.lineThrough)),
          ],
          const SizedBox(height: 10),
          Text(annual ? 'Billed annually.' : 'Billed monthly.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: colors.onSurfaceVariant)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: highlighted
                ? FilledButton.icon(
                    onPressed: isActive ? null : onChoose,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      shape: const StadiumBorder(),
                    ),
                    icon: Icon(
                        isActive
                            ? Icons.check_rounded
                            : Icons.arrow_forward_rounded,
                        size: 20),
                    iconAlignment: IconAlignment.end,
                    label: Text(
                        isActive ? 'Your current plan' : 'Choose annual',
                        textAlign: TextAlign.center),
                  )
                : OutlinedButton.icon(
                    onPressed: isActive ? null : onChoose,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.onSurface,
                      side: BorderSide(color: colors.outline),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      shape: const StadiumBorder(),
                    ),
                    icon: Icon(
                        isActive
                            ? Icons.check_rounded
                            : Icons.arrow_forward_rounded,
                        size: 20),
                    iconAlignment: IconAlignment.end,
                    label: Text(
                        isActive ? 'Your current plan' : 'Choose monthly',
                        textAlign: TextAlign.center),
                  ),
          ),
          const SizedBox(height: 28),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.auto_awesome_outlined, size: 22, color: colors.primary),
            const SizedBox(width: 12),
            Expanded(
                child: Text(
                    annual
                        ? 'All monthly membership features:'
                        : 'Everything in Free, plus:',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600))),
          ]),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Divider(height: 1, color: colors.outlineVariant),
          ),
          for (final feature in const [
            'Full access to Home and the practice Library',
            'Daily Anchors and Daily Pauses',
            'Save your favorite practices',
            'Connect and share in the Community',
            'Mood check-ins and progress tracking',
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.check_rounded, size: 22, color: colors.primary),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(feature,
                        style:
                            theme.textTheme.bodyMedium?.copyWith(height: 1.4))),
              ]),
            ),
        ],
      ),
    );
  }
}
