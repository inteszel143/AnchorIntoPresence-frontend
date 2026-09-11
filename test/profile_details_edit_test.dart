import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfully_evolve_app/common/app_theme.dart';
import 'package:mindfully_evolve_app/screens/user_profile/userprofile_screen.dart';
import 'package:mindfully_evolve_app/screens/user_profile/user_model.dart';
import 'package:mindfully_evolve_app/screens/edit_profile/edit_profile.dart';
import 'package:mindfully_evolve_app/screens/edit_profile/editprofile_bloc/edit_profile_bloc.dart';
import 'package:mindfully_evolve_app/screens/edit_profile/editprofile_bloc/edit_profile_event.dart';
import 'package:mindfully_evolve_app/screens/edit_profile/editprofile_bloc/edit_profile_state.dart';

class EditFixture extends EditProfileBloc {
  UpdateProfile? submitted;
  @override
  void add(EditProfileEvent event) {
    if (event is UpdateProfile) {
      submitted = event;
    } else {
      super.add(event);
    }
  }
}

void main() {
  testWidgets('profile keeps real data and fits long text in both themes',
      (tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var edits = 0;
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      await tester.pumpWidget(MaterialApp(
          theme: theme,
          home: Scaffold(
              body: SingleChildScrollView(
                  child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: ProfileDetails(
                          user: UserModel(
                              id: 'real',
                              name: 'A real account name',
                              email: 'a.long.email.address@example.com',
                              provider: ''),
                          onEdit: () => edits++))))));
      await tester.pumpAndSettle();
      expect(find.text('Test User'), findsNothing);
      expect(find.text('A real account name'), findsNWidgets(2));
      await tester.ensureVisible(find.text('Edit profile'));
      await tester.tap(find.text('Edit profile'));
      expect(tester.takeException(), isNull);
    }
    expect(edits, 2);
  });

  testWidgets(
      'edit validates blank names and preserves the typed name after an error',
      (tester) async {
    final bloc = EditFixture();
    await tester.pumpWidget(MaterialApp(
        home: BlocProvider<EditProfileBloc>.value(
            value: bloc,
            child: const ProfileEditForm(
                initialName: 'Jane', email: 'jane@example.com'))));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '  ');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -700));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    expect(bloc.submitted, isNull);
    expect(find.text('Please enter your name.'), findsOneWidget);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 700));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '  Jane Smith  ');
    await tester.pumpAndSettle();
    bloc.emit(bloc.state.copyWith(error: 'Please try again'));
    await tester.pumpAndSettle();
    expect(find.text('  Jane Smith  '), findsOneWidget);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -700));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save changes'));
    expect(bloc.submitted?.name, 'Jane Smith');
    bloc.emit(EditProfileState(name: 'Jane Smith', isLoading: true));
    await tester.pump();
    expect(
        tester.widget<FilledButton>(find.byType(FilledButton).last).onPressed,
        isNull);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(bloc.close);
  });

  testWidgets('photo options open in dark mode and can be dismissed',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.dark,
        home: const UserprofileEditScreen(
            name: 'Jane', email: 'jane@example.com')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Change photo'));
    await tester.pumpAndSettle();
    expect(find.text('Take a photo'), findsOneWidget);
    expect(find.text('Choose from gallery'), findsOneWidget);
    Navigator.of(tester.element(find.text('Take a photo'))).pop();
    await tester.pumpAndSettle();
    expect(find.text('Change profile photo'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
