import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindfully_evolve_app/screens/dashboard/mood_picker.dart';

void main() {
  testWidgets('picker starts with the saved profile mood', (tester) async {
    String? saved;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
          body: MoodPicker(
        initialMood: 'connected',
        onConfirm: (mood) => saved = mood,
      )),
    ));
    expect(find.text('Connected'), findsOneWidget);
    await tester.tap(find.text('Save my mood'));
    expect(saved, 'Connected');
  });

  testWidgets('selecting an emoji saves only after confirmation',
      (tester) async {
    String? saved;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: MoodPicker(onConfirm: (mood) => saved = mood)),
    ));
    await tester.tap(find.byTooltip('Connected'));
    await tester.pumpAndSettle();
    expect(saved, isNull);
    expect(find.text('Connected'), findsOneWidget);
    await tester.tap(find.text('Save my mood'));
    expect(saved, 'Connected');
  });

  testWidgets('saving disables submission and mood changes', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
          body: MoodPicker(
              isSaving: true,
              onConfirm: (_) {
                fail('Must not submit while saving');
              })),
    ));
    await tester.tap(find.byTooltip('Connected'));
    await tester.pump();
    expect(find.text('Calm'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('small screen and large text allow retry after an error',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    String? saved;
    await tester.pumpWidget(MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(2)),
        child: child!,
      ),
      home: Scaffold(
          body: MoodPicker(
        error: 'Please try again',
        onConfirm: (mood) => saved = mood,
      )),
    ));
    expect(tester.takeException(), isNull);
    expect(find.text('Please try again'), findsOneWidget);
    await tester.ensureVisible(find.byType(FilledButton));
    await tester.tap(find.byType(FilledButton));
    expect(saved, 'Calm');
  });
}
