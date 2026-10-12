import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mindfully_evolve_app/screens/subscriptionmanagement/load_subscription_products.dart';

void main() {
  test('unavailable billing stops before requesting products', () async {
    await expectLater(
        loadSubscriptionProducts(
          isAvailable: () async => false,
          query: (_) async => throw Exception('must not query'),
          productIds: {'monthly'},
          isAndroid: true,
        ),
        throwsA(isA<StateError>()
            .having((e) => e.message, 'message', contains('Play Store'))));
  });
  test('store errors and empty catalogs are errors, not loaded plans',
      () async {
    for (final response in [
      ProductDetailsResponse(
          productDetails: [],
          notFoundIDs: [],
          error: IAPError(
              source: 'test', code: 'unavailable', message: 'offline')),
      ProductDetailsResponse(productDetails: [], notFoundIDs: ['monthly']),
    ]) {
      await expectLater(
          loadSubscriptionProducts(
            isAvailable: () async => true,
            query: (_) async => response,
            productIds: {'monthly'},
            isAndroid: true,
          ),
          throwsA(isA<StateError>()));
    }
  });
  test('successful lookup uses requested IDs and retains available plans',
      () async {
    final plan = ProductDetails(
        id: 'monthly',
        title: 'Monthly',
        description: '',
        price: '\$5',
        rawPrice: 5,
        currencyCode: 'USD');
    final result = await loadSubscriptionProducts(
      isAvailable: () async => true,
      query: (ids) async {
        expect(ids, {'monthly', 'annual'});
        return ProductDetailsResponse(
            productDetails: [plan], notFoundIDs: ['annual']);
      },
      productIds: {'monthly', 'annual'},
      isAndroid: false,
    );
    expect(result, [plan]);
  });
  test('unresponsive store times out', () async {
    await expectLater(
        loadSubscriptionProducts(
          isAvailable: () => Completer<bool>().future,
          query: (_) async => throw Exception('must not query'),
          productIds: {'monthly'},
          isAndroid: true,
          timeout: const Duration(milliseconds: 10),
        ),
        throwsA(isA<StateError>()
            .having((e) => e.message, 'message', contains('too long'))));
  });
}
