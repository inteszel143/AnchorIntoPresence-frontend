import 'package:equatable/equatable.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../user_purchase_model.dart';

abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object?> get props => [];
}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionPlansLoaded extends SubscriptionState {
  final List<ProductDetails> products;
  final bool isPurchasing;
  final String? purchasedProductId;

  const SubscriptionPlansLoaded({
    required this.products,
    this.isPurchasing = false,
    this.purchasedProductId,
  });

  @override
  List<Object?> get props => [products, isPurchasing, purchasedProductId];
}

class SubscriptionPurchasing extends SubscriptionState {}

class PurchaseStatusLoaded extends SubscriptionState {
  final Map<String, bool> purchaseStatus;

  const PurchaseStatusLoaded({required this.purchaseStatus});

  @override
  List<Object?> get props => [purchaseStatus];
}

class SubscriptionPurchased extends SubscriptionState {
  final String productId;

  const SubscriptionPurchased({required this.productId});

  @override
  List<Object?> get props => [productId];
}

class SubscriptionRestored extends SubscriptionState {
  final String productId;

  const SubscriptionRestored({required this.productId});

  @override
  List<Object?> get props => [productId];
}

class SubscriptionError extends SubscriptionState {
  final String message;

  const SubscriptionError({required this.message});

  @override
  List<Object?> get props => [message];
}

class BillingHistoryInitial extends SubscriptionState {}

class BillingHistoryLoading extends SubscriptionState {}

class BillingHistoryLoaded extends SubscriptionState {
  final List<UserPurchase> purchases;

  const BillingHistoryLoaded(this.purchases);

  @override
  List<Object?> get props => [purchases];
}

class BillingHistoryError extends SubscriptionState {
  final String error;

  const BillingHistoryError(this.error);

  @override
  List<Object?> get props => [error];
}
