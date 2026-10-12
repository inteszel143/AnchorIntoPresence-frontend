import 'package:in_app_purchase/in_app_purchase.dart';

/// Google order IDs cannot be used to retrieve offers. The server needs the
/// purchase token supplied by Play Billing, not an Apple receipt or offer token.
Map<String, String> purchaseReportingFields(PurchaseDetails purchase) {
  if (purchase.verificationData.source != 'google_play') return {};
  final token = purchase.verificationData.serverVerificationData;
  return {
    'platform': 'android',
    if (token.isNotEmpty) 'purchaseToken': token,
  };
}
