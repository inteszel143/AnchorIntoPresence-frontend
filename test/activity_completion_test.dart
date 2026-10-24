import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mindfully_evolve_app/helping_widgets/postactivity_checkbox.dart';
import 'package:mindfully_evolve_app/screens/activity_details/activity_bloc/post_activity_bloc.dart';
import 'package:mindfully_evolve_app/screens/activity_details/activityresponse_model.dart';
import 'package:mindfully_evolve_app/screens/track/activity_log_updates.dart';
import 'package:mindfully_evolve_app/screens/track/track_bloc/track_bloc.dart';
import 'package:mindfully_evolve_app/screens/track/track_bloc/track_event.dart';
import 'package:mindfully_evolve_app/screens/track/track_bloc/track_state.dart';
import 'package:mindfully_evolve_app/screens/track/track_screen.dart';

http.Response summary(String title, {String totalTime = '10:30'}) => http.Response(
    jsonEncode({
      'status': true,
      'message': '',
      'data': {
        'loggedActivities': {'totalTime': totalTime, 'thumbnails': []},
        'categoryDistribution': {},
        'loginDates': {'streak': []},
        'completedActivities': [
          {
            'name': title,
            'completedAt': '2026-10-12T10:00:00Z',
            'totalVideoTime': '10:00'
          }
        ]
      }
    }),
    200);
PostActivityResponseModel saved() => PostActivityResponseModel.fromJson({
      'status': true,
      'message': 'saved',
      'data': {
        '_id': 'log',
        'userId': 'user',
        'activityId': 'practice',
        'videoTimestamp': '10:00',
        'totalVideoTime': '10:00',
        'isCompleted': true,
        'createdAt': '2026-10-12T10:00:00Z',
        'updatedAt': '2026-10-12T10:00:00Z'
      }
    });
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(
      () => FlutterSecureStorage.setMockInitialValues({'auth_token': 'test'}));
  testWidgets('completion stays unchecked until saved; failure allows retry',
      (tester) async {
    var request = Completer<PostActivityResponseModel>();
    var calls = 0;
    final bloc = PostActivityBloc(submit: (_) {
      calls++;
      return request.future;
    });
    addTearDown(bloc.close);
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: BlocProvider.value(
                value: bloc,
                child: const MarkAsCompleteCheckbox(
                    activityId: 'practice',
                    videoTimestamp: '10:00',
                    totalVideoTime: '10:00',
                    isChecked: false)))));
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, false);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).onChanged, isNull);
    request.completeError(Exception('offline'));
    await tester.pumpAndSettle();
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, false);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).onChanged, isNotNull);
    request = Completer<PostActivityResponseModel>();
    final revision = activityLogRevision.value;
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    request.complete(saved());
    await tester.pumpAndSettle();
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, true);
    expect(activityLogRevision.value, revision + 1);
    expect(calls, 2);
  });
  testWidgets('Track refreshes on tab return and confirmed saves',
      (tester) async {
    var calls = 0;
    final client = MockClient((_) async => summary('Practice ${++calls}', totalTime: '00:09'));
    addTearDown(client.close);
    final bloc = TrackBloc(client: client);
    Future<void> show(bool active) async {
      await tester.pumpWidget(MaterialApp(
          home: TrackScreen(isActive: active, createBloc: () => bloc)));
      await tester.pumpAndSettle();
    }

    await show(true);
    expect(calls, 1);
    expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('practice-minutes')))
            .data,
        '9');
    expect(find.text('seconds of practice today'), findsOneWidget);
    await show(false);
    activityLogRevision.value++;
    await tester.pump();
    expect(calls, 1);
    await show(true);
    expect(calls, 2);
    activityLogRevision.value++;
    await tester.pumpAndSettle();
    expect(calls, 3);
    expect(find.text('Recent log'), findsNothing);
    expect(find.text('Your week'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  test('older Track response cannot overwrite a refresh after completion',
      () async {
    final pending = <Completer<http.Response>>[];
    final client = MockClient((_) {
      final c = Completer<http.Response>();
      pending.add(c);
      return c.future;
    });
    final bloc = TrackBloc(client: client);
    addTearDown(() => bloc.close());
    addTearDown(client.close);
    bloc.add(TrackDataFetchEvent());
    while (pending.isEmpty) {
      await Future<void>.delayed(Duration.zero);
    }
    bloc.add(TrackDataFetchEvent());
    while (pending.length < 2) {
      await Future<void>.delayed(Duration.zero);
    }
    final loaded = bloc.stream.firstWhere((s) => s is TrackLoadedState);
    pending[1].complete(summary('New completion'));
    await loaded;
    pending[0].complete(summary('Old data'));
    await Future<void>.delayed(Duration.zero);
    expect(
        (bloc.state as TrackLoadedState)
            .userActivity
            .data
            .completedActivities
            .single
            .name,
        'New completion');
  });
}
