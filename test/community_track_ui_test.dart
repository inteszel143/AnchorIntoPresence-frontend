import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfully_evolve_app/common/app_theme.dart';
import 'package:mindfully_evolve_app/screens/community/community_screen.dart';
import 'package:mindfully_evolve_app/screens/community/community_model.dart';
import 'package:mindfully_evolve_app/screens/community/community_bloc/community_state.dart';
import 'package:mindfully_evolve_app/screens/track/track_screen.dart';
import 'package:mindfully_evolve_app/screens/track/track_model.dart';
import 'package:mindfully_evolve_app/screens/track/track_bloc/track_state.dart';

void main() {
  WidgetController.hitTestWarningShouldBeFatal = true;
  for (final dark in [false, true]) {
    testWidgets('Community scrolls safely with large text, dark=$dark',
        (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final posts = List.generate(
          5,
          (i) => Post(
              id: '$i',
              shareId: '',
              userId: 'someone',
              userName: 'A community member with a long name',
              message: 'Taking a little time to slow down today.',
              postType: '',
              images: [],
              postAnonymously: false,
              liked: false,
              likesCount: 2,
              commentsCount: 1,
              sharesCount: 0,
              createdAt: DateTime.now()));
      await tester.pumpWidget(MaterialApp(
          theme: dark ? AppTheme.dark : AppTheme.light,
          builder: (_, child) => MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2)),
              child: child!),
          home: CommunityFeed(state: CommunityLoaded(posts: posts))));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Create post'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();
      expect(find.byType(CommunityFeed), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
    testWidgets('Track supports month navigation and large text, dark=$dark',
        (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final summary = UserActivitySummary.fromJson({
        'message': '',
        'status': true,
        'data': {
          'loggedActivities': {'totalTime': '01:24', 'thumbnails': []},
          'categoryDistribution': {},
          'loginDates': {'streak': []}
        }
      });
      await tester.pumpWidget(MaterialApp(
          theme: dark ? AppTheme.dark : AppTheme.light,
          builder: (_, child) => MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2)),
              child: child!),
          home: TrackOverview(state: TrackLoadedState(summary))));
      await tester.pumpAndSettle();
      expect(find.text('84'), findsOneWidget);
      await tester.scrollUntilVisible(find.byTooltip('Previous month'), 250,
          scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();
      final calendarBefore = tester
          .widgetList<Text>(find.descendant(
              of: find.byType(CalendarGrid), matching: find.byType(Text)))
          .map((t) => t.data)
          .toList();
      await tester.tap(find.byTooltip('Previous month'));
      await tester.pumpAndSettle();
      final calendarAfter = tester
          .widgetList<Text>(find.descendant(
              of: find.byType(CalendarGrid), matching: find.byType(Text)))
          .map((t) => t.data)
          .toList();
      expect(calendarAfter, isNot(equals(calendarBefore)));
      await Scrollable.ensureVisible(
          tester.element(find.byTooltip('Next month')),
          alignment: 0.4);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Next month'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
