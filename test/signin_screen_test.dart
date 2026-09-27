import 'package:mindfully_evolve_app/common/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfully_evolve_app/screens/signin/signin_screen.dart';

void main() {
  testWidgets(
      'sign in fits narrow and wide screens and supports password visibility',
      (tester) async {
    for (final entry in {
      'DM Sans': 'DMSans/DMSans-Variable.ttf',
      'Manrope': 'Manrope/Manrope-Variable.ttf'
    }.entries) {
      final loader = FontLoader(entry.key)
        ..addFont(rootBundle.load('assets/fonts/${entry.value}'));
      await tester.runAsync(loader.load);
    }
    for (final size in [
      const Size(320, 568),
      const Size(320, 700),
      const Size(390, 844),
      const Size(1124, 1276)
    ]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(const MaterialApp(home: SigninScreen()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Welcome back.'), findsOneWidget);
      final scrollable = tester.state<ScrollableState>(find
          .descendant(
              of: find.byType(SingleChildScrollView),
              matching: find.byType(Scrollable))
          .first);
      expect(scrollable.position.maxScrollExtent, 0,
          reason: 'Sign-in controls should fit without scrolling at $size');
      expect(find.text('Create an account').hitTestable(), findsOneWidget);
      final button = find.widgetWithText(ButtonWidget, 'Sign in');
      expect(tester.widget<ButtonWidget>(button).isActive, isFalse);
      final fields = find.byType(TextField);
      await tester.enterText(fields.first, 'hello@example.com');
      await tester.enterText(fields.last, 'example-password');
      await tester.pump();
      expect(tester.widget<ButtonWidget>(button).isActive, isTrue);
      await tester.ensureVisible(find.byTooltip('Show password'));
      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();
      expect(find.byTooltip('Hide password'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    }
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
