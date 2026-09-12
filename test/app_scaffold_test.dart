import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mindfully_evolve_app/common/app_theme.dart';
import 'package:mindfully_evolve_app/common/main_screen.dart';
import 'package:mindfully_evolve_app/common/widgets/app_scaffold.dart';
import 'package:mindfully_evolve_app/screens/dashboard/dashboard_bloc/home_bloc.dart';
import 'package:mindfully_evolve_app/screens/track/track_bloc/track_bloc.dart';
import 'package:mindfully_evolve_app/utils/global.dart' as globals;

import 'profile_screen_test.dart' show LoadedTrackBloc;

void main() {
  testWidgets(
      'each route has a themed background and controls stay interactive',
      (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: Builder(
          builder: (context) => AppScaffold(
                body: Center(
                    child: FilledButton(
                  onPressed: () =>
                      Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (_) => AppScaffold(
                      appBar: AppBar(title: const Text('Details')),
                      body: const Center(child: Text('Another page')),
                    ),
                  )),
                  child: const Text('Open details'),
                )),
              )),
    ));
    await tester.pumpAndSettle();
    expect(
        find.image(const AssetImage('assets/images/app-background-light.png')),
        findsOneWidget);
    await tester.tap(find.text('Open details'));
    await tester.pumpAndSettle();
    expect(find.text('Another page'), findsOneWidget);
    expect(find.byType(AppBackground), findsOneWidget);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    await tester.pumpAndSettle();
    expect(
        find.image(const AssetImage('assets/images/app-background-dark.png')),
        findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Open details'), findsOneWidget);
    expect(
        find.image(const AssetImage('assets/images/app-background-dark.png')),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home, Profile and Settings share the light and dark backgrounds',
      (tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
    final previous = globals.isSubscribed;
    globals.isSubscribed = false;
    addTearDown(() => globals.isSubscribed = previous);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    const capture = bool.fromEnvironment('CAPTURE_APP_BACKGROUND');
    if (capture) {
      for (final font in [
        ('DM Sans', 'assets/fonts/DMSans/DMSans-Variable.ttf'),
        ('Manrope', 'assets/fonts/Manrope/Manrope-Variable.ttf'),
        ('MaterialIcons', 'fonts/MaterialIcons-Regular.otf'),
      ]) {
        final loader = FontLoader(font.$1)..addFont(rootBundle.load(font.$2));
        await tester.runAsync(loader.load);
      }
    }
    for (final dark in [false, true]) {
      final themeName = dark ? 'dark' : 'light';
      final boundaryKey = GlobalKey();
      await tester.pumpWidget(MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => HomePageBloc()),
          BlocProvider<TrackBloc>(create: (_) => LoadedTrackBloc()),
        ],
        child: MaterialApp(
          theme: dark ? AppTheme.dark : AppTheme.light,
          builder: (context, child) => RepaintBoundary(
            key: boundaryKey,
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                padding: const EdgeInsets.only(top: 44, bottom: 34),
              ),
              child: child!,
            ),
          ),
          home: const MainScreen(),
        ),
      ));
      if (capture) {
        await tester.runAsync(() => precacheImage(
              AssetImage('assets/images/app-background-$themeName.png'),
              boundaryKey.currentContext!,
            ));
      }
      for (final page in ['home', 'profile', 'settings']) {
        if (page == 'profile') await tester.tap(find.text('Profile'));
        if (page == 'settings') await tester.tap(find.byTooltip('Settings'));
        await tester.pumpAndSettle();
        expect(find.byType(AppBackground), findsWidgets);
        expect(
            find.image(
                AssetImage('assets/images/app-background-$themeName.png')),
            findsWidgets);
        expect(tester.takeException(), isNull);
        if (capture) {
          final boundary = boundaryKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
          await tester.runAsync(() async {
            final image = await boundary.toImage(pixelRatio: 2);
            final data = await image.toByteData(format: ui.ImageByteFormat.png);
            await File('build/background-$page-$themeName.png')
                .writeAsBytes(data!.buffer.asUint8List());
            image.dispose();
          });
        }
      }
      await tester.pumpWidget(const SizedBox());
    }
  });
}
