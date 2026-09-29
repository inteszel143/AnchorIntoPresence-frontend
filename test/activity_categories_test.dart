import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mindfully_evolve_app/screens/activity_listing/activity_categories.dart';
import 'package:mindfully_evolve_app/screens/activity_listing/getactivity_model.dart';

void main() {
  test('legacy API identifies a Pause even if it contains a video field',
      () async {
    final client = MockClient((request) async {
      final isCategories = request.url.path.endsWith('/categories');
      return http.Response(
          jsonEncode({
            'status': true,
            'data': isCategories
                ? [
                    {'_id': 'anchor-category', 'name': 'Daily Anchor'},
                    {'_id': 'pause-category', 'name': 'Daily Pause'},
                  ]
                : [
                    {
                      '_id': request.url.queryParameters['categoryId'] ==
                              'pause-category'
                          ? 'pause'
                          : 'anchor'
                    }
                  ],
            'pagination': {'totalPages': 1},
          }),
          200);
    });
    final response = await resolveActivityCategories({
      'status': true,
      'message': '',
      'recommendedActivities': [],
      'data': [
        for (final id in ['pause', 'anchor'])
          {
            '_id': id,
            'name': id,
            'description': '',
            'thumbnail': '',
            'video': '/old-video.mp4',
            'tags': [],
            'isFavorite': true,
          }
      ],
    }, client: client, token: 'local-test');
    final activities = ActivityResponse.fromJson(response).activities;
    expect(activities.first.isDailyPause, isTrue);
    expect(activities.last.isDailyAnchor, isTrue);
    expect(activities.first.isFavorite, isTrue);
    client.close();
  });
}
