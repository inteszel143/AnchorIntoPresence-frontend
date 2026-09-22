import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../helping_widgets/sociallogin-button.dart';
import '../../utils/image_constants.dart';
import '../auth/google_auth.dart';

class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({
    super.key,
    required this.onSignedIn,
    this.height = 60,
    this.authenticate = authenticateWithGoogle,
  });

  final Future<void> Function(UserCredential) onSignedIn;
  final Future<UserCredential?> Function() authenticate;
  final double height;

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _busy = false;

  Future<void> _signIn() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final credential = await widget.authenticate();
      if (!mounted || credential == null) return;
      await widget.onSignedIn(credential);
    } catch (error) {
      if (!mounted) return;
      if (error is PlatformException && error.code == 'sign_in_canceled') {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(googleSignInErrorMessage(error))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => SocialLoginButton(
        _busy ? 'Connecting to Google…' : 'Continue with Google',
        _busy ? Icons.hourglass_top : Image.asset(ImageConstants.googleIcon),
        height: widget.height,
        onPressed: _busy ? null : _signIn,
      );
}
