import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:mindfully_evolve_app/screens/subscriptionmanagement/subscription_management_bloc/subscriprion_management_event.dart';
import 'package:mindfully_evolve_app/screens/subscriptionmanagement/subscription_management_bloc/subscriprion_management_state.dart';

import '../../../common/local_storage.dart';
import '../../../utils/api_service.dart';
import '../../../utils/global.dart' as globals;

// Product IDs — updated to match what was created in App Store Connect
class SubscriptionProductIds {
  // iOS — auto-renewable subscription IDs (as created in App Store Connect)
  static const String iosMonthly = 'com.mindfully.premium.monthly.consumable';
  static const String iosAnnual = 'com.mindfull.premium.year.consumable';

  // Android — keep as-is (unchanged)
  static const String androidMonthly =
      'com.mindfull.premium.monthly.consumable';
  static const String androidYearly = 'com.mindfull.premium.yearly.consumable';
  static const String androidFounding = 'com.mindfull.premium.founding.annual';

  static Set<String> get iosIds => {iosMonthly, iosAnnual};
  static Set<String> get androidIds =>
      {androidMonthly, androidYearly, androidFounding};
  static Set<String> get platformIds => Platform.isIOS ? iosIds : androidIds;
}

// Offer IDs — match the Promotional Offer IDs set in App Store Connect
class AndroidOfferIds {
  static const String partnerOfferId = 'partner';
  static const String foundingMemberOfferId = 'founding-member';
}

class OfferIds {
  // Annual offer IDs
  static const String foundingMemberAnnual = 'founding_members';
  static const String marketingPartnerAnnual = 'marketing_partners_annual';

