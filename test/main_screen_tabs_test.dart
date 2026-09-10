import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mindfully_evolve_app/common/main_screen.dart';
import 'package:mindfully_evolve_app/common/widgets/app_tab_bar.dart';
import 'package:mindfully_evolve_app/screens/dashboard/dashboard_bloc/home_bloc.dart';
import 'package:mindfully_evolve_app/screens/track/track_bloc/track_bloc.dart';
import 'package:mindfully_evolve_app/screens/meditate/meditate_screen.dart';
import 'package:mindfully_evolve_app/screens/profile/profile_screen.dart';
import 'package:mindfully_evolve_app/utils/global.dart' as globals;

void main() {
  testWidgets('fifth tab stays in range and maps to Profile after Meditate',
      (tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    final previous = globals.isSubscribed;
    globals.isSubscribed = true;
    addTearDown(() => globals.isSubscribed = previous);
    await tester.pumpWidget(MultiBlocProvider(providers: [
      BlocProvider(create: (_) => HomePageBloc()),
      BlocProvider(create: (_) => TrackBloc()),
    ], child: const MaterialApp(home: MainScreen(initialIndex: 4))));
    await tester.pump();
    expect(
        tester.widget<IndexedStack>(find.byType(IndexedStack)).children.length,
        5);
    expect(find.byType(ProfileScreen), findsOneWidget);
    await tester.tap(find.text('Meditate'));
    await tester.pump();
    expect(tester.widget<AppTabBar>(find.byType(AppTabBar)).selectedIndex, 1);
    expect(find.byType(MeditateScreen), findsOneWidget);
    await tester.tap(find.text('Profile'));
    await tester.pump();
    expect(tester.widget<IndexedStack>(find.byType(IndexedStack)).index, 4);
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
