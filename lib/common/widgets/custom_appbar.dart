import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: SizedBox(
        height: 40,
        child: Row(
          children: [
            // Left icon
            SizedBox(
              width: 60,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: GestureDetector(
                    onTap: onTap ??
                        () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                        },
                    child: image ??
                        SvgPicture.asset(
                          'assets/images/back_icon_new.svg',
                          width: 28,
                          height: 28,
                        ),
                  ),
                ),
              ),
            ),

            // Title
            Expanded(
              child: Center(
                child: Text(
                  headingTxt,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    color: const Color(0xff12150E),
                    fontWeight: FontWeight.w400,
                    letterSpacing: Fonts.headingLetterSpacing,
                    fontFamily: Fonts.heading,
                  ),
                ),
              ),
            ),

            // Right icon
            SizedBox(
              width: 60,
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: GestureDetector(
                    onTap: onOkTap,
                    child: okimage ??
                        const SizedBox(
                          width: 32,
                          height: 32,
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
