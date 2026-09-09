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
import '../../common/widgets/auth_theme.dart';
import '../../utils/color_constants.dart';
import '../../utils/fonts.dart';
import '../../utils/global.dart' as globals;
import '../signup/signup_screen.dart';

class SubscriptionManagementScreen extends StatefulWidget {
  final bool? isSubscribed;

  const SubscriptionManagementScreen({super.key, this.isSubscribed = true});

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
          backgroundColor:
              Theme.of(context).colorScheme.surfaceContainerHighest,
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
                        child: Icon(
                          Icons.close,
                          size: 22,
                          color: Theme.of(dialogContext).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  "Confirm Purchase",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w400,
                    letterSpacing: Fonts.headingLetterSpacing,
                    fontFamily: Fonts.heading,
                    color: Theme.of(dialogContext).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: Fonts.body,
                        color: Theme.of(dialogContext)
                          .colorScheme
                          .onSurfaceVariant,
                      letterSpacing: 2,
                      height: 1.0,
                    ),
                    children: [
                      const TextSpan(text: "You are about to "),
                      TextSpan(
                        text: "purchase:",
                        style: TextStyle(
                          color: Theme.of(dialogContext).colorScheme.primary,
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
                            color: Theme.of(dialogContext).colorScheme.onSurface,
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
                            backgroundColor:
                              Theme.of(dialogContext).colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Confirm',
                          style: TextStyle(
                            color: Theme.of(dialogContext).colorScheme.onPrimary,
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
    return AuthTheme(
      child: BlocProvider<SubscriptionBloc>.value(
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
              SnackBar(content: Text(state.message)),
            );

            _bloc.add(FetchSubscriptionPlans(productIds: _productIds));
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomAppbar(headingTxt: Strings.subscriptionManagement),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MAKE SPACE FOR WHAT MATTERS',
                            style: TextStyle(
                              fontFamily: Fonts.body,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Choose your plan',
                            style: TextStyle(
                              fontFamily: Fonts.heading,
                              fontSize: 30,
                              height: 1.15,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Go deeper with guided practices and a calmer space to return to every day.',
                            style: TextStyle(
                              fontFamily: Fonts.body,
                              fontSize: 15,
                              height: 1.5,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Tab switcher ────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
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
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 13),
                                  decoration: BoxDecoration(
                                    color: !isBillingTab
                                      ? Theme.of(context).colorScheme.primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    Strings.plans,
                                    style: TextStyle(
                                        color: !isBillingTab
                                          ? Theme.of(context).colorScheme.onPrimary
                                          : Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
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
                                          ? Theme.of(context).colorScheme.primary
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(11),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      Strings.billingHistory,
                                      style: TextStyle(
                                        color: isBillingTab
                                          ? Theme.of(context)
                                            .colorScheme
                                            .onPrimary
                                          : Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
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

                    const SizedBox(height: 24),

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
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 720 ? 3 : 1;
              final gap = columns == 1 ? 0.0 : 16.0;
              final cardWidth = columns == 1
                  ? constraints.maxWidth
                  : (constraints.maxWidth - gap * (columns - 1)) / columns;

              return Wrap(
                spacing: gap,
                runSpacing: 16,
                children: uniquePlans.map((plan) {
                  final isActive = plan.id.split(':').first ==
                          (globals.alreadyPurchasedProductId ?? '')
                              .split(':')
                              .first &&
                      isSubscriptionActive();
                  final priceInfo = _resolveOfferPrice(plan);
                  final features = _featuresForPlan(plan);

                  return SizedBox(
                    width: cardWidth,
                    child: _buildPlanCard(
                      context,
                      plan,
                      isActive,
                      priceInfo,
                      features,
                    ),
                  );
                }).toList(),
              );
            },
          ),

          // ── Redeem / Offer Code button ──────────────────────────────────
          const SizedBox(height: 20),
          if (Platform.isIOS)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () => _bloc.add(const RedeemOfferCode()),
                icon: const Icon(Icons.local_offer_outlined, size: 18),
                label: const Text('Redeem Code'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: Fonts.body,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
        ],
      );
    }

    if (state is SubscriptionError) {
      return Center(
        child: Column(
          children: [
            Text(state.message),
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

  List<String> _featuresForPlan(ProductDetails plan) {
    final id = plan.id.split(':').first;
    if (id.contains('founding')) {
      return [
        'Founding member pricing',
        'All guided practices',
        'Progress tracking and favorites',
        'Access across devices',
      ];
    }
    if (id.contains('year')) {
      return [
        'All guided practices',
        'Progress tracking and favorites',
        'Access across devices',
        'Best value for the year',
      ];
    }
    return [
      'All guided practices',
      'Progress tracking and favorites',
      'Access across devices',
    ];
  }

  Widget _buildPlanCard(
    BuildContext context,
    ProductDetails plan,
    bool isActive,
    ({String displayPrice, String? originalPrice, String? bestOfferToken})
        priceInfo,
    List<String> features,
  ) {
    final colors = Theme.of(context).colorScheme;
    final hasDiscount = priceInfo.originalPrice != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        border: Border.all(color: colors.outline),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
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
                          groupValue: (globals.alreadyPurchasedProductId ?? '')
                              .split(':')
                              .first,
                          activeColor: colors.primary,
                          onChanged: isActive
                              ? null
                              : (_) => _showConfirmationDialog(context, plan),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _cleanPlanTitle(plan.title),
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            fontFamily: Fonts.body,
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isActive)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Current',
                    style: TextStyle(
                      color: colors.onPrimary,
                      fontFamily: Fonts.body,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Your space to slow down, with more room to return to yourself.',
            style: TextStyle(
              fontFamily: Fonts.body,
              fontSize: 13,
              height: 1.4,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                priceInfo.displayPrice,
                style: TextStyle(
                  fontFamily: Fonts.heading,
                  fontSize: 30,
                  height: 1,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),
              if (hasDiscount) ...[
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    priceInfo.originalPrice!,
                    style: TextStyle(
                      fontFamily: Fonts.body,
                      fontSize: 13,
                      color: colors.onSurfaceVariant,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 5),
          Text(
            plan.id.split(':').first.contains('month') ? 'per month' : 'per year',
            style: TextStyle(
              fontFamily: Fonts.body,
              fontSize: 12,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: isActive
                ? () => _bloc.add(RestorePurchasesEvent())
                : () => _showConfirmationDialog(context, plan),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                isActive ? 'Restore Purchases' : 'Choose plan',
                style: TextStyle(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  fontFamily: Fonts.body,
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'EVERYTHING INCLUDED',
            style: TextStyle(
              fontFamily: Fonts.body,
              fontSize: 11,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          ...features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 11),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, size: 17, color: colors.primary),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      feature,
                      style: TextStyle(
                        fontFamily: Fonts.body,
                        fontSize: 13,
                        height: 1.25,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.25)
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.35);
            final statusTextColor = Theme.of(context).colorScheme.onSurface;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline),
              boxShadow: [
                BoxShadow(
                  color: ColorCodes.greyColor.withValues(alpha: 0.1),
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
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: Text(
                      toBeginningOfSentenceCase(item.planType ?? 'Monthly') ??
                          'Monthly',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
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
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        fontFamily: Fonts.body,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Price: $price',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        fontFamily: Fonts.body,
                        color: Theme.of(context).colorScheme.onSurface,
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
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        fontFamily: Fonts.body,
                        color: Theme.of(context).colorScheme.onSurface,
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
