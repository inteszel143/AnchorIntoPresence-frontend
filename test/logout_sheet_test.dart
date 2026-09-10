import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfully_evolve_app/common/app_theme.dart';
import 'package:mindfully_evolve_app/common/local_storage.dart';
import 'package:mindfully_evolve_app/common/logoutconfirmation_dialog.dart';
import 'package:mindfully_evolve_app/utils/string_constants.dart';

void main() {
  testWidgets(
      'confirmed logout removes protected routes and blocks back navigation',
      (tester) async {
    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      FlutterSecureStorage.setMockInitialValues({'auth_token': 'test-session'});
      final navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(MaterialApp(
        navigatorKey: navigatorKey,
        theme: AppTheme.light.copyWith(platform: platform),
        home: const Scaffold(body: Text('Protected home')),
      ));
      navigatorKey.currentState!.push(MaterialPageRoute<void>(
        builder: (context) => Scaffold(
            body: TextButton(
          onPressed: () => showLogoutConfirmationDialog(context),
          child: const Text('Settings logout'),
        )),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings logout'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(Strings.logout));
      await tester.pumpAndSettle();
      expect(await LocalStorage.getToken(), isNull);
      expect(find.text('Welcome back.'), findsOneWidget);
      expect(navigatorKey.currentState!.canPop(), isFalse);
      expect(find.text('Protected home', skipOffstage: false), findsNothing);
      expect(find.text('Settings logout', skipOffstage: false), findsNothing);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.dragFrom(const Offset(1, 300), const Offset(350, 0));
      await tester.pumpAndSettle();
      expect(find.text('Welcome back.'), findsOneWidget);
      expect(navigatorKey.currentState!.canPop(), isFalse);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('logout sheet opens at bottom and dismissals preserve session',
      (tester) async {
    FlutterSecureStorage.setMockInitialValues({'auth_token': 'test-session'});
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
          body: Builder(
              builder: (context) => TextButton(
                    onPressed: () => showLogoutConfirmationDialog(context),
                    child: const Text('Open'),
                  ))),
    ));
    for (final dismissal in ['cancel', 'close', 'drag']) {
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(tester.getBottomLeft(find.byType(BottomSheet)).dy, 800);
      expect(find.text(Strings.areYouSureForSignOut), findsOneWidget);
      if (dismissal == 'cancel') {
        await tester.tap(find.text(Strings.cancel));
      } else if (dismissal == 'close') {
        await tester.tap(find.byTooltip('Close'));
      } else {
        await tester.fling(
            find.byType(BottomSheet), const Offset(0, 600), 1500);
      }
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsNothing);
      expect(await LocalStorage.getToken(), 'test-session');
      expect(tester.takeException(), isNull);
    }
  });
}
