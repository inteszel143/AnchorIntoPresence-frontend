import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfully_evolve_app/common/app_theme.dart';
import 'package:mindfully_evolve_app/screens/subscriptionmanagement/subscription_plan_card.dart';

void main() {
  testWidgets('plan cards fit small screens and large text in both themes',
      (tester) async {
    tester.view.physicalSize = const Size(320, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      await tester.pumpWidget(MaterialApp(
        theme: theme,
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Scaffold(
              body: SingleChildScrollView(
                  child: Padding(
            padding: const EdgeInsets.all(20),
            child: SubscriptionPlanCard(
              title: 'Annual Membership',
              price: 'PHP 12,999.00',
              originalPrice: 'PHP 15,999.00',
              period: 'per year',
              isActive: false,
              isFounding: true,
              onChoose: () {},
            ),
          ))),
        ),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('choose acts once and current plan cannot be repurchased',
      (tester) async {
    var chosen = 0;
    for (final active in [false, true]) {
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: SubscriptionPlanCard(
        title: 'Monthly Membership',
        price: '\$9.99',
        period: 'per month',
        isActive: active,
        onChoose: () => chosen++,
      ))));
      await tester.tap(find.byType(FilledButton));
      expect(chosen, 1);
      if (active) expect(find.text('Current plan'), findsOneWidget);
    }
  });
}
