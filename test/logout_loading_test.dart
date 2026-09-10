import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfully_evolve_app/common/logoutconfirmation_dialog.dart';
import 'package:mindfully_evolve_app/utils/string_constants.dart';

void main() {
  for (final fail in [false, true]) {
    testWidgets(
        'logout button spinner blocks Back and cleans up on ${fail ? 'failure' : 'success'}',
        (tester) async {
      final deletion = Completer<void>();
      const channel =
          MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel,
          (call) async {
        if (call.method == 'delete') await deletion.future;
        return null;
      });
      addTearDown(() => tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null));
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: Builder(
        builder: (context) => TextButton(
            onPressed: () => showLogoutConfirmationDialog(context),
            child: const Text('Open logout')),
      ))));
      await tester.tap(find.text('Open logout'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(Strings.logout));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      final activeLoader = find.descendant(
          of: find.byType(FilledButton),
          matching: find.byType(CircularProgressIndicator));
      expect(activeLoader, findsOneWidget);
      expect(find.text(Strings.logout), findsNothing);
      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(activeLoader, findsOneWidget);
      expect(find.text(Strings.logout), findsNothing);
      if (fail) {
        deletion.completeError(PlatformException(code: 'storage_error'));
      } else {
        deletion.complete();
      }
      await tester.pumpAndSettle();
      expect(activeLoader, findsNothing);
      expect(
          find.text(
              fail ? 'Couldn’t log out. Please try again.' : 'Welcome back.'),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
