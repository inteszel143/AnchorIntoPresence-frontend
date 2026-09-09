import 'package:flutter/material.dart';
import '../../utils/fonts.dart';

/// Authentication screens follow the device appearance without changing other routes.
class AuthTheme extends StatelessWidget {
  const AuthTheme({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = MediaQuery.platformBrightnessOf(context) == Brightness.dark ||
        Theme.of(context).brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF514C40),
      brightness: dark ? Brightness.dark : Brightness.light,
    ).copyWith(
      surface: dark ? const Color(0xFF211F1C) : const Color(0xFFFAF9F6),
      surfaceContainerHighest:
          dark ? const Color(0xFF2C2925) : const Color(0xFFFFFDFC),
      onSurface: dark ? const Color(0xFFF3EEE7) : const Color(0xFF47423C),
      onSurfaceVariant:
          dark ? const Color(0xFFC8BFB3) : const Color(0xFF746D63),
      primary: dark ? const Color(0xFFDED0B9) : const Color(0xFF514C40),
      onPrimary: dark ? const Color(0xFF29251F) : Colors.white,
      outline: dark ? const Color(0xFF9B8E7B) : const Color(0xFFAEA08A),
    );
    return Theme(
      data: ThemeData(
        useMaterial3: true,
        brightness: scheme.brightness,
        colorScheme: scheme,
        scaffoldBackgroundColor: scheme.surface,
        fontFamily: Fonts.body,
      ),
      child: child,
    );
  }
}
