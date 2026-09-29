import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfully_evolve_app/common/app_theme.dart';
import 'package:mindfully_evolve_app/common/widgets/daily_pause_preview.dart';
import 'store_assets/capture_test.dart' show AssetHttp;

void main() {
  testWidgets('Pause sheet fits small screens, supports large text and closes',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final oldHttp = HttpOverrides.current;
    final bytes =
        (await rootBundle.load('assets/images/onboarding/calm-light.png'))
            .buffer
            .asUint8List();
    HttpOverrides.global = AssetHttp(bytes);
    addTearDown(() => HttpOverrides.global = oldHttp);
    final key = GlobalKey();
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      for (final scale in [1.0, 2.0]) {
        tester.view.physicalSize = const Size(320, 568);
        await tester.pumpWidget(RepaintBoundary(
            key: key,
            child: MaterialApp(
              theme: theme,
              builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.linear(scale)),
                  child: child!),
              home: Scaffold(
                  body: Builder(
                      builder: (context) => TextButton(
                            onPressed: () => showDailyPausePreview(context,
                                title: 'Return to this moment',
                                thumbnail: 'https://test.local/pause.png'),
                            child: const Text('Open pause'),
                          ))),
            )));
        await tester.tap(find.text('Open pause'));
        await tester.pump();
        await tester.runAsync(() async =>
            Future<void>.delayed(const Duration(milliseconds: 150)));
        await tester.pumpAndSettle();
        expect(find.byType(DailyPausePreview), findsOneWidget);
        expect(find.byIcon(Icons.schedule_rounded), findsNothing);
        final share = find.widgetWithText(FilledButton, 'Share this pause');
        expect(share.hitTestable(), findsOneWidget);
        expect(tester.widget<FilledButton>(share).onPressed, isNotNull);
        expect(tester.takeException(), isNull);
        if (theme == AppTheme.light &&
            scale == 1 &&
            const bool.fromEnvironment('CAPTURE_PAUSE')) {
          await tester.runAsync(() async {
            final boundary = key.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
            final image = await boundary.toImage(pixelRatio: 2);
            final data = await image.toByteData(format: ui.ImageByteFormat.png);
            await File('/tmp/daily-pause-preview.png')
                .writeAsBytes(data!.buffer.asUint8List());
            image.dispose();
          });
        }
        await tester.tap(find.byTooltip('Close preview'));
        await tester.pumpAndSettle();
        expect(find.byType(DailyPausePreview), findsNothing);
      }
    }
  });
}
