import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../common/widgets/scroll_title_page.dart';
import '../../helping_widgets/activityitem_tile.dart';
import '../activity_listing/getactivity_bloc/getrecent_activities_bloc.dart';
import '../activity_listing/getactivity_bloc/getrecent_activities_event.dart';
import '../activity_listing/getactivity_bloc/getrecent_activities_state.dart';

class MeditateScreen extends StatelessWidget {
  const MeditateScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => ActivityBloc()..add(FetchActivities(useCache: true)),
        child: const MeditationLibrary(),
      );
}

/// Browses the existing meditation collection without a separate content API.
class MeditationLibrary extends StatefulWidget {
  const MeditationLibrary({super.key});

  @override
  State<MeditationLibrary> createState() => _MeditationLibraryState();
}

class _MeditationLibraryState extends State<MeditationLibrary> {
  final _search = TextEditingController();
  bool _favoritesOnly = false;
  String? _tag;

  IconData _tagIcon(String tag) {
    final name = tag.toLowerCase();
    if (name.contains('sleep') || name.contains('rest')) {
      return Icons.bedtime_outlined;
    }
    if (name.contains('breath')) return Icons.air_rounded;
    if (name.contains('calm') || name.contains('relax')) {
      return Icons.spa_outlined;
    }
    if (name.contains('focus')) return Icons.center_focus_strong_rounded;
    return Icons.self_improvement_rounded;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: ScrollTitlePage(
        title: 'Meditate',
        child: Center(
            child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(children: [
            Builder(
                builder: (context) => ValueListenableBuilder<bool>(
                      valueListenable: ScrollTitlePage.visibilityOf(context)!,
                      builder: (context, visible, _) => SizedBox(
                        height: 56,
                        child: Center(
                            child: ExcludeSemantics(
                          excluding: !visible,
                          child: AnimatedOpacity(
                            opacity: visible ? 1 : 0,
                            duration: const Duration(milliseconds: 180),
                            child: Text('Meditate',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w700)),
                          ),
                        )),
                      ),
                    )),
            Expanded(
                child: BlocConsumer<ActivityBloc, ActivityState>(
              listener: (context, state) {
                if (state is ActivityFavouriteLoaded) {
                  final message = switch (state.message.trim().toLowerCase()) {
                    'added to favorite' => 'Added to Favorites.',
                    'removed from favorite' => 'Removed from Favorites.',
                    _ => state.message.trim().isEmpty
                        ? 'Favorites updated.'
                        : state.message,
                  };
                  final width = MediaQuery.sizeOf(context).width;
                  final horizontalMargin =
                      width > 348 ? (width - 300) / 2 : 24.0;
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 3),
                      backgroundColor: const Color(0xFF4B503D),
                      elevation: 6,
                      margin: EdgeInsets.fromLTRB(
                          horizontalMargin, 0, horizontalMargin, 24),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: Color(0xFF747A62)),
                      ),
                      content: Row(children: [
                        const Icon(Icons.check_circle_outline_rounded,
                            color: Colors.white, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Text(message,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    height: 1.4))),
                      ]),
                    ));
                  context
                      .read<ActivityBloc>()
                      .add(FetchActivities(useCache: true));
                }
              },
              buildWhen: (_, state) => state is! ActivityFavouriteLoaded,
              builder: (context, state) {
                final all = state is ActivityLoaded
                    ? state.activities.activities
                    : null;
                final tags =
                    all?.expand((item) => item.tags).toSet().toList() ??
                        <String>[];
                tags.sort();
                final selectedTag = tags.contains(_tag) ? _tag : null;
                final query = _search.text.trim().toLowerCase();
                final filtered = all
                    ?.where((item) =>
                        (!_favoritesOnly || item.isFavorite) &&
                        (selectedTag == null ||
                            item.tags.contains(selectedTag)) &&
                        '${item.name} ${item.description} ${item.tags.join(' ')}'
                            .toLowerCase()
                            .contains(query))
                    .toList();
                return CustomScrollView(slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverToBoxAdapter(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text('Meditate',
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Text('Find a little space to return to yourself.',
                            style: TextStyle(
                                color: colors.onSurfaceVariant,
                                fontSize: 15,
                                height: 1.5)),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _search,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Search meditations',
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: _search.text.isEmpty
                                ? null
                                : IconButton(
                                    tooltip: 'Clear search',
                                    icon: const Icon(Icons.close_rounded),
                                    onPressed: () => setState(_search.clear)),
                            filled: true,
                            fillColor: colors.surfaceContainerHighest,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(children: [
                              ChoiceChip(
                                  avatar: const Icon(
                                      Icons.self_improvement_rounded,
                                      size: 22),
                                  showCheckmark: false,
                                  shape: const StadiumBorder(),
                                  side: BorderSide.none,
                                  backgroundColor: colors.surface,
                                  selectedColor: colors.secondaryContainer,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  labelStyle: TextStyle(
                                      fontSize: 16,
                                      color: !_favoritesOnly
                                          ? colors.onSecondaryContainer
                                          : colors.onSurfaceVariant),
                                  label: const Text('All practices'),
                                  selected: !_favoritesOnly,
                                  onSelected: (_) =>
                                      setState(() => _favoritesOnly = false)),
                              const SizedBox(width: 12),
                              ChoiceChip(
                                  avatar: const Icon(
                                      Icons.favorite_border_rounded,
                                      size: 22),
                                  showCheckmark: false,
                                  shape: const StadiumBorder(),
                                  side: BorderSide.none,
                                  backgroundColor: colors.surface,
                                  selectedColor: colors.secondaryContainer,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  labelStyle: TextStyle(
                                      fontSize: 16,
                                      color: _favoritesOnly
                                          ? colors.onSecondaryContainer
                                          : colors.onSurfaceVariant),
                                  label: const Text('Favorites'),
                                  selected: _favoritesOnly,
                                  onSelected: (_) =>
                                      setState(() => _favoritesOnly = true)),
                            ])),
                        if (tags.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(children: [
                              for (final tag in tags)
                                Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: FilterChip(
                                        avatar: Icon(_tagIcon(tag), size: 20),
                                        showCheckmark: false,
                                        shape: const StadiumBorder(),
                                        side: BorderSide.none,
                                        backgroundColor: colors.surface,
                                        selectedColor:
                                            colors.secondaryContainer,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 12),
                                        labelStyle: TextStyle(
                                            fontSize: 15,
                                            color: selectedTag == tag
                                                ? colors.onSecondaryContainer
                                                : colors.onSurfaceVariant),
                                        label: Text(tag),
                                        selected: selectedTag == tag,
                                        onSelected: (selected) => setState(() =>
                                            _tag = selected ? tag : null))),
                            ]),
                          ),
                        ],
                        const SizedBox(height: 20),
                      ],
                    )),
                  ),
                  if (state is ActivityError)
                    SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                            child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Your practices couldn’t load.'),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                                onPressed: () => context
                                    .read<ActivityBloc>()
                                    .add(FetchActivities()),
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Try again')),
                          ],
                        )))
                  else if (all == null)
                    const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: CircularProgressIndicator()))
                  else if (filtered!.isEmpty)
                    SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                            child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                              _favoritesOnly
                                  ? 'No saved practices match your selection.'
                                  : 'No meditations match your search.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: colors.onSurfaceVariant)),
                        )))
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      sliver: SliverList(
                          delegate:
                              SliverChildBuilderDelegate((context, index) {
                        final item = filtered[index];
                        return ActivityItemTile(
                            key: ValueKey(item.id),
                            collectionStyle: true,
                            videoUrl: item.video.replaceAll(' ', ''),
                            videoDuration: '--:--',
                            heading: item.name,
                            description: item.description,
                            tags: item.tags,
                            id: item.id,
                            thumbnail: item.thumbnail,
                            isLiked: item.isFavorite);
                      }, childCount: filtered.length)),
                    ),
                ]);
              },
            )),
          ]),
        )),
      ),
    );
  }
}
