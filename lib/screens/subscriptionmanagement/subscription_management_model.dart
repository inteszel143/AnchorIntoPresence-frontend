import 'package:in_app_purchase/in_app_purchase.dart';

class SubscriptionPlan {
  final String planType;
  final String productId;
  final String planName;
  final String price;
  final List<String> features;

  SubscriptionPlan({
    required this.planType,
    required this.productId,
    required this.planName,
    required this.price,
    required this.features,
  });

  factory SubscriptionPlan.fromProduct(
    ProductDetails product,
    String planType,
    String planName,
    List<String> features,
  ) {
    return SubscriptionPlan(
      planType: planType,
      productId: product.id,
      planName: planName,
      price: product.price,
      features: features,
    );
  }
}
