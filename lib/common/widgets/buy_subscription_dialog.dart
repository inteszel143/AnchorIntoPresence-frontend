import 'package:flutter/material.dart';
import 'package:mindfully_evolve_app/utils/color_constants.dart';

import '../../utils/fonts.dart';

void showSubscriptionDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: ColorCodes.whitecolor,
              shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [

            Padding(
              padding: const EdgeInsets.fromLTRB(35, 55, 35, 35),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  SizedBox(height: 10),
                  Text(
                    "To access this feature please\nbuy subscription first.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w400,
                      letterSpacing: Fonts.headingLetterSpacing,
                      fontFamily: Fonts.heading,
                      color:  ColorCodes.confirmationtextcolor,
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),

            // Close Button (top-right)
            Positioned(
              right: 12,
              top: 12,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.close,
                  size: 20,
                  color: ColorCodes.blackcolor,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
