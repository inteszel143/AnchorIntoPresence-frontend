import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/urls.dart';
import '../utils/global.dart' as globals;
import 'local_storage.dart';

/// Notify the server when reachable, but always allow local logout offline.
Future<void> logoutSession({http.Client? client}) async {
  final token = await LocalStorage.getToken();
  if (token != null && token.isNotEmpty) {
    final transport = client ?? http.Client();
    try {
      final response = await transport.post(Uri.parse(Urls.logout), headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      }).timeout(const Duration(seconds: 5));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint('Server logout unavailable; clearing the local session.');
      }
    } catch (_) {
      debugPrint('Server logout unavailable; clearing the local session.');
    } finally {
      if (client == null) transport.close();
    }
  }
  await LocalStorage.deleteToken();
  globals.alreadyPurchasedProductId = '';
  globals.isSubscribed = false;
  globals.userId = '';
  globals.userName = '';
  globals.userImage = '';
  globals.lastTransactionDate = null;
  globals.planType = null;
}
