import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfully_evolve_app/common/app_theme.dart';
import 'package:mindfully_evolve_app/common/widgets/app_tab_bar.dart';

void main() {
  testWidgets('Community stays on one line with large text on narrow phones',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    for (final width in [320.0, 360.0, 390.0]) {
      tester.view.physicalSize = Size(width, 800);
      for (final scale in [1.0, 1.5, 2.0, 3.0]) {
        var tapped = -1;
        await tester.pumpWidget(MaterialApp(
            theme: AppTheme.light,
            home: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
              child: Scaffold(
                  bottomNavigationBar: AppTabBar(
                      selectedIndex: 2, onTap: (index) => tapped = index)),
            )));
        await tester.pumpAndSettle();
        final label =
            tester.renderObject<RenderParagraph>(find.text('Community'));
        final boxes = label.getBoxesForSelection(
            const TextSelection(baseOffset: 0, extentOffset: 9));
        expect(boxes.map((box) => box.top).toSet().length, 1);
        expect(label.didExceedMaxLines, isFalse);
        final tab = find.ancestor(
            of: find.text('Community'), matching: find.byType(InkWell));
        expect(tester.getSize(tab).height, greaterThanOrEqualTo(48));
        await tester.tap(find.text('Community'));
        expect(tapped, 2);
        expect(tester.takeException(), isNull);
      }
    }
  });

  testWidgets('tabs select their existing destinations and fit small screens',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      tester.view.physicalSize = const Size(320, 800);
      var selected = 0;
      await tester.pumpWidget(MaterialApp(
          theme: theme,
          home: StatefulBuilder(
            builder: (context, setState) => Scaffold(
                bottomNavigationBar: AppTabBar(
              selectedIndex: selected,
              onTap: (index) => setState(() => selected = index),
            )),
          )));
      expect(find.text('Meditate'), findsNothing);
      for (final (index, label)
          in ['Home', 'Library', 'Community', 'Track', 'Settings'].indexed) {
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
        expect(selected, index);
        expect(tester.widget<AppTabBar>(find.byType(AppTabBar)).selectedIndex,
            index);
        expect(tester.takeException(), isNull);
      }
    }
  });

  testWidgets(
      'large labels and bottom safe area fit; capture reference preview',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final key = GlobalKey();
    if (const bool.fromEnvironment('CAPTURE_TAB_BAR')) {
      final loader = FontLoader('DM Sans')
        ..addFont(rootBundle.load('assets/fonts/DMSans/DMSans-Variable.ttf'));
      await tester.runAsync(loader.load);
      final icons = FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await tester.runAsync(icons.load);
    }
    for (final scale in [2.0, 1.0]) {
      await tester.pumpWidget(MaterialApp(
          theme: AppTheme.light,
          home: MediaQuery(
            data: MediaQueryData(
                padding: const EdgeInsets.only(bottom: 34),
                textScaler: TextScaler.linear(scale)),
            child: Scaffold(
                bottomNavigationBar: RepaintBoundary(
                    key: key,
                    child: AppTabBar(selectedIndex: 4, onTap: (_) {}))),
          )));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    if (const bool.fromEnvironment('CAPTURE_TAB_BAR')) {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 2);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        await File('/tmp/app-tab-bar.png')
            .writeAsBytes(data!.buffer.asUint8List());
        image.dispose();
      });
    }
  });
}
