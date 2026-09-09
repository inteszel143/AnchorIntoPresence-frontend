// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // 🌐 Web config (if needed, adjust separately from Firebase console)
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDAJqQHEJKP9AUpCMEGw1VKXNzCXOzFP4g',
    appId: '1:935021721863:web:YOUR_WEB_APP_ID',
    messagingSenderId: '935021721863',
    projectId: 'mindfull-yoga-project',
    authDomain: 'mindfull-yoga-project.firebaseapp.com',
    storageBucket: 'mindfull-yoga-project.firebasestorage.app',
    measurementId: 'G-YOUR_MEASUREMENT_ID',
  );

  // 🤖 Android config
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyCWox43DoNYa0FC2ioIJQx1F25-8PEoKLM",
    appId: "1:935021721863:android:2db430c9a59ec0c011eda2",
    messagingSenderId: "935021721863",
    projectId: "mindfull-yoga-project",
    storageBucket: "mindfull-yoga-project.firebasestorage.app",
  );

  
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDAJqQHEJKP9AUpCMEGw1VKXNzCXOzFP4g',
    appId: '1:935021721863:ios:317eaba94885163c11eda2',
    messagingSenderId: '935021721863',
    projectId: 'mindfull-yoga-project',
    storageBucket: 'mindfull-yoga-project.firebasestorage.app',
    androidClientId: '935021721863-42d82c4ttvs45gtc49kr8udm2p7ao8de.apps.googleusercontent.com',
    iosClientId: '935021721863-l48mfchnelul946np3s2ua03m2tehhcl.apps.googleusercontent.com',
    iosBundleId: 'com.mindfull.minfullyevolveapp',
  );

  // 🍏 macOS uses same config as iOS
  static const FirebaseOptions macos = ios;

  // 🖥 Windows config (if used, adjust from Firebase console)
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDAJqQHEJKP9AUpCMEGw1VKXNzCXOzFP4g',
    appId: '1:935021721863:web:YOUR_WEB_APP_ID',
    messagingSenderId: '935021721863',
    projectId: 'mindfull-yoga-project',
    authDomain: 'mindfull-yoga-project.firebaseapp.com',
    storageBucket: 'mindfull-yoga-project.firebasestorage.app',
    measurementId: 'G-YOUR_MEASUREMENT_ID',
  );
}
