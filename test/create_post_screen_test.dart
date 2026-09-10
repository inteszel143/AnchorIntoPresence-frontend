import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfully_evolve_app/common/app_theme.dart';
import 'package:mindfully_evolve_app/screens/add_post/add_post_screen.dart';

void main() {
  for (final dark in [false, true]) {
    testWidgets('Composer validation and photo options, dark=$dark',
        (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MaterialApp(
          theme: dark ? AppTheme.dark : AppTheme.light,
          builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.5)),
              child: child!),
          home: const CreatePostScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Post'));
      await tester.pumpAndSettle();
      expect(find.text('Please add a message or photo'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'A quiet moment today.');
      tester.testTextInput.hide();
      await tester.scrollUntilVisible(find.text('Add photo'), 250,
          scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add photo'));
      await tester.pumpAndSettle();
      expect(find.text('Camera'), findsOneWidget);
      expect(find.text('Gallery'), findsOneWidget);
      Navigator.of(tester.element(find.text('Gallery'))).pop();
      await tester.pumpAndSettle();
      expect(find.text('A quiet moment today.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
