import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:mindfully_evolve_app/screens/subscriptionmanagement/android_offer_dialog.dart';

void main() {
  const phase = PricingPhaseWrapper(
      billingCycleCount: 0,
      billingPeriod: 'P1M',
      formattedPrice: '\$5.00',
      priceAmountMicros: 5000000,
      priceCurrencyCode: 'USD',
      recurrenceMode: RecurrenceMode.infiniteRecurring);
  final products =
      GooglePlayProductDetails.fromProductDetails(const ProductDetailsWrapper(
    description: '',
    name: 'Monthly',
    productId: 'monthly',
    productType: ProductType.subs,
    title: 'Monthly',
    subscriptionOfferDetails: [
      SubscriptionOfferDetailsWrapper(
          basePlanId: 'monthly',
          offerTags: [],
          offerIdToken: 'base-token',
          pricingPhases: [phase]),
      SubscriptionOfferDetailsWrapper(
          basePlanId: 'monthly',
          offerId: 'anchorvip',
          offerTags: [],
          offerIdToken: 'vip-token',
          pricingPhases: [phase]),
    ],
  ));
  test('code matches only the specific offer and preserves its checkout token',
      () {
    final matches = matchingAndroidOffers(products, ' ANCHORVIP ');
    expect(matches.length, 1);
    expect(selectedAndroidOffer(matches.single)!.offerIdToken, 'vip-token');
    expect(matchingAndroidOffers(products, 'anchorambassador'), isEmpty);
    expect(matchingAndroidOffers(products, 'invalid'), isEmpty);
    expect(offerPhaseLabel(phase), contains('renews until canceled'));
  });
  testWidgets(
      'code check shows terms and returns the selected offer only after confirmation',
      (tester) async {
    GooglePlayProductDetails? result;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Builder(
                builder: (context) => TextButton(
                      onPressed: () async {
                        result = await showDialog<GooglePlayProductDetails>(
                            context: context,
                            builder: (_) =>
                                AndroidOfferDialog(load: () async => products));
                      },
                      child: const Text('Open'),
                    )))));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'anchorvip');
    await tester.tap(find.text('Check code'));
    await tester.pumpAndSettle();
    expect(find.text('Monthly'), findsOneWidget);
    expect(find.textContaining('renews until canceled'), findsOneWidget);
    expect(result, isNull);
    await tester.ensureVisible(find.text('Continue to Google Play'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue to Google Play'));
    await tester.pumpAndSettle();
    expect(selectedAndroidOffer(result!)!.offerIdToken, 'vip-token');
  });
}
