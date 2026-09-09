import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mindfully_evolve_app/utils/fonts.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../common/widgets/custom_appbar.dart';
import '../../utils/color_constants.dart';
import '../../utils/image_constants.dart';
import '../../utils/share_options.dart';
import '../../utils/string_constants.dart';
import '../../utils/urls.dart';
import '../comment/comment_screen.dart';
import 'community_bloc/community_bloc.dart';
import 'community_bloc/community_event.dart';
import 'community_bloc/community_state.dart';

// Displays the details of a community post accessed through a shared link.
class PostDetailScreen extends StatelessWidget {
  final String shareId;

  PostDetailScreen({super.key, required this.shareId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Loads the shared community post using its share ID.
      create: (context) =>
          CommunityBloc()..add(FetchCommunityPost(shareId: shareId)),
      child: Scaffold(
        backgroundColor: ColorCodes.backgroundcolor,
        body: Column(
          children: [
            SizedBox(height: 15),
            CustomAppbar(headingTxt: Strings.communityDetail),
            Expanded(
              child: BlocBuilder<CommunityBloc, CommunityState>(
                builder: (context, state) {
                  // Displays a loading indicator while the post details are being fetched.
                  if (state is CommunityLoading) {
                    return Center(child: CircularProgressIndicator());
                  }
                  // Displays an error message if the post cannot be loaded.
                  else if (state is CommunityError) {
                    return Center(child: Text('Error: ${state.message}'));
                  } else if (state is SharedCommunityLoaded) {
                    final post = state.post;
                    final timeAgo = timeago.format(post.createdAt);

                    return SingleChildScrollView(
                      child: Container(
                        margin: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: ColorCodes.whitecolor,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: post.image!.isNotEmpty
                                        ? NetworkImage(
                                            '${Urls.baseUrlimages}${post.image}')
                                        : const AssetImage(
                                            ImageConstants.williamsonProfile),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        post.userName,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: Fonts.body,
                                          color: ColorCodes.nameColor,
                                        ),
                                      ),
                                      Text(
                                        timeAgo,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: Fonts.body,
                                          color: Color(0xff51585C),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: ColorCodes.lightContainerColor,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    child: Text(
                                      post.postType,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: Fonts.body,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              post.images.isNotEmpty &&
                                      post.images.first != null
                                  ? Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 8),
                                      child: Image.network(
                                        '${Urls.baseUrlimages}${post.images.first}',
                                        width: double.infinity,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Container(),
                              Text(
                                post.message,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: Fonts.body,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Divider(),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      String postId = post.id;
                                      // Allows the user to like or unlike the community post.
                                      BlocProvider.of<CommunityBloc>(context)
                                          .add(LikePostEvent(postId));
                                    },
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                          ImageConstants.postLikeIcon,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          post.likesCount.toString(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () {
                                      // Opens the comments section for the selected post.
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CommentScreen(post: post),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                            ImageConstants.commentIcon),
                                        const SizedBox(width: 5),
                                        Text(
                                          post.commentsCount.toString(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () {
                                      String postMessage =
                                          "Check out this amazing post!";
                                      String postUrl =
                                          '${Urls.baseUrlimages}/app/post/share/${post.shareId}';
                                      // Provides sharing options for the community post.
                                      ShareUtils.showShareOptions(
                                          context, postMessage, postUrl);
                                    },
                                    child: SvgPicture.asset(
                                        ImageConstants.shareIcon),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return Center(child: Text('No post found.'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
