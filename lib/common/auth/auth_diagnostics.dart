import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Debug-only metadata. Never pass request/response bodies or token values here.
void logAuthStage(String stage, {Object? error, int? status}) {
  if (!kDebugMode) return;
  final code = switch (error) {
    FirebaseException e => e.code,
    PlatformException e => e.code,
    _ => null,
  };
  debugPrint('[Auth] $stage'
      '${status == null ? '' : ' HTTP=$status'}'
      '${error == null ? '' : ' error=${error.runtimeType}'}'
      '${code == null ? '' : ' code=$code'}');
}

class SocialLoginException implements Exception {
  const SocialLoginException(this.message);
  final String message;
}
