import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:intl/intl.dart';
import 'package:mindfully_evolve_app/common/main_screen.dart';
import 'package:mindfully_evolve_app/screens/subscriptionmanagement/subscription_management_bloc/subscriprion_management_bloc.dart';
import 'package:mindfully_evolve_app/screens/subscriptionmanagement/subscription_management_bloc/subscriprion_management_event.dart';
import 'package:mindfully_evolve_app/screens/subscriptionmanagement/subscription_management_bloc/subscriprion_management_state.dart';
import 'package:mindfully_evolve_app/utils/string_constants.dart';

import '../../common/local_storage.dart';
import '../../common/widgets/custom_appbar.dart';
import '../../utils/color_constants.dart';
import '../../utils/fonts.dart';
import '../../utils/global.dart' as globals;
import '../signup/signup_screen.dart';

class SubscriptionManagementScreen extends StatefulWidget {
  final bool? isSubscribed;

  const SubscriptionManagementScreen({Key? key, this.isSubscribed = true})
      : super(key: key);

  @override
  State<SubscriptionManagementScreen> createState() =>
      _SubscriptionManagementScreenState();
}

class _SubscriptionManagementScreenState
    extends State<SubscriptionManagementScreen> {
  late Set<String> _productIds;
  bool _hasNavigated = false;
  bool isBillingTab = false;
  bool _hasToken = false;

  late final SubscriptionBloc _bloc;

  @override
  void initState() {
    super.initState();
    _setPlatformSpecificProductIds();
    _bloc = SubscriptionBloc();
    _initialize();
  }

  bool isSubscriptionActive() {
    if (globals.lastTransactionDate == null || globals.planType == null) {
      return false;
    }
    final purchaseDate = DateTime.tryParse(globals.lastTransactionDate!);
    if (purchaseDate == null) return false;
    final now = DateTime.now();
    if (globals.planType == 'monthly') {
      return purchaseDate.add(const Duration(days: 30)).isAfter(now);
    } else {
      return purchaseDate.add(const Duration(days: 365)).isAfter(now);
    }
  }

  Future<void> _initialize() async {
    final token = await LocalStorage.getToken();
    if (mounted) {
      setState(() => _hasToken = token != null && token.isNotEmpty);
    }
    _bloc.add(FetchSubscriptionPlans(productIds: _productIds));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _setPlatformSpecificProductIds() {
    if (Platform.isIOS) {
      _productIds = {
        'com.mindfully.premium.monthly.consumable',
        'com.mindfull.premium.year.consumable',
      };
    } else {
      _productIds = {
        'com.mindfull.premium.monthly.consumable',
        'com.mindfull.premium.yearly.consumable',
        'com.mindfull.premium.founding.annual'
      };
    }
  }

  Future<void> _showConfirmationDialog(
      BuildContext context, ProductDetails plan) async {
    final priceInfo = _resolveOfferPrice(plan);
    final bool hasDiscount = priceInfo.originalPrice != null;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: ColorCodes.whiteNewReplacement,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.of(dialogContext).pop(),
                      child: Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.close,
                          size: 22,
                          color: ColorCodes.blackcolor,
                        ),
                      ),
                    ),
                  ],
                ),
                const Text(
                  "Confirm Purchase",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w400,
                    letterSpacing: Fonts.headingLetterSpacing,
                    fontFamily: Fonts.heading,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: Fonts.body,
                      color: ColorCodes.descriptioncolor,
                      letterSpacing: 2,
                      height: 1.0,
                    ),
                    children: [
                      const TextSpan(text: "You are about to "),
                      TextSpan(
                        text: "purchase:",
                        style: TextStyle(
                          color: ColorCodes.buttoncolor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(text: "\n${_cleanPlanTitle(plan.title)}"),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (hasDiscount) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        priceInfo.displayPrice,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: Fonts.body,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        priceInfo.originalPrice!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                          fontFamily: Fonts.body,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                ] else
                  Text(
                    "Price: ${priceInfo.displayPrice}",
                    style: const TextStyle(
                        letterSpacing: Fonts.headingLetterSpacing,
                        fontFamily: Fonts.heading,
                        fontSize: 16,
                        fontWeight: FontWeight.w400),
                  ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.black87,
                            fontFamily: Fonts.body,
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (priceInfo.bestOfferToken != null) {
                            _bloc.add(PurchasePlanWithOffer(
                              plan: plan,
                              offerToken: priceInfo.bestOfferToken!,
                            ));
                          } else {
                            _bloc.add(PurchasePlan(plan: plan));
                          }
                          Navigator.of(dialogContext).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorCodes.buttoncolor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Confirm',
                          style: TextStyle(
                            color: ColorCodes.whitecolor,
                            fontFamily: Fonts.body,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _cleanPlanTitle(String rawTitle) {
    final parenIndex = rawTitle.lastIndexOf('(');
    if (parenIndex > 0) {
      return rawTitle.substring(0, parenIndex).trim();
    }
    return rawTitle.trim();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SubscriptionBloc>.value(
      value: _bloc,
      child: BlocConsumer<SubscriptionBloc, SubscriptionState>(
        listener: (context, state) async {
          if (state is SubscriptionPurchasing) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Processing your purchase...")),
            );
          } else if (state is SubscriptionPurchased) {
            if (_hasNavigated) return;
            _hasNavigated = true;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Purchase successful!")),
            );

            final token = await LocalStorage.getToken();
            if (!mounted) return;

            if (token != null && token.isNotEmpty) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => MainScreen(initialIndex: 0)),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => SignupScreen()),
              );
            }
          } else if (state is SubscriptionRestored) {
            if (_hasNavigated) return;
            _hasNavigated = true;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Purchase restored!")),
            );

            _bloc.add(FetchSubscriptionPlans(productIds: _productIds));
          } else if (state is SubscriptionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("${state.message}")),
            );

            _bloc.add(FetchSubscriptionPlans(productIds: _productIds));
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: ColorCodes.backgroundcolor,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomAppbar(headingTxt: Strings.subscriptionManagement),

                    const SizedBox(height: 20),

                    // ── Tab switcher ────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: ColorCodes.whitecolor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: ColorCodes.searchboxcolor),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() => isBillingTab = false);
                                  _bloc.add(FetchSubscriptionPlans(
                                      productIds: _productIds));
                                },
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: !isBillingTab
                                        ? ColorCodes.buttoncolor
                                        : Colors.transparent,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8)),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    Strings.plans,
                                    style: TextStyle(
                                      color: !isBillingTab
                                          ? ColorCodes.blackcolor
                                          : ColorCodes.blackcolor,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      fontFamily: Fonts.body,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (_hasToken)
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() => isBillingTab = true);
                                    _bloc.add(FetchBillingHistory());
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isBillingTab
                                          ? ColorCodes.buttoncolor
                                          : Colors.transparent,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(8)),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      Strings.billingHistory,
                                      style: TextStyle(
                                        color: isBillingTab
                                            ? ColorCodes.blackcolor
                                            : ColorCodes.blackcolor
                                                .withOpacity(0.7),
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        fontFamily: Fonts.body,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Content ─────────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: (_hasToken && isBillingTab)
                          ? _buildBillingHistoryTab(state)
                          : _buildPlansTab(state),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Plans tab

  // ── Offer-aware price resolution ──────────────────────────────────────────
  // Returns a record with:
  //   • displayPrice   – the price string to show prominently
  //   • originalPrice  – non-null only when a discounted offer is available
  //                      (caller should render it struck-through)
  //   • bestOfferToken – non-null on Android when a discount offer exists
  //
  // Logic:
  //   Android: inspect subscriptionOfferDetails. The first entry whose offerId
  //            is NOT null (i.e. a named promotional offer) is considered the
  //            "discount". The base plan price comes from the entry whose
  //            offerId IS null (or the product's own price as fallback).
  //   iOS:     no offer-detail list; fall back to plan.price.
  ({String displayPrice, String? originalPrice, String? bestOfferToken})
      _resolveOfferPrice(ProductDetails plan) {
    if (!Platform.isAndroid || plan is! GooglePlayProductDetails) {
      return (
        displayPrice: plan.price,
        originalPrice: null,
        bestOfferToken: null
      );
    }

    final offers = plan.productDetails.subscriptionOfferDetails;
    if (offers == null || offers.isEmpty) {
      return (
        displayPrice: plan.price,
        originalPrice: null,
        bestOfferToken: null
      );
    }

    String? basePrice;
    String? offerPrice;
    String? offerToken;

    for (final dynamic o in offers) {
      String? id;
      try {
        id = o.offerId;
      } catch (_) {}

      List<dynamic>? phases;
      try {
        phases = o.pricingPhases.pricingPhaseList;
      } catch (_) {
        try {
          phases = o.pricingPhases;
        } catch (_) {}
      }

      if (phases == null || phases.isEmpty) continue;

      final price = phases.first.formattedPrice?.toString() ?? '';

      String token = '';
      try {
        token = o.offerToken ?? '';
      } catch (_) {}

      // 🔹 BASE PLAN
      if (id == null) {
        basePrice = phases.last.formattedPrice?.toString();
      }

      // 🔹 OFFER (discount)
      else {
        // pick first valid offer
        if (offerPrice == null && price.isNotEmpty) {
          offerPrice = price;
          offerToken = token;
        }
      }
    }

    // ✅ If offer exists → show discount
    if (offerPrice != null && basePrice != null) {
      return (
        displayPrice: offerPrice,
        originalPrice: basePrice,
        bestOfferToken: offerToken,
      );
    }

    // fallback
    return (
      displayPrice: basePrice ?? plan.price,
      originalPrice: null,
      bestOfferToken: null,
    );
  }

  // ── Deduplicate products by base product ID ───────────────────────────────
  // On Android, queryProductDetails can return one GooglePlayProductDetails
  // per SubscriptionOfferDetails entry, which produces duplicate monthly /
  // yearly cards. We keep only the first occurrence of each base product ID
  // (the offer selection is handled inside the card via _resolveOfferPrice).
  List<ProductDetails> _deduplicateProducts(List<ProductDetails> products) {
    final seen = <String>{};
    final result = <ProductDetails>[];
    for (final p in products) {
      final baseId = p.id.split(':').first;
      if (seen.add(baseId)) {
        result.add(p);
      }
    }
    return result;
  }

  Widget _buildPlansTab(SubscriptionState state) {
    if (state is SubscriptionPlansLoaded) {
      // Deduplicate so each plan (monthly / yearly) appears exactly once.
      final uniquePlans = _deduplicateProducts(state.products);

      return Column(
        children: [
          // ── Plan cards ──────────────────────────────────────────────────
          ...uniquePlans.map((plan) {
            final bool isActive = plan.id.split(':').first ==
                    (globals.alreadyPurchasedProductId ?? '')
                        .split(':')
                        .first &&
                isSubscriptionActive();

            // Resolve which price(s) to display for this plan.
            final priceInfo = _resolveOfferPrice(plan);
            final bool hasDiscount = priceInfo.originalPrice != null;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: ColorCodes.whitecolor,
                  border: Border.all(color: ColorCodes.searchboxcolor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: GestureDetector(
                            onTap: isActive
                                ? null
                                : () => _showConfirmationDialog(context, plan),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Radio<String>(
                                    value: plan.id.split(':').first,
                                    groupValue:
                                        (globals.alreadyPurchasedProductId ??
                                                '')
                                            .split(':')
                                            .first,
                                    activeColor: ColorCodes.buttoncolor,
                                    onChanged: isActive
                                        ? null
                                        : (_) => _showConfirmationDialog(
                                            context, plan),
                                  ),
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  _cleanPlanTitle(plan.title),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: Fonts.body,
                                    color: ColorCodes.mainheadingcolor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // ── Price display: discounted or standard ──────────
                        Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: hasDiscount
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    // Original price — struck through
                                    Text(
                                      priceInfo.originalPrice!,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: Fonts.body,
                                        color: ColorCodes.mainheadingcolor
                                            .withOpacity(0.5),
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                    // Discounted (new) price — prominent
                                    Text(
                                      priceInfo.displayPrice,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: Fonts.body,
                                        color: ColorCodes.mainheadingcolor,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  priceInfo.displayPrice,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: Fonts.body,
                                    color: ColorCodes.mainheadingcolor,
                                  ),
                                ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 7),

                    // ── Purchase / Restore button ──────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GestureDetector(
                        onTap: isActive
                            ? () => _bloc.add(RestorePurchasesEvent())
                            : () => _showConfirmationDialog(context, plan),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: ColorCodes.buttoncolor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            isActive ? 'Restore Purchases' : 'Purchase',
                            style: const TextStyle(
                              color: ColorCodes.blackcolor,
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              fontFamily: Fonts.body,
                            ),
                          ),
                        ),
                      ),
                    ),

                    if (isActive)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 15, top: 4),
                            child: Text(
                              "Already Purchased",
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: Fonts.body,
                                fontWeight: FontWeight.w400,
                                color: ColorCodes.tag1color,
                              ),
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          }).toList(),

          // ── Redeem / Offer Code button ──────────────────────────────────
          const SizedBox(height: 4),
          if (Platform.isIOS)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () => _bloc.add(const RedeemOfferCode()),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: ColorCodes.buttoncolor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ColorCodes.buttoncolor),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    Platform.isIOS ? 'Redeem Code' : 'Redeem Promo Code',
                    style: TextStyle(
                      color: ColorCodes.blackcolor,
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      fontFamily: Fonts.body,
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
        ],
      );
    }

    if (state is SubscriptionError) {
      return Center(
        child: Column(
          children: [
            Text("${state.message}"),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () =>
                  _bloc.add(FetchSubscriptionPlans(productIds: _productIds)),
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    return const Center(
        child: CircularProgressIndicator(
      color: ColorCodes.buttoncolor,
    ));
  }

  // Billing history tab
  Widget _buildBillingHistoryTab(SubscriptionState state) {
    if (state is BillingHistoryLoading) {
      return const Center(
          child: CircularProgressIndicator(color: ColorCodes.buttoncolor));
    }

    if (state is BillingHistoryLoaded) {
      if (state.purchases.isEmpty) {
        return const Center(child: Text("No billing history available."));
      }

      String getFormattedPrice(String? currencyCode, double amount) {
        final Map<String, String> symbols = {'INR': '₹', 'USD': '\$'};
        final symbol = symbols[currencyCode] ?? '\$';
        return '$symbol${amount.toStringAsFixed(2)}';
      }

      return Column(
        children: state.purchases.map((item) {
          final formattedDate =
              DateFormat('MMM dd, yyyy').format(item.purchaseDate);

          final price = getFormattedPrice(item.currencySymbol, item.amount);

          final oneMonthAgo = DateTime.now().subtract(const Duration(days: 30));
          final oneYearAgo = DateTime.now().subtract(const Duration(days: 365));

          DateTime nextBillingDate;
          if (item.planType == 'monthly') {
            nextBillingDate = item.purchaseDate.add(const Duration(days: 30));
          } else if (item.planType == 'yearly') {
            nextBillingDate = item.purchaseDate.add(const Duration(days: 365));
          } else {
            nextBillingDate = item.purchaseDate;
          }

          final nextFormattedDate =
              DateFormat('MMM dd, yyyy').format(nextBillingDate);

          final isActive = (item.planType == 'monthly' &&
                  item.purchaseDate.isAfter(oneMonthAgo)) ||
              (item.planType == 'yearly' &&
                  item.purchaseDate.isAfter(oneYearAgo));

          final statusText = isActive ? 'Active' : 'Expired';
          final statusColor = isActive
              ? ColorCodes.tag1color.withOpacity(0.4)
              : ColorCodes.tag2color.withOpacity(0.4);
          final statusTextColor = ColorCodes.blackcolor;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              color: ColorCodes.whitecolor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ColorCodes.searchboxcolor),
              boxShadow: [
                BoxShadow(
                  color: ColorCodes.greyColor.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: ColorCodes.buttoncolor,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: Text(
                      toBeginningOfSentenceCase(item.planType ?? 'Monthly') ??
                          'Monthly',
                      style: const TextStyle(
                        color: ColorCodes.blackcolor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: Fonts.body,
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      toBeginningOfSentenceCase(item.planType ?? 'Monthly') ??
                          'Monthly',
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        fontFamily: Fonts.body,
                        color: ColorCodes.mainheadingcolor,
                      ),
                    ),
                    Text(
                      'Price: $price',
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        fontFamily: Fonts.body,
                        color: ColorCodes.mainheadingcolor,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    children: [
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusTextColor,
                            fontFamily: Fonts.body,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Next Billing: $nextFormattedDate',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        fontFamily: Fonts.body,
                        color: ColorCodes.mainheadingcolor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    if (state is BillingHistoryError) {
      return Center(
          child: Text("Error loading billing history: ${state.error}"));
    }

    return const SizedBox();
  }
}
