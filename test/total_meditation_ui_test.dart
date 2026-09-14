import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfully_evolve_app/common/app_theme.dart';
import 'package:mindfully_evolve_app/common/widgets/activity_calendar.dart';
import 'package:mindfully_evolve_app/screens/totalmedication/total_meditaion.dart';
import 'package:mindfully_evolve_app/screens/totalmedication/total_meditation_model.dart';
import 'package:mindfully_evolve_app/screens/totalmedication/totalmeditation_bloc/total_meditation_state.dart';
import 'package:mindfully_evolve_app/screens/track/track_bloc/track_state.dart';
import 'package:mindfully_evolve_app/screens/track/track_model.dart';

void main() {
  for (final dark in [false, true]) {
    testWidgets('total meditation layout, calendar and recovery dark=$dark',
        (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final track = TrackLoadedState(UserActivitySummary.fromJson({
        'status': true,
        'message': '',
        'data': {
          'loggedActivities': {'totalTime': '01:24', 'thumbnails': []},
          'categoryDistribution': {},
          'loginDates': {'streak': []},
        },
      }));
      var retries = 0;
      Future<void> show(TotalMeditationState state) async {
        await tester.pumpWidget(MaterialApp(
          theme: dark ? AppTheme.dark : AppTheme.light,
          builder: (_, child) => MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2)),
              child: child!),
          home: TotalMeditationOverview(
              meditationState: state,
              trackState: track,
              onRetry: () => retries++),
        ));
        await tester.pump();
      }

      await show(TotalMeditationLoadingState());
      expect(find.byTooltip('Back'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await show(TotalMeditationErrorState('Connection unavailable'));
      await tester.ensureVisible(find.text('Try again'));
      await tester.tap(find.text('Try again'));
      expect(retries, 1);
      for (final empty in [false, true]) {
        await show(
            TotalMeditationLoadedState(TotalMeditationDataResponse.fromJson({
          'status': true,
          'data': {
            'week': empty
                ? []
                : [
                    for (final day in [
                      'Mon',
                      'Tue',
                      'Wed',
                      'Thu',
                      'Fri',
                      'Sat',
                      'Sun'
                    ])
                      {'day': day, 'value': 12},
                  ]
          },
        })));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        if (empty)
          expect(
              find.text('No practice recorded this week yet.'), findsOneWidget);
        await tester.ensureVisible(find.byTooltip('Previous month'));
        await tester.pumpAndSettle();
        final before = tester
            .widgetList<Text>(find.descendant(
                of: find.byType(CalendarGrid), matching: find.byType(Text)))
            .map((t) => t.data)
            .toList();
        await tester.tap(find.byTooltip('Previous month'));
        await tester.pumpAndSettle();
        final after = tester
            .widgetList<Text>(find.descendant(
                of: find.byType(CalendarGrid), matching: find.byType(Text)))
            .map((t) => t.data)
            .toList();
        expect(after, isNot(equals(before)));
        expect(tester.takeException(), isNull);
      }
    });
  }
}
