import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Loads real store prices and keeps unavailable stores distinct from empty catalogs.
Future<List<ProductDetails>> loadSubscriptionProducts({
  required Future<bool> Function() isAvailable,
  required Future<ProductDetailsResponse> Function(Set<String>) query,
  required Set<String> productIds,
  required bool isAndroid,
  Duration timeout = const Duration(seconds: 20),
}) async {
  final store = isAndroid ? 'Google Play' : 'the App Store';
  try {
    return await (() async {
      if (!await isAvailable()) {
        throw StateError(isAndroid
            ? 'Google Play billing is unavailable. Open the Play Store, check that you’re signed in, then try again.'
            : 'The App Store is unavailable. Check your connection and App Store account, then try again.');
      }
      final response = await query(productIds);
      if (response.error != null) {
        throw StateError(
            'We couldn’t connect to $store to load plans. Check your connection and try again.');
      }
      if (response.productDetails.isEmpty) {
        throw StateError(
            'No subscription plans are available from $store for this account right now. Please try again later.');
      }
      return response.productDetails;
    })()
        .timeout(timeout);
  } on TimeoutException {
    throw StateError('$store is taking too long to respond. Please try again.');
  }
}
