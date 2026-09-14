import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mindfully_evolve_app/screens/comment/comment_screen.dart';
import 'package:mindfully_evolve_app/screens/community/community_model.dart';
import 'package:mindfully_evolve_app/utils/color_constants.dart';

import '../../screens/comment/comment_bloc/comment_bloc.dart';
import '../../screens/comment/comment_bloc/comment_event.dart';
import '../../utils/fonts.dart';
import '../../utils/image_constants.dart';
import '../../utils/string_constants.dart';

Future<void> showCommentDeleteConfirmationDialog(
    BuildContext context, Post post, String commentId) async {
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
              backgroundColor: ColorCodes.whitecolor,
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
                          child: ClipOval(
                            child: SvgPicture.asset(
                              ImageConstants.svgDeleteIcon,
                              colorFilter: const ColorFilter.mode(
                                  ColorCodes.charcoal, BlendMode.srcIn),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Center(
                            child: Text(
                              Strings.areYouSureForDeleteComment,
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
                              onPressed: () async {
                                context.read<CommentBloc>().add(
                                    DeleteCommentEvent(post.id, commentId));
                                context
                                    .read<CommentBloc>()
                                    .add(FetchCommentsEvent(post.id));
                                //Navigator.pop(context);
                                await Future.delayed(
                                    const Duration(milliseconds: 500));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('comment deleted successfully!'),
                                    backgroundColor: ColorCodes.buttoncolor,
                                  ),
                                );
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          CommentScreen(post: post)),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                fixedSize: Size(135, 41),
                                backgroundColor: ColorCodes.buttonActive,
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
                                  color: ColorCodes.whitecolor,
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
