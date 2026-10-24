import 'package:flutter_test/flutter_test.dart';
import 'package:mindfully_evolve_app/screens/dashboard/home_model.dart';

void main() {
  final profile = <String, dynamic>{
    '_id': 'user-id',
    'email': 'member@example.com',
    'provider': 'credentials',
    'isVerified': true,
    'isBlocked': false,
    'resetPassword': false,
    'createdAt': '2026-10-24T00:00:00.000Z',
    'updatedAt': '2026-10-24T00:00:00.000Z',
    'subscriptionStatus': 'not bought',
  };

  test('sign-in profile accepts an omitted or null optional display name', () {
    for (final data in [profile, {...profile, 'name': null}]) {
      final parsed = ProfileDataModel.fromJson(data);
      expect(parsed.name, '');
      expect(parsed.email, 'member@example.com');
      expect(parsed.isVerified, isTrue);
      expect(parsed.subscriptionStatus, 'not bought');
    }
  });

  test('sign-in profile preserves an existing display name', () {
    expect(ProfileDataModel.fromJson({...profile, 'name': 'Meditation'}).name,
        'Meditation');
  });
}
