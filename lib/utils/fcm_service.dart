import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../common/local_storage.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

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
    } catch (_) {
      debugPrint('Unable to cache the refreshed push token.');
    }
  }, onError: (Object _) {
    debugPrint('Push token refresh is not available yet.');
  });
  await getFCMTokenForSignin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: DarwinInitializationSettings(),
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

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
