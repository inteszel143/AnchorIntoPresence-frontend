import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfully_evolve_app/common/app_theme.dart';
import 'package:mindfully_evolve_app/common/deleteconfirmation_dialog.dart';
import 'package:mindfully_evolve_app/utils/string_constants.dart';

void main() {
  testWidgets(
      'delete confirmation opens at bottom and dismisses without deletion',
      (tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      await tester.pumpWidget(MaterialApp(
        theme: theme,
        home: Scaffold(
            body: Builder(
                builder: (context) => TextButton(
                      onPressed: () => showDeleteConfirmationDialog(context),
                      child: const Text('Open'),
                    ))),
      ));
      for (final dismiss in ['cancel', 'close', 'swipe']) {
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(find.byType(BottomSheet), findsOneWidget);
        expect(tester.getBottomLeft(find.byType(BottomSheet)).dy, 800);
        expect(find.text(Strings.areYouSureForDeleteAccount), findsOneWidget);
        if (dismiss == 'cancel') {
          await tester.tap(find.text(Strings.cancel));
        } else if (dismiss == 'close') {
          await tester.tap(find.byTooltip('Close'));
        } else {
          await tester.fling(
              find.byType(BottomSheet), const Offset(0, 600), 1500);
        }
        await tester.pumpAndSettle();
        expect(find.byType(BottomSheet), findsNothing);
        expect(find.text('Open'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    }
  });
}
