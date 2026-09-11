import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfully_evolve_app/common/app_theme.dart';
import 'package:mindfully_evolve_app/screens/activity_listing/activity_listing.dart';
import 'package:mindfully_evolve_app/screens/activity_listing/activity_listing_daily.dart';
import 'package:mindfully_evolve_app/screens/activity_listing/getactivity_model.dart';
import 'package:mindfully_evolve_app/screens/activity_listing/getactivity_bloc/getrecent_activities_bloc.dart';
import 'package:mindfully_evolve_app/screens/activity_listing/getactivity_bloc/getrecent_activities_event.dart';
import 'package:mindfully_evolve_app/screens/activity_listing/getactivity_bloc/getrecent_activities_state.dart';

class CollectionFixture extends ActivityBloc {
  CollectionFixture(ActivityState initial) {
    emit(initial);
  }
  final requests = <FetchActivities>[];
  @override
  void add(ActivityEvent event) {
    if (event is FetchActivities) requests.add(event);
  }
}

void main() {
  testWidgets(
      'both collection routes preserve category search, retry and back navigation',
      (tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final pause in [false, true]) {
      final bloc = CollectionFixture(ActivityError('offline'));
      await tester.pumpWidget(MaterialApp(
          theme: AppTheme.dark,
          builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(1.6)),
              child: child!),
          home: BlocProvider<ActivityBloc>.value(
              value: bloc,
              child: pause
                  ? const MeditationListing(categoryId: 'pause')
                  : const MeditationListingDaily(categoryId: 'anchor'))));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Back'), findsOneWidget);
      expect(bloc.requests.single.categoryId, pause ? 'pause' : 'anchor');
      await tester.enterText(find.byType(TextField), 'calm');
      await tester.pump(const Duration(milliseconds: 600));
      expect(bloc.requests.last.search, 'calm');
      tester.testTextInput.hide();
      await tester.pumpAndSettle();
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -900));
      await tester.pumpAndSettle();
      final requestCount = bloc.requests.length;
      await tester.tap(find.text('Try again'));
      expect(bloc.requests.length, requestCount + 1);
      expect(bloc.requests.last.search, 'calm');
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 1200));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Clear search'));
      expect(bloc.requests.last.search, isEmpty);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await tester.runAsync(bloc.close);
    }
  });

  testWidgets(
      'pause card opens an image preview with an explicit close control',
      (tester) async {
    final bloc = CollectionFixture(ActivityLoaded(ActivityResponse(
        message: '',
        status: true,
        recommendedActivities: [],
        activities: [
          Activity(
              id: 'pause',
              name: 'A quiet moment',
              description: '',
              thumbnail: '',
              video: '',
              isFavorite: false,
              tags: [])
        ])));
    await tester.pumpWidget(MaterialApp(
        home: BlocProvider<ActivityBloc>.value(
            value: bloc, child: const MeditationListing(categoryId: 'pause'))));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -450));
    await tester.pumpAndSettle();
    await tester.tap(find.text('A quiet moment'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.byTooltip('Share moment'), findsOneWidget);
    await tester.tap(find.byTooltip('Close preview'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(bloc.close);
  });
}
