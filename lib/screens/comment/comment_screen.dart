import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindfully_evolve_app/screens/community/community_screen.dart';
import 'package:mindfully_evolve_app/utils/fonts.dart';
import 'package:mindfully_evolve_app/utils/global.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../common/widgets/commentdeletionconfirmation_dialog.dart';
import '../../common/widgets/custom_appbar.dart';
import '../../utils/color_constants.dart';
import '../../utils/image_constants.dart';
import '../../utils/string_constants.dart';
import '../../utils/urls.dart';
import '../community/community_model.dart';
import 'comment_bloc/comment_bloc.dart';
import 'comment_bloc/comment_event.dart';
import 'comment_bloc/comment_state.dart';
import 'comment_model.dart';

class CommentScreen extends StatefulWidget {
  final Post post;
  const CommentScreen({Key? key, required this.post}) : super(key: key);

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final FocusNode _focusNode = FocusNode();
  List<Comment> _comments = []; // Store the comments in a list

  @override
  Widget build(BuildContext context) {
    final timeAgo = timeago.format(widget.post.createdAt);
    final postId = widget.post.id;
    final userId = widget.post.userId;

    return BlocProvider(
      create: (context) => CommentBloc()..add(FetchCommentsEvent(postId)),
      child: Scaffold(
        backgroundColor: ColorCodes.backgroundcolor,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Column(
              children: [
                SizedBox(height: 15),
                CustomAppbar(
                  headingTxt: Strings.comments,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CommunityScreen()),
                    );
                  },
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: ColorCodes.whiteNewReplacement,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: (widget.post.image != null &&
                                      widget.post.image!.isNotEmpty)
                                  ? NetworkImage(widget.post.image!)
                                  : AssetImage(ImageConstants.userProfile)
                                      as ImageProvider,
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.post.userName,
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
                          ],
                        ),
                        const SizedBox(height: 10),
                        widget.post.imagesList.isNotEmpty
                            ? Container(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Image.network(
                                  '${Urls.baseUrlimages}${widget.post.images?.first}',
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(),
                        const SizedBox(height: 10),
                        Text(
                          widget.post.message,
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

                        BlocListener<CommentBloc, CommentState>(
                          listener: (context, state) {
                            if (state is CommentDeleted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Comment deleted successfully!'),
                                  backgroundColor: ColorCodes.buttoncolor,
                                ),
                              );
                            }
                          },
                          child: BlocBuilder<CommentBloc, CommentState>(
                            builder: (context, state) {
                              if (state is CommentLoading ||
                                  state is CommentPosting ||
                                  state is CommentLiking) {
                                return _comments.isNotEmpty
                                    ? Column(
                                        children: _comments.map((comment) {
                                          return CommentSection(
                                            comment: comment,
                                            post: widget.post,
                                            userid: widget.post.userId,
                                            onReply: () {
                                              context.read<CommentBloc>().add(
                                                  UpdateParentCommentEvent(
                                                      comment.id));
                                              _focusNode.requestFocus();
                                            },
                                          );
                                        }).toList(),
                                      )
                                    : Center(
                                        child: CircularProgressIndicator());
                              } else if (state is CommentLoaded) {
                                // Update the state only when new comments are loaded.
                                if (_comments != state.comments) {
                                  _comments = state.comments;
                                }

                                return Column(
                                  children: state.comments.map((comment) {
                                    return CommentSection(
                                      comment: comment,
                                      post: widget.post,
                                      userid: widget.post.userId,
                                      onReply: () {
                                        context.read<CommentBloc>().add(
                                            UpdateParentCommentEvent(
                                                comment.id));
                                        _focusNode.requestFocus();
                                      },
                                    );
                                  }).toList(),
                                );
                              } else if (state is CommentError) {
                                // Show error message and retain the previous list of comments.
                                return Column(
                                  children: [
                                    Center(
                                        child: Text('Error: ${state.message}')),
                                    if (_comments.isNotEmpty)
                                      ..._comments.map((comment) {
                                        return CommentSection(
                                          comment: comment,
                                          post: widget.post,
                                          userid: widget.post.userId,
                                          onReply: () {
                                            context.read<CommentBloc>().add(
                                                UpdateParentCommentEvent(
                                                    comment.id));
                                            _focusNode.requestFocus();
                                          },
                                        );
                                      }).toList(),
                                  ],
                                );
                              } else if (state is ParentCommentUpdated) {
                                // If we are in loading state, show the previously loaded comments.
                                return _comments.isNotEmpty
                                    ? Column(
                                        children: _comments.map((comment) {
                                          return CommentSection(
                                            comment: comment,
                                            post: widget.post,
                                            userid: widget.post.userId,
                                            onReply: () {
                                              context.read<CommentBloc>().add(
                                                  UpdateParentCommentEvent(
                                                      comment.id));
                                              _focusNode.requestFocus();
                                            },
                                          );
                                        }).toList(),
                                      )
                                    : Container();
                              }
                              return Container(); // Return an empty container by default
                            },
                          ),
                        ),

                        // Input for new comment
                        AnimatedPadding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                          ),
                          duration: const Duration(milliseconds: 150),
                          curve: Curves.easeOut,
                          child: MessageInput(
                            postId: postId,
                            focusNode: _focusNode,
                          ),
                        ),
                      ],
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

