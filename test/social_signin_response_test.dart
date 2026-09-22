import 'package:flutter_test/flutter_test.dart';
import 'package:mindfully_evolve_app/screens/signin/signin_model.dart';

void main() {
  test('a rejected social login preserves its message without user data', () {
    final result = SocialSigninResponseModel.fromJson({
      'message': 'This email is already registered with password login',
    });
    expect(result.data, isNull);
    expect(result.token, isEmpty);
    expect(result.message, contains('password login'));
  });

  test('a null data response does not throw', () {
    final result = SocialSigninResponseModel.fromJson({
      'message': 'All fields are required',
      'data': null,
    });
    expect(result.token, isEmpty);
  });

  test('successful social login reads the nested session token', () {
    final result = SocialSigninResponseModel.fromJson({
      'data': {'email': 'test@example.com', 'token': 'test-session'},
    });
    expect(result.token, 'test-session');
    expect(result.data?.email, 'test@example.com');
  });
}
