import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfully_evolve_app/utils/string_constants.dart';
import 'package:mindfully_evolve_app/common/app_theme.dart';
import 'package:mindfully_evolve_app/common/widgets/information_page.dart';
import 'package:mindfully_evolve_app/common/widgets/legal_document.dart';
import 'package:mindfully_evolve_app/helping_widgets/faqitem_tile.dart';
import 'package:mindfully_evolve_app/screens/contact_support/contact_supportscreen.dart';

void main() {
  testWidgets(
      'support fields retain input when keyboard changes layout and validate',
      (tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const ContactSupportscreen()));
    await tester
        .ensureVisible(find.widgetWithText(FilledButton, Strings.submit));
    await tester.tap(find.widgetWithText(FilledButton, Strings.submit));
    await tester.pumpAndSettle();
    expect(find.text('Please enter title'), findsOneWidget);
    expect(find.text('Please enter description'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, 'My question');
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pumpAndSettle();
    expect(find.text('My question'), findsOneWidget);
    await tester
        .ensureVisible(find.widgetWithText(FilledButton, Strings.submit));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('FAQ answers still expand and collapse', (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.dark,
        home: const InformationPage(
          title: 'FAQs',
          slivers: [
            SliverToBoxAdapter(
                child:
                    FAQItemTile(question: 'A question?', answer: 'An answer.'))
          ],
        )));
    await tester.tap(find.text('A question?'));
    await tester.pumpAndSettle();
    expect(find.text('An answer.').hitTestable(), findsOneWidget);
    await tester.tap(find.text('A question?'));
    await tester.pumpAndSettle();
    expect(find.text('An answer.').hitTestable(), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'document layout fits narrow screens with large text in both themes',
      (tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      await tester.pumpWidget(MaterialApp(
          theme: theme,
          home: const MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(2)),
            child: InformationPage(title: 'Privacy Policy', slivers: [
              SliverToBoxAdapter(
                  child: LegalDocument(
                      description:
                          '<h2>Your information</h2><p>This sample paragraph checks the document layout and spacing.</p><ul><li>First item</li><li>Second item</li></ul>')),
            ]),
          )));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -200));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}
