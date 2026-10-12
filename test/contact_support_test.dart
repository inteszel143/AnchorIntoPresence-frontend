import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfully_evolve_app/common/app_theme.dart';
import 'package:mindfully_evolve_app/screens/contact_support/contact_supportscreen.dart';
import 'package:mindfully_evolve_app/screens/contact_support/contact_support_model.dart';
import 'package:mindfully_evolve_app/screens/contact_support/contactsupport_bloc/contact_support_bloc.dart';

void main() {
  testWidgets('Something else requires and submits a custom title',
      (tester) async {
    String? sentTitle;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: ContactSupportscreen(
          createBloc: () => ContactSupportBloc(
                submit: ({required title, required description}) async {
                  sentTitle = title;
                  return ContactSupportResponseModel(
                      status: true, message: 'Sent', data: {});
                },
              )),
    ));
    await tester.pumpAndSettle();
    final titleField = find.byKey(const ValueKey('support-title'));
    expect(titleField, findsNothing);
    await tester.ensureVisible(find.text('Something else'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Something else'));
    await tester.pumpAndSettle();
    expect(titleField, findsOneWidget);
    await tester.enterText(find.byType(TextFormField).last, 'My message');
    await tester.ensureVisible(find.text('Send message'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Send message'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter a title.'), findsOneWidget);
    expect(sentTitle, isNull);
    await tester.enterText(titleField, '  A suggestion  ');
    await tester.ensureVisible(find.text('Using the app'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Using the app'));
    await tester.pumpAndSettle();
    expect(titleField, findsNothing);
    await tester.tap(find.text('Something else'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextFormField>(titleField).controller!.text,
        '  A suggestion  ');
    await tester.ensureVisible(find.text('Send message'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Send message'));
    await tester.pumpAndSettle();
    expect(sentTitle, 'A suggestion');
    expect(find.text('Your message has been sent'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  for (final dark in [false, true]) {
    testWidgets('support is usable with large text, dark=$dark',
        (tester) async {
      tester.view.physicalSize = const Size(320, 850);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MaterialApp(
        theme: dark ? AppTheme.dark : AppTheme.light,
        home: const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(2)),
          child: ContactSupportscreen(),
        ),
      ));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Send message'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
      'failed send preserves draft; retry sends selected topic and confirms',
      (tester) async {
    var calls = 0;
    final pending = Completer<ContactSupportResponseModel>();
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: ContactSupportscreen(
          createBloc: () => ContactSupportBloc(
                submit: ({required title, required description}) async {
                  calls++;
                  expect(title, 'Account & sign-in');
                  expect(description, 'I cannot sign in.');
                  if (calls == 1) return pending.future;
                  return ContactSupportResponseModel(
                      status: true, message: 'Sent', data: {});
                },
              )),
    ));
    await tester.ensureVisible(find.text('Account & sign-in'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Account & sign-in'));
    await tester.enterText(find.byType(TextFormField), 'I cannot sign in.');
    await tester.ensureVisible(find.text('Send message'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Send message'));
    await tester.pump();
    expect(find.text('Sending…'), findsOneWidget);
    expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Sending…'))
            .onPressed,
        isNull);
    pending.completeError(Exception('offline'));
    await tester.pumpAndSettle();
    expect(find.text('I cannot sign in.'), findsOneWidget);
    expect(
        find.text(
            'Your message couldn’t be sent. Check your connection and try again.'),
        findsOneWidget);
    await tester.ensureVisible(find.text('Send message'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Send message'));
    await tester.pumpAndSettle();
    expect(find.text('Your message has been sent'), findsOneWidget);
    expect(calls, 2);
    await tester.ensureVisible(find.text('Send another message'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Send another message'));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField))
            .controller!
            .text,
        isEmpty);
    expect(tester.takeException(), isNull);
  });
}
