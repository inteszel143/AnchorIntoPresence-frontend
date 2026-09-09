import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

import '../screens/activity_details/activity_bloc/post_activity_bloc.dart';
import '../screens/activity_details/activity_details.dart';
import '../screens/activity_listing/getactivity_bloc/getrecent_activities_bloc.dart';
import '../screens/activity_listing/getactivity_bloc/getrecent_activities_event.dart';
import '../utils/color_constants.dart';
import '../utils/fonts.dart';
import '../utils/image_constants.dart';
import '../utils/urls.dart';

class ActivityItemTile extends StatefulWidget {
  final String videoUrl;
  final String videoDuration;
  final bool isLiked;
  final String heading;
  final List<String> tags;
  final String description;
  final String id;
  final String thumbnail;
  final String? categoryId;
  final bool collectionStyle;

  const ActivityItemTile({
    super.key,
    required this.videoUrl,
    required this.videoDuration,
    this.isLiked = false,
    required this.heading,
    required this.tags,
    required this.description,
    required this.id,
    required this.thumbnail,
    this.categoryId,
    this.collectionStyle = false,
  });

  @override
  _ActivityItemTileState createState() => _ActivityItemTileState();
}

class _ActivityItemTileState extends State<ActivityItemTile> {
  late bool isLiked;
  late Future<Uint8List?> _thumbnailFuture;
  late Future<String> _durationFuture;

  @override
  void initState() {
    super.initState();
    isLiked = widget.isLiked;
    _thumbnailFuture =
        _fetchThumbnail('${Urls.baseUrlimages}${widget.thumbnail}');
    _durationFuture = _getVideoDuration(widget.videoUrl);
  }

  @override
  void didUpdateWidget(covariant ActivityItemTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    isLiked = widget.isLiked;
    if (oldWidget.thumbnail != widget.thumbnail) {
      _thumbnailFuture =
          _fetchThumbnail('${Urls.baseUrlimages}${widget.thumbnail}');
    }
    if (oldWidget.videoUrl != widget.videoUrl) {
      _durationFuture = _getVideoDuration(widget.videoUrl);
    }
  }

