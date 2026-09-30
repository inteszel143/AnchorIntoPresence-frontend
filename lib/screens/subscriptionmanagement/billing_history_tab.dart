import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'user_purchase_model.dart';

/// Account purchase records, loaded separately from store plan state.
class BillingHistoryTab extends StatelessWidget {
  const BillingHistoryTab({
    super.key,
    required this.purchases,
    required this.onRetry,
  });

  final Future<List<UserPurchase>?> purchases;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Billing History', style: theme.textTheme.titleLarge),
        const SizedBox(height: 6),
        Text('Subscription purchases linked to your account.',
            style: TextStyle(color: colors.onSurfaceVariant)),
        const SizedBox(height: 20),
        FutureBuilder<List<UserPurchase>?>(
          future: purchases,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return _message(
                  context,
                  Icons.wifi_off_rounded,
                  'Billing history couldn’t load',
                  'Please check your connection and try again.',
                  retry: true);
            }
            if (snapshot.data == null) {
              return _message(
                  context,
                  Icons.person_outline_rounded,
                  'Sign in to view billing history',
                  'Your purchase history will appear here when you’re signed in.');
            }
            final records = [...snapshot.data!]
              ..sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
            if (records.isEmpty) {
              return _message(
                  context,
                  Icons.receipt_long_outlined,
                  'No billing history yet',
                  'Purchases linked to your account will appear here.');
            }
            final locale = Localizations.localeOf(context).toString();
            return Column(
              children: [
                ...records.map((purchase) {
                  final plan = purchase.productId.contains('founding')
                      ? 'Founding membership'
                      : purchase.planType == 'monthly'
                          ? 'Monthly membership'
                          : purchase.planType == 'yearly' ||
                                  purchase.planType == 'annual'
                              ? 'Annual membership'
                              : 'Subscription';
                  final billingDate = purchase.nextBillingDate ??
                      purchase.purchaseDate.add(Duration(
                          days: purchase.planType == 'monthly' ? 30 : 365));
                  final estimated = purchase.nextBillingDate == null;
                  final active =
                      !purchase.purchaseDate.isAfter(DateTime.now()) &&
                          billingDate.isAfter(DateTime.now());
                  final currency = purchase.currencySymbol?.trim() ?? '';
                  final amount = currency.isEmpty
                      ? NumberFormat.decimalPattern(locale)
                          .format(purchase.amount)
                      : NumberFormat.currency(
                              locale: locale, name: currency, symbol: currency)
                          .format(purchase.amount);
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colors.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            DateFormat.yMMMd(locale)
                                .format(purchase.purchaseDate.toLocal()),
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: colors.onSurfaceVariant)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 20,
                          runSpacing: 8,
                          alignment: WrapAlignment.spaceBetween,
                          children: [
                            Text(plan, style: theme.textTheme.titleMedium),
                            Text(amount,
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 10,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                                'Next billing: ${DateFormat.yMMMd(locale).format(billingDate.toLocal())}${estimated ? ' (estimated)' : ''}',
                                style: theme.textTheme.bodyMedium),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: active
                                    ? colors.primaryContainer
                                    : colors.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(20),
                                border:
                                    Border.all(color: colors.outlineVariant),
                              ),
                              child: Text(active ? 'Active' : 'Expired',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                      color: active
                                          ? colors.onPrimaryContainer
                                          : colors.onSurfaceVariant,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                        if (estimated) ...[
                          const SizedBox(height: 6),
                          Text(
                              'Date and status are based on the recorded plan period.',
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: colors.onSurfaceVariant)),
                        ],
                        if (purchase.purchaseId.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text('Transaction ID',
                              style: theme.textTheme.labelSmall),
                          const SizedBox(height: 4),
                          SelectableText(purchase.purchaseId,
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: colors.onSurfaceVariant)),
                        ],
                      ],
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _message(
      BuildContext context, IconData icon, String title, String description,
      {bool retry = false}) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(children: [
        Icon(icon, size: 32, color: theme.colorScheme.primary),
        const SizedBox(height: 16),
        Text(title,
            textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5)),
        if (retry) ...[
          const SizedBox(height: 16),
          OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again')),
        ],
      ]),
    );
  }
}
