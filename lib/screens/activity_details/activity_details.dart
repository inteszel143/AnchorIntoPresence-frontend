import '../../common/widgets/scroll_title_page.dart';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/custom_videoplayer.dart';
import '../../common/widgets/custom_appbar.dart';
import '../../helping_widgets/checkbox_cubic.dart';
import '../../helping_widgets/postactivity_checkbox.dart';
import '../activity_listing/getactivity_bloc/getrecent_activities_bloc.dart';
import '../activity_listing/getactivity_bloc/getrecent_activities_event.dart';
import 'activity_bloc/post_activity_bloc.dart';
import 'activity_bloc/post_activity_event.dart';

// Displays the selected activity details, video, favorite status, and completion option.
class ActivityDetailScreen extends StatefulWidget {
  final String videoUrl;
  final Uint8List? thumbnail;
  final String name;
  final String duration;
  final List<String> tags;
  final String description;
  final String activityId;
  final bool isFavorite;

  const ActivityDetailScreen({
    super.key,
    required this.videoUrl,
    required this.thumbnail,
    required this.name,
    required this.duration,
    required this.tags,
    required this.description,
    required this.activityId,
    required this.isFavorite,
  });

  @override
  State<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  // Tracks the favorite status locally to update the UI immediately after the user toggles it.
  late final ValueNotifier<bool> isFavoriteNotifier;
  // Keeps track of the user's current video progress for activity tracking and completion.
  final ValueNotifier<Duration> watchedDuration = ValueNotifier(Duration.zero);
  bool hasSentStartedEvent = false;

  @override
  void initState() {
    super.initState();
    isFavoriteNotifier = ValueNotifier(widget.isFavorite);
  }

  @override
  void dispose() {
    isFavoriteNotifier.dispose();
    watchedDuration.dispose();
    super.dispose();
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: ScrollTitlePage(
        title: widget.name,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ValueListenableBuilder<bool>(
                  valueListenable: isFavoriteNotifier,
                  builder: (context, favorite, _) => CustomAppbar(
                    headingTxt: '',
                    onTap: () => Navigator.pop(context, true),
                    okimage: Tooltip(
                      message: favorite
                          ? 'Remove from favorites'
                          : 'Save meditation',
                      child: Icon(
                          favorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: favorite ? Colors.red : colors.onSurface),
                    ),
                    onOkTap: () {
                      context
                          .read<ActivityBloc>()
                          .add(ToggleFavorite(activityId: widget.activityId));
                      isFavoriteNotifier.value = !favorite;
                    },
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.name,
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 14),
                        Wrap(spacing: 8, runSpacing: 8, children: [
                          if (widget.duration != '--:--')
                            _chip(context, widget.duration,
                                icon: Icons.schedule_rounded),
                          for (final tag in widget.tags) _chip(context, tag),
                        ]),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: colors.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(28)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: AspectRatio(
                              aspectRatio: 16 / 10,
                              child: ColoredBox(
                                color: Colors.black,
                                child: OnlineVideoPlayer(
                                  videoUrl: widget.videoUrl,
                                  thumbnail: widget.thumbnail,
                                  onProgress: (position) {
                                    watchedDuration.value = position;
                                    if (!hasSentStartedEvent &&
                                        position > Duration.zero) {
                                      hasSentStartedEvent = true;
                                      context.read<PostActivityBloc>().add(
                                          MarkActivityComplete(
                                              activityId: widget.activityId,
                                              videoTimestamp:
                                                  formatDuration(position),
                                              totalVideoTime: widget.duration,
                                              isCompleted: false));
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 26),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                              color: colors.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(24)),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('About this practice',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                            fontWeight: FontWeight.w600)),
                                const SizedBox(height: 12),
                                Text(widget.description,
                                    style: TextStyle(
                                        fontSize: 15,
                                        height: 1.7,
                                        color: colors.onSurfaceVariant)),
                              ]),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              color: colors.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(24)),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('A moment for you',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                            fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                Text(
                                    'When you’re ready, mark your practice as complete.',
                                    style: TextStyle(
                                        color: colors.onSurfaceVariant,
                                        height: 1.5)),
                                const SizedBox(height: 16),
                                BlocProvider(
                                  create: (_) => CheckboxCubit(),
                                  child: ValueListenableBuilder<Duration>(
                                    valueListenable: watchedDuration,
                                    builder: (context, position, _) =>
                                        MarkAsCompleteCheckbox(
                                      activityId: widget.activityId,
                                      videoTimestamp: formatDuration(position),
                                      totalVideoTime: widget.duration,
                                      isChecked: false,
                                    ),
                                  ),
                                ),
                              ]),
                        ),
                      ]),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _chip(BuildContext context, String label, {IconData? icon}) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[
          Icon(icon, size: 15, color: colors.onSurfaceVariant),
          const SizedBox(width: 6),
        ],
        Text(label,
            style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant)),
      ]),
    );
  }
}
