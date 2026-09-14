import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfully_evolve_app/common/app_theme.dart';
import 'package:mindfully_evolve_app/screens/dashboard/home_dashboard.dart';
import 'package:mindfully_evolve_app/screens/dashboard/home_model.dart';
import 'package:mindfully_evolve_app/screens/dashboard/dashboard_bloc/home_state.dart';
import 'package:mindfully_evolve_app/screens/dashboard/dashboard_bloc/recently_played_model.dart';

HomePageLoadedState fixture({bool recent = true, String? mood}) =>
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
                  isCompleted: false,
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
                      state:
                          fixture(mood: scale == 1 ? 'grounded' : 'connected'),
                      onProfile: () => action = 'profile',
                      onSearch: () => action = 'search',
                      onFavorites: () => action = 'favorites',
                      onMeditate: () {},
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
        for (final tooltip in ['Search meditations', 'Notifications']) {
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
        await tester.tap(find.byTooltip('Search meditations'));
        expect(action, 'search');
        expect(find.widgetWithText(ActionChip, 'Notifications'), findsNothing);
        await tester.tap(find.byTooltip('Notifications'));
        expect(action, 'notifications');
        await tester.tap(find.byWidgetPredicate((widget) =>
            widget is Semantics && widget.properties.label == 'Open profile'));
        expect(action, 'profile');
        await tester.ensureVisible(find.text('Favorites'));
        await tester.tap(find.text('Favorites'));
        expect(action, 'favorites');
        await tester.scrollUntilVisible(find.text('Finding calm'), 200,
            scrollable: find.byType(Scrollable).first);
        await Scrollable.ensureVisible(
            tester.element(find.text('Finding calm')),
            alignment: 0.5);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Finding calm'));
        expect(action, 'recent');
        await tester.drag(find.byType(ListView).first, const Offset(0, -500));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      }
    }
  });
}
