import 'package:flutter_test/flutter_test.dart';
import 'package:mindfully_evolve_app/screens/dashboard/dashboard_bloc/recently_played_model.dart';

void main() {
  RecentlyPlayedActivity item(
          {String? category = 'Daily Anchor',
          String position = '02:10',
          String total = '10:00',
          bool completed = false,
          String video = '/practice.mp4'}) =>
      RecentlyPlayedActivity(
          id: 'test',
          videoTimestamp: position,
          totalVideoTime: total,
          isCompleted: completed,
          category: category == null
              ? null
              : RecentlyPlayedCategory(id: 'category', name: category),
          name: 'Practice',
          thumbnail: '',
          video: video,
          description: '',
          duration: '',
          tags: [],
          isFavorite: false);

  test('only started, unfinished guided Anchors can continue', () {
    expect(item().canContinueListening, isTrue);
    expect(item(category: 'Daily Pause').canContinueListening, isFalse);
    expect(item(category: null).canContinueListening, isFalse);
    expect(item(video: '').canContinueListening, isFalse);
    expect(item(completed: true).canContinueListening, isFalse);
    expect(item(position: '00:00').canContinueListening, isFalse);
    expect(item(position: '--:--').canContinueListening, isFalse);
    expect(item(position: '10:00').canContinueListening, isFalse);
    expect(item(position: '11:00').canContinueListening, isFalse);
    expect(item(position: '00:99').canContinueListening, isFalse);
    expect(item(position: '01:02:03', total: '02:00:00').canContinueListening,
        isTrue);
    expect(item(total: '--:--').canContinueListening, isTrue);
  });
}
