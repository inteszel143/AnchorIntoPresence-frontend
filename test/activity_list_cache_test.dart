import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mindfully_evolve_app/screens/activity_listing/activity_list_cache.dart';
import 'package:mindfully_evolve_app/screens/activity_listing/getactivity_model.dart';
import 'package:mindfully_evolve_app/screens/activity_listing/getactivity_bloc/getrecent_activities_bloc.dart';
import 'package:mindfully_evolve_app/screens/activity_listing/getactivity_bloc/getrecent_activities_event.dart';
import 'package:mindfully_evolve_app/screens/activity_listing/getactivity_bloc/getrecent_activities_state.dart';

void main() {
  setUp(ActivityListCache.clear);
  tearDown(ActivityListCache.clear);

  final response = ActivityResponse(
      message: '', activities: [], recommendedActivities: [], status: true);

  test('a reopened page receives its cached list without a loading state',
      () async {
    final key = jsonEncode([1, 10, '', '', null]);
    ActivityListCache.put(key, response, ActivityListCache.revision);
    for (var visit = 0; visit < 2; visit++) {
      final bloc = ActivityBloc();
      final next = bloc.stream.first;
      bloc.add(FetchActivities(useCache: true));
      expect(await next, isA<ActivityLoaded>());
      expect((bloc.state as ActivityLoaded).activities, same(response));
      await bloc.close();
    }
  });

  test('clearing a session rejects results from earlier requests', () {
    final oldRevision = ActivityListCache.revision;
    ActivityListCache.clear();
    ActivityListCache.put('old account', response, oldRevision);
    expect(ActivityListCache.get('old account'), isNull);
  });
}
