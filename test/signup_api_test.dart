import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mindfully_evolve_app/utils/api_service.dart';

void main() {
  Future<dynamic> signup(http.Client client) => ApiService.signup(
        name: ' Test Person ',
        email: ' person@example.com ',
        password: 'test-password',
        client: client,
      );

  test('successful signup preserves names and trims email', () async {
    final result = await signup(MockClient((request) async {
      expect(jsonDecode(request.body), {
        'name': 'Test Person',
        'email': 'person@example.com',
        'password': 'test-password',
      });
      return http.Response('{"status":true,"message":"OTP sent to email"}', 200);
    }));
    expect(result.status, isTrue);
  });

  test('server errors are not reported as internet problems', () async {
    for (final body in ['<html>Server error</html>', '', 'null']) {
      final result = await signup(MockClient((_) async => http.Response(body, 502)));
      expect(result.status, isFalse);
      expect(result.message, contains('temporarily unavailable'));
    }
  });

  test('email delivery and duplicate email messages reach the user', () async {
    for (final code in [409, 503]) {
      final result = await signup(MockClient((_) async => http.Response(
          '{"message":"Please try again shortly"}', code)));
      expect(result.status, isFalse);
      expect(result.message, 'Please try again shortly');
    }
  });

  test('malformed success response is not reported as a network error', () async {
    await expectLater(
      signup(MockClient((_) async => http.Response('<html>Error</html>', 200))),
      throwsA(predicate((error) => error.toString().contains('unexpected response'))),
    );
  });

  test('a real connection failure has a connection message', () async {
    await expectLater(
      signup(MockClient((_) async => throw const SocketException('offline'))),
      throwsA(predicate((error) => error.toString().contains('check your internet connection'))),
    );
  });
}
