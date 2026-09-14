import 'package:flutter/material.dart';
import 'package:mindfully_evolve_app/utils/fonts.dart';
import 'package:mindfully_evolve_app/utils/color_constants.dart';

class ButtonWidget extends StatelessWidget {
  final String btnTxt;
  final double widthFactor;
  final double height;
  final bool isActive;
  final VoidCallback? onTap;

  const ButtonWidget({
    super.key,
    required this.btnTxt,
    required this.widthFactor,
    required this.height,
    this.isActive = true,
    this.onTap,
  });

  static ButtonStyle get primaryStyle => ElevatedButton.styleFrom(
        backgroundColor: ColorCodes.buttonActive,
        disabledBackgroundColor: ColorCodes.buttonActive,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: ColorCodes.cream,
        disabledForegroundColor: ColorCodes.cream,
        textStyle: const TextStyle(
          fontFamily: Fonts.body,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      );

  @override
  Widget build(BuildContext context) {
    const bgColor = ColorCodes.buttonActive;
    const foregroundColor = ColorCodes.cream;
    final screenWidth = MediaQuery.of(context).size.width;
    final borderRadius = BorderRadius.circular(14);
    // Keep the same painted surface when form validity changes on any platform.
    final content = Container(
      alignment: Alignment.center,
      width: screenWidth * widthFactor,
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: bgColor),
        borderRadius: borderRadius,
      ),
      child: Text(
        btnTxt,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: foregroundColor,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          fontFamily: Fonts.body,
        ),
      ),
    );

    return IgnorePointer(
      ignoring: !isActive,
      child: SafeArea(
        top: false,
        child: onTap == null
            ? content
            : Material(
                color: Colors.transparent,
                borderRadius: borderRadius,
                child: InkWell(
                  onTap: isActive ? onTap : null,
                  borderRadius: borderRadius,
                  splashColor: ColorCodes.cream.withValues(alpha: 0.2),
                  highlightColor: ColorCodes.cream.withValues(alpha: 0.1),
                  child: content,
                ),
              ),
      ),
    );
  }
}
