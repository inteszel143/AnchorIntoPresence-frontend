import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfully_evolve_app/common/app_theme.dart';
import 'package:mindfully_evolve_app/common/main_screen.dart';
import 'package:mindfully_evolve_app/screens/account/account_screen.dart';
import 'package:mindfully_evolve_app/screens/welcome/illustrated_welcome_screen.dart';
import 'package:mindfully_evolve_app/screens/welcome/legacy_welcome_screen.dart';
import 'package:mindfully_evolve_app/screens/welcome/welcome_screen.dart';
import 'package:mindfully_evolve_app/utils/global.dart' as globals;

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  testWidgets('welcome build flag selects the preserved or illustrated UI',
      (tester) async {
    await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const WelcomeScreen()));
    expect(
        find.byType(WelcomeScreen.useLegacyOnboarding
            ? LegacyWelcomeScreen
            : IllustratedWelcomeScreen),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('next, back, swipe and start complete the welcome journey',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light, home: const IllustratedWelcomeScreen()));
    expect(find.text('Find your calm'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Make room for rest'), findsOneWidget);
    await tester.tap(find.byTooltip('Previous page'));
    await tester.pumpAndSettle();
    expect(find.text('Find your calm'), findsOneWidget);
    await tester.drag(find.byType(PageView), const Offset(-700, 0));
    await tester.pumpAndSettle();
    expect(find.text('Make room for rest'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Feel more connected'), findsOneWidget);
    expect(find.text('Skip'), findsNothing);
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    expect(find.byType(AccountOnboardingScreen), findsOneWidget);
    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await tester.pumpAndSettle();
    expect(find.text('Start'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNotNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('skip opens account onboarding without a token', (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light, home: const IllustratedWelcomeScreen()));
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.byType(AccountOnboardingScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('signed-in users continue to Home and cannot return to welcome',
      (tester) async {
    FlutterSecureStorage.setMockInitialValues({'auth_token': 'test-session'});
    final previous = globals.isSubscribed;
    globals.isSubscribed = false;
    addTearDown(() => globals.isSubscribed = previous);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light, home: const IllustratedWelcomeScreen()));
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.byType(MainScreen), findsOneWidget);
    expect(find.byType(IllustratedWelcomeScreen), findsNothing);
    expect(tester.state<NavigatorState>(find.byType(Navigator).first).canPop(),
        isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('small screens, landscape and large text keep actions reachable',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    for (final size in [const Size(320, 568), const Size(844, 390)]) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.dark,
        home: const MediaQuery(
          data: MediaQueryData(
            textScaler: TextScaler.linear(2),
            padding: EdgeInsets.only(top: 24, bottom: 24),
            disableAnimations: true,
          ),
          child: IllustratedWelcomeScreen(),
        ),
      ));
      for (var page = 0; page < 2; page++) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      expect(find.text('Start').hitTestable(), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('theme selects the mascot and each step selects its expression',
      (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const IllustratedWelcomeScreen(),
    ));
    // Theme selects sunrise/sunset without changing the current step.
    for (final brightness in [Brightness.dark, Brightness.light]) {
      tester.platformDispatcher.platformBrightnessTestValue = brightness;
      await tester.pumpAndSettle();
      expect(find.text('Find your calm'), findsOneWidget);
      expect(
          find.image(AssetImage(
              'assets/images/onboarding/${brightness == Brightness.dark ? 'sunset' : 'sunrise'}.png')),
          findsOneWidget);
    }
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    for (final brightness in [Brightness.dark, Brightness.light]) {
      tester.platformDispatcher.platformBrightnessTestValue = brightness;
      await tester.pumpAndSettle();
      expect(find.text('Make room for rest'), findsOneWidget);
      final background =
          tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor!;
      final foreground =
          tester.widget<Text>(find.text('Make room for rest')).style!.color!;
      final luminances = [
        background.computeLuminance(),
        foreground.computeLuminance()
      ]..sort();
      expect((luminances.last + .05) / (luminances.first + .05),
          greaterThanOrEqualTo(4.5));
      expect(background.computeLuminance(),
          brightness == Brightness.dark ? lessThan(.1) : greaterThan(.8));
      expect(
          find.image(AssetImage(
              'assets/images/onboarding/${brightness == Brightness.dark ? 'sunset' : 'sunrise'}-rest.png')),
          findsOneWidget);
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      final buttonColors = [
        button.style!.backgroundColor!.resolve({})!.computeLuminance(),
        button.style!.foregroundColor!.resolve({})!.computeLuminance(),
      ]..sort();
      expect((buttonColors.last + .05) / (buttonColors.first + .05),
          greaterThanOrEqualTo(4.5));
      final overlay = tester
          .widget<AnnotatedRegion<SystemUiOverlayStyle>>(
            find.byType(AnnotatedRegion<SystemUiOverlayStyle>).first,
          )
          .value;
      expect(overlay.statusBarIconBrightness,
          brightness == Brightness.dark ? Brightness.light : Brightness.dark);
      expect(tester.takeException(), isNull);
    }
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    for (final brightness in [Brightness.dark, Brightness.light]) {
      tester.platformDispatcher.platformBrightnessTestValue = brightness;
      await tester.pumpAndSettle();
      expect(find.text('Feel more connected'), findsOneWidget);
      expect(
          find.image(AssetImage(
              'assets/images/onboarding/${brightness == Brightness.dark ? 'sunset' : 'sunrise'}-connected.png')),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('capture illustrated welcome pages', (tester) async {
    if (!const bool.fromEnvironment('CAPTURE_ONBOARDING')) return;
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    for (final font in [
      ('DM Sans', 'assets/fonts/DMSans/DMSans-Variable.ttf'),
      ('Manrope', 'assets/fonts/Manrope/Manrope-Variable.ttf'),
      ('MaterialIcons', 'fonts/MaterialIcons-Regular.otf'),
    ]) {
      final loader = FontLoader(font.$1)..addFont(rootBundle.load(font.$2));
      await tester.runAsync(loader.load);
    }
    for (final dark in [false, true]) {
      final boundaryKey = GlobalKey();
      await tester.pumpWidget(MaterialApp(
        theme: dark ? AppTheme.dark : AppTheme.light,
        home: RepaintBoundary(
          key: boundaryKey,
          child: const MediaQuery(
            data: MediaQueryData(padding: EdgeInsets.only(top: 44, bottom: 34)),
            child: IllustratedWelcomeScreen(),
          ),
        ),
      ));
      for (final expression in ['', '-rest', '-connected']) {
        final name = '${dark ? 'sunset' : 'sunrise'}$expression';
        await tester.runAsync(() => precacheImage(
            AssetImage('assets/images/onboarding/$name.png'),
            boundaryKey.currentContext!));
      }
      for (var page = 0; page < 3; page++) {
        await tester.pumpAndSettle();
        final boundary = boundaryKey.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 2);
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(
                  'build/onboarding-${dark ? 'dark' : 'light'}-${page + 1}.png')
              .writeAsBytes(data!.buffer.asUint8List());
          image.dispose();
        });
        if (page < 2) await tester.tap(find.text('Next'));
      }
      await tester.pumpWidget(const SizedBox());
    }

    expect(tester.takeException(), isNull);
  });
}