  Widget _collectionCard(
      AsyncSnapshot<Uint8List?> thumbnail, AsyncSnapshot<String> duration) {
    final colors = Theme.of(context).colorScheme;
    final ready = thumbnail.connectionState == ConnectionState.done &&
        duration.connectionState == ConnectionState.done;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .35)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: AspectRatio(
            aspectRatio: 16 / 8,
            child: Stack(fit: StackFit.expand, children: [
              ColoredBox(
                color: colors.surface,
                child: thumbnail.data != null
                    ? Image.memory(thumbnail.data!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(Icons.spa_outlined,
                            size: 40, color: colors.onSurfaceVariant))
                    : Center(
                        child: thumbnail.connectionState == ConnectionState.done
                            ? Icon(Icons.spa_outlined,
                                size: 40, color: colors.onSurfaceVariant)
                            : const CircularProgressIndicator(strokeWidth: 2)),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton.filledTonal(
                  tooltip:
                      isLiked ? 'Remove from favorites' : 'Save meditation',
                  style: IconButton.styleFrom(
                      backgroundColor: colors.surfaceContainerHighest),
                  onPressed: () {
                    // Wait for the list refresh after the server confirms the change.
                    context
                        .read<ActivityBloc>()
                        .add(ToggleFavorite(activityId: widget.id));
                  },
                  icon: Icon(
                      isLiked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: isLiked ? Colors.red : colors.onSurfaceVariant),
                ),
              ),
              Positioned(
                left: 10,
                bottom: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: .65),
                      borderRadius: BorderRadius.circular(20)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.play_arrow_rounded,
                        color: Colors.white, size: 17),
                    const SizedBox(width: 4),
                    Text(ready ? duration.data ?? '--:--' : 'Loading…',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12)),
                  ]),
                ),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        Text(widget.heading,
            style: TextStyle(
                fontFamily: Fonts.heading,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colors.onSurface)),
        const SizedBox(height: 7),
        Text(widget.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 13, height: 1.5, color: colors.onSurfaceVariant)),
        if (widget.tags.isNotEmpty) ...[
          const SizedBox(height: 14),
          Wrap(spacing: 6, runSpacing: 6, children: [
            for (final tag in widget.tags.take(3))
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(20)),
                child: Text(tag,
                    style: TextStyle(
                        fontSize: 11, color: colors.onSurfaceVariant)),
              ),
          ]),
        ],
      ]),
    );
  }

  Future<Uint8List?> _fetchThumbnail(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<String> _getVideoDuration(String url) async {
    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(url));
      await controller.initialize();
      final duration = controller.value.duration;
      controller.dispose();
      final minutes =
          duration.inMinutes.remainder(60).toString().padLeft(2, '0');
      final seconds =
          duration.inSeconds.remainder(60).toString().padLeft(2, '0');
      return '$minutes:$seconds';
    } catch (e) {
      return "--:--";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.collectionStyle
          ? const EdgeInsets.only(bottom: 16)
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: FutureBuilder<Uint8List?>(
        future: _thumbnailFuture,
        builder: (context, snapshotThumb) {
          return FutureBuilder<String>(
            future: _durationFuture,
            builder: (context, snapshotDuration) {
              final isThumbReady =
                  snapshotThumb.connectionState == ConnectionState.done;
              final isDurationReady =
                  snapshotDuration.connectionState == ConnectionState.done;

              if (snapshotThumb.hasError || snapshotDuration.hasError) {
                return const Center(child: Text('Error loading data.'));
              }

              return GestureDetector(
                onTap: () async {
                  if (isThumbReady && isDurationReady) {
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider(
                          create: (_) => PostActivityBloc(),
                          child: ActivityDetailScreen(
                            videoUrl: widget.videoUrl,
                            thumbnail: snapshotThumb.data ?? Uint8List(0),
                            name: widget.heading,
                            duration: snapshotDuration.data ?? "--:--",
                            tags: widget.tags,
                            description: widget.description,
                            activityId: widget.id,
                            isFavorite: isLiked,
                          ),
                        ),
                      ),
                    );
                    if (result == true && context.mounted) {
                      // This tile is reused on screens (e.g. Recently
                      // Played) that don't provide an ActivityBloc above
                      // them, so guard the refresh instead of crashing.
                      try {
                        context.read<ActivityBloc>().add(FetchActivities(
                            categoryId: widget.categoryId,
                            useCache: widget.collectionStyle));
                      } catch (e) {}
                    }
                  }
                },
                child: widget.collectionStyle
                    ? _collectionCard(snapshotThumb, snapshotDuration)
                    : Container(
                        decoration: BoxDecoration(
                          color: ColorCodes.whitecolor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: ColorCodes.searchboxcolor),
                        ),
                        padding: const EdgeInsets.all(5),
                        child: Stack(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Thumbnail
                                Container(
                                  width: 120,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: ColorCodes.black12color,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        // Show thumbnail if available, otherwise fallback
                                        if (isThumbReady &&
                                            snapshotThumb.data != null)
                                          Image.memory(snapshotThumb.data!,
                                              fit: BoxFit.cover)
                                        else
                                          const Center(
                                              child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: ColorCodes.buttoncolor,
                                          )),

                                        Positioned(
                                          top: 5,
                                          right: 5,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                isLiked = !isLiked;
                                              });

                                              try {
                                                BlocProvider.of<ActivityBloc>(
                                                        context)
                                                    .add(
                                                  ToggleFavorite(
                                                      activityId: widget.id),
                                                );
                                              } catch (e) {}
                                            },
                                            child: SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: SvgPicture.asset(
                                                isLiked
                                                    ? ImageConstants
                                                        .svgRedLikeIcon
                                                    : ImageConstants
                                                        .svgWhiteLikeIcon,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Duration
                                        Positioned(
                                          bottom: 5,
                                          left: 5,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: ColorCodes.black54color
                                                  .withValues(alpha: 0.6),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              isDurationReady
                                                  ? snapshotDuration.data!
                                                  : "--:--",
                                              style: const TextStyle(
                                                color: ColorCodes.whitecolor,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Text Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.heading,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          letterSpacing:
                                              Fonts.headingLetterSpacing,
                                          fontFamily: Fonts.heading,
                                          color: ColorCodes.mainheadingcolor,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      const SizedBox(height: 8),
                                      Text(
                                        widget.description,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: Fonts.body,
                                          color: ColorCodes.descriptioncolor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
              );
            },
          );
        },
      ),
    );
  }
}
