import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mindfully_evolve_app/common/app_theme.dart';
import 'package:mindfully_evolve_app/common/splash_wrapper.dart';
import 'package:mindfully_evolve_app/common/widgets/main_page.dart';
import 'package:mindfully_evolve_app/screens/welcome/welcome_screen.dart';

void main() {
  testWidgets('fresh install moves from splash to welcome', (tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: const SplashWrapper(),
    ));
    expect(find.byType(MainPage), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.text('Find your calm'), findsOneWidget);
    expect(tester.state<NavigatorState>(find.byType(Navigator).first).canPop(),
        isFalse);
    expect(tester.takeException(), isNull);
  });
}
