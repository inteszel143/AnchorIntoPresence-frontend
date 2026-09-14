import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mindfully_evolve_app/common/main_screen.dart';
import 'package:mindfully_evolve_app/common/widgets/app_tab_bar.dart';
import 'package:mindfully_evolve_app/common/widgets/subscription_tab_page.dart';
import 'package:mindfully_evolve_app/screens/dashboard/dashboard_bloc/home_bloc.dart';
import 'package:mindfully_evolve_app/screens/track/track_bloc/track_bloc.dart';
import 'package:mindfully_evolve_app/screens/setting/setting_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mindfully_evolve_app/utils/global.dart' as globals;

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  testWidgets('nonmembers can navigate the three gated tabs without a modal',
      (tester) async {
    final previous = globals.isSubscribed;
    globals.isSubscribed = false;
    addTearDown(() => globals.isSubscribed = previous);
    await tester.pumpWidget(const MaterialApp(home: MainScreen()));

    for (final index in [0, 1, 2, 0]) {
      final tabBar = tester.widget<AppTabBar>(find.byType(AppTabBar));
      tabBar.onTap(index);
      await tester.pump();
      expect(tester.widget<AppTabBar>(find.byType(AppTabBar)).selectedIndex,
          index);
      expect(find.byType(Dialog), findsNothing);
      expect(find.byType(SubscriptionTabPage), findsOneWidget);
      expect(
          tester
              .widget<SubscriptionTabPage>(find.byType(SubscriptionTabPage))
              .tabIndex,
          index);
      expect(find.text('View subscription plans'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets(
      'subscription invitation scrolls on small screens and opens plans',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var openedPlans = false;
    await tester.pumpWidget(MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
        child: Scaffold(
            body: SubscriptionTabPage(
          tabIndex: 2,
          onSubscribe: () => openedPlans = true,
        )),
      ),
    ));
    await tester.ensureVisible(find.byType(FilledButton));
    await tester.tap(find.byType(FilledButton));
    expect(openedPlans, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fourth tab opens Settings without requiring a subscription',
      (tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    final previous = globals.isSubscribed;
    globals.isSubscribed = false;
    addTearDown(() => globals.isSubscribed = previous);
    await tester.pumpWidget(MultiBlocProvider(providers: [
      BlocProvider(create: (_) => HomePageBloc()),
      BlocProvider(create: (_) => TrackBloc()),
    ], child: const MaterialApp(home: MainScreen(initialIndex: 3))));
    await tester.pump();
    expect(
        tester.widget<IndexedStack>(find.byType(IndexedStack)).children.length,
        4);
    expect(find.byType(SettingScreen), findsOneWidget);
    expect(find.byTooltip('Back'), findsNothing);
    expect(find.text('Meditate'), findsNothing);
    await tester.tap(find.text('Community'));
    await tester.pump();
    expect(tester.widget<AppTabBar>(find.byType(AppTabBar)).selectedIndex, 1);
    expect(
        tester
            .widget<SubscriptionTabPage>(find.byType(SubscriptionTabPage))
            .tabIndex,
        1);
    expect(find.text('Feel connected on your journey.'), findsOneWidget);
    await tester.tap(find.descendant(
        of: find.byType(AppTabBar), matching: find.text('Settings')));
    await tester.pump();
    expect(tester.widget<IndexedStack>(find.byType(IndexedStack)).index, 3);
    expect(find.byType(SettingScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
