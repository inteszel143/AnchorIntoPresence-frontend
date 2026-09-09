import 'package:mindfully_evolve_app/common/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfully_evolve_app/screens/signin/signin_screen.dart';

void main() {
  testWidgets(
      'sign in fits narrow and wide screens and supports password visibility',
      (tester) async {
    for (final size in [const Size(320, 700), const Size(1124, 1276)]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(const MaterialApp(home: SigninScreen()));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Welcome back.'), findsOneWidget);
      final button = find.widgetWithText(ButtonWidget, 'Sign in');
      expect(tester.widget<ButtonWidget>(button).isActive, isFalse);
      final fields = find.byType(TextFormField);
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
