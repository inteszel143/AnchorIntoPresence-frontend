import 'package:flutter/material.dart';
import '../app_theme.dart';

/// Keeps standalone authentication routes aligned with the global palette.
class AuthTheme extends StatelessWidget {
  const AuthTheme({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = MediaQuery.platformBrightnessOf(context) == Brightness.dark ||
        Theme.of(context).brightness == Brightness.dark;
    return Theme(
      data: dark ? AppTheme.dark : AppTheme.light,
      child: child,
    );
  }
}
