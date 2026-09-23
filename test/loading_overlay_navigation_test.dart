import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfully_evolve_app/common/widgets/loading_overlay.dart';

void main() {
  testWidgets('loading completion preserves the context used for navigation',
      (tester) async {
    final loading = ValueNotifier(true);
    addTearDown(loading.dispose);
    late BuildContext loginContext;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ValueListenableBuilder<bool>(
          valueListenable: loading,
          builder: (_, isLoading, __) => LoadingOverlay(
            isLoading: isLoading,
            child: Builder(builder: (context) {
              loginContext = context;
              return const Text('Sign in');
            }),
          ),
        ),
      ),
    ));

    final contextBeforeSuccess = loginContext;
    loading.value = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Sign-in schedules navigation before the loading overlay rebuilds.
      if (contextBeforeSuccess.mounted) {
        Navigator.of(contextBeforeSuccess).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => const Scaffold(body: Text('Home destination')),
          ),
        );
      }
    });
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Home destination'), findsOneWidget);
  });
}
