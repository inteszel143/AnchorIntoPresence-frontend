import 'package:flutter/material.dart';

/// A compact comparison card using the store's localized price strings.
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isActive
            ? Color.alphaBlend(
                colors.primary.withValues(alpha: .06), colors.surface)
            : colors.surfaceContainerHighest,
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
                  style: theme.textTheme.titleMedium
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
                          fontWeight: FontWeight.w600)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(price,
                  style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -.8,
                      height: 1.2)),
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
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isActive ? null : onChoose,
              style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14))),
              child: Text(isActive ? 'Your current plan' : 'Choose plan',
                  textAlign: TextAlign.center),
            ),
          ),
        ],
      ),
    );
  }
}
