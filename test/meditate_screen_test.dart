import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfully_evolve_app/common/app_theme.dart';
import 'package:mindfully_evolve_app/helping_widgets/activityitem_tile.dart';
import 'package:mindfully_evolve_app/screens/meditate/meditate_screen.dart';
import 'package:mindfully_evolve_app/screens/activity_listing/getactivity_model.dart';
import 'package:mindfully_evolve_app/screens/activity_listing/getactivity_bloc/getrecent_activities_bloc.dart';
import 'package:mindfully_evolve_app/screens/activity_listing/getactivity_bloc/getrecent_activities_state.dart';

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

void main() {
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
    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();
    expect(
        find.text('No saved practices match your selection.'), findsOneWidget);
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();
    expect(
        tester.widget<ActivityItemTile>(find.byType(ActivityItemTile)).heading,
        'Morning pause');
    await tester.tap(find.widgetWithText(FilterChip, 'Sleep'));
    await tester.pumpAndSettle();
    expect(find.byType(ActivityItemTile), findsNothing);
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
