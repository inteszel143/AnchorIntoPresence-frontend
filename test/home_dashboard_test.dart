import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfully_evolve_app/common/app_theme.dart';
import 'package:mindfully_evolve_app/screens/dashboard/home_dashboard.dart';
import 'package:mindfully_evolve_app/screens/dashboard/home_model.dart';
import 'package:mindfully_evolve_app/screens/dashboard/dashboard_bloc/home_state.dart';
import 'package:mindfully_evolve_app/screens/dashboard/dashboard_bloc/recently_played_model.dart';

HomePageLoadedState fixture({bool recent = true}) => HomePageLoadedState(
      profileData: ProfileDataModel(
          id: 'test',
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
                      state: fixture(),
                      onProfile: () => action = 'profile',
                      onSearch: () => action = 'search',
                      onMood: () => action = 'mood',
                      onFavorites: () => action = 'favorites',
                      onMeditate: () {},
                      onRecent: () {},
                      onNotifications: () {},
                      onActivity: (item) => action = item.id,
                      onCategory: (_) {},
                      onResume: (_) => action = 'recent')),
            )));
        await tester.pumpAndSettle();
        expect(find.text('Hi,\nLuciana!'), findsOneWidget);
        await tester.tap(find.byTooltip('Search meditations'));
        expect(action, 'search');
        await tester.tap(find.byWidgetPredicate((widget) =>
            widget is Semantics && widget.properties.label == 'Open profile'));
        expect(action, 'profile');
        await tester.ensureVisible(find.text('How are you feeling today?'));
        await tester.tap(find.text('How are you feeling today?'));
        expect(action, 'mood');
        await tester.ensureVisible(find.text('Favorites'));
        await tester.tap(find.text('Favorites'));
        expect(action, 'favorites');
        await tester.scrollUntilVisible(find.text('Finding calm'), 200,
            scrollable: find.byType(Scrollable).first);
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
