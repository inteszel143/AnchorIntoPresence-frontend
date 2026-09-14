import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
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
        disabledBackgroundColor: ColorCodes.buttonInactive,
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
    final bgColor =
        isActive ? ColorCodes.buttonActive : ColorCodes.buttonInactive;
    final screenWidth = MediaQuery.of(context).size.width;
    final borderRadius = BorderRadius.circular(14);
    if (PlatformInfo.isIOS) {
      return IgnorePointer(
        ignoring: !isActive,
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: screenWidth * widthFactor,
            height: height,
            // Some callers attach their gesture to the parent widget.
            child: IgnorePointer(
              ignoring: onTap == null,
              child: AdaptiveButton.child(
                onPressed: isActive ? (onTap ?? () {}) : null,
                enabled: isActive,
                style: PlatformInfo.isIOS26OrHigher()
                    ? AdaptiveButtonStyle.prominentGlass
                    : AdaptiveButtonStyle.filled,
                size: AdaptiveButtonSize.large,
                color: bgColor,
                borderRadius: borderRadius,
                minSize: Size(0, height),
                child: Text(
                  btnTxt,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: ColorCodes.cream,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: Fonts.body,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    final content = Container(
      alignment: Alignment.center,
      width: screenWidth * widthFactor,
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: bgColor),
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: bgColor.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        btnTxt,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: ColorCodes.cream,
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