class CommentSection extends StatefulWidget {
  final Comment comment;
  final Post post;
  final String userid;
  final VoidCallback onReply;

  CommentSection({
    required this.comment,
    required this.post,
    required this.userid,
    required this.onReply,
  });

  @override
  _CommentSectionState createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  bool showReplies = false;

  void toggleReplies() {
    setState(() {
      showReplies = !showReplies;
    });
  }

  @override
  Widget build(BuildContext context) {
    final timeAgo = timeago.format(widget.comment.createdAt);
    final image = widget.comment.image;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: (image != null && image.isNotEmpty)
                    ? NetworkImage('${Urls.baseUrlimages}$image')
                    : AssetImage(ImageConstants.userProfile) as ImageProvider,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Container(
                  color: ColorCodes.lightContainerColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 8, 10, 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.comment.userName ?? 'user name',
                              style: TextStyle(fontWeight: FontWeight.bold),
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
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: double.infinity,
                          ),
                          child: Text(
                            widget.comment.message,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              fontFamily: Fonts.body,
                            ),
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 50, top: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BlocBuilder<CommentBloc, CommentState>(
                  builder: (context, state) {
                    final bool isLiking = state is CommentLiking;
                    return GestureDetector(
                      onTap: isLiking
                          ? null
                          : () {
                              context.read<CommentBloc>().add(
                                    LikeCommentEvent(widget.comment.postId,
                                        widget.comment.id),
                                  );
                            },
                      child: Text(
                        isLiking ? "Liking..." : "Like",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: Fonts.body,
                          color: widget.comment.liked
                              ? Colors.blue
                              : ColorCodes.blackcolor,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: widget.onReply,
                  child: const Text(
                    "Reply",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontFamily: Fonts.body,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                if (userId == widget.comment.userId)
                  GestureDetector(
                    onTap: () {
                      showCommentDeleteConfirmationDialog(
                          context, widget.post, widget.comment.id);
                    },
                    child: const Text(
                      "Delete",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: Fonts.body,
                        color: Colors.black,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (widget.comment.repliesCount > 0)
            Padding(
              padding: const EdgeInsets.only(left: 50, top: 5),
              child: GestureDetector(
                onTap: toggleReplies,
                child: Text(
                  showReplies
                      ? "Hide Replies"
                      : "View Replies (${widget.comment.repliesCount})",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: Fonts.body,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          if (showReplies)
            ...?widget.comment.replies?.map((reply) {
              return Padding(
                padding: const EdgeInsets.only(left: 50),
                child: SubCommentSection(
                  reply: reply,
                  post: widget.post,
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
}

class SubCommentSection extends StatelessWidget {
  final Reply reply;
  final Post post;

  const SubCommentSection({
    required this.reply,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    String? userName = reply.userName;

    String? userImage = reply.image;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // User image
              CircleAvatar(
                backgroundImage: (userImage != null && userImage.isNotEmpty)
                    ? NetworkImage('${Urls.baseUrlimages}$userImage')
                    : AssetImage(ImageConstants.userProfile) as ImageProvider,
              ),
              const SizedBox(width: 10),

              // User name and message
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    color: ColorCodes.lightContainerColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 5),
                          // Message
                          Text(
                            reply.message,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          if (userId == reply.userId)
            GestureDetector(
              onTap: () {
                showCommentDeleteConfirmationDialog(
                    context, post, reply.id ?? '');
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 55),
                child: const Text(
                  "Delete",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: Fonts.body,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class MessageInput extends StatefulWidget {
  final String postId;
  final FocusNode focusNode;

  const MessageInput({
    Key? key,
    required this.postId,
    required this.focusNode,
  }) : super(key: key);

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CommentBloc, CommentState>(
      listener: (context, state) {
        if (state is CommentPosted) {
          controller.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Comment posted!'),
              backgroundColor: ColorCodes.buttoncolor,
            ),
          );
        } else if (state is CommentPostError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: ColorCodes.buttoncolor,
            ),
          );
        }
      },
      builder: (context, state) {
        final bool isPosting = state is CommentPosting;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Container(
            decoration: BoxDecoration(
              color: ColorCodes.lightContainerColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: widget.focusNode,
                    enabled: !isPosting,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.send,
                    decoration: InputDecoration(
                      hintText: Strings.writeYourMessage,
                      hintStyle: TextStyle(
                        color: const Color(0xff51585C),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        fontFamily: Fonts.body,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 20),
                    ),
                  ),
                ),

                // Send button
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (context, value, child) {
                    final hasText = value.text.trim().isNotEmpty;
                    return IconButton(
                      icon: isPosting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Image.asset(ImageConstants.sendIcon),
                      onPressed: hasText
                          ? () {
                              final parentCommentId = context
                                      .read<CommentBloc>()
                                      .state is ParentCommentUpdated
                                  ? (context.read<CommentBloc>().state
                                          as ParentCommentUpdated)
                                      .parentCommentId
                                  : '';

                              context.read<CommentBloc>().add(
                                    PostCommentEvent(
                                      widget.postId,
                                      parentCommentId,
                                      controller.text.trim(),
                                    ),
                                  );
                            }
                          : null,
                    );
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
