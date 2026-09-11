import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfully_evolve_app/common/app_theme.dart';
import 'package:mindfully_evolve_app/screens/activity_listing/favourite_activities.dart';
import 'package:mindfully_evolve_app/screens/activity_listing/recent_activity.dart';
import 'package:mindfully_evolve_app/screens/activity_listing/activity_list_cache.dart';
import 'package:mindfully_evolve_app/screens/activity_listing/getactivity_model.dart';
import 'package:mindfully_evolve_app/screens/notification/notificaton_screen.dart';
import 'package:mindfully_evolve_app/screens/notification/notification_bloc/notification_state.dart';
import 'package:mindfully_evolve_app/screens/notification/notification_model.dart'
    as model;

void main() {
  testWidgets('collection empty states fit small screens in both themes',
      (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(ActivityListCache.clear);
    ActivityListCache.put(
        jsonEncode([1, 10, '', '', null]),
        ActivityResponse(
            message: '',
            activities: [],
            recommendedActivities: [],
            status: true),
        ActivityListCache.revision);
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      for (final page in [
        const FavouriteActivity(),
        const RecentActivity(recentlyPlayedActivities: []),
        NotificationView(
            state: NotificationLoaded(notifications: []), onRefresh: () {}),
      ]) {
        await tester.pumpWidget(MaterialApp(
            theme: theme,
            builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(2)),
                child: child!),
            home: page));
        await tester.pumpAndSettle();
        expect(find.byTooltip('Back'), findsOneWidget);
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      }
    }
  });

  testWidgets('notification navigation stays visible and error can retry',
      (tester) async {
    var retries = 0;
    for (final state in [
      NotificationLoading(),
      NotificationError(errorMessage: 'offline')
    ]) {
      await tester.pumpWidget(MaterialApp(
          home: NotificationView(state: state, onRefresh: () => retries++)));
      await tester.pump();
      expect(find.byTooltip('Back'), findsOneWidget);
    }
    await tester.tap(find.text('Try again'));
    expect(retries, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('long notification titles wrap at large text sizes',
      (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      builder: (context, child) => MediaQuery(
          data:
              MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(2)),
          child: child!),
      home: NotificationView(
          onRefresh: () {},
          state: NotificationLoaded(notifications: [
            model.Notification(
                id: 'one',
                title: 'A gentle reminder to make room for yourself today',
                description: 'Your next practice is ready whenever you are.',
                createdAt: DateTime.now()),
          ])),
    ));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.text('Just now'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
