import 'app_back_button.dart';
import 'scroll_title_page.dart';
import 'app_circle_button.dart';
import 'package:flutter/material.dart';

import '../../utils/fonts.dart';

class CustomAppbar extends StatelessWidget {
  final String headingTxt;
  final Widget? okimage;
  final void Function()? onOkTap;
  final void Function()? onTap;
  final Widget? image;
  final double rightPadding;

  const CustomAppbar({
    super.key,
    required this.headingTxt,
    this.okimage,
    this.onOkTap,
    this.onTap,
    this.image,
    this.rightPadding = 0,
  });

  @override
  Widget build(BuildContext context) {
    final visibility = ScrollTitlePage.visibilityOf(context);
    final title =
        headingTxt.isEmpty ? ScrollTitlePage.titleOf(context) : headingTxt;
    final titleWidget = Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 21,
        color: Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.w700,
        letterSpacing: Fonts.headingLetterSpacing,
        fontFamily: Fonts.heading,
      ),
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 16, rightPadding, 0),
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            SizedBox(
                width: 48,
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: AppBackButton(onPressed: onTap, icon: image))),
            Expanded(
              child: Center(
                child: visibility == null || headingTxt.isNotEmpty
                    ? titleWidget
                    : ValueListenableBuilder<bool>(
                        valueListenable: visibility,
                        builder: (context, visible, child) => ExcludeSemantics(
                          excluding: !visible,
                          child: AnimatedOpacity(
                            opacity: visible ? 1 : 0,
                            duration: const Duration(milliseconds: 180),
                            child: child,
                          ),
                        ),
                        child: titleWidget,
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
