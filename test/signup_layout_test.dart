import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfully_evolve_app/common/app_theme.dart';
import 'package:mindfully_evolve_app/screens/signup/signup_screen.dart';

void main() {
  testWidgets('signup fits a phone and scrolls for keyboard and large text',
      (tester) async {
    tester.view.devicePixelRatio = 1;
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
      for (final compactViewport in [false, true]) {
        tester.view.physicalSize =
            compactViewport ? const Size(320, 568) : const Size(375, 812);
        await tester.pumpWidget(MaterialApp(
          theme: (dark ? AppTheme.dark : AppTheme.light)
              .copyWith(platform: TargetPlatform.iOS),
          home: RepaintBoundary(
            key: boundaryKey,
            child: MediaQuery(
              data: MediaQueryData(
                size: tester.view.physicalSize,
                padding: const EdgeInsets.only(top: 44, bottom: 34),
                viewInsets: EdgeInsets.only(bottom: compactViewport ? 250 : 0),
                textScaler: TextScaler.linear(compactViewport ? 2 : 1),
              ),
              child: const SignupScreen(),
            ),
          ),
        ));
        await tester.pumpAndSettle();
        for (final widget in tester.widgetList<Image>(find.byType(Image))) {
          await tester.runAsync(
              () => precacheImage(widget.image, boundaryKey.currentContext!));
        }
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final scroll =
            tester.state<ScrollableState>(find.byType(Scrollable).first);
        if (!compactViewport) {
          expect(scroll.position.maxScrollExtent, 0);
          expect(find.text('Sign in').hitTestable(), findsOneWidget);
          expect(
              find.text('Continue with Apple').hitTestable(), findsOneWidget);
          if (const bool.fromEnvironment('CAPTURE_SIGNUP')) {
            await tester.runAsync(() async {
              final boundary = boundaryKey.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
              final image = await boundary.toImage(pixelRatio: 2);
              final bytes =
                  await image.toByteData(format: ui.ImageByteFormat.png);
              await File('build/signup-${dark ? 'dark' : 'light'}.png')
                  .writeAsBytes(bytes!.buffer.asUint8List());
              image.dispose();
            });
          }
        } else {
          expect(scroll.position.maxScrollExtent, greaterThan(0));
          await tester.ensureVisible(find.text('Sign in'));
          await tester.pumpAndSettle();
          expect(find.text('Sign in').hitTestable(), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
        await tester.pumpWidget(const SizedBox());
      }
    }
  }, variant: TargetPlatformVariant({TargetPlatform.iOS}));
}
