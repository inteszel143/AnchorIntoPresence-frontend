import 'package:mindfully_evolve_app/common/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindfully_evolve_app/common/widgets/loading_overlay.dart';
import 'package:mindfully_evolve_app/screens/signin/signin_bloc/signin_bloc.dart';
import 'package:mindfully_evolve_app/screens/signin/signin_bloc/signin_state.dart';
import 'package:mindfully_evolve_app/screens/signin/signin_screen.dart';

void main() {
  testWidgets('loading covers the screen and clears previous notifications',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);

    await tester.pumpWidget(const MaterialApp(home: SigninScreen()));
    await tester.pumpAndSettle();
    final formContext = tester.element(find.byType(Form));
    final bloc = formContext.read<SigninBloc>();
    ScaffoldMessenger.of(formContext).showSnackBar(
      const SnackBar(content: Text('Previous error')),
    );
    await tester.pumpAndSettle();

    // Drive the UI state without making a real authentication request.
    bloc.emit(SigninLoading());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Previous error'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    final blur = find.descendant(
      of: find.byType(LoadingOverlay),
      matching: find.byType(BackdropFilter),
    );
    for (final keyboardHeight in [300.0, 0.0]) {
      tester.view.viewInsets = FakeViewPadding(bottom: keyboardHeight);
      await tester.pump();
      expect(tester.getRect(blur), const Rect.fromLTWH(0, 0, 390, 844));
      expect(tester.takeException(), isNull);
    }

    bloc.emit(SigninFailure('Please try again'));
    await tester.pumpAndSettle();
    expect(find.byType(BackdropFilter), findsNothing);
    expect(find.text('Please try again'), findsOneWidget);
  });

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
