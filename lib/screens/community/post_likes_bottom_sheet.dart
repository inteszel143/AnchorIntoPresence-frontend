import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/color_constants.dart';
import '../../utils/fonts.dart';
import '../../utils/image_constants.dart';
import 'community_bloc/post_likes_bloc.dart';
import 'community_bloc/post_likes_event.dart';
import 'community_bloc/post_likes_state.dart';

/// Shows the "who liked this post" bottom sheet for [postId].
/// Call this on long-press of the like icon.
void showPostLikesBottomSheet(BuildContext context, String postId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => PostLikesBottomSheet(postId: postId),
  );
}

class PostLikesBottomSheet extends StatefulWidget {
  final String postId;

  const PostLikesBottomSheet({super.key, required this.postId});

  @override
  State<PostLikesBottomSheet> createState() => _PostLikesBottomSheetState();
}

class _PostLikesBottomSheetState extends State<PostLikesBottomSheet> {
  bool _listenerAttached = false;

  void _attachScrollListener(
      BuildContext context, ScrollController controller) {
    if (_listenerAttached) return;
    _listenerAttached = true;
    controller.addListener(() => _onScroll(context, controller));
  }

  void _onScroll(BuildContext context, ScrollController controller) {
    if (!controller.hasClients) return;
    // Prefetch the next page a bit before the very bottom so the new
    // rows are already there by the time the user reaches them —
    // no pause, no jump, no visible reload.
    final nearBottom =
        controller.position.pixels >= controller.position.maxScrollExtent - 200;
    if (!nearBottom) return;

    final bloc = context.read<PostLikesBloc>();
    final state = bloc.state;
    if (state is PostLikesLoaded && state.hasMore && !state.isLoadingMore) {
      bloc.add(FetchPostLikesEvent(
        postId: widget.postId,
        page: state.currentPage + 1,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PostLikesBloc()
        ..add(FetchPostLikesEvent(postId: widget.postId, page: 1)),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.35,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          _attachScrollListener(context, scrollController);

          return Container(
            decoration: BoxDecoration(
              color: ColorCodes.whitecolor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Likes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: Fonts.body,
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                Expanded(
                  child: BlocBuilder<PostLikesBloc, PostLikesState>(
                    builder: (context, state) {
                      if (state is PostLikesLoading ||
                          state is PostLikesInitial) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is PostLikesError) {
                        return Center(child: Text('Error: ${state.message}'));
                      } else if (state is PostLikesLoaded) {
                        if (state.likes.isEmpty) {
                          return const Center(child: Text('No likes yet.'));
                        }
                        return ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          // +1 slot for the small inline loader while the
                          // next page loads — keeps the existing rows
                          // perfectly still, nothing above them shifts.
                          itemCount: state.likes.length +
                              (state.isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= state.likes.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                ),
                              );
                            }
                            final like = state.likes[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: like.userImage != null &&
                                        like.userImage!.isNotEmpty
                                    ? NetworkImage(like.userImage!)
                                    : AssetImage(ImageConstants.userProfile)
                                        as ImageProvider,
                              ),
                              title: Text(
                                like.userName,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: Fonts.body,
                                ),
                              ),
                            );
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
