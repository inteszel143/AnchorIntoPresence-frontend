import 'app_back_button.dart';
import 'app_circle_button.dart';
import 'package:flutter/material.dart';

import '../../utils/fonts.dart';

class CustomAppbar extends StatelessWidget {
  final String headingTxt;
  final Widget? okimage;
  final void Function()? onOkTap;
  final void Function()? onTap;
  final Widget? image;

  const CustomAppbar({
    super.key,
    required this.headingTxt,
    this.okimage,
    this.onOkTap,
    this.onTap,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 12, 0),
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            AppBackButton(onPressed: onTap, icon: image),
            Expanded(
              child: Center(
                child: Text(
                  headingTxt,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 21,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    letterSpacing: Fonts.headingLetterSpacing,
                    fontFamily: Fonts.heading,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 48,
              height: 48,
              child: Align(
                alignment: Alignment.centerRight,
                child: okimage == null
                    ? const SizedBox.square(dimension: 44)
                    : AppCircleButton(icon: okimage!, onPressed: onOkTap),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
