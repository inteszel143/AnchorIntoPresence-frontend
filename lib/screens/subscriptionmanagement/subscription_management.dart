import 'purchase_feedback.dart';
import 'package:mindfully_evolve_app/common/widgets/app_scaffold.dart';
import '../../common/widgets/scroll_title_page.dart';
import 'subscription_plan_card.dart';
import 'billing_history_tab.dart';
import 'user_purchase_model.dart';
import '../../utils/api_service.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:mindfully_evolve_app/common/main_screen.dart';
import 'package:mindfully_evolve_app/screens/subscriptionmanagement/subscription_management_bloc/subscriprion_management_bloc.dart';
import 'package:mindfully_evolve_app/screens/subscriptionmanagement/subscription_management_bloc/subscriprion_management_event.dart';
import 'package:mindfully_evolve_app/screens/subscriptionmanagement/subscription_management_bloc/subscriprion_management_state.dart';
import 'package:mindfully_evolve_app/utils/string_constants.dart';

import '../../common/local_storage.dart';
import '../../common/widgets/custom_appbar.dart';
import '../../common/widgets/auth_theme.dart';
import '../../utils/color_constants.dart';
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
  bool _showBillingHistory = false;
  Future<List<UserPurchase>?>? _billingHistory;

  late final SubscriptionBloc _bloc;

  @override
  void initState() {
    super.initState();
    _setPlatformSpecificProductIds();
    _bloc = SubscriptionBloc();
    _bloc.add(FetchSubscriptionPlans(productIds: _productIds));
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

  Future<void> _showConfirmationSheet(
      BuildContext context, ProductDetails plan) async {
    final priceInfo = _resolveOfferPrice(plan);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: colors.surface,
      constraints: const BoxConstraints(maxWidth: 600),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Confirm your plan',
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('A little more space for your daily practice.',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: colors.onSurfaceVariant, height: 1.5)),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: colors.outlineVariant),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_cleanPlanTitle(plan.title),
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(priceInfo.displayPrice,
                            style: theme.textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        Text(
                            plan.id.contains('month')
                                ? 'per month'
                                : 'per year',
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: colors.onSurfaceVariant)),
                      ],
                    ),
                    if (priceInfo.originalPrice != null) ...[
                      const SizedBox(height: 6),
                      Text(priceInfo.originalPrice!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                              decoration: TextDecoration.lineThrough)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                  'Review the final price and renewal terms in the store before completing your purchase.',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: colors.onSurfaceVariant, height: 1.5)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    if (priceInfo.bestOfferToken != null) {
                      _bloc.add(PurchasePlanWithOffer(
                        plan: plan,
                        offerToken: priceInfo.bestOfferToken!,
                      ));
                    } else {
                      _bloc.add(PurchasePlan(plan: plan));
                    }
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Continue to purchase',
                      textAlign: TextAlign.center),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: const Text('Not now'),
                ),
              ),
            ],
          ),
        ),
      ),
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
              if (!mounted || !context.mounted) return;

              if (token != null && token.isNotEmpty) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => MainScreen(initialIndex: 0)),
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
            } else if (state is SubscriptionCancelled) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(const SnackBar(
                  content: Text(purchaseCancellationMessage),
                ));
            } else if (state is SubscriptionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            return AppScaffold(
              body: ScrollTitlePage(
                title: Strings.subscriptionManagement,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CustomAppbar(headingTxt: ''),
                          Expanded(
                            child: SingleChildScrollView(
                              padding:
                                  const EdgeInsets.only(top: 20, bottom: 32),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(Strings.subscriptionManagement,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineLarge
                                          ?.copyWith(
                                              fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 8),
                                  Text(
                                      'A little more space for your daily practice.',
                                      style: TextStyle(
                                          fontSize: 15,
                                          height: 1.5,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant)),
                                  const SizedBox(height: 24),
                                  DefaultTabController(
                                    length: 2,
                                    child: TabBar(
                                      isScrollable: true,
                                      tabAlignment: TabAlignment.start,
                                      labelColor: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      unselectedLabelColor: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant
                                          .withValues(alpha: .7),
                                      labelStyle: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                              fontWeight: FontWeight.w700),
                                      unselectedLabelStyle: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                              fontWeight: FontWeight.w500),
                                      labelPadding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      indicatorSize: TabBarIndicatorSize.label,
                                      indicatorWeight: 3,
                                      indicatorColor:
                                          Theme.of(context).colorScheme.primary,
                                      dividerColor: Theme.of(context)
                                          .colorScheme
                                          .outlineVariant
                                          .withValues(alpha: .5),
                                      splashBorderRadius:
                                          BorderRadius.circular(10),
                                      tabs: const [
                                        Tab(text: 'Plans'),
                                        Tab(text: 'Billing History'),
                                      ],
                                      onTap: (index) {
                                        setState(() {
                                          _showBillingHistory = index == 1;
                                          if (_showBillingHistory) {
                                            _billingHistory ??=
                                                _loadBillingHistory();
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  if (_showBillingHistory)
                                    BillingHistoryTab(
                                      purchases: _billingHistory!,
                                      onRetry: () => setState(() {
                                        _billingHistory = _loadBillingHistory();
                                      }),
                                    )
                                  else ...[
                                    Text('Choose your plan',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge),
                                    const SizedBox(height: 6),
                                    Text('Find a rhythm that works for you.',
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant)),
                                    const SizedBox(height: 16),
                                    _buildPlansTab(state),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<List<UserPurchase>?> _loadBillingHistory() async {
    final token = await LocalStorage.getToken();
    if (token == null || token.isEmpty) return null;
    return ApiService.fetchUserPurchases();
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

      if (uniquePlans.isEmpty) {
        return _statusPanel(
          icon: Icons.storefront_outlined,
          title: 'Plans aren’t available right now',
          description: 'Please try again in a moment.',
          onRetry: () =>
              _bloc.add(FetchSubscriptionPlans(productIds: _productIds)),
        );
      }
      return Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final largeText = MediaQuery.textScalerOf(context).scale(16) > 20;
              final maxColumns = largeText
                  ? 1
                  : constraints.maxWidth >= 900
                      ? 3
                      : constraints.maxWidth >= 600
                          ? 2
                          : 1;
              final columns = uniquePlans.length.clamp(1, maxColumns);
              final gap = columns == 1 ? 0.0 : 16.0;
              final cardWidth = columns == 1
                  ? constraints.maxWidth
                  : (constraints.maxWidth - gap * (columns - 1)) / columns;

              return Wrap(
                spacing: gap,
                runSpacing: 16,
                children: uniquePlans.map((plan) {
                  final isActive = plan.id.split(':').first ==
                          globals.alreadyPurchasedProductId.split(':').first &&
                      isSubscriptionActive();
                  final priceInfo = _resolveOfferPrice(plan);

                  return SizedBox(
                    width: cardWidth,
                    child: _buildPlanCard(
                      context,
                      plan,
                      isActive,
                      priceInfo,
                    ),
                  );
                }).toList(),
              );
            },
          ),
          if (Platform.isIOS) ...[
            const SizedBox(height: 12),
            Center(
              child: TextButton.icon(
                onPressed: () => _bloc.add(const RedeemOfferCode()),
                icon: const Icon(Icons.local_offer_outlined, size: 18),
                label: const Text('Redeem Code'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          _includedBenefits(),
          const SizedBox(height: 12),
        ],
      );
    }

    if (state is SubscriptionError) {
      return _statusPanel(
        icon: Icons.wifi_off_rounded,
        title: 'Plans couldn’t load',
        description: state.message,
        onRetry: () =>
            _bloc.add(FetchSubscriptionPlans(productIds: _productIds)),
      );
    }

    return const Center(
        child: CircularProgressIndicator(
      color: ColorCodes.buttoncolor,
    ));
  }

  Widget _buildPlanCard(
    BuildContext context,
    ProductDetails plan,
    bool isActive,
    ({
      String displayPrice,
      String? originalPrice,
      String? bestOfferToken
    }) priceInfo,
  ) =>
      SubscriptionPlanCard(
        title: _cleanPlanTitle(plan.title),
        price: priceInfo.displayPrice,
        originalPrice: priceInfo.originalPrice,
        period: plan.id.split(':').first.contains('month')
            ? 'per month'
            : 'per year',
        isActive: isActive,
        isFounding: plan.id.contains('founding'),
        onChoose: () => _showConfirmationSheet(context, plan),
      );

  Widget _includedBenefits() {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.outlineVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Included in every plan',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          for (final feature in [
            (Icons.self_improvement_rounded, 'All guided practices'),
            (Icons.favorite_border_rounded, 'Progress tracking and favorites'),
            (Icons.devices_rounded, 'Access across devices'),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(children: [
                Icon(feature.$1, size: 20, color: colors.primary),
                const SizedBox(width: 12),
                Expanded(child: Text(feature.$2)),
              ]),
            ),
        ],
      ),
    );
  }

  Widget _statusPanel(
      {required IconData icon,
      required String title,
      required String description,
      VoidCallback? onRetry}) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24)),
      child: Column(children: [
        Icon(icon, size: 32, color: colors.primary),
        const SizedBox(height: 16),
        Text(title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(description,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.onSurfaceVariant, height: 1.5)),
        if (onRetry != null) ...[
          const SizedBox(height: 16),
          OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again')),
        ],
      ]),
    );
  }
}
