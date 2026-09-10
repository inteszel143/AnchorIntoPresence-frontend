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
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isActive
            ? colors.surfaceContainerLow
            : colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: isActive ? colors.primary : colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              if (isActive || isFounding)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(isActive ? 'Current plan' : 'Founding member',
                      style: TextStyle(
                          color: colors.onPrimaryContainer,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(price,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              Text(period, style: TextStyle(color: colors.onSurfaceVariant)),
              if (originalPrice != null)
                Text(originalPrice!,
                    style: TextStyle(
                        color: colors.onSurfaceVariant,
                        decoration: TextDecoration.lineThrough)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isActive ? null : onChoose,
              style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
              child: Text(isActive ? 'Your current plan' : 'Choose plan'),
            ),
          ),
        ],
      ),
    );
  }
}
