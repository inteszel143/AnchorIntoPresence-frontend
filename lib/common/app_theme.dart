import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../utils/fonts.dart';
import '../utils/color_constants.dart';
import 'widgets/button_widget.dart';

class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: ColorCodes.taupe,
      brightness: dark ? Brightness.dark : Brightness.light,
    ).copyWith(
      surface: dark ? const Color(0xFF211F1C) : ColorCodes.cream,
      surfaceContainerHighest: dark ? const Color(0xFF2C2925) : ColorCodes.cream,
      surfaceContainerLow: dark ? const Color(0xFF292620) : ColorCodes.cream,
      onSurface: dark ? ColorCodes.cream : ColorCodes.charcoal,
      onSurfaceVariant:
          dark ? ColorCodes.sand : ColorCodes.charcoal,
      primary: dark ? ColorCodes.taupe : ColorCodes.charcoal,
      onPrimary: dark ? const Color(0xFF29251F) : ColorCodes.cream,
      primaryContainer: ColorCodes.taupe,
      onPrimaryContainer: const Color(0xFF29251F),
      secondary: dark ? ColorCodes.clay : ColorCodes.charcoal,
      onSecondary: dark ? const Color(0xFF29251F) : ColorCodes.cream,
      secondaryContainer: ColorCodes.sand,
      onSecondaryContainer: ColorCodes.charcoal,
      tertiary: dark ? ColorCodes.sand : ColorCodes.charcoal,
      onTertiary: dark ? const Color(0xFF29251F) : ColorCodes.cream,
      tertiaryContainer: ColorCodes.sand,
      onTertiaryContainer: ColorCodes.charcoal,
      outline: ColorCodes.taupe,
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
