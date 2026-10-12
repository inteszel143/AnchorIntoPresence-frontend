import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfully_evolve_app/common/app_theme.dart';
import 'package:mindfully_evolve_app/screens/track/your_week_card.dart';
import 'package:mindfully_evolve_app/screens/totalmedication/total_meditation_model.dart';

TotalMeditationDataResponse response(List<Map<String, dynamic>> week) =>
    TotalMeditationDataResponse.fromJson({
      'status': true,
      'data': {'week': week}
    });

void main() {
  for (final dark in [false, true]) {
    testWidgets('weekly minutes fit narrow screens and large text, dark=$dark',
        (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final semantics = tester.ensureSemantics();

      await tester.pumpWidget(MaterialApp(
        theme: dark ? AppTheme.dark : AppTheme.light,
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Scaffold(
              body: SingleChildScrollView(
                  child: Padding(
            padding: const EdgeInsets.all(20),
            child: YourWeekCard(
                load: () async => response([
                      {'day': 'Wed', 'value': 15},
                      {'day': 'Mon', 'value': 10},
                    ])),
          ))),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('25 minutes this week'), findsNothing);
      expect(
          find.bySemanticsLabel('Mon: 10 minutes of practice'), findsOneWidget);
      expect(
          find.bySemanticsLabel('Tue: 0 minutes of practice'), findsOneWidget);
      semantics.dispose();
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('loading, failed request, retry, and empty week are distinct',
      (tester) async {
    final pending = Completer<TotalMeditationDataResponse>();
    var calls = 0;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: YourWeekCard(
      load: () => ++calls == 1 ? pending.future : Future.value(response([])),
    ))));
    await tester.pump();
    expect(find.text('0 minutes this week'), findsNothing);
    pending.completeError(Exception('offline'));
    await tester.pumpAndSettle();
    expect(find.text('Your week couldn’t load. Please try again.'),
        findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(calls, 2);
    expect(find.text('0 minutes this week'), findsNothing);
    expect(find.text('No practice recorded this week yet.'), findsOneWidget);
  });
}
