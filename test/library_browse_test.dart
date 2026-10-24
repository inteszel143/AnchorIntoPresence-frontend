import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfully_evolve_app/common/app_theme.dart';
import 'package:mindfully_evolve_app/common/widgets/app_tab_bar.dart';
import 'package:mindfully_evolve_app/screens/meditate/meditate_screen.dart';
import 'package:mindfully_evolve_app/screens/meditate/library_practice_card.dart';
import 'package:mindfully_evolve_app/screens/activity_listing/getactivity_model.dart';
import 'package:mindfully_evolve_app/screens/activity_listing/getactivity_bloc/getrecent_activities_bloc.dart';
import 'package:mindfully_evolve_app/screens/activity_listing/getactivity_bloc/getrecent_activities_state.dart';
import 'package:mindfully_evolve_app/helping_widgets/activityitem_tile.dart';
import 'store_assets/capture_test.dart' show AssetHttp;

class BrowseFixture extends ActivityBloc {
  BrowseFixture() {
    emit(ActivityLoaded(ActivityResponse(
        message: '',
        status: true,
        recommendedActivities: [],
        activities: [
          for (var i = 0; i < 6; i++)
            Activity(
              id: '$i',
              name: [
                'Return to stillness',
                'A moment to breathe',
                'Begin again',
                'You are right where you need to be',
                'Make space for yourself',
                'Small moments matter'
              ][i],
              description: 'Find a quiet moment in your day.',
              thumbnail: 'https://fixture.local/artwork-$i.png',
              video: '',
              isFavorite: false,
              tags: ['Calm'],
              categoryName: i < 3 ? 'Daily Anchor' : 'Daily Pause',
            ),
        ])));
  }
}

void main() {
  testWidgets('browse rows scroll, View all filters, and search can be opened',
      (tester) async {
    for (final font in [
      ('DM Sans', 'assets/fonts/DMSans/DMSans-Variable.ttf'),
      ('Manrope', 'assets/fonts/Manrope/Manrope-Variable.ttf'),
      ('MaterialIcons', 'fonts/MaterialIcons-Regular.otf'),
    ]) {
      await tester.runAsync(
          (FontLoader(font.$1)..addFont(rootBundle.load(font.$2))).load);
    }
    final oldHttp = HttpOverrides.current;
    final bytes =
        (await rootBundle.load('assets/images/onboarding/calm-light.png'))
            .buffer
            .asUint8List();
    HttpOverrides.global = AssetHttp(bytes);
    addTearDown(() => HttpOverrides.global = oldHttp);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      for (final scale in [1.0, 2.0]) {
        tester.view.physicalSize =
            Size(scale == 1 ? 414 : 320, scale == 1 ? 896 : 568);
        final capture = GlobalKey();
        await tester.pumpWidget(RepaintBoundary(
            key: capture,
            child: MaterialApp(
              theme: theme,
              debugShowCheckedModeBanner: false,
              builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.linear(scale)),
                  child: child!),
              home: Scaffold(
                body: BlocProvider<ActivityBloc>(
                    create: (_) => BrowseFixture(),
                    child: const MeditationLibrary()),
                bottomNavigationBar: AppTabBar(selectedIndex: 1, onTap: (_) {}),
              ),
            )));
        await tester.runAsync(() async =>
            Future<void>.delayed(const Duration(milliseconds: 150)));
        await tester.pumpAndSettle();
        expect(find.byType(LibraryPracticeCard), findsWidgets);
        expect(find.byType(TextField), findsNothing);
        expect(tester.takeException(), isNull);
        if (scale == 1 && const bool.fromEnvironment('CAPTURE_LIBRARY')) {
          await tester.runAsync(() async {
            final boundary = capture.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
            final image = await boundary.toImage(pixelRatio: 2);
            final png = await image.toByteData(format: ui.ImageByteFormat.png);
            await File('/tmp/library-${theme.brightness.name}.png')
                .writeAsBytes(png!.buffer.asUint8List());
            image.dispose();
          });
        }
        await Scrollable.ensureVisible(
            tester.element(
                find.byKey(const PageStorageKey('library-Daily Anchors'))),
            alignment: .2);
        await tester.pumpAndSettle();
        await tester.drag(
            find.byKey(const PageStorageKey('library-Daily Anchors')),
            const Offset(-220, 0));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await Scrollable.ensureVisible(
            tester.element(find.text('View all').first),
            alignment: .2);
        await tester.pumpAndSettle();
        await tester.tap(find.text('View all').first);
        await tester.pumpAndSettle();
        expect(find.byType(LibraryPracticeCard), findsNothing);
        expect(find.byType(ActivityItemTile), findsWidgets);
        expect(
            tester
                .widget<ChoiceChip>(
                    find.widgetWithText(ChoiceChip, 'Daily Anchors'))
                .selected,
            isTrue);
        await tester.tap(find.byTooltip('Search Library'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'no match');
        await tester.pumpAndSettle();
        expect(find.text('No practices match your search.'), findsOneWidget);
        await tester.tap(find.byTooltip('Close search'));
        await tester.pumpAndSettle();
        expect(find.byType(TextField), findsNothing);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      }
    }
  });
}
