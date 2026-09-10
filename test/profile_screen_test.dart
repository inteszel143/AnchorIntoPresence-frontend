import 'package:mindfully_evolve_app/screens/user_profile/userprofile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mindfully_evolve_app/common/app_theme.dart';
import 'package:mindfully_evolve_app/screens/dashboard/dashboard_bloc/home_bloc.dart';
import 'package:mindfully_evolve_app/screens/profile/profile_screen.dart';
import 'package:mindfully_evolve_app/screens/setting/setting_screen.dart';
import 'package:mindfully_evolve_app/screens/track/track_bloc/track_bloc.dart';
import 'package:mindfully_evolve_app/screens/track/track_bloc/track_state.dart';
import 'package:mindfully_evolve_app/screens/track/track_model.dart';

class LoadedTrackBloc extends TrackBloc {
  LoadedTrackBloc() {
    emit(TrackLoadedState(UserActivitySummary.fromJson({
      'message': '',
      'status': true,
      'data': {
        'loggedActivities': {'totalTime': '13:24', 'thumbnails': []},
        'categoryDistribution': {},
        'loginDates': {
          'streak': [
            {
              'loginDates': [
                '2026-01-01',
                '2026-01-02',
                '2026-01-02',
                '2026-01-04'
              ]
            }
          ]
        },
      },
    })));
  }
}

void main() {
  testWidgets('profile fits both themes and settings returns to profile',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;
    for (final dark in [false, true]) {
      tester.view.physicalSize = const Size(320, 900);
      await tester.pumpWidget(MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => HomePageBloc()),
          BlocProvider<TrackBloc>(create: (_) => LoadedTrackBloc()),
        ],
        child: MaterialApp(
            theme: dark ? AppTheme.dark : AppTheme.light,
            home: const ProfileScreen()),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('804'), findsOneWidget);
      expect(find.text('Your profile'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Open profile'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(UserprofileScreen), findsOneWidget);
      tester.state<NavigatorState>(find.byType(Navigator).first).pop();
      await tester.pumpAndSettle();
      expect(find.byType(ProfileScreen), findsOneWidget);
      await tester.ensureVisible(find.byTooltip('Previous month'));
      await tester.tap(find.byTooltip('Previous month'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Next month'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byTooltip('Settings'));
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      expect(find.byType(SettingScreen), findsOneWidget);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(find.byType(SettingScreen), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    }
  });
}
