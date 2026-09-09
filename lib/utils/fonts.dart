import 'package:flutter/material.dart';

class Fonts {
  static const body = 'DM Sans';
  static const heading = 'Manrope';
  static const headingLetterSpacing = -0.5;

  // Use variable weights for intermediate UI weights such as 450, 550, 650.
  static TextStyle bodyStyle({double weight = 400}) => TextStyle(
        fontFamily: body,
        fontVariations: [FontVariation('wght', weight)],
      );

  static const quoteStyle = TextStyle(
    fontFamily: 'Georgia',
    fontFamilyFallback: ['serif'],
    fontStyle: FontStyle.italic,
    fontSize: 19,
  );

  static TextTheme textTheme(TextTheme base) {
    const headingStyle = TextStyle(
      fontFamily: heading,
      letterSpacing: headingLetterSpacing,
    );
    return base.copyWith(
      displayLarge: base.displayLarge?.merge(headingStyle),
      displayMedium: base.displayMedium?.merge(headingStyle),
      displaySmall: base.displaySmall?.merge(headingStyle),
      headlineLarge: base.headlineLarge?.merge(headingStyle),
      headlineMedium: base.headlineMedium?.merge(headingStyle),
      headlineSmall: base.headlineSmall?.merge(headingStyle),
      titleLarge: base.titleLarge?.merge(headingStyle),
    );
  }
}
