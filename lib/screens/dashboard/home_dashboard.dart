import 'package:flutter/material.dart';
import '../../utils/urls.dart';
import 'dashboard_bloc/home_state.dart';
import 'dashboard_bloc/recently_played_model.dart';
import 'home_model.dart';
import 'mood_picker.dart';

/// Home's presentation uses only the user's existing profile and content data.
class HomeDashboard extends StatelessWidget {
  const HomeDashboard(
      {super.key,
      required this.state,
      required this.onProfile,
      required this.onSearch,
      required this.onMood,
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
      onMood,
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
    final mood = moodOptionFor(state.profileData.userMood);
    final name = state.profileData.name.trim();
    final firstName = name.isEmpty || name.contains('@')
        ? 'there'
        : name.split(RegExp(r'\s+')).first;
    final anchors =
        state.homePageData.data['Daily Anchor']?.activities ?? <ActivityData>[];
    final pauses =
        state.homePageData.data['Daily Pause']?.activities ?? <ActivityData>[];
    final recent = state.recentlyPlayedData.firstOrNull;
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
    Widget rail(List<ActivityData> items) => SizedBox(
          height: 270 + (MediaQuery.textScalerOf(context).scale(14) - 14) * 4,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final item = items[index];
              return SizedBox(
                  width: 190,
                  child: Material(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(24),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                        onTap: () => onActivity(item),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(children: [
                              _image(context, item.thumbnail,
                                  width: 190, height: 156),
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
                                          color: colors.surface
                                              .withValues(alpha: .94),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Text(item.categoryName,
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
                                padding:
                                    const EdgeInsets.fromLTRB(14, 14, 14, 4),
                                child: Text(item.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(height: 1.4))),
                            Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 14),
                                child: Text(item.tagName?.join(' · ') ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: colors.onSurfaceVariant,
                                        fontSize: 12))),
                          ],
                        )),
                  ));
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
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                  child: Text('Hi,\n$firstName!',
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(
                              fontWeight: FontWeight.w600, height: 1.2))),
              IconButton.filledTonal(
                  tooltip: 'Search meditations',
                  style: IconButton.styleFrom(
                      backgroundColor: colors.surfaceContainerHighest),
                  onPressed: onSearch,
                  icon: const Icon(Icons.search_rounded)),
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
            ]),
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Material(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF3D3031)
                  : const Color(0xFFF6E9E7),
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                onTap: onMood,
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(children: [
                      CircleAvatar(
                          backgroundColor: colors.surface.withValues(alpha: .7),
                          child: mood == null
                              ? Icon(Icons.sentiment_satisfied_alt_rounded,
                                  color: colors.onSurface)
                              : Text(mood.$2,
                                  semanticsLabel: 'Current mood: ${mood.$1}',
                                  style: const TextStyle(fontSize: 26))),
                      const SizedBox(width: 14),
                      Expanded(
                          child: Text('How are you feeling today?',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(height: 1.4))),
                      const Icon(Icons.chevron_right_rounded),
                    ])),
              ),
            ),
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
                (
                  Icons.notifications_none_rounded,
                  'Notifications',
                  onNotifications
                )
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
          if (recent != null) ...[
            heading('Continue your journey', onRecent),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Material(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(24),
                child: InkWell(
                  onTap: () => onResume(recent),
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: _image(context, recent.thumbnail,
                                width: 96, height: 116)),
                        const SizedBox(width: 16),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(recent.category?.name ?? 'Meditation',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: colors.onSurfaceVariant)),
                              const SizedBox(height: 8),
                              Text(recent.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 8),
                              Text(
                                  recent.isCompleted
                                      ? 'Completed · Practice again'
                                      : 'Last played ${recent.videoTimestamp}',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: colors.onSurfaceVariant)),
                            ])),
                        const Icon(Icons.chevron_right_rounded, size: 20),
                      ])),
                ),
              ),
            ),
            const SizedBox(height: 28),
          ],
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
