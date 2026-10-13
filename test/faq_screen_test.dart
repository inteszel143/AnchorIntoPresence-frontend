import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfully_evolve_app/common/app_theme.dart';
import 'package:mindfully_evolve_app/screens/faq/faq.dart';
import 'package:mindfully_evolve_app/screens/faq/faq_bloc/faq_bloc.dart';
import 'package:mindfully_evolve_app/screens/contact_support/contact_supportscreen.dart';

void main() {
  for (final dark in [false, true]) {
    testWidgets(
        'FAQ search, clear, answers and support work with large text, dark=$dark',
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
        home: FrequentlyAskedQuestionsScreen(
            createBloc: () => FaqBloc(
                fetch: (page, limit, query) async => {
                      'data': query.isEmpty
                          ? [
                              {
                                '_id': '1',
                                'question': 'How do reminders work?',
                                'answer': 'Choose a time in Settings.',
                                'status': 1
                              }
                            ]
                          : [],
                    })),
      ));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('How do reminders work?'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('How do reminders work?'));
      await tester.pumpAndSettle();
      expect(find.text('Choose a time in Settings.'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'missing');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
      expect(find.text('No matching questions'), findsOneWidget);
      await tester.ensureVisible(find.byTooltip('Clear search'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Clear search'));
      await tester.pumpAndSettle();
      expect(find.text('How do reminders work?'), findsOneWidget);
      await tester.ensureVisible(find.text('Contact Support'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Contact Support'));
      await tester.pumpAndSettle();
      expect(find.byType(ContactSupportscreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('failed FAQ load can be retried', (tester) async {
    var calls = 0;
    await tester.pumpWidget(MaterialApp(
        home: FrequentlyAskedQuestionsScreen(
            createBloc: () => FaqBloc(fetch: (_, __, ___) async {
                  if (++calls == 1) throw Exception('offline');
                  return {'data': []};
                }))));
    await tester.pumpAndSettle();
    expect(find.text('Questions couldn’t load'), findsOneWidget);
    await tester.ensureVisible(find.text('Try again'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('No questions available yet'), findsOneWidget);
    expect(calls, 2);
  });
}
