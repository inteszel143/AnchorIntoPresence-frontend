import 'auth_diagnostics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<UserCredential?> authenticateWithGoogle() async {
  var stage = 'google.accountPicker';
  try {
    logAuthStage(stage);
    final account = await GoogleSignIn().signIn();
    if (account == null) return null; // The account picker was dismissed.
    stage = 'google.tokens';
    logAuthStage(stage);
    final tokens = await account.authentication;
    stage = 'firebase.credentialExchange';
    logAuthStage(stage);
    final credential = await FirebaseAuth.instance.signInWithCredential(
      GoogleAuthProvider.credential(
        accessToken: tokens.accessToken,
        idToken: tokens.idToken,
      ),
    );
    logAuthStage('firebase.authenticated');
    return credential;
  } catch (error) {
    logAuthStage(stage, error: error);
    rethrow;
  }
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
