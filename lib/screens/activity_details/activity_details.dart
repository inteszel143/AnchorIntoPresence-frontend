import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mindfully_evolve_app/utils/image_constants.dart';

import '../../common/custom_videoplayer.dart';
import '../../common/widgets/custom_appbar.dart';
import '../../helping_widgets/checkbox_cubic.dart';
import '../../helping_widgets/postactivity_checkbox.dart';
import '../../utils/color_constants.dart';
import '../../utils/fonts.dart';
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
    Key? key,
    required this.videoUrl,
    required this.thumbnail,
    required this.name,
    required this.duration,
    required this.tags,
    required this.description,
    required this.activityId,
    required this.isFavorite,
  }) : super(key: key);

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
    return Scaffold(
      backgroundColor: ColorCodes.backgroundcolor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: isFavoriteNotifier,
                builder: (context, currentFavorite, _) {
                  return CustomAppbar(
                    headingTxt: '',
                    okimage: SizedBox(
                      width: 40,
                      height: 40,
                      child: currentFavorite
                          ? SvgPicture.asset(ImageConstants.svgRedLikeIcon)
                          : SvgPicture.asset(ImageConstants.svgLikeIcon),
                    ),
                    onTap: () {
                      Navigator.pop(context, true);
                    },
                    // Updates the activity's favorite status and immediately reflects the change in the UI.
                    onOkTap: () {
                      BlocProvider.of<ActivityBloc>(context).add(
                        ToggleFavorite(
                          activityId: widget.activityId,
                        ),
                      );
                      isFavoriteNotifier.value = !currentFavorite;
                    },
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 32,
                  height: 310,
                  child: OnlineVideoPlayer(
                    videoUrl: widget.videoUrl,
                    thumbnail: widget.thumbnail,
                    // Records the user's initial activity engagement when video playback begins.
                    onProgress: (position) {
                      watchedDuration.value = position;

                      if (!hasSentStartedEvent && position > Duration.zero) {
                        hasSentStartedEvent = true;
                        // Submits the activity's current video progress to the backend.
                        context.read<PostActivityBloc>().add(
                              MarkActivityComplete(
                                activityId: widget.activityId,
                                videoTimestamp: formatDuration(position),
                                totalVideoTime: widget.duration,
                                isCompleted: false,
                              ),
                            );
                      }
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                  widget.name,
                  style: const TextStyle(
                    color: ColorCodes.mainheadingcolor,
                    fontWeight: FontWeight.w400,
                    fontSize: 18,
                    letterSpacing: Fonts.headingLetterSpacing,
                    fontFamily: Fonts.heading,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                  widget.description,
                  style: TextStyle(
                    color: ColorCodes.descriptioncolor,
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    fontFamily: Fonts.body,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: BlocProvider(
                  create: (_) => CheckboxCubit(),
                  child: BlocBuilder<CheckboxCubit, Set<String>>(
                    builder: (context, completedSet) {
                      final isChecked =
                          completedSet.contains(widget.activityId);
                      // Allows the user to manually mark the activity as complete.
                      return MarkAsCompleteCheckbox(
                        activityId: widget.activityId,
                        videoTimestamp: formatDuration(watchedDuration.value),
                        totalVideoTime: widget.duration,
                        isChecked: isChecked,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
