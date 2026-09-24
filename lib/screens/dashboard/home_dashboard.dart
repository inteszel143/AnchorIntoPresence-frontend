import 'package:flutter/material.dart';
import '../../utils/urls.dart';
import 'dashboard_bloc/home_state.dart';
import 'dashboard_bloc/recently_played_model.dart';
import 'home_model.dart';

/// Home's presentation uses only the user's existing profile and content data.
class HomeDashboard extends StatelessWidget {
  const HomeDashboard(
      {super.key,
      required this.state,
      required this.onProfile,
      required this.onSearch,
      required this.onFavorites,
      required this.onMeditate,
      required this.onRecent,
      required this.onNotifications,
      required this.onActivity,
      required this.onCategory,
      required this.onResume});
  final HomePageLoadedState state;
  final VoidCallback onProfile,
      onSearch,
      onFavorites,
      onMeditate,
      onRecent,
      onNotifications;
  final ValueChanged<ActivityData> onActivity;
  final ValueChanged<String> onCategory;
  final ValueChanged<RecentlyPlayedActivity> onResume;

  static String imageUrl(String path) => Uri.tryParse(path)?.hasScheme == true
      ? path
      : '${Urls.baseUrlimages}$path';

  Widget _image(BuildContext context, String path,
          {double? width, double? height, BoxFit fit = BoxFit.contain}) =>
      Image.network(
        imageUrl(path),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => Container(
            width: width,
            height: height,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Icon(Icons.self_improvement_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
      );

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final name = state.profileData.name.trim();
    final firstName = name.isEmpty || name.contains('@')
        ? 'there'
        : name.split(RegExp(r'\s+')).first;
    final anchors =
        state.homePageData.data['Daily Anchor']?.activities ?? <ActivityData>[];
    final pauses =
        state.homePageData.data['Daily Pause']?.activities ?? <ActivityData>[];
    final recentItems = state.recentlyPlayedData;
    Widget heading(String title, VoidCallback onSeeAll) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 12, 16),
          child: Row(children: [
            Expanded(
                child: Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w600))),
            TextButton(onPressed: onSeeAll, child: const Text('See all')),
          ]),
        );
    Widget activityCard({
      required String thumbnail,
      required String category,
      required String title,
      required String subtitle,
      required VoidCallback onTap,
      int subtitleMaxLines = 1,
    }) {
      return SizedBox(
          width: 190,
          child: Material(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(24),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
                onTap: onTap,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(children: [
                      _image(context, thumbnail, width: 190, height: 156),
                      Positioned(
                        top: 12,
                        left: 12,
                        right: 12,
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                  color: colors.surface.withValues(alpha: .94),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Text(category,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: colors.onSurface,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700)),
                            )),
                      ),
                    ]),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
                        child: Text(title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(height: 1.4))),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text(subtitle,
                            maxLines: subtitleMaxLines,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: colors.onSurfaceVariant, fontSize: 12))),
                  ],
                )),
          ));
    }

    Widget rail(List<ActivityData> items) => SizedBox(
          height: 270 + (MediaQuery.textScalerOf(context).scale(14) - 14) * 4,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final item = items[index];
              return activityCard(
                thumbnail: item.thumbnail,
                category: item.categoryName,
                title: item.name,
                subtitle: item.tagName?.join(' · ') ?? '',
                onTap: () => onActivity(item),
              );
            },
          ),
        );
    return Center(
        child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 680),
      child: ListView(
        padding: const EdgeInsets.only(top: 20, bottom: 32),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: LayoutBuilder(builder: (context, constraints) {
              final greeting = Text('Hi,\n$firstName!',
                  style: Theme.of(context)
                      .textTheme
                      .headlineLarge
                      ?.copyWith(fontWeight: FontWeight.w600, height: 1.2));
              final actions = Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton.filledTonal(
                    tooltip: 'Search meditations',
                    style: IconButton.styleFrom(
                        foregroundColor: colors.onSurface,
                        backgroundColor: colors.surfaceContainerHighest),
                    onPressed: onSearch,
                    icon: const Icon(Icons.search_rounded)),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                    tooltip: 'Notifications',
                    style: IconButton.styleFrom(
                        foregroundColor: colors.onSurface,
                        backgroundColor: colors.surfaceContainerHighest),
                    onPressed: onNotifications,
                    icon: const Icon(Icons.notifications_none_rounded)),
                const SizedBox(width: 8),
                Semantics(
                    button: true,
                    label: 'Open profile',
                    child: InkWell(
                      onTap: onProfile,
                      customBorder: const CircleBorder(),
                      child: ClipOval(
                          child: SizedBox.square(
                        dimension: 48,
                        child: state.profileData.image?.isNotEmpty == true
                            ? _image(context, state.profileData.image!,
                                width: 48, height: 48, fit: BoxFit.cover)
                            : ColoredBox(
                                color: colors.surfaceContainerHighest,
                                child: Icon(Icons.person_rounded,
                                    color: colors.primary)),
                      )),
                    )),
              ]);
              if (constraints.maxWidth < 360 ||
                  MediaQuery.textScalerOf(context).scale(16) > 20) {
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [greeting, const SizedBox(height: 12), actions]);
              }
              return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Expanded(child: greeting), actions]);
            }),
          ),
          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              for (final item in [
                (Icons.favorite_border_rounded, 'Favorites', onFavorites),
                (Icons.self_improvement_rounded, 'Meditate', onMeditate),
                (Icons.history_rounded, 'Recently played', onRecent),
              ]) ...[
                ActionChip(
                    avatar: Icon(item.$1, size: 18),
                    label: Text(item.$2),
                    onPressed: item.$3,
                    backgroundColor: colors.surfaceContainerHighest,
                    shape: const StadiumBorder(),
                    side: BorderSide.none,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                const SizedBox(width: 10),
              ],
            ]),
          ),
          const SizedBox(height: 24),
          if (anchors.isNotEmpty) ...[
            heading(
                'Your daily recommendations', () => onCategory('Daily Anchor')),
            rail(anchors),
            const SizedBox(height: 28),
          ],
          if (pauses.isNotEmpty) ...[
            heading('A moment to pause', () => onCategory('Daily Pause')),
            rail(pauses),
          ],
          if (recentItems.isNotEmpty) ...[
            if (pauses.isNotEmpty) const SizedBox(height: 28),
            heading('Continue your journey', onRecent),
            SizedBox(
              height:
                  270 + (MediaQuery.textScalerOf(context).scale(14) - 14) * 4,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: recentItems.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final recent = recentItems[index];
                  return activityCard(
                    thumbnail: recent.thumbnail,
                    category: recent.category?.name ?? 'Meditation',
                    title: recent.name,
                    subtitle: recent.isCompleted
                        ? 'Completed · Practice again'
                        : 'Last played ${recent.videoTimestamp}',
                    onTap: () => onResume(recent),
                    subtitleMaxLines: 2,
                  );
                },
              ),
            ),
            const SizedBox(height: 28),
          ],
          if (anchors.isEmpty && pauses.isEmpty)
            Padding(
                padding: const EdgeInsets.all(20),
                child: Text('Your daily practices will appear here.',
                    style: TextStyle(color: colors.onSurfaceVariant))),
        ],
      ),
    ));
  }
}
