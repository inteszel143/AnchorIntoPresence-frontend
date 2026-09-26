import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfully_evolve_app/common/app_theme.dart';
import 'package:mindfully_evolve_app/common/deleteconfirmation_dialog.dart';
import 'package:mindfully_evolve_app/common/logoutconfirmation_dialog.dart';

void main() {
  for (final dark in [false, true]) {
    for (final delete in [false, true]) {
      testWidgets('confirmation fits large text and both themes: $dark/$delete',
          (tester) async {
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        if (const bool.fromEnvironment('CAPTURE_SHEETS')) {
          final icons = FontLoader('MaterialIcons')
            ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
          final body = FontLoader('DM Sans')
            ..addFont(
                rootBundle.load('assets/fonts/DMSans/DMSans-Variable.ttf'));
          final heading = FontLoader('Manrope')
            ..addFont(
                rootBundle.load('assets/fonts/Manrope/Manrope-Variable.ttf'));
          await tester.runAsync(() async {
            await icons.load();
            await body.load();
            await heading.load();
          });
        }
        for (final scale in [1.0, 2.0]) {
          tester.view.physicalSize =
              scale == 1 ? const Size(414, 896) : const Size(320, 640);
          final key = GlobalKey();
          await tester.pumpWidget(RepaintBoundary(
              key: key,
              child: MaterialApp(
                theme: dark ? AppTheme.dark : AppTheme.light,
                builder: (_, child) => MediaQuery(
                    data: MediaQueryData(textScaler: TextScaler.linear(scale)),
                    child: child!),
                home: Scaffold(
                    body: Builder(
                        builder: (context) => Center(
                                child: TextButton(
                              onPressed: () => delete
                                  ? showDeleteConfirmationDialog(context)
                                  : showLogoutConfirmationDialog(context),
                              child: const Text('Open confirmation'),
                            )))),
              )));
          await tester.tap(find.text('Open confirmation'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          if (scale == 1) {
            expect(tester.getCenter(find.text('Cancel')).dy,
                tester.getCenter(find.text(delete ? 'Delete' : 'Logout')).dy);
            if (const bool.fromEnvironment('CAPTURE_SHEETS')) {
              final boundary = key.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
              await tester.runAsync(() async {
                final image = await boundary.toImage(pixelRatio: 2);
                final bytes =
                    await image.toByteData(format: ui.ImageByteFormat.png);
                final file = File(
                    'build/modal-previews/${delete ? 'delete' : 'logout'}-${dark ? 'dark' : 'light'}.png');
                await file.parent.create(recursive: true);
                await file.writeAsBytes(bytes!.buffer.asUint8List());
                image.dispose();
              });
            }
          }
          await tester.ensureVisible(find.text('Cancel'));
          await tester.tap(find.text('Cancel'));
          await tester.pumpAndSettle();
          expect(find.byType(BottomSheet), findsNothing);
          await tester.pumpWidget(const SizedBox());
        }
      });
    }
  }
}