  // Monthly offer ID
  static const String marketingPartnerMonthly = 'marketing_partners_monthly';
}

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  late final StreamSubscription<List<PurchaseDetails>> _purchaseSubscription;

  // Cached products — always available for purchase stream callbacks
  List<ProductDetails> _cachedProducts = [];

  bool _restoreTriggered = false;

  SubscriptionBloc() : super(SubscriptionInitial()) {
    _purchaseSubscription =
        _inAppPurchase.purchaseStream.listen(_onPurchaseUpdate);

    on<FetchSubscriptionPlans>(_onFetchSubscriptionPlans);
    on<PurchasePlan>(_onPurchasePlan);
    on<RedeemOfferCode>(_onRedeemOfferCode); // NEW — offer code sheet
    on<HandlePurchaseCompleted>(_onHandlePurchaseCompleted);
    on<HandlePurchaseRestored>(_onHandlePurchaseRestored);
    on<PurchaseFailed>(_onPurchaseFailed);
    on<RestorePurchasesEvent>(_onRestorePurchases);
    on<FetchBillingHistory>(_onFetchBillingHistory);
    on<PurchasePlanWithOffer>(_onPurchasePlanWithOffer);
  }

  @override
  Future<void> close() {
    _purchaseSubscription.cancel();
    return super.close();
  }

  // Fetch subscription plans
  Future<void> _onFetchSubscriptionPlans(
    FetchSubscriptionPlans event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      final productIds = SubscriptionProductIds.platformIds;

      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(productIds);

      if (response.notFoundIDs.isNotEmpty && response.productDetails.isEmpty) {
        emit(const SubscriptionError(message: "Products not found"));
        return;
      }

      _cachedProducts = response.productDetails;
      emit(SubscriptionPlansLoaded(products: _cachedProducts));
    } catch (e) {
      // Check if it's a network-related error
      String errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('network') ||
          errorMessage.contains('connection') ||
          errorMessage.contains('host') ||
          errorMessage.contains('socket') ||
          errorMessage.contains('timeout')) {
        emit(const SubscriptionError(
            message:
                "No internet connection. Please check your network and try again."));
      } else {
        final errorMessage = e is Exception
            ? e.toString().replaceFirst('Exception: ', '')
            : e.toString();
        emit(SubscriptionError(message: errorMessage));
      }
    }
  }

  Future<void> _onPurchasePlanWithOffer(
    PurchasePlanWithOffer event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      if (Platform.isAndroid && event.offerToken != null) {
        final googlePurchaseParam = GooglePlayPurchaseParam(
          productDetails: event.plan,
          applicationUserName: null,
          changeSubscriptionParam: null,
        );
        // Pass the offer token via the Android-specific param
        final androidAddition = _inAppPurchase
            .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
        // Use buyNonConsumable — subscriptions are always non-consumable
        await _inAppPurchase.buyNonConsumable(
          purchaseParam: GooglePlayPurchaseParam(
            productDetails: event.plan,
            applicationUserName: null,
            changeSubscriptionParam: null,
          ),
        );
      } else {
        // iOS or no offer token — fall back to regular purchase
        add(PurchasePlan(plan: event.plan));
      }
    } catch (e) {
      final errorMessage = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : e.toString();
      emit(SubscriptionError(message: errorMessage));
    }
  }

  // Trigger purchase
  // For auto-renewable subscriptions on iOS we MUST use buyNonConsumable.
  // The old code was calling buyConsumable on iOS which is wrong for subs.
  Future<void> _onPurchasePlan(
    PurchasePlan event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      final PurchaseParam purchaseParam =
          PurchaseParam(productDetails: event.plan);

      // Auto-renewable subscriptions always use buyNonConsumable regardless
      // of what the product ID says — even if it has "consumable" in the name.
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      final errorMessage = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : e.toString();
      emit(SubscriptionError(message: errorMessage));
    }
  }

  // Redeem Offer Code — opens Apple's native code redemption sheet (iOS only)
  // This handles all three offer types:
  //   • Founding Members (annual $69)
  //   • Marketing Partners Monthly ($7.99)
  //   • Marketing Partners Annual ($79)
  // Apple validates the code, applies the discount, and the result comes back
  // through the normal purchaseStream as PurchaseStatus.purchased.
  Future<void> _onRedeemOfferCode(
    RedeemOfferCode event,
    Emitter<SubscriptionState> emit,
  ) async {
    if (!Platform.isIOS) return;

    try {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();

      await iosPlatformAddition.presentCodeRedemptionSheet();
      // After the user enters the code the result arrives via purchaseStream —
      // no further action needed here.
    } catch (e) {
      emit(SubscriptionError(message: 'Could not open redemption sheet: $e'));
    }
  }

  // Restore purchases
  Future<void> _onRestorePurchases(
    RestorePurchasesEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    try {
      _restoreTriggered = true;
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      _restoreTriggered = false;
      final errorMessage = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : e.toString();
      emit(SubscriptionError(message: errorMessage));
    }
  }

  // Purchase stream handler
  // Handles new purchases, restored purchases (including offer code redemptions)
  Future<void> _onPurchaseUpdate(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (final purchaseDetails in purchaseDetailsList) {
      if (isClosed) return;

      final productId = purchaseDetails.productID;
      final purchaseId = purchaseDetails.purchaseID ?? '';
      final purchaseDate = purchaseDetails.transactionDate ??
          DateTime.now().millisecondsSinceEpoch.toString();

      // ── Drain stuck/replayed transactions at startup ──────────────────────
      if (purchaseDetails.status == PurchaseStatus.purchased &&
          _cachedProducts.isEmpty) {
        try {
          await _inAppPurchase.completePurchase(purchaseDetails);
        } catch (_) {}
        continue;
      }

      // ── Safe product lookup ───────────────────────────────────────────────
      ProductDetails? matchingProduct;
      try {
        matchingProduct = _cachedProducts.firstWhere((p) => p.id == productId);
      } catch (_) {
        matchingProduct = null;
      }

      final currencyCode = matchingProduct?.currencyCode ?? 'USD';

      // Parse price safely — handles $9.99, ₹799, £8.99 etc.
      final amount = matchingProduct != null
          ? (double.tryParse(
                  matchingProduct.price.replaceAll(RegExp(r'[^\d.]'), '')) ??
              0.0)
          : 0.0;

      // Determine plan type from product ID
      final String planType =
          productId.contains('monthly') ? 'monthly' : 'yearly';

      // ── Check if this came from an offer code redemption ──────────────────
      // On iOS, when a user redeems an offer code, the purchase comes through
      // the stream just like a regular purchase. We detect it via the
      // SKPaymentTransaction promotional offer field.
      String? redeemedOfferId;
      if (Platform.isIOS) {
        try {
          final skDetails = purchaseDetails as AppStorePurchaseDetails;
          redeemedOfferId = skDetails
              .skPaymentTransaction.payment.paymentDiscount?.identifier;
          if (redeemedOfferId != null) {}
        } catch (_) {
          // Not an AppStorePurchaseDetails — safe to ignore
        }
      }

      switch (purchaseDetails.status) {
        // ── PURCHASED (includes offer code redemptions) ───────────────────
        case PurchaseStatus.purchased:
          try {
            final token = await LocalStorage.getToken();

            final purchaseData = {
              "productId": productId,
              "purchaseId": purchaseId,
              "amount": amount,
              "purchaseDate": purchaseDate,
              "planType": planType,
              "currencySymbol": currencyCode,
              // Send offer ID to your backend so it can record which
              // campaign the user came from
              if (redeemedOfferId != null) "offerId": redeemedOfferId,
            };

            if (token != null && token.isNotEmpty) {
              await ApiService.sendPurchase(
                productId: productId,
                purchaseId: purchaseId,
                amount: amount.toInt(),
                purchaseDate: purchaseDate,
                planType: planType,
                currencySymbol: currencyCode,
              );
            } else {
              await LocalStorage.savePurchase(purchaseData);
              await LocalStorage.saveBool(true);
            }

            // Always complete BEFORE emitting state
            await _inAppPurchase.completePurchase(purchaseDetails);

            if (!isClosed) {
              globals.alreadyPurchasedProductId = productId;
              globals.isSubscribed = true;
              // Normalize to ISO-8601 so DateTime.tryParse works in the UI.
              // transactionDate from the plugin can be a Unix-ms string on Android.
              final ms = int.tryParse(purchaseDate);
              globals.lastTransactionDate = ms != null
                  ? DateTime.fromMillisecondsSinceEpoch(ms).toIso8601String()
                  : purchaseDate;
              globals.planType = planType;
              add(HandlePurchaseCompleted(productId));
            }
          } catch (e) {
            try {
              await _inAppPurchase.completePurchase(purchaseDetails);
            } catch (_) {}
            final errorMessage = e is Exception
                ? e.toString().replaceFirst('Exception: ', '')
                : e.toString();
            add(PurchaseFailed(errorMessage));
          }
          break;

        // ── RESTORED ─────────────────────────────────────────────────────
        // Auto-renewable subscriptions come back here when the user taps
        // "Restore Purchases". Apple re-delivers the most recent transaction.
        case PurchaseStatus.restored:
          try {
            final token = await LocalStorage.getToken();

            if (token != null && token.isNotEmpty) {
              await ApiService.sendPurchase(
                productId: productId,
                purchaseId: purchaseId,
                amount: amount.toInt(),
                purchaseDate: purchaseDate,
                planType: planType,
                currencySymbol: currencyCode,
              );
            } else {
              // No token yet — save locally for later sync
              await LocalStorage.savePurchase({
                "productId": productId,
                "purchaseId": purchaseId,
                "amount": amount,
                "purchaseDate": purchaseDate,
                "planType": planType,
                "currencySymbol": currencyCode,
              });
              await LocalStorage.saveBool(true);
            }

            await _inAppPurchase.completePurchase(purchaseDetails);

            if (!isClosed) {
              globals.alreadyPurchasedProductId = productId;
              globals.isSubscribed = true;
              final ms = int.tryParse(purchaseDate);
              globals.lastTransactionDate = ms != null
                  ? DateTime.fromMillisecondsSinceEpoch(ms).toIso8601String()
                  : purchaseDate;
              globals.planType = planType;
              _restoreTriggered = false;
              add(HandlePurchaseRestored(productId));
            }
          } catch (e) {
            _restoreTriggered = false;
            final errorMessage = e is Exception
                ? e.toString().replaceFirst('Exception: ', '')
                : e.toString();
            add(PurchaseFailed(errorMessage));
          }
          break;

        // ── ERROR ────────────────────────────────────────────────────────
        case PurchaseStatus.error:
          add(PurchaseFailed(
              purchaseDetails.error?.message ?? "Purchase error"));
          break;

        // ── CANCELED ─────────────────────────────────────────────────────
        case PurchaseStatus.canceled:
          add(PurchaseFailed("Purchase canceled"));
          break;

        // ── PENDING ──────────────────────────────────────────────────────
        // Happens when a purchase needs parental approval (Ask to Buy)
        case PurchaseStatus.pending:
          if (!isClosed && _cachedProducts.isNotEmpty) {
            emit(SubscriptionPlansLoaded(
              products: _cachedProducts,
              isPurchasing: true,
            ));
          }
          break;
      }
    }
  }

  // Handle purchase completed
  void _onHandlePurchaseCompleted(
    HandlePurchaseCompleted event,
    Emitter<SubscriptionState> emit,
  ) {
    globals.alreadyPurchasedProductId = event.productId;
    globals.isSubscribed = true;
    emit(SubscriptionPurchased(productId: event.productId));
  }

  // Handle purchase restored
  void _onHandlePurchaseRestored(
    HandlePurchaseRestored event,
    Emitter<SubscriptionState> emit,
  ) {
    globals.alreadyPurchasedProductId = event.productId;
    globals.isSubscribed = true;
    emit(SubscriptionRestored(productId: event.productId));
  }

  // Handle purchase failed
  void _onPurchaseFailed(
    PurchaseFailed event,
    Emitter<SubscriptionState> emit,
  ) {
    emit(SubscriptionError(message: event.message));
  }

  // Fetch billing history
  Future<void> _onFetchBillingHistory(
    FetchBillingHistory event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(BillingHistoryLoading());
    try {
      final purchases = await ApiService.fetchUserPurchases();
      emit(BillingHistoryLoaded(purchases));
    } catch (e) {
      emit(BillingHistoryError(e.toString()));
    }
  }
}
