import 'package:flutter/material.dart';
import '../../common/widgets/app_toast.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveTabColor =
        isDark ? colors.surfaceContainerHighest : Colors.white;
    final inactiveTabForeground =
        isDark ? colors.onSurfaceVariant : const Color(0xFF58584F);
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
                  AppToast.show(context, message);
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
                          style: const TextStyle(fontSize: 14),
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Search meditations',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            prefixIconConstraints: const BoxConstraints(
                                minWidth: 44, minHeight: 44),
                            suffixIconConstraints: const BoxConstraints(
                                minWidth: 44, minHeight: 44),
                            prefixIcon:
                                const Icon(Icons.search_rounded, size: 20),
                            suffixIcon: _search.text.isEmpty
                                ? null
                                : IconButton(
                                    tooltip: 'Clear search',
                                    icon: const Icon(Icons.close_rounded,
                                        size: 18),
                                    onPressed: () => setState(_search.clear)),
                            filled: true,
                            fillColor: colors.surfaceContainerHighest,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(children: [
                              ChoiceChip(
                                  avatar: Icon(Icons.self_improvement_rounded,
                                      size: 18,
                                      color: !_favoritesOnly
                                          ? colors.onSecondaryContainer
                                          : inactiveTabForeground),
                                  showCheckmark: false,
                                  shape: const StadiumBorder(),
                                  side: BorderSide.none,
                                  backgroundColor: inactiveTabColor,
                                  selectedColor: colors.secondaryContainer,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  labelStyle: TextStyle(
                                      fontSize: 14,
                                      color: !_favoritesOnly
                                          ? colors.onSecondaryContainer
                                          : inactiveTabForeground),
                                  label: const Text('All practices'),
                                  selected: !_favoritesOnly,
                                  onSelected: (_) =>
                                      setState(() => _favoritesOnly = false)),
                              const SizedBox(width: 8),
                              ChoiceChip(
                                  avatar: Icon(Icons.favorite_border_rounded,
                                      size: 18,
                                      color: _favoritesOnly
                                          ? colors.onSecondaryContainer
                                          : inactiveTabForeground),
                                  showCheckmark: false,
                                  shape: const StadiumBorder(),
                                  side: BorderSide.none,
                                  backgroundColor: inactiveTabColor,
                                  selectedColor: colors.secondaryContainer,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  labelStyle: TextStyle(
                                      fontSize: 14,
                                      color: _favoritesOnly
                                          ? colors.onSecondaryContainer
                                          : inactiveTabForeground),
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
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                        avatar: Icon(_tagIcon(tag),
                                            size: 18,
                                            color: selectedTag == tag
                                                ? colors.onSecondaryContainer
                                                : inactiveTabForeground),
                                        showCheckmark: false,
                                        shape: const StadiumBorder(),
                                        side: BorderSide.none,
                                        backgroundColor: inactiveTabColor,
                                        selectedColor:
                                            colors.secondaryContainer,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        labelStyle: TextStyle(
                                            fontSize: 14,
                                            color: selectedTag == tag
                                                ? colors.onSecondaryContainer
                                                : inactiveTabForeground),
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
