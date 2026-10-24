import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mindfully_evolve_app/common/app_theme.dart';
import 'package:mindfully_evolve_app/helping_widgets/user_provider/user_provider.dart';
import 'package:mindfully_evolve_app/screens/profile/my_profile_preview.dart';
import 'package:mindfully_evolve_app/screens/setting/setting_screen.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('Settings opens the profile preview and back returns to Settings',
      (tester) async {
    final user = UserProvider()..setUser('Anchor Account', '');
    await tester.pumpWidget(ChangeNotifierProvider.value(
        value: user,
        child: MaterialApp(
            theme: AppTheme.light, home: SettingScreen(isTab: true))));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('View my profile'));
    await tester.tap(find.text('View my profile'));
    await tester.pumpAndSettle();
    expect(find.byType(MyProfilePreview), findsOneWidget);
    expect(find.text('Anchor Account'), findsOneWidget);
    expect(find.text('Coming soon'), findsNWidgets(4));
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(MyProfilePreview), findsNothing);
    expect(find.text('View my profile'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'all upcoming features fit small screens and large text in both themes',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      await tester.pumpWidget(MaterialApp(
          theme: theme,
          builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(2)),
              child: child!),
          home: const MyProfilePreview()));
      await tester.pumpAndSettle();
      expect(find.text('Your mindful journey'), findsOneWidget);
      for (final title in ['Personal stats', 'Streak', 'Skills', 'Badges']) {
        await tester.ensureVisible(find.text(title));
        await tester.pumpAndSettle();
        expect(find.text(title).hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
      expect(find.text('Coming soon'), findsNWidgets(4));
    }
  });
  testWidgets(
      'profile shows paired placeholder stats without invented progress',
      (tester) async {
    tester.view.physicalSize = const Size(414, 896);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final font in [
      ('DM Sans', 'assets/fonts/DMSans/DMSans-Variable.ttf'),
      ('Manrope', 'assets/fonts/Manrope/Manrope-Variable.ttf'),
      ('MaterialIcons', 'fonts/MaterialIcons-Regular.otf'),
    ]) {
      await tester.runAsync(
          (FontLoader(font.$1)..addFont(rootBundle.load(font.$2))).load);
    }
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      final key = GlobalKey();
      await tester.pumpWidget(RepaintBoundary(
          key: key,
          child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: theme,
              home: const MyProfilePreview())));
      await tester.pumpAndSettle();
      for (final label in [
        'Total minutes',
        'Active days',
        'Current streak',
        'Longest streak'
      ]) {
        expect(find.text(label), findsOneWidget);
      }
      expect(find.text('—'), findsNWidgets(4));
      expect(tester.getTopLeft(find.text('Total minutes')).dy,
          tester.getTopLeft(find.text('Active days')).dy);
      expect(tester.takeException(), isNull);
      if (const bool.fromEnvironment('CAPTURE_PROFILE')) {
        await tester.runAsync(() async {
          final boundary =
              key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 2);
          final png = await image.toByteData(format: ui.ImageByteFormat.png);
          await File('/tmp/my-profile-${theme.brightness.name}.png')
              .writeAsBytes(png!.buffer.asUint8List());
          image.dispose();
        });
      }
    }
  });
}
