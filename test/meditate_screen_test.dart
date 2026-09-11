import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfully_evolve_app/common/app_theme.dart';
import 'package:mindfully_evolve_app/helping_widgets/activityitem_tile.dart';
import 'package:mindfully_evolve_app/screens/meditate/meditate_screen.dart';
import 'package:mindfully_evolve_app/screens/activity_listing/getactivity_model.dart';
import 'package:mindfully_evolve_app/screens/activity_listing/getactivity_bloc/getrecent_activities_bloc.dart';
import 'package:mindfully_evolve_app/screens/activity_listing/getactivity_bloc/getrecent_activities_state.dart';
import 'package:mindfully_evolve_app/screens/activity_listing/getactivity_bloc/getrecent_activities_event.dart';

class LibraryFixtureBloc extends ActivityBloc {
  LibraryFixtureBloc() {
    emit(ActivityLoaded(ActivityResponse(
        message: '',
        status: true,
        recommendedActivities: [],
        activities: [
          Activity(
              id: 'one',
              name: 'Morning pause',
              description: 'A gentle start',
              thumbnail: '',
              video: '',
              isFavorite: true,
              tags: ['Calm']),
          Activity(
              id: 'two',
              name: 'Evening rest',
              description: 'Wind down',
              thumbnail: '',
              video: '',
              isFavorite: false,
              tags: ['Sleep']),
        ])));
  }
}

class FavoriteToastFixtureBloc extends LibraryFixtureBloc {
  late final ActivityLoaded loaded = state as ActivityLoaded;

  @override
  void add(ActivityEvent event) {
    if (event is ToggleFavorite) {
      final item = loaded.activities.activities
          .firstWhere((item) => item.id == event.activityId);
      emit(ActivityFavouriteLoaded(
          item.isFavorite ? 'Removed from favorite' : 'Added to favorite'));
    } else if (event is FetchActivities) {
      emit(loaded);
    }
  }
}

void main() {
  testWidgets('heart action shows a floating confirmation that dismisses',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: BlocProvider<ActivityBloc>(
          create: (_) => FavoriteToastFixtureBloc(),
          child: const MeditationLibrary()),
    ));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byTooltip('Remove from favorites').first);
    await tester.tap(find.byTooltip('Remove from favorites').first);
    await tester.pumpAndSettle();
    expect(find.text('Removed from Favorites.'), findsOneWidget);
    expect(tester.widget<SnackBar>(find.byType(SnackBar)).behavior,
        SnackBarBehavior.floating);
    expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsNothing);
    await tester.scrollUntilVisible(find.byTooltip('Save meditation'), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.byTooltip('Save meditation'));
    await tester.pumpAndSettle();
    expect(find.text('Added to Favorites.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'library searches existing content and combines favorites and tag filters',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: BlocProvider<ActivityBloc>(
          create: (_) => LibraryFixtureBloc(),
          child: const MeditationLibrary()),
    ));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Evening');
    await tester.pumpAndSettle();
    expect(
        tester.widget<ActivityItemTile>(find.byType(ActivityItemTile)).heading,
        'Evening rest');
    await tester.ensureVisible(find.text('Favorites'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();
    expect(
        find.text('No saved practices match your selection.'), findsOneWidget);
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();
    expect(
        tester.widget<ActivityItemTile>(find.byType(ActivityItemTile)).heading,
        'Morning pause');
    await tester.ensureVisible(find.widgetWithText(FilterChip, 'Sleep'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'Sleep'));
    await tester.pumpAndSettle();
    expect(find.byType(ActivityItemTile), findsNothing);
    await tester.ensureVisible(find.text('All practices'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('All practices'));
    await tester.pumpAndSettle();
    expect(
        tester.widget<ActivityItemTile>(find.byType(ActivityItemTile)).heading,
        'Evening rest');
    expect(tester.takeException(), isNull);
  });

  test(
      'active and inactive tab colors are readable against both page backgrounds',
      () {
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      for (final color in [
        theme.colorScheme.primary,
        theme.colorScheme.onSurfaceVariant
      ]) {
        final a = color.computeLuminance();
        final b = theme.scaffoldBackgroundColor.computeLuminance();
        final contrast = ((a > b ? a : b) + .05) / ((a < b ? a : b) + .05);
        expect(contrast, greaterThanOrEqualTo(4.5));
      }
    }
  });
}
