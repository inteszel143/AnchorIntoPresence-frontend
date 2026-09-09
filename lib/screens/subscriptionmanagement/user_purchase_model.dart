class UserPurchase {
  final String userId;
  final String purchaseId;
  final String productId;
  final String? currencySymbol;
  final double amount;
  final String? planType;
  final DateTime purchaseDate;

  UserPurchase({
    required this.userId,
    required this.purchaseId,
    required this.productId,
    this.currencySymbol,
    required this.amount,
    this.planType,
    required this.purchaseDate,
  });

  factory UserPurchase.fromJson(Map<String, dynamic> json) {
    return UserPurchase(
      userId: json['userId'] as String,
      purchaseId: json['purchaseId'] as String,
      productId: json['productId'] as String,
      currencySymbol: json['currencySymbol'] as String? ?? 'INR',
      amount: (json['amount'] as num).toDouble(),
      planType: json['planType'] ?? 'monthly',
      purchaseDate: DateTime.parse(json['purchaseDate'] as String),
    );
  }
}
