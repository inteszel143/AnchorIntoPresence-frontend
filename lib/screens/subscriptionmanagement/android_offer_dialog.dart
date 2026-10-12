import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'load_subscription_products.dart';
import 'subscription_management_bloc/subscriprion_management_bloc.dart';

const androidRedeemCodes = {'anchorambassador', 'anchorvip'};

SubscriptionOfferDetailsWrapper? selectedAndroidOffer(
    GooglePlayProductDetails product) {
  final index = product.subscriptionIndex;
  final offers = product.productDetails.subscriptionOfferDetails;
  if (index == null || offers == null || index < 0 || index >= offers.length)
    return null;
  return offers[index];
}

List<GooglePlayProductDetails> matchingAndroidOffers(
    List<ProductDetails> products, String code) {
  final normalized = code.trim().toLowerCase();
  if (!androidRedeemCodes.contains(normalized)) return [];
  return products
      .whereType<GooglePlayProductDetails>()
      .where((product) => selectedAndroidOffer(product)?.offerId == normalized)
      .toList();
}

String offerPhaseLabel(PricingPhaseWrapper phase) {
  final match = RegExp(r'^P(\d+)([DWMY])$').firstMatch(phase.billingPeriod);
  final unit = {'D': 'day', 'W': 'week', 'M': 'month', 'Y': 'year'};
  final period = match == null
      ? phase.billingPeriod
      : '${match[1]} ${unit[match[2]]}${match[1] == '1' ? '' : 's'}';
  final price = phase.priceAmountMicros == 0 ? 'Free' : phase.formattedPrice;
  if (phase.recurrenceMode == RecurrenceMode.infiniteRecurring) {
    return '$price every $period, renews until canceled';
  }
  if (phase.recurrenceMode == RecurrenceMode.finiteRecurring) {
    return '$price per $period for ${phase.billingCycleCount} billing cycle(s)';
  }
  return '$price for $period';
}

class AndroidOfferDialog extends StatefulWidget {
  const AndroidOfferDialog({super.key, this.load});
  final Future<List<ProductDetails>> Function()? load;
  @override
  State<AndroidOfferDialog> createState() => _AndroidOfferDialogState();
}

class _AndroidOfferDialogState extends State<AndroidOfferDialog> {
  final _code = TextEditingController();
  bool _loading = false;
  String? _error;
  List<GooglePlayProductDetails> _offers = [];

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    FocusScope.of(context).unfocus();
    final code = _code.text.trim().toLowerCase();
    if (!androidRedeemCodes.contains(code)) {
      setState(() {
        _error = 'This code isn’t recognized. Check it and try again.';
        _offers = [];
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _offers = [];
    });
    try {
      final products = await (widget.load?.call() ??
          loadSubscriptionProducts(
            isAvailable: InAppPurchase.instance.isAvailable,
            query: InAppPurchase.instance.queryProductDetails,
            productIds: SubscriptionProductIds.androidIds,
            isAndroid: true,
          ));
      if (!mounted) return;
      final offers = matchingAndroidOffers(products, code);
      setState(() {
        _offers = offers;
        if (offers.isEmpty)
          _error =
              'This offer isn’t available for your Google Play account right now.';
      });
    } catch (error) {
      if (mounted)
        setState(() => _error = error is StateError
            ? error.message.toString()
            : 'Couldn’t check this offer. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Redeem code'),
        content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                    'Enter your offer code to see available subscription offers.'),
                const SizedBox(height: 16),
                TextField(
                  controller: _code,
                  enabled: !_loading,
                  autocorrect: false,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                      labelText: 'Offer code', border: OutlineInputBorder()),
                  onChanged: (_) => setState(() {
                    _offers = [];
                    _error = null;
                  }),
                  onSubmitted: (_) => _check(),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Semantics(
                      liveRegion: true,
                      child: Text(_error!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error))),
                ],
                const SizedBox(height: 16),
                FilledButton(
                    onPressed: _loading ? null : _check,
                    child: Text(_loading ? 'Checking…' : 'Check code')),
                for (final product in _offers) ...[
                  const Divider(height: 32),
                  Text(product.title,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  for (final phase
                      in selectedAndroidOffer(product)!.pricingPhases)
                    Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(offerPhaseLabel(phase))),
                  const Text(
                      'Review and confirm your subscription in Google Play. You can manage or cancel it there.'),
                  const SizedBox(height: 12),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, product),
                      child: const Text('Continue to Google Play')),
                ],
              ],
            ))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'))
        ],
      );
}
