// Frame supplied, unmodified device captures with the established native layout.
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfully_evolve_app/common/app_theme.dart';
import 'capture_test.dart' as layout;

const root = '../output/app-store-handheld';
const shots = [
  ('01-daily-practice', 'Your daily ritual for grounding,\nmeditation, and presence.', 'Your daily anchor, your moment to pause.'),
  ('02-guided-meditations', 'Make room\nfor yourself.', 'Explore guided meditations in your Library.'),
  ('03-daily-pauses', 'Space to pause.\nRoom to reflect.', 'Words of encouragement and presence.'),
  ('04-daily-anchor', 'Find your\ndaily anchor.', 'Take a moment to ground yourself.'),
  ('05-track', 'Small moments.\nA growing practice.', 'Honor the time you give yourself.'),
  ('06-settings', 'Make space\nfor your practice.', 'Your favorites, reminders, and preferences.'),
];

void main() {
  testWidgets('export handheld posters from supplied iPhone captures', (tester) async {
    if (!const bool.fromEnvironment('CAPTURE_STORE')) return;
    layout.handArtwork = File('$root/assets/hand-phone.png').readAsBytesSync();
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    for (final font in [
      ('DM Sans', 'assets/fonts/DMSans/DMSans-Variable.ttf'),
      ('Manrope', 'assets/fonts/Manrope/Manrope-Variable.ttf'),
    ]) {
      await tester.runAsync((FontLoader(font.$1)..addFont(rootBundle.load(font.$2))).load);
    }
    final posters = <Uint8List>[];
    for (var i = 0; i < shots.length; i++) {
      final shot = shots[i];
      final raw = File('$root/raw/${shot.$1}.png').readAsBytesSync();
      tester.view.physicalSize = const Size(440, 956);
      final key = GlobalKey();
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: RepaintBoundary(key: key, child: DefaultTextStyle(
          style: const TextStyle(fontFamily: 'DM Sans', decoration: TextDecoration.none),
          child: layout.handheldPoster(i, raw, headline: shot.$2, supportingCopy: shot.$3),
        )),
      ));
      await tester.runAsync(() async {
        await precacheImage(MemoryImage(raw), key.currentContext!);
        await precacheImage(MemoryImage(layout.handArtwork), key.currentContext!);
      });
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      posters.add(await layout.save(tester, key, '$root/screenshots/${shot.$1}.png', 3));
      await tester.pumpWidget(const SizedBox());
    }
    tester.view.physicalSize = const Size(1320, 1912);
    final key = GlobalKey();
    await tester.pumpWidget(MaterialApp(home: RepaintBoundary(key: key,
      child: ColoredBox(color: layout.cream, child: GridView.count(
        crossAxisCount: 3, childAspectRatio: 440 / 956,
        children: [for (final bytes in posters) Image.memory(bytes)],
      )),
    )));
    await tester.runAsync(() async {
      for (final bytes in posters) {
        await precacheImage(MemoryImage(bytes), key.currentContext!);
      }
    });
    await tester.pumpAndSettle();
    await layout.save(tester, key, '$root/contact-sheet.png', 1);
    expect(tester.takeException(), isNull);
  });
}
