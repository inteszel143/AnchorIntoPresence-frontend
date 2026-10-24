import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mindfully_evolve_app/common/app_theme.dart';
import 'package:mindfully_evolve_app/common/widgets/new_user_welcome.dart';

String token(String id) {
  String encode(Map<String, dynamic> data) =>
      base64Url.encode(utf8.encode(jsonEncode(data))).replaceAll('=', '');
  return '${encode({'alg': 'HS256'})}.${encode({'userId': id})}.signature';
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('dismissal is saved per account and prevents repeat welcomes', (tester) async {
    var account = 'first-user';
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (context) =>
      Scaffold(body: TextButton(onPressed: () => showNewUserWelcome(context, token(account)),
        child: const Text('Open'))))));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.byType(NewUserWelcomeDialog), findsOneWidget);
    await tester.tap(find.text('Let’s begin'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.byType(NewUserWelcomeDialog), findsNothing);
    account = 'second-user';
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.byType(NewUserWelcomeDialog), findsOneWidget);
    await tester.tap(find.byTooltip('Close welcome'));
    await tester.pumpAndSettle();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('welcome_seen_v1_first-user'), isTrue);
    expect(prefs.getBool('welcome_seen_v1_second-user'), isTrue);
  });

  testWidgets('welcome supports small screens, large text and both themes', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      await tester.pumpWidget(MaterialApp(theme: theme, home: MediaQuery(
        data: const MediaQueryData(size: Size(320, 568), textScaler: TextScaler.linear(2)),
        child: const Scaffold(body: NewUserWelcomeDialog()),
      )));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Let’s begin'));
      expect(find.text('Let’s begin').hitTestable(), findsOneWidget);
    }
  });
}
