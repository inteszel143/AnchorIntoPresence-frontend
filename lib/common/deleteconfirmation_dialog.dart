import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mindfully_evolve_app/utils/color_constants.dart';

import '../screens/signin/deleteaccount_bloc/delete_account_bloc.dart';
import '../screens/signin/deleteaccount_bloc/delete_account_event.dart';
import '../screens/signin/signin_screen.dart';
import '../utils/fonts.dart';
import '../utils/image_constants.dart';
import '../utils/string_constants.dart';

Future<void> showDeleteConfirmationDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Center(
        child: UnconstrainedBox(
          constrainedAxis: Axis.horizontal,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Dialog(
              insetPadding: EdgeInsets.zero,
              backgroundColor: ColorCodes.whiteNewReplacement,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(10, 25, 10, 25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 74,
                          height: 74,
                          padding: EdgeInsets.all(17),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ColorCodes.buttoncolor,
                          ),
                          child: ClipOval(
                            child: SvgPicture.asset(
                              ImageConstants.svgDeleteIcon,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Center(
                            child: Text(
                              Strings.areYouSureForDeleteAccount,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w400,
                                letterSpacing: Fonts.headingLetterSpacing,
                                fontFamily: Fonts.heading,
                                color: ColorCodes.confirmationtextcolor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                fixedSize: Size(135, 41),
                                side: BorderSide(color: ColorCodes.buttoncolor),
                                backgroundColor: ColorCodes.whitecolor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                Strings.cancel,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: Fonts.body,
                                  color: ColorCodes.canceltextcolor,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                context
                                    .read<AccountDeletionBloc>()
                                    .add(AccountDeletionRequest());

                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SigninScreen()),
                                  (Route<dynamic> route) => false,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                fixedSize: Size(135, 41),
                                backgroundColor: ColorCodes.buttoncolor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                Strings.delete,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: Fonts.body,
                                  color: ColorCodes.blackcolor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 15,
                    right: 15,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Icon(
                        Icons.close,
                        color: ColorCodes.blackcolor,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
