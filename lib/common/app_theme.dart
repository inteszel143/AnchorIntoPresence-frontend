import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../utils/fonts.dart';
import 'widgets/button_widget.dart';

class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF514C40),
      brightness: dark ? Brightness.dark : Brightness.light,
    ).copyWith(
      surface: dark ? const Color(0xFF211F1C) : const Color(0xFFF7F5F1),
      surfaceContainerHighest: dark ? const Color(0xFF2C2925) : Colors.white,
      surfaceContainerLow: dark ? const Color(0xFF292620) : Colors.white,
      onSurface: dark ? const Color(0xFFF3EEE7) : const Color(0xFF47423C),
      onSurfaceVariant:
          dark ? const Color(0xFFC8BFB3) : const Color(0xFF746D63),
      primary: dark ? const Color(0xFFDED0B9) : const Color(0xFF514C40),
      onPrimary: dark ? const Color(0xFF29251F) : Colors.white,
      outline: dark ? const Color(0xFF9B8E7B) : const Color(0xFFAEA08A),
    );
    final theme = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      canvasColor: scheme.surface,
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: brightness,
        scaffoldBackgroundColor: scheme.surface,
      ),
      cardTheme: CardThemeData(color: scheme.surfaceContainerHighest),
      fontFamily: Fonts.body,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonWidget.primaryStyle,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonWidget.primaryStyle,
      ),
    );
    return theme.copyWith(textTheme: Fonts.textTheme(theme.textTheme));
  }
}
