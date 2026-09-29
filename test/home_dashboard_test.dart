import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfully_evolve_app/common/app_theme.dart';
import 'package:mindfully_evolve_app/screens/dashboard/home_dashboard.dart';
import 'package:mindfully_evolve_app/screens/dashboard/home_model.dart';
import 'package:mindfully_evolve_app/screens/dashboard/dashboard_bloc/home_state.dart';
import 'package:mindfully_evolve_app/screens/dashboard/dashboard_bloc/recently_played_model.dart';

HomePageLoadedState fixture(
        {bool recent = true, bool completed = false, String? mood}) =>
    HomePageLoadedState(
      profileData: ProfileDataModel(
          id: 'test',
          userMood: mood,
          name: 'Luciana Test',
          email: 'test@example.com',
          isVerified: true,
          isBlocked: false,
          createdAt: DateTime(2025),
          updatedAt: DateTime(2025),
          resetPassword: false),
      homePageData: HomePageDataModel(message: '', status: true, data: {
        'Daily Anchor': CategoryData(activities: [
          ActivityData(
              id: 'anchor',
              categoryId: 'anchors',
              name: 'A gentle beginning',
              thumbnail: '',
              description: 'Take a quiet moment',
              categoryName: 'Daily Anchor',
              video: '/practice.mp4',
              isFavorite: false)
        ]),
        'Daily Pause': CategoryData(activities: [
          ActivityData(
              id: 'pause',
              categoryId: 'pauses',
              name: 'Return to this moment',
              thumbnail: '',
              description: '',
              categoryName: 'Daily Pause',
              isFavorite: false)
        ]),
      }),
      recentlyPlayedData: recent
          ? [
              RecentlyPlayedActivity(
                  id: 'recent',
                  videoTimestamp: '02:10',
                  totalVideoTime: '10:00',
                  isCompleted: completed,
                  name: 'Finding calm',
                  thumbnail: '',
                  video: '/practice.mp4',
                  description: '',
                  duration: '',
                  tags: [],
                  isFavorite: false)
            ]
          : [],
    );

