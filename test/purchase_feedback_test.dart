import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mindfully_evolve_app/screens/subscriptionmanagement/purchase_feedback.dart';
import 'package:mindfully_evolve_app/screens/subscriptionmanagement/subscription_management_bloc/subscriprion_management_state.dart';

void main() {
  test('recognizes explicit Apple and Google checkout cancellations', () {
    for (final code in [
      'userCancelled',
      'userCanceled',
      'user_canceled',
      'paymentCancelled',
      'SKErrorPaymentCancelled',
      'purchase_cancelled',
    ]) {
      expect(isUserPurchaseCancellation(PlatformException(code: code)), isTrue,
          reason: code);
    }
    expect(
        isUserPurchaseCancellation(IAPError(
          source: 'storekit',
          code: 'purchase_error',
          message: 'StoreKitError.userCancelled',
        )),
        isTrue);
    expect(
        isUserPurchaseCancellation(PlatformException(
          code: 'storekit_error',
          details: {'reason': 'userCancelled'},
        )),
        isTrue);
  });

  test('does not disguise real failures or subscription status as cancellation',
      () {
    for (final message in [
      'Network timeout',
      'Payment declined',
      'Subscription canceled',
      'Request canceled due to timeout',
      'Server unavailable',
      'userCancelledUnexpectedFailure',
    ]) {
      expect(isUserPurchaseCancellation(Exception(message)), isFalse,
          reason: message);
    }
    expect(isUserPurchaseCancellation(null), isFalse);
  });

  test('cancelled state retains plans and resets pending checkout', () {
    final products = [
      ProductDetails(
        id: 'monthly',
        title: 'Monthly',
        description: 'Monthly plan',
        price: '\$9.99',
        rawPrice: 9.99,
        currencyCode: 'USD',
      )
    ];
    final state = SubscriptionCancelled(products: products);
    expect(state, isA<SubscriptionPlansLoaded>());
    expect(state.products, same(products));
    expect(state.isPurchasing, isFalse);
    expect(state, isNot(SubscriptionPlansLoaded(products: products)));
  });
}
