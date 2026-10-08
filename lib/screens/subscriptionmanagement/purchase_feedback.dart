import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Recognize explicit user cancellations without treating network failures or
/// subscription cancellations as a dismissed checkout.
bool isUserPurchaseCancellation(Object? error) {
  final values = error is PlatformException
      ? [error.code, error.message, error.details]
      : error is IAPError
          ? [error.code, error.message, error.details]
          : [error];
  final text = values.join(' ').toLowerCase();
  return RegExp(
    r'\b(user[ _-]?cancel[le]*d|payment[ _-]?cancel[le]*d|'
    r'skerrorpaymentcancelled|purchase[ _-]cancel[le]*d)\b',
  ).hasMatch(text);
}

const purchaseCancellationMessage =
    'No problem. You can choose a plan or redeem a code whenever you’re ready.';
const purchaseFailureMessage =
    'We couldn’t complete your purchase. Please try again in a moment.';
