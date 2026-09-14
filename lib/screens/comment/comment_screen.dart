import 'package:mindfully_evolve_app/common/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../common/widgets/commentdeletionconfirmation_dialog.dart';
import '../../common/widgets/custom_appbar.dart';
import '../../common/widgets/scroll_title_page.dart';
import '../../utils/global.dart';
import '../../utils/urls.dart';
import '../community/community_model.dart';
import 'comment_bloc/comment_bloc.dart';
import 'comment_bloc/comment_event.dart';
import 'comment_bloc/comment_state.dart';
import 'comment_model.dart';

class CommentScreen extends StatelessWidget {
  const CommentScreen({super.key, required this.post});
  final Post post;

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => CommentBloc()..add(FetchCommentsEvent(post.id)),
        child: CommentsContent(post: post),
      );
}

class CommentsContent extends StatefulWidget {
  const CommentsContent({super.key, required this.post});
  final Post post;
  @override
  State<CommentsContent> createState() => _CommentsContentState();
}

class _CommentsContentState extends State<CommentsContent> {
  final _focus = FocusNode();
  List<Comment> _comments = [];

  @override
  void initState() {
    super.initState();
    final state = context.read<CommentBloc>().state;
    if (state is CommentLoaded) _comments = state.comments;
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<CommentBloc, CommentState>(
        listener: (context, state) {
          if (state is CommentLoaded) _comments = state.comments;
          if (state is CommentDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Comment deleted successfully!')));
          }
        },
        builder: (context, state) {
          final text = Theme.of(context).textTheme;
          final colors = Theme.of(context).colorScheme;
          return AppScaffold(
            body: ScrollTitlePage(
                title: 'Comments',
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(children: [
                          CustomAppbar(
                              headingTxt: '',
                              onTap: () => Navigator.pop(context)),
                          Expanded(
                              child: CustomScrollView(
                                  keyboardDismissBehavior:
                                      ScrollViewKeyboardDismissBehavior.onDrag,
                                  slivers: [
                                SliverToBoxAdapter(
                                    child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 24, bottom: 24),
                                        child: Text('Comments',
                                            style: text.headlineLarge?.copyWith(
                                                fontWeight: FontWeight.w600)))),
                                SliverToBoxAdapter(
                                    child: Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                            color:
                                                colors.surfaceContainerHighest,
                                            borderRadius:
                                                BorderRadius.circular(24)),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _Author(
                                                  name: widget.post.userName,
                                                  image: widget.post.image,
                                                  date: widget.post.createdAt),
                                              if (widget
                                                  .post.images.isNotEmpty) ...[
                                                const SizedBox(height: 18),
                                                ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            18),
                                                    child: Image.network(
                                                        _imageUrl(widget
                                                            .post.images.first),
                                                        width: double.infinity,
                                                        height: 220,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (_, __,
                                                                ___) =>
                                                            SizedBox(
                                                                height: 100,
                                                                child: Center(
                                                                    child: Icon(
                                                                        Icons.image_outlined,
                                                                        color: colors.onSurfaceVariant)))))
                                              ],
                                              const SizedBox(height: 16),
                                              Text(widget.post.message,
                                                  style: text.bodyLarge
                                                      ?.copyWith(height: 1.6)),
                                            ]))),
                                SliverToBoxAdapter(
                                    child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 28, bottom: 16),
                                        child: Text('Conversation',
                                            style: text.titleLarge?.copyWith(
                                                fontWeight: FontWeight.w600)))),
                                if (state is CommentError)
                                  SliverToBoxAdapter(
                                      child: Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 16),
                                          child: Text(state.message,
                                              style: text.bodyMedium?.copyWith(
                                                  color: colors.error)))),
                                if (_comments.isEmpty &&
                                    state is CommentLoading)
                                  const SliverToBoxAdapter(
                                      child: Padding(
                                          padding: EdgeInsets.all(24),
                                          child: Center(
                                              child:
                                                  CircularProgressIndicator())))
                                else if (_comments.isEmpty &&
                                    state is! CommentError)
                                  SliverToBoxAdapter(
                                      child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 24),
                                          child: Column(children: [
                                            Icon(
                                                Icons
                                                    .chat_bubble_outline_rounded,
                                                size: 32,
                                                color: colors.onSurfaceVariant),
                                            const SizedBox(height: 12),
                                            Text('Start the conversation',
                                                style: text.titleMedium),
                                            const SizedBox(height: 6),
                                            Text(
                                                'Share a thoughtful comment below.',
                                                textAlign: TextAlign.center,
                                                style: text.bodyMedium
                                                    ?.copyWith(
                                                        color: colors
                                                            .onSurfaceVariant))
                                          ])))
                                else
                                  SliverList.builder(
                                      itemCount: _comments.length,
                                      itemBuilder: (context, index) {
                                        final comment = _comments[index];
                                        return CommentSection(
                                            key: ValueKey(comment.id),
                                            comment: comment,
                                            post: widget.post,
                                            userid: widget.post.userId,
                                            onReply: () {
                                              context.read<CommentBloc>().add(
                                                  UpdateParentCommentEvent(
                                                      comment.id));
                                              _focus.requestFocus();
                                            });
                                      }),
                                const SliverToBoxAdapter(
                                    child: SizedBox(height: 24)),
                              ])),
                          MessageInput(
                              postId: widget.post.id, focusNode: _focus),
                        ])),
                  ),
                )),
          );
        },
      );
}