void main() {
  testWidgets('five recent activities scroll and resume the selected item',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 1800);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final state = fixture();
    for (var index = 2; index <= 5; index++) {
      state.recentlyPlayedData.add(RecentlyPlayedActivity(
        id: 'recent-$index',
        videoTimestamp: '01:00',
        totalVideoTime: '10:00',
        isCompleted: false,
        name: 'Recent practice $index',
        thumbnail: '',
        video: '/practice-$index.mp4',
        description: '',
        duration: '',
        tags: [],
        isFavorite: false,
      ));
    }
    String? resumed;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
          body: HomeDashboard(
        state: state,
        onProfile: () {},
        onSearch: () {},
        onRecent: () {},
        onNotifications: () {},
        onActivity: (_) {},
        onCategory: (_) {},
        onResume: (item) => resumed = item.id,
      )),
    ));
    await tester.pumpAndSettle();
    final rail = find
        .byWidgetPredicate((widget) =>
            widget is ListView && widget.scrollDirection == Axis.horizontal)
        .last;
    final scrollable =
        find.descendant(of: rail, matching: find.byType(Scrollable)).first;
    await tester.scrollUntilVisible(find.text('Recent practice 5'), 180,
        scrollable: scrollable);
    await Scrollable.ensureVisible(
        tester.element(find.text('Recent practice 5')),
        alignment: 0.5);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Recent practice 5'));
    expect(resumed, 'recent-5');
    expect(tester.takeException(), isNull);
  });
  testWidgets('continue follows pause and See all opens recent history',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 1800);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var openedRecent = false;
    String? openedActivity;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
          body: HomeDashboard(
        state: fixture(),
        onProfile: () {},
        onSearch: () {},
        onRecent: () => openedRecent = true,
        onNotifications: () {},
        onActivity: (item) => openedActivity = item.id,
        onCategory: (_) {},
        onResume: (_) {},
      )),
    ));
    await tester.pumpAndSettle();
    final ritual = find.byKey(const ValueKey('daily-ritual'));
    expect(find.descendant(of: ritual, matching: find.text('Daily Anchor')),
        findsOneWidget);
    expect(find.descendant(of: ritual, matching: find.text('Daily Pause')),
        findsOneWidget);
    expect(
        find.descendant(of: ritual, matching: find.text('Continue Listening')),
        findsNothing);
    await tester.tap(find.text('A gentle beginning'));
    expect(openedActivity, 'anchor');
    await tester.tap(find.text('Return to this moment'));
    expect(openedActivity, 'pause');
    final anchorY = tester.getTopLeft(find.text('Daily Anchor').first).dy;
    final pauseY = tester.getTopLeft(find.text('Daily Pause').first).dy;
    final continueY = tester.getTopLeft(find.text('Continue Listening')).dy;
    expect(tester.getTopLeft(find.text('Your Practice Today')).dy,
        lessThan(anchorY));
    expect(find.text('The guided meditation for today'), findsOneWidget);
    expect(find.text('An inspiration to carry with you today'), findsOneWidget);
    expect(anchorY, lessThan(pauseY));
    expect(pauseY, lessThan(continueY));
    final heading = find
        .ancestor(
            of: find.text('Continue Listening'), matching: find.byType(Row))
        .first;
    await tester
        .tap(find.descendant(of: heading, matching: find.text('See all')));
    expect(openedRecent, isTrue);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'reference layout fits light/dark and large text; callbacks stay connected',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var action = '';
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      for (final scale in [1.0, 2.0]) {
        tester.view.physicalSize = const Size(320, 900);
        await tester.pumpWidget(MaterialApp(
            theme: theme,
            home: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
              child: Scaffold(
                  body: HomeDashboard(
                      state: fixture(
                          completed: scale == 2,
                          mood: scale == 1 ? 'grounded' : 'connected'),
                      onProfile: () => action = 'profile',
                      onSearch: () => action = 'search',
                      onRecent: () {},
                      onNotifications: () => action = 'notifications',
                      onActivity: (item) => action = item.id,
                      onCategory: (_) {},
                      onResume: (_) => action = 'recent')),
            )));
        await tester.pumpAndSettle();
        expect(find.text('Hi,\nLuciana!'), findsOneWidget);
        expect(find.text('How are you feeling today?'), findsNothing);
        expect(
            find.byIcon(Icons.sentiment_satisfied_alt_rounded), findsNothing);
        for (final tooltip in ['Search Library', 'Notifications']) {
          final buttonFinder = find.byWidgetPredicate(
              (widget) => widget is IconButton && widget.tooltip == tooltip);
          final button = tester.widget<IconButton>(buttonFinder);
          final iconContext = tester.element(
              find.descendant(of: buttonFinder, matching: find.byType(Icon)));
          final foreground = IconTheme.of(iconContext).color!;
          final background = button.style!.backgroundColor!.resolve({})!;
          final luminances = [
            foreground.computeLuminance(),
            background.computeLuminance()
          ]..sort();
          expect((luminances.last + .05) / (luminances.first + .05),
              greaterThanOrEqualTo(4.5));
        }
        await tester.tap(find.byTooltip('Search Library'));
        expect(action, 'search');
        expect(find.widgetWithText(ActionChip, 'Notifications'), findsNothing);
        await tester.tap(find.byTooltip('Notifications'));
        expect(action, 'notifications');
        await tester.tap(find.byWidgetPredicate((widget) =>
            widget is Semantics && widget.properties.label == 'Open profile'));
        expect(action, 'profile');
        expect(find.byType(ActionChip), findsNothing);
        expect(find.text('Favorites'), findsNothing);
        expect(find.text('Meditate'), findsNothing);
        expect(find.text('Recently played'), findsNothing);
        expect(find.text('Explore Meditations'), findsNothing);
        await tester.scrollUntilVisible(find.text('Finding calm'), 200,
            scrollable: find.byType(Scrollable).first);
        await Scrollable.ensureVisible(
            tester.element(find.text('Finding calm')),
            alignment: 0.5);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Finding calm'));
        expect(action, 'recent');
        expect(
            find.text(scale == 2
                ? 'Completed · Practice again'
                : 'Last played 02:10'),
            findsOneWidget);
        await tester.drag(find.byType(ListView).first, const Offset(0, -500));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      }
    }
  });
}
