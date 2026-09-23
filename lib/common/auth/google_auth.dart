import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<UserCredential?> authenticateWithGoogle() async {
  final account = await GoogleSignIn().signIn();
  if (account == null) return null; // The account picker was dismissed.
  final tokens = await account.authentication;
  return FirebaseAuth.instance.signInWithCredential(
    GoogleAuthProvider.credential(
      accessToken: tokens.accessToken,
      idToken: tokens.idToken,
    ),
  );
}

String googleSignInErrorMessage(Object error) {
  final code = switch (error) {
    FirebaseAuthException e => e.code,
    PlatformException e => e.code,
    _ => 'unknown',
  };
  if (code == 'network_error' || code == 'network-request-failed') {
    return 'Please check your internet connection and try Google sign-in again.';
  }
  if (code == 'account-exists-with-different-credential') {
    return 'This email uses another sign-in method. Please use your original sign-in method.';
  }
  if (code == 'user-disabled') {
    return 'This account has been disabled. Please contact support.';
  }
  // Include only the error code, never credentials or the native error payload.
  return 'Google sign-in could not complete ($code). Please try again or contact support.';
}