String _imageUrl(String image) =>
    image.startsWith('http') ? image : '${Urls.baseUrlimages}$image';

class _Author extends StatelessWidget {
  const _Author({required this.name, this.image, this.date});
  final String name;
  final String? image;
  final DateTime? date;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fallback = Container(
        width: 40,
        height: 40,
        color: colors.surfaceContainerLow,
        child: Icon(Icons.person_outline_rounded, color: colors.primary));
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ClipOval(
          child: image?.isNotEmpty == true
              ? Image.network(_imageUrl(image!),
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => fallback)
              : fallback),
      const SizedBox(width: 12),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w700)),
        if (date != null) ...[
          const SizedBox(height: 3),
          Text(timeago.format(date!),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: colors.onSurfaceVariant))
        ],
      ])),
    ]);
  }
}

class CommentSection extends StatefulWidget {
  const CommentSection(
      {super.key,
      required this.comment,
      required this.post,
      required this.userid,
      required this.onReply});
  final Comment comment;
  final Post post;
  final String userid;
  final VoidCallback onReply;
  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  bool _showReplies = false;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final comment = widget.comment;
    return Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(24)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _Author(
              name: comment.userName ?? 'Community member',
              image: comment.image,
              date: comment.createdAt),
          const SizedBox(height: 14),
          Text(comment.message,
              style:
                  Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5)),
          const SizedBox(height: 8),
          Wrap(spacing: 4, children: [
            BlocBuilder<CommentBloc, CommentState>(
                builder: (context, state) => TextButton.icon(
                    style: TextButton.styleFrom(
                        foregroundColor: comment.liked
                            ? colors.error
                            : colors.onSurfaceVariant),
                    onPressed: state is CommentLiking
                        ? null
                        : () => context
                            .read<CommentBloc>()
                            .add(LikeCommentEvent(comment.postId, comment.id)),
                    icon: Icon(
                        comment.liked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 18),
                    label: Text(state is CommentLiking ? 'Liking…' : 'Like'))),
            TextButton(onPressed: widget.onReply, child: const Text('Reply')),
            if (userId == comment.userId)
              TextButton(
                  style: TextButton.styleFrom(foregroundColor: colors.onSurface),
                  onPressed: () => showCommentDeleteConfirmationDialog(
                      context, widget.post, comment.id),
                  child: const Text('Delete')),
          ]),
          if (comment.repliesCount > 0)
            TextButton.icon(
                onPressed: () => setState(() => _showReplies = !_showReplies),
                icon: Icon(_showReplies
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded),
                label: Text(_showReplies
                    ? 'Hide replies'
                    : 'View replies (${comment.repliesCount})')),
          if (_showReplies)
            ...?comment.replies?.map(
                (reply) => SubCommentSection(reply: reply, post: widget.post)),
        ]));
  }
}

class SubCommentSection extends StatelessWidget {
  const SubCommentSection({super.key, required this.reply, required this.post});
  final Reply reply;
  final Post post;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(18)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _Author(
              name: reply.userName ?? 'Community member', image: reply.image),
          const SizedBox(height: 12),
          Text(reply.message,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(height: 1.5)),
          if (userId == reply.userId)
            TextButton(
                style: TextButton.styleFrom(foregroundColor: colors.onSurface),
                onPressed: () => showCommentDeleteConfirmationDialog(
                    context, post, reply.id),
                child: const Text('Delete')),
        ]));
  }
}

class MessageInput extends StatefulWidget {
  const MessageInput(
      {super.key, required this.postId, required this.focusNode});
  final String postId;
  final FocusNode focusNode;
  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final _controller = TextEditingController();
  String _parentId = '';
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send(BuildContext context) {
    if (_controller.text.trim().isEmpty ||
        context.read<CommentBloc>().state is CommentPosting) {
      return;
    }
    context.read<CommentBloc>().add(
        PostCommentEvent(widget.postId, _parentId, _controller.text.trim()));
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<CommentBloc, CommentState>(
        listener: (context, state) {
          if (state is ParentCommentUpdated) _parentId = state.parentCommentId;
          if (state is CommentPosted) {
            _controller.clear();
            _parentId = '';
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Comment posted!')));
          } else if (state is CommentPostError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final colors = Theme.of(context).colorScheme;
          final busy = state is CommentPosting;
          return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                  padding: const EdgeInsets.fromLTRB(4, 4, 8, 4),
                  decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: colors.outlineVariant.withValues(alpha: .5))),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                            child: TextField(
                                controller: _controller,
                                focusNode: widget.focusNode,
                                enabled: !busy,
                                minLines: 1,
                                maxLines: 4,
                                keyboardType: TextInputType.multiline,
                                textInputAction: TextInputAction.newline,
                                decoration: InputDecoration(
                                    hintText: _parentId.isEmpty
                                        ? 'Write a comment…'
                                        : 'Write a reply…',
                                    hintStyle: TextStyle(
                                        color: colors.onSurfaceVariant),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12)))),
                        ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _controller,
                            builder: (context, value, _) => IconButton.filled(
                                tooltip: 'Send comment',
                                style: IconButton.styleFrom(
                                    backgroundColor: colors.primary,
                                    foregroundColor: colors.onPrimary),
                                onPressed: !busy && value.text.trim().isNotEmpty
                                    ? () => _send(context)
                                    : null,
                                icon: busy
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: colors.onSurfaceVariant))
                                    : const Icon(Icons.arrow_upward_rounded))),
                      ])));
        },
      );
}
