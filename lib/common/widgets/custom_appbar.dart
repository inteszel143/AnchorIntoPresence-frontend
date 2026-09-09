import 'package:flutter/material.dart';

import '../../utils/fonts.dart';

class CustomAppbar extends StatelessWidget {
  final String headingTxt;
  final Widget? okimage;
  final void Function()? onOkTap;
  final void Function()? onTap;
  final Widget? image;

  const CustomAppbar({super.key, 
    required this.headingTxt,
    this.okimage,
    this.onOkTap,
    this.onTap,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    final onBack = onTap ?? () {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 12, 0),
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: image == null
                  ? IconButton(
                      onPressed: onBack,
                      tooltip: 'Back',
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        size: 21,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    )
                  : IconButton(
                      onPressed: onBack,
                      tooltip: 'Back',
                      padding: EdgeInsets.zero,
                      icon: image!,
                    ),
            ),

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
                child: IconButton(
                  onPressed: onOkTap,
                  padding: EdgeInsets.zero,
                  icon: okimage ?? const SizedBox(width: 32, height: 32),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
