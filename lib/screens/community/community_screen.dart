import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../common/widgets/tab_content_page.dart';
import '../../common/widgets/postdeletionconfirmation_dialog.dart';
import '../../utils/global.dart';
import '../../utils/urls.dart';
import '../comment/comment_screen.dart';
import '../add_post/add_post_screen.dart';
import 'community_bloc/community_bloc.dart';
import 'community_bloc/community_event.dart';
import 'community_bloc/community_state.dart';
import 'community_model.dart';
import 'post_likes_bottom_sheet.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => CommunityBloc()..add(FetchPostsEvent()),
        child: BlocConsumer<CommunityBloc, CommunityState>(
          listener: (context, state) {
            if (state is PostDeleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Post deleted successfully!')));
              context.read<CommunityBloc>().add(FetchPostsEvent());
            }
          },
          builder: (context, state) => CommunityFeed(state: state),
        ),
      );
}

class CommunityFeed extends StatelessWidget {
  const CommunityFeed({super.key, required this.state});
  final CommunityState state;

  @override
  Widget build(BuildContext context) => TabContentPage(
        title: 'Community',
        subtitle: 'A space to connect and grow together.',
        bottomAction: FloatingActionButton(
            heroTag: 'community-create-post',
            tooltip: 'Create post',
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            elevation: 2,
            shape: const CircleBorder(),
            onPressed: () async {
              final created = await Navigator.push<bool>(context,
                  MaterialPageRoute(builder: (_) => const CreatePostScreen()));
              if (created == true && context.mounted) {
                context.read<CommunityBloc>().add(FetchPostsEvent());
              }
            },
            child: const Icon(Icons.add_rounded)),
        slivers: [
          if (state is CommunityLoaded &&
              (state as CommunityLoaded).posts.isNotEmpty)
            SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList.builder(
                    itemCount: (state as CommunityLoaded).posts.length,
                    itemBuilder: (context, index) => CommunityPostCard(
                        post: (state as CommunityLoaded).posts[index])))
          else
            SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                        child: state is CommunityLoading
                            ? const CircularProgressIndicator()
                            : Column(mainAxisSize: MainAxisSize.min, children: [
                                Icon(Icons.forum_outlined,
                                    size: 40,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant),
                                const SizedBox(height: 16),
                                Text(
                                    state is CommunityError
                                        ? (state as CommunityError).message
                                        : 'No posts yet',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                              ])))),
        ],
      );
}

class CommunityPostCard extends StatelessWidget {
  const CommunityPostCard({super.key, required this.post});
  final Post post;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme.apply(
          bodyColor: colors.onSurface,
          displayColor: colors.onSurface,
        );
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark
              ? colors.surfaceContainerHighest
              : Colors.white,
          borderRadius: BorderRadius.circular(24)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          ClipOval(
              child: (post.image?.isNotEmpty ?? false)
                  ? Image.network(post.image!,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _avatar(colors))
                  : _avatar(colors)),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(post.userName,
                    style:
                        text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(timeago.format(post.createdAt),
                    style: text.bodySmall
                        ?.copyWith(color: colors.onSurfaceVariant)),
              ])),
          if (post.userId == userId)
            PopupMenuButton<String>(
                tooltip: 'Post options',
                icon: Icon(Icons.more_horiz_rounded, color: colors.onSurface),
                onSelected: (value) {
                  if (value == 'delete') {
                    showPostDeleteConfirmationDialog(context, post.id);
                  }
                },
                itemBuilder: (_) => [
                      const PopupMenuItem(
                          value: 'delete', child: Text('Delete'))
                    ]),
        ]),
        if (post.imagesList.isNotEmpty) ...[
          const SizedBox(height: 18),
          ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(
                  post.images.first.startsWith('http')
                      ? post.images.first
                      : '${Urls.baseUrlimages}${post.images.first}',
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                      height: 160,
                      color: colors.surfaceContainerLow,
                      alignment: Alignment.center,
                      child: Icon(Icons.image_outlined,
                          color: colors.onSurfaceVariant)))),
        ],
        const SizedBox(height: 16),
        Text(post.message, style: text.bodyLarge?.copyWith(height: 1.6)),
        const SizedBox(height: 16),
        Divider(height: 1, color: colors.outlineVariant.withValues(alpha: .4)),
        const SizedBox(height: 8),
        Wrap(spacing: 16, children: [
          TextButton.icon(
              style: TextButton.styleFrom(
                  foregroundColor:
                      post.liked ? colors.error : colors.onSurfaceVariant,
                  minimumSize: const Size(48, 48)),
              onPressed: () =>
                  context.read<CommunityBloc>().add(LikePostEvent(post.id)),
              onLongPress: () => showPostLikesBottomSheet(context, post.id),
              icon: Icon(
                  post.liked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: 21),
              label: Text('${post.likesCount}')),
          TextButton.icon(
              style: TextButton.styleFrom(
                  foregroundColor: colors.onSurfaceVariant,
                  minimumSize: const Size(48, 48)),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => CommentScreen(post: post))),
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 21),
              label: Text('${post.commentsCount}')),
        ]),
      ]),
    );
  }

  Widget _avatar(ColorScheme colors) => Container(
      width: 44,
      height: 44,
      color: colors.surfaceContainerLow,
      child: Icon(Icons.person_outline_rounded, color: colors.primary));
}
