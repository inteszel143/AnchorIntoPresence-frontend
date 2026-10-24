import 'library_practice_card.dart';
import '../activity_listing/getactivity_model.dart';
import 'meditate_loading.dart';
import '../activity_listing/category_collection.dart';
import 'package:mindfully_evolve_app/common/widgets/app_scaffold.dart';
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

/// Browses anchors and pauses with shared category, favorite, and search filters.
class MeditationLibrary extends StatefulWidget {
  const MeditationLibrary({super.key});

  @override
  State<MeditationLibrary> createState() => _MeditationLibraryState();
}

class _MeditationLibraryState extends State<MeditationLibrary> {
  final _search = TextEditingController();
  String _filter = 'All';
  bool _searchOpen = false;
  bool get _favoritesOnly => _filter == 'Favorites';
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
        isDark ? colors.onSurfaceVariant : const Color(0xFF595959);
    return AppScaffold(
      body: ScrollTitlePage(
        title: 'Library',
        child: Center(
            child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(children: [
                const SizedBox(width: 48),
                Expanded(
                    child: Text('Library',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w600))),
                IconButton.filledTonal(
                  tooltip: _searchOpen ? 'Close search' : 'Search Library',
                  onPressed: () => setState(() {
                    _searchOpen = !_searchOpen;
                    if (!_searchOpen) _search.clear();
                  }),
                  icon: Icon(
                      _searchOpen ? Icons.close_rounded : Icons.search_rounded),
                  constraints:
                      const BoxConstraints(minWidth: 48, minHeight: 48),
                ),
              ]),
            ),
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
                        (_filter != 'Daily Anchors' || item.isDailyAnchor) &&
                        (_filter != 'Daily Pauses' || item.isDailyPause) &&
                        (['All', 'Favorites', 'Daily Anchors', 'Daily Pauses']
                                .contains(_filter) ||
                            item.categoryLabel == _filter ||
                            (_filter == 'More practices' &&
                                item.categoryLabel.isEmpty)) &&
                        (selectedTag == null ||
                            item.tags.contains(selectedTag)) &&
                        '${item.name} ${item.description} ${item.categoryLabel} ${item.tags.join(' ')}'
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
                        const SizedBox(height: 8),
                        if (_searchOpen) ...[
                          TextField(
                            controller: _search,
                            autofocus: true,
                            style: const TextStyle(fontSize: 14),
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Search Library',
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
                        ],
                        SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(children: [
                              for (final filter in [
                                'All',
                                'Daily Anchors',
                                'Daily Pauses',
                                'Favorites',
                                if (![
                                  'All',
                                  'Favorites',
                                  'Daily Anchors',
                                  'Daily Pauses'
                                ].contains(_filter))
                                  _filter,
                              ])
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    showCheckmark: false,
                                    shape: const StadiumBorder(),
                                    side: BorderSide.none,
                                    backgroundColor: inactiveTabColor,
                                    selectedColor: colors.secondaryContainer,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    labelStyle: TextStyle(
                                      fontSize: 14,
                                      color: _filter == filter
                                          ? colors.onSecondaryContainer
                                          : inactiveTabForeground,
                                    ),
                                    avatar: Icon(
                                        switch (filter) {
                                          'Daily Anchors' =>
                                            Icons.self_improvement_rounded,
                                          'Daily Pauses' => Icons.spa_outlined,
                                          'Favorites' =>
                                            Icons.favorite_border_rounded,
                                          _ => Icons.grid_view_rounded,
                                        },
                                        size: 18,
                                        color: _filter == filter
                                            ? colors.onSecondaryContainer
                                            : inactiveTabForeground),
                                    label: Text(filter),
                                    selected: _filter == filter,
                                    onSelected: (_) =>
                                        setState(() => _filter = filter),
                                  ),
                                ),
                            ])),
                        if (tags.isNotEmpty &&
                            (_searchOpen ||
                                _filter != 'All' ||
                                _tag != null)) ...[
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
                        const SizedBox(height: 28),
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
                    const SliverPadding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
                      sliver: SliverToBoxAdapter(
                        child: MeditateLoadingSkeleton(),
                      ),
                    )
                  else if (filtered!.isEmpty)
                    SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                            child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                              _favoritesOnly
                                  ? 'No saved practices match your selection.'
                                  : 'No practices match your search.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: colors.onSurfaceVariant)),
                        )))
                  else if (_filter == 'All' &&
                      query.isEmpty &&
                      selectedTag == null)
                    SliverList.list(children: [
                      for (final category
                          in filtered.map((item) => item.categoryLabel).toSet())
                        _collectionRow(
                          context,
                          title: category == 'Daily Anchor'
                              ? 'Daily Anchors'
                              : category == 'Daily Pause'
                                  ? 'Daily Pauses'
                                  : category.isEmpty
                                      ? 'More practices'
                                      : category,
                          items: filtered
                              .where((item) => item.categoryLabel == category)
                              .toList(),
                        ),
                      const SizedBox(height: 24),
                    ])
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      sliver: SliverList(
                          delegate:
                              SliverChildBuilderDelegate((context, index) {
                        final item = filtered[index];
                        if (item.isDailyPause) {
                          return PauseCollectionCard(
                            key: ValueKey(item.id),
                            activity: item,
                            showLibraryActions: true,
                          );
                        }
                        return ActivityItemTile(
                            key: ValueKey(item.id),
                            collectionStyle: true,
                            categoryLabel: item.categoryLabel,
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

  Widget _collectionRow(BuildContext context,
      {required String title, required List<Activity> items}) {
    final width = MediaQuery.sizeOf(context).width.clamp(0.0, 600.0);
    final cardWidth = (width * .43).clamp(152.0, 230.0);
    final scale = MediaQuery.textScalerOf(context).scale(20) / 20;
    final cardHeight = cardWidth * 1.56 + (scale - 1).clamp(0.0, 2.0) * 80;
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            Expanded(
                child: Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w600))),
            TextButton(
              onPressed: () => setState(() => _filter = title),
              child: const Text('View all'),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: cardHeight,
          child: ListView.separated(
            key: PageStorageKey('library-$title'),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (_, index) => SizedBox(
              width: cardWidth,
              child: LibraryPracticeCard(
                  key: ValueKey(items[index].id), activity: items[index]),
            ),
          ),
        ),
      ]),
    );
  }
}
