import 'package:equatable/equatable.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object> get props => [];
}

class FetchSubscriptionPlans extends SubscriptionEvent {
  final Set<String> productIds;

  const FetchSubscriptionPlans({required this.productIds});

  @override
  List<Object> get props => [productIds];
}

class PurchasePlan extends SubscriptionEvent {
  final ProductDetails plan;

  const PurchasePlan({required this.plan});

  @override
  List<Object> get props => [plan];
}

// NEW — purchase with a specific Android subscription offer (base / partner /
// founding-member).  On iOS this falls back to a plain PurchasePlan.
// Dispatch this when the user selects a discounted offer on Android.
class PurchasePlanWithOffer extends SubscriptionEvent {
  final ProductDetails plan;

  /// The offer token from [SubscriptionOfferDetails.offerToken].
  /// Pass null to use the base plan.
  final String? offerToken;

  const PurchasePlanWithOffer({
    required this.plan,
    this.offerToken,
  });

  @override
  List<Object> get props => [plan, offerToken ?? ''];
}

// Opens the platform's native offer/coupon code redemption sheet.
// • iOS  → Apple's SKPaymentQueue.presentCodeRedemptionSheet
// • Android → Google Play's launchPriceChangeConfirmationFlow / redeem intent
//   (redeemable promo codes entered on Play Store, not inside the app)
// The result (success/failure) comes back through the purchaseStream.
class RedeemOfferCode extends SubscriptionEvent {
  const RedeemOfferCode();
}

class CheckPurchasesStatus extends SubscriptionEvent {
  final Set<String> productIds;

  const CheckPurchasesStatus({required this.productIds});

  @override
  List<Object> get props => [productIds];
}

class CompletePurchase extends SubscriptionEvent {
  final PurchaseDetails purchaseDetails;

  const CompletePurchase(this.purchaseDetails);

  @override
  List<Object> get props => [purchaseDetails];
}

class PurchaseFailed extends SubscriptionEvent {
  final String message;

  const PurchaseFailed(this.message);

  @override
  List<Object> get props => [message];
}

class HandlePurchaseCompleted extends SubscriptionEvent {
  final String productId;

  const HandlePurchaseCompleted(this.productId);

  @override
  List<Object> get props => [productId];
}

class HandlePurchaseRestored extends SubscriptionEvent {
  final String productId;

  const HandlePurchaseRestored(this.productId);

  @override
  List<Object> get props => [productId];
}

class FetchBillingHistory extends SubscriptionEvent {
  const FetchBillingHistory();
}

class RestorePurchasesEvent extends SubscriptionEvent {
  const RestorePurchasesEvent();
}
