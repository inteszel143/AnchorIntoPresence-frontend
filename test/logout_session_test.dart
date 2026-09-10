import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mindfully_evolve_app/common/local_storage.dart';
import 'package:mindfully_evolve_app/common/logout_session.dart';
import 'package:mindfully_evolve_app/utils/global.dart' as globals;
import 'package:mindfully_evolve_app/utils/fcm_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final offline in [false, true]) {
    test('logout calls endpoint and clears session, offline=$offline',
        () async {
      FlutterSecureStorage.setMockInitialValues(
          {'auth_token': 'test-auth', 'fcm_token': 'test-push'});
      globals.isSubscribed = true;
      globals.userName = 'Previous user';
      var called = false;
      final client = MockClient((request) async {
        called = true;
        expect(request.method, 'POST');
        expect(request.url.path, '/api/auth/logout');
        expect(request.headers['Authorization'], 'Bearer test-auth');
        if (offline) throw const SocketException('offline');
        return http.Response('{"status":true}', 200);
      });
      await logoutSession(client: client);
      client.close();
      expect(called, isTrue);
      expect(await LocalStorage.getToken(), isNull);
      expect(await LocalStorage.getFCMToken(), 'test-push');
      expect(globals.isSubscribed, isFalse);
      expect(globals.userName, isEmpty);
    });
  }
  test(
      'unavailable Firebase falls back to cached token without blocking sign-in',
      () async {
    FlutterSecureStorage.setMockInitialValues({'fcm_token': 'cached-push'});
    expect(await getFCMTokenForSignin(), 'cached-push');
    FlutterSecureStorage.setMockInitialValues({});
    expect(await getFCMTokenForSignin(), isNull);
  });
}
