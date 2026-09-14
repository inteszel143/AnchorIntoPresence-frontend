import 'package:flutter/material.dart';

import '../utils/color_constants.dart';
import '../utils/fonts.dart';

class SocialLoginButton extends StatelessWidget {
  final String text;
  final dynamic icon;
  final Color? color;
  final double height;
  final void Function()? onPressed;

  const SocialLoginButton(this.text, this.icon,
      {this.color, this.height = 60, super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).colorScheme.surfaceContainerHighest
              : ColorCodes.whitecolor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: ColorCodes.searchboxcolor,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(),
            const SizedBox(width: 8),
            Flexible(
                child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.onSurface
                    : ColorCodes.socialbuttontextcolor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: Fonts.body,
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (icon is Image) {
      return SizedBox(
        width: 20,
        height: 20,
        child: icon as Widget,
      );
    } else if (icon is IconData) {
      return Icon(icon, color: color ?? ColorCodes.blackcolor, size: 20);
    } else {
      return Icon(Icons.error, color: ColorCodes.redcolor);
    }
  }
}
