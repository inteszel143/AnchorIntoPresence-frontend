import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfully_evolve_app/screens/subscriptionmanagement/billing_history_tab.dart';
import 'package:mindfully_evolve_app/screens/subscriptionmanagement/user_purchase_model.dart';

void main() {
  Widget page(Future<List<UserPurchase>?> future, {VoidCallback? retry}) =>
      MaterialApp(
          home: Scaffold(
              body: SingleChildScrollView(
                  child: BillingHistoryTab(
                      purchases: future, onRetry: retry ?? () {}))));

  testWidgets('handles loading, signed-out, empty, and retry states',
      (tester) async {
    final pending = Completer<List<UserPurchase>?>();
    await tester.pumpWidget(page(pending.future));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    pending.complete(null);
    await tester.pumpAndSettle();
    expect(find.text('Sign in to view billing history'), findsOneWidget);

    await tester.pumpWidget(page(Future.value([])));
    await tester.pumpAndSettle();
    expect(find.text('No billing history yet'), findsOneWidget);

    var retried = false;
    final failed = Completer<List<UserPurchase>?>();
    await tester.pumpWidget(page(failed.future, retry: () => retried = true));
    failed.completeError(Exception('offline'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Try again'));
    expect(retried, isTrue);
  });

  testWidgets('each record shows next billing and its period status',
      (tester) async {
    await tester.pumpWidget(page(Future.value([
      UserPurchase(
          userId: 'user',
          purchaseId: 'old',
          productId: 'monthly',
          planType: 'monthly',
          amount: 9.99,
          purchaseDate: DateTime(2000, 1, 1)),
      UserPurchase(
          userId: 'user',
          purchaseId: 'current',
          productId: 'annual',
          planType: 'yearly',
          amount: 99,
          purchaseDate: DateTime(2020),
          nextBillingDate: DateTime(2100, 6, 15)),
    ])));
    await tester.pumpAndSettle();
    expect(find.text('Next Billing'), findsNothing);
    expect(find.text('Next billing: Jan 31, 2000 (estimated)'), findsOneWidget);
    expect(find.text('Next billing: Jun 15, 2100'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Expired'), findsOneWidget);
  });

  testWidgets('sorts newest first and fits narrow screens with large text',
      (tester) async {
    tester.view.physicalSize = const Size(320, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final purchases = [
      for (final day in [1, 2])
        UserPurchase(
            userId: 'user',
            purchaseId: 'transaction-$day',
            productId: 'monthly',
            amount: 9.99,
            currencySymbol: 'USD',
            planType: 'monthly',
            purchaseDate: DateTime(2026, 9, day)),
    ];
    await tester.pumpWidget(MaterialApp(
        home: MediaQuery(
      data: const MediaQueryData(textScaler: TextScaler.linear(2)),
      child: Scaffold(
          body: SingleChildScrollView(
              child: Padding(
        padding: const EdgeInsets.all(20),
        child: BillingHistoryTab(
            purchases: Future.value(purchases), onRetry: () {}),
      ))),
    )));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(tester.getTopLeft(find.text('transaction-2')).dy,
        lessThan(tester.getTopLeft(find.text('transaction-1')).dy));
    expect(find.textContaining('9.99'), findsNWidgets(2));
  });
}
