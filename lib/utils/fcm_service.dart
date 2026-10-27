import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'urls.dart';
import 'package:flutter/foundation.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../common/local_storage.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

StreamSubscription<String>? _tokenRefreshSubscription;

/// Refresh before sign-in; lack of push support must not stop password login.
Future<String?> getFCMTokenForSignin() async {
  try {
    final messaging = FirebaseMessaging.instance;
    if (!Platform.isIOS ||
        await messaging.getAPNSToken().timeout(const Duration(seconds: 3)) !=
            null) {
      final token =
          await messaging.getToken().timeout(const Duration(seconds: 3));
      if (token != null && token.isNotEmpty) {
        await LocalStorage.saveFCMToken(token);
        return token;
      }
    }
  } catch (_) {
    // Push registration is optional; fall back to the cached token.
  }
  return LocalStorage.getFCMToken();
}

Future<void> syncPushToken([String? refreshedToken]) async {
  try {
    final auth = await LocalStorage.getToken();
    if (auth == null || auth.isEmpty) return;
    final token = refreshedToken ?? await getFCMTokenForSignin();
    if (token == null || token.isEmpty) return;
    final response = await http.patch(
      Uri.parse('${Urls.baseUrl}/api/users/push-token'),
      headers: {'Authorization': 'Bearer $auth', 'Content-Type': 'application/json'},
      body: jsonEncode({'fcmToken': token}),
    ).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) debugPrint('Push registration will retry when the app resumes.');
  } catch (_) {
    debugPrint('Push registration will retry when the app resumes.');
  }
}

Future<void> initializeFCM() async {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await _tokenRefreshSubscription?.cancel();
  _tokenRefreshSubscription = messaging.onTokenRefresh.listen((token) async {
    try {
      await LocalStorage.saveFCMToken(token);
      await syncPushToken(token);
    } catch (_) {
      debugPrint('Unable to cache the refreshed push token.');
    }
  }, onError: (Object _) {
    debugPrint('Push token refresh is not available yet.');
  });
  await getFCMTokenForSignin();
  unawaited(syncPushToken());
  await messaging.setForegroundNotificationPresentationOptions(
    alert: true, badge: true, sound: true,
  );

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: DarwinInitializationSettings(),
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(const AndroidNotificationChannel(
        'default_channel', 'Default Channel', importance: Importance.high,
      ));

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'default_channel',
            'Default Channel',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {});
}
