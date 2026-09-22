import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfully_evolve_app/common/widgets/google_sign_in_button.dart';

class _Credential extends Fake implements UserCredential {}

void main() {
  Future<void> mount(
      WidgetTester tester, Future<UserCredential?> Function() authenticate,
      {Future<void> Function(UserCredential)? onSignedIn}) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
          body: GoogleSignInButton(
        authenticate: authenticate,
        onSignedIn: onSignedIn ?? (_) async {},
      )),
    ));
  }

  testWidgets('pending sign-in shows feedback and prevents duplicate requests',
      (tester) async {
    final pending = Completer<UserCredential?>();
    var calls = 0;
    await mount(tester, () {
      calls++;
      return pending.future;
    });
    await tester.tap(find.text('Continue with Google'));
    await tester.pump();
    expect(find.text('Connecting to Google…'), findsOneWidget);
    await tester.tap(find.text('Connecting to Google…'));
    expect(calls, 1);
    pending.complete(null);
    await tester.pumpAndSettle();
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('native errors are visible and allow retry', (tester) async {
    await mount(
        tester, () async => throw PlatformException(code: 'sign_in_failed'));
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();
    expect(
        find.textContaining(
            'Google sign-in could not complete (sign_in_failed)'),
        findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
  });

  testWidgets('Firebase network failures show useful feedback', (tester) async {
    await mount(
        tester,
        () async =>
            throw FirebaseAuthException(code: 'network-request-failed'));
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Please check your internet connection'),
        findsOneWidget);
  });

  testWidgets('success hands the credential to the backend callback',
      (tester) async {
    final credential = _Credential();
    UserCredential? received;
    await mount(tester, () async => credential, onSignedIn: (value) async {
      received = value;
    });
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();
    expect(received, same(credential));
  });

  testWidgets('completion after leaving the screen is safe', (tester) async {
    final pending = Completer<UserCredential?>();
    await mount(tester, () => pending.future);
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpWidget(const SizedBox());
    pending.completeError(PlatformException(code: 'sign_in_failed'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
