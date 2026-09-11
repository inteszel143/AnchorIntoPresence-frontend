import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../common/widgets/collection_page.dart';
import '../../helping_widgets/activityitem_tile.dart';
import '../../utils/share_options.dart';
import '../dashboard/home_dashboard.dart';
import 'getactivity_model.dart';
import 'getactivity_bloc/getrecent_activities_bloc.dart';
import 'getactivity_bloc/getrecent_activities_event.dart';
import 'getactivity_bloc/getrecent_activities_state.dart';

class CategoryCollection extends StatefulWidget {
  const CategoryCollection(
      {super.key, required this.categoryId, this.isPause = false});
  final String categoryId;
  final bool isPause;

  @override
  State<CategoryCollection> createState() => _CategoryCollectionState();
}

class _CategoryCollectionState extends State<CategoryCollection> {
  final _search = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _fetch();
    });
  }

  void _fetch() {
    _debounce?.cancel();
    context.read<ActivityBloc>().add(FetchActivities(
        categoryId: widget.categoryId, search: _search.text.trim()));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CollectionPage(
      title:
          widget.isPause ? 'A moment to pause' : 'Your daily recommendations',
      description: widget.isPause
          ? 'Small reminders to slow down and return to this moment.'
          : 'Make a little room for yourself with a daily practice.',
      onRefresh: _fetch,
      slivers: [
        SliverToBoxAdapter(
            child: Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: TextField(
            controller: _search,
            style: const TextStyle(fontSize: 14),
            onChanged: (_) {
              setState(() {});
              _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 500), _fetch);
            },
            decoration: InputDecoration(
              hintText:
                  widget.isPause ? 'Search moments' : 'Search meditations',
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 44, minHeight: 44),
              suffixIconConstraints:
                  const BoxConstraints(minWidth: 44, minHeight: 44),
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: () {
                        setState(_search.clear);
                        _fetch();
                      }),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
            ),
          ),
        )),
        BlocConsumer<ActivityBloc, ActivityState>(
          listener: (context, state) {
            if (state is ActivityFavouriteLoaded) _fetch();
          },
          buildWhen: (_, state) => state is! ActivityFavouriteLoaded,
          builder: (context, state) {
            if (state is ActivityError) {
              return SliverToBoxAdapter(
                  child: CollectionMessage(
                icon: Icons.wifi_off_rounded,
                title: 'Your collection couldn’t load',
                description: 'Please try again in a moment.',
                action: OutlinedButton.icon(
                    onPressed: _fetch,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Try again')),
              ));
            }
            if (state is! ActivityLoaded) {
              return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                      child: CircularProgressIndicator(
                          semanticsLabel: 'Loading collection')));
            }
            final items = state.activities.activities;
            if (items.isEmpty) {
              final searching = _search.text.trim().isNotEmpty;
              return SliverToBoxAdapter(
                  child: CollectionMessage(
                icon: searching
                    ? Icons.search_off_rounded
                    : Icons.self_improvement_rounded,
                title: searching
                    ? 'No matches just yet'
                    : 'A little calm is on its way',
                description: searching
                    ? 'Try a different word or clear your search.'
                    : 'New moments will appear here when they’re available.',
                action: searching
                    ? OutlinedButton(
                        onPressed: () {
                          setState(_search.clear);
                          _fetch();
                        },
                        child: const Text('Clear search'))
                    : null,
              ));
            }
            return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
              final item = items[index];
              if (widget.isPause) return PauseCollectionCard(activity: item);
              return ActivityItemTile(
                key: ValueKey(item.id),
                collectionStyle: true,
                id: item.id,
                categoryId: widget.categoryId,
                heading: item.name,
                description: item.description,
                tags: item.tags,
                videoUrl: item.video.replaceAll(' ', ''),
                videoDuration: '--:--',
                thumbnail: item.thumbnail,
                isLiked: item.isFavorite,
              );
            }, childCount: items.length));
          },
        ),
      ],
    );
  }
}

class PauseCollectionCard extends StatelessWidget {
  const PauseCollectionCard({super.key, required this.activity});
  final Activity activity;

  Widget _image(BuildContext context) => Image.network(
        HomeDashboard.imageUrl(activity.thumbnail),
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => SizedBox(
            height: 160,
            child: Center(
                child: Text('This image couldn’t load.',
                    style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant)))),
      );

  Future<void> _preview(BuildContext context) => showDialog<void>(
        context: context,
        builder: (context) => _PausePreview(activity: activity),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _preview(context),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            AspectRatio(aspectRatio: 16 / 10, child: _image(context)),
            Padding(
                padding: const EdgeInsets.all(18),
                child: Row(children: [
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(activity.name, style: theme.textTheme.titleMedium),
                        const SizedBox(height: 6),
                        Text('Take a moment',
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                      ])),
                  const SizedBox(width: 12),
                  Icon(Icons.open_in_full_rounded,
                      size: 20, color: theme.colorScheme.onSurfaceVariant),
                ])),
          ]),
        ),
      ),
    );
  }
}

class _PausePreview extends StatefulWidget {
  const _PausePreview({required this.activity});
  final Activity activity;
  @override
  State<_PausePreview> createState() => _PausePreviewState();
}

class _PausePreviewState extends State<_PausePreview> {
  final _imageKey = GlobalKey();
  bool _sharing = false;
  bool _imageReady = false;

  Future<void> _share() async {
    setState(() => _sharing = true);
    ui.Image? image;
    try {
      final boundary =
          _imageKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      image = await boundary.toImage(
          pixelRatio: MediaQuery.devicePixelRatioOf(context));
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final directory = await getTemporaryDirectory();
      final file = File(
          '${directory.path}/pause-${DateTime.now().microsecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes!.buffer.asUint8List());
      if (mounted) {
        ShareUtils.showShareOptionsWithImage(context, XFile(file.path));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Couldn’t share this image. Please try again.')));
      }
    } finally {
      image?.dispose();
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) => Dialog(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
              child: Row(children: [
                Expanded(
                    child: Text(widget.activity.name,
                        style: Theme.of(context).textTheme.titleMedium)),
                IconButton(
                    tooltip: 'Share moment',
                    onPressed: _imageReady && !_sharing ? _share : null,
                    icon: const Icon(Icons.share_outlined)),
                IconButton(
                    tooltip: 'Close preview',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded)),
              ])),
          RepaintBoundary(
              key: _imageKey,
              child: Image.network(
                HomeDashboard.imageUrl(widget.activity.thumbnail),
                fit: BoxFit.contain,
                frameBuilder: (context, child, frame, synchronous) {
                  if (!_imageReady && (frame != null || synchronous)) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _imageReady = true);
                    });
                  }
                  return child;
                },
                errorBuilder: (_, __, ___) => const Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                        'This image couldn’t load. Please try again later.')),
              )),
        ])),
      );
}
