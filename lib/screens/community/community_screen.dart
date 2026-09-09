import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mindfully_evolve_app/common/main_screen.dart';
import 'package:mindfully_evolve_app/common/widgets/postdeletionconfirmation_dialog.dart';
import 'package:mindfully_evolve_app/screens/comment/comment_screen.dart';
import 'package:mindfully_evolve_app/utils/fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../common/widgets/custom_appbar.dart';
import '../../utils/color_constants.dart';
import '../../utils/global.dart';
import '../../utils/image_constants.dart';
import '../../utils/string_constants.dart';
import '../../utils/urls.dart';
import '../add_post/add_post_screen.dart';
import 'community_bloc/community_bloc.dart';
import 'community_bloc/community_event.dart';
import 'community_bloc/community_state.dart';
import 'post_likes_bottom_sheet.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});
  void _sharePost(BuildContext context, String postMessage, String postUrl) {
    Share.share('$postMessage\n$postUrl');
  }

  // Show custom bottom sheet with share options
  void _showShareOptions(
      BuildContext context, String postMessage, String postUrl) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          color: ColorCodes.whiteNewReplacement,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Share Via',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              // WhatsApp Share Button
              SingleChildScrollView(
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        _sharePost(context, postMessage, postUrl);
                        Navigator.pop(
                            context); // Close the bottom sheet after sharing
                      },
                      child: Column(
                        children: [
                          Image.asset(ImageConstants.whatsappIcon,
                              width: 46, height: 46),
                          const SizedBox(width: 10),
                          Text(
                            'WhatsApp',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Facebook Share Button
                    GestureDetector(
                      onTap: () {
                        _sharePost(context, postMessage, postUrl);
                        Navigator.pop(context);
                      },
                      child: Column(
                        children: [
                          Image.asset(ImageConstants.facebookIcon,
                              width: 46, height: 46),
                          const SizedBox(width: 10),
                          Text(
                            'Facebook',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Instagram Share Button
                    GestureDetector(
                      onTap: () {
                        _sharePost(context, postMessage, postUrl);
                        Navigator.pop(context);
                      },
                      child: Column(
                        children: [
                          Image.asset(ImageConstants.instaIcon,
                              width: 46, height: 46),
                          const SizedBox(width: 10),
                          Text(
                            'Instagram',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),

                    GestureDetector(
                      onTap: () {
                        Share.share(postUrl);
                        Navigator.pop(context);
                      },
                      child: Column(
                        children: [
                          Image.asset(ImageConstants.copylinkIcon,
                              width: 46, height: 46),
                          const SizedBox(height: 10),
                          Text(
                            'Copy Link',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),

                    GestureDetector(
                      onTap: () {
                        Share.share(postUrl);
                        Navigator.pop(context);
                      },
                      child: Column(
                        children: [
                          Image.asset(ImageConstants.twitterIcon,
                              width: 46, height: 46),
                          const SizedBox(height: 10),
                          Text(
                            'Twitter',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String mapTabToPostType(String tab) {
    return tab == 'All' ? tab.toLowerCase() : tab;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CommunityBloc()..add(FetchPostsEvent()),
      child: BlocListener<CommunityBloc, CommunityState>(
        listener: (context, state) {
          if (state is PostDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Post deleted successfully!'),
                backgroundColor: ColorCodes.buttoncolor,
              ),
            );
            context.read<CommunityBloc>().add(FetchPostsEvent());
          }
        },
        child: WillPopScope(
          onWillPop: () async {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => MainScreen(
                        initialIndex: 0,
                      )),
              (route) => false,
            );
            return false;
          },
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: Column(
              children: [
                SizedBox(
                  height: 15,
                ),
                CustomAppbar(
                  headingTxt: Strings.community,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MainScreen(
                                initialIndex: 0,
                              )),
                    );
                  },
                  okimage:
                      Icon(Icons.add, color: ColorCodes.buttoncolor, size: 30),
                  onOkTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CreatePostScreen()),
                    );
                  },
                ),
                Row(
                  children: [],
                ),
                Expanded(
                  child: GestureDetector(
                    onVerticalDragUpdate: (details) {
                      Navigator.of(context).pop();
                    },
                    child: BlocBuilder<CommunityBloc, CommunityState>(
                      builder: (context, state) {
                        if (state is CommunityLoading) {
                          return Center(child: CircularProgressIndicator());
                        } else if (state is CommunityError) {
                          return Center(child: Text('Error: ${state.message}'));
                        } else if (state is CommunityLoaded) {
                          if (state.posts.isEmpty) {
                            return Center(
                              child: Text(
                                "No data found",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          }
                          return ListView.builder(
                            itemCount: state.posts.length,
                            itemBuilder: (context, index) {
                              final post = state.posts[index];
                              final timeAgo = timeago.format(post.createdAt);
                              return GestureDetector(
                                child: Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(15, 0, 15, 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: ColorCodes.whiteNewReplacement,
                                    boxShadow: [],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 16, 16, 16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Profile Info
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundImage: post.image !=
                                                          '' &&
                                                      post.image!.isNotEmpty
                                                  ? NetworkImage(post.image!)
                                                  : AssetImage(ImageConstants
                                                      .userProfile),
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
                                            if (post.userId == userId)
                                              PopupMenuButton<String>(
                                                padding: EdgeInsets.zero,
                                                icon: Icon(Icons.more_vert,
                                                    size: 20,
                                                    color: Colors.black87),
                                                onSelected: (value) {
                                                  String postId = post.id;
                                                  if (value == 'delete') {
                                                    showPostDeleteConfirmationDialog(
                                                        context, postId);
                                                  }
                                                },
                                                itemBuilder: (BuildContext
                                                        context) =>
                                                    <PopupMenuEntry<String>>[
                                                  const PopupMenuItem<String>(
                                                    value: 'delete',
                                                    child: Text('Delete'),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),

                                        const SizedBox(height: 10),

                                        post.imagesList.isNotEmpty
                                            ? Container(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 8),
                                                child: Image.network(
                                                  '${Urls.baseUrlimages}${post.images.first}',
                                                  width: double.infinity,
                                                  height: 200,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : Container(),
                                        // Post content
                                        Text(
                                          post.message,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            fontFamily: Fonts.body,
                                            height: 2,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Divider(),
                                        const SizedBox(height: 5),
                                        // Interaction buttons
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                String postId = post.id;
                                                BlocProvider.of<CommunityBloc>(
                                                        context)
                                                    .add(LikePostEvent(postId));
                                              },
                                              onLongPress: () {
                                                showPostLikesBottomSheet(
                                                    context, post.id);
                                              },
                                              child: Row(
                                                children: [
                                                  SvgPicture.asset(
                                                    post.liked
                                                        ? ImageConstants
                                                            .svgRedLikeIcon
                                                        : ImageConstants
                                                            .postLikeIcon,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    post.likesCount.toString(),
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          CommentScreen(
                                                            post: post,
                                                          )),
                                                );
                                              },
                                              child: Row(
                                                children: [
                                                  SvgPicture.asset(
                                                      ImageConstants
                                                          .commentIcon),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    post.commentsCount
                                                        .toString(),
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                        return Center(child: Text('No posts available.'));
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
