import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfully_evolve_app/common/widgets/button_widget.dart';
import 'package:mindfully_evolve_app/screens/signin/signin_screen.dart';
import 'package:mindfully_evolve_app/screens/signup/signup_screen.dart';

void main() {
  testWidgets(
      'auth screens adapt to system appearance at narrow and wide widths',
      (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    tester.view.devicePixelRatio = 1;
    for (final signup in [false, true]) {
      for (final width in [320.0, 1124.0]) {
        tester.view.physicalSize = Size(width, 1276);
        await tester.pumpWidget(MaterialApp(
            home: signup ? const SignupScreen() : const SigninScreen()));
        for (final brightness in [
          Brightness.light,
          Brightness.dark,
          Brightness.light
        ]) {
          tester.platformDispatcher.platformBrightnessTestValue = brightness;
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          final context = tester.element(find.byType(Form));
          final theme = Theme.of(context);
          expect(theme.brightness, brightness);
          expect(
              theme.scaffoldBackgroundColor,
              brightness == Brightness.dark
                  ? const Color(0xFF211F1C)
                  : const Color(0xFFF0EAE6));
          double contrast(Color a, Color b) {
            final first = a.computeLuminance();
            final second = b.computeLuminance();
            return ((first > second ? first : second) + 0.05) /
                ((first < second ? first : second) + 0.05);
          }

          expect(
              contrast(theme.colorScheme.onSurface, theme.colorScheme.surface),
              greaterThanOrEqualTo(4.5));
          expect(
              contrast(theme.colorScheme.onSurfaceVariant,
                  theme.colorScheme.surface),
              greaterThanOrEqualTo(4.5));
          expect(
              contrast(theme.colorScheme.onPrimary, theme.colorScheme.primary),
              greaterThanOrEqualTo(4.5));
          final field = tester.widget<TextField>(find.byType(TextField).first);
          expect(field.decoration!.fillColor,
              theme.colorScheme.surfaceContainerHighest);
          expect(field.style!.color, theme.colorScheme.onSurface);
        }
        await tester.pumpWidget(const SizedBox());
      }
    }
  });

  testWidgets(
      'signup validates email and password and allows password visibility in dark mode',
      (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await tester.pumpWidget(const MaterialApp(home: SignupScreen()));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(1), 'invalid');
    await tester.enterText(fields.at(2), 'abcdef');
    await tester.ensureVisible(find.byTooltip('Show password'));
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(find.byTooltip('Hide password'), findsOneWidget);
    final button = find.widgetWithText(ButtonWidget, 'Create free account');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.text('Please enter a valid email address'), findsOneWidget);
    expect(
        find.text('Password must contain at least one letter and one number'),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
