import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import '../../utils/urls.dart';
import 'dashboard_bloc/home_state.dart';
import 'dashboard_bloc/recently_played_model.dart';
import 'home_model.dart';
import 'home_loading.dart';

/// Home's presentation uses only the user's existing profile and content data.
class HomeDashboard extends StatelessWidget {
  const HomeDashboard(
      {super.key,
      required this.state,
      required this.onProfile,
      required this.onSearch,
      required this.onRecent,
      required this.onNotifications,
      required this.onActivity,
      required this.onCategory,
      required this.onResume});
  final HomePageLoadedState state;
  final VoidCallback onProfile, onSearch, onRecent, onNotifications;
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
    final recentItems = state.recentlyPlayedData
        .where((item) => item.canContinueListening)
        .toList();
    Widget heading(String title, VoidCallback onSeeAll,
            {String? description}) =>
        Padding(
          padding:
              EdgeInsets.fromLTRB(20, 0, 12, description == null ? 16 : 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: Text(title,
                      style: (description == null
                              ? Theme.of(context).textTheme.titleLarge
                              : Theme.of(context).textTheme.titleMedium)
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ),
                TextButton(onPressed: onSeeAll, child: const Text('See all')),
              ]),
              if (description != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant, height: 1.4)),
                ),
            ],
          ),
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

    Widget pauseContent(ActivityData item) {
      final name = item.name.trim();
      final title = {'daily pause', 'daily pauses'}.contains(name.toLowerCase())
          ? 'Carry this with you.'
          : name;
      final showTitle = title.isNotEmpty;
      final showTags = item.tagName?.isNotEmpty == true;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _image(context, item.thumbnail),
              ),
            ),
          ),
          if (showTitle || showTags)
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showTitle)
                    Text(title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                fontWeight: FontWeight.w600, height: 1.35)),
                  if (showTitle && showTags) const SizedBox(height: 8),
                  if (showTags)
                    Text(item.tagName!.join(' · '),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant, height: 1.4)),
                ],
              ),
            ),
        ],
      );
    }

    Widget practiceCard(List<ActivityData> items, {required bool anchor}) {
      final category = anchor ? 'Daily Anchor' : 'Daily Pause';
      final tint = Color.alphaBlend(
          colors.primaryContainer.withValues(alpha: anchor ? .18 : .07),
          colors.surface);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                  anchor
                      ? Icons.self_improvement_rounded
                      : Icons.wb_sunny_outlined,
                  size: 18,
                  color: colors.onPrimaryContainer),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(category,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
            ),
            TextButton(
              onPressed: () => onCategory(category),
              child: const Text('See all'),
            ),
          ]),
          const SizedBox(height: 4),
          Text(
            anchor
                ? "Today's guided meditation"
                : 'A gentle reminder to carry with you.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: colors.onSurfaceVariant, height: 1.5),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(builder: (context, constraints) {
            final stacked = constraints.maxWidth < 260 ||
                MediaQuery.textScalerOf(context).scale(16) > 24;
            return _PracticeScroll(
              showIndicator: items.length > 1,
              category: category,
              itemCount: items.length,
              pageExtent: constraints.maxWidth + 12,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var index = 0; index < items.length; index++) ...[
                    if (index > 0) const SizedBox(width: 12),
                    SizedBox(
                      width: constraints.maxWidth,
                      child: Material(
                        color: anchor ? tint : Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: anchor
                              ? BorderSide(color: colors.outlineVariant)
                              : BorderSide.none,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => onActivity(items[index]),
                          child: !anchor
                              ? pauseContent(items[index])
                              : Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Flex(
                                    direction: stacked
                                        ? Axis.vertical
                                        : Axis.horizontal,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child: _image(
                                            context, items[index].thumbnail,
                                            width: stacked
                                                ? constraints.maxWidth - 28
                                                : 80,
                                            height: stacked ? 120 : 96,
                                            fit: BoxFit.cover),
                                      ),
                                      SizedBox(
                                          width: stacked ? 0 : 14,
                                          height: stacked ? 14 : 0),
                                      Flexible(
                                        flex: stacked ? 0 : 1,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(items[index].name,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        height: 1.35)),
                                            if (items[index]
                                                    .tagName
                                                    ?.isNotEmpty ==
                                                true) ...[
                                              const SizedBox(height: 6),
                                              Text(
                                                  items[index]
                                                      .tagName!
                                                      .join(' · '),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                          color: colors
                                                              .onSurfaceVariant)),
                                            ],
                                            const SizedBox(height: 14),
                                            Row(children: [
                                              if (anchor) ...[
                                                Icon(
                                                    Icons
                                                        .play_circle_filled_rounded,
                                                    size: 24,
                                                    color: colors.primary),
                                                const SizedBox(width: 8),
                                              ],
                                              Expanded(
                                                child: Text(
                                                    anchor
                                                        ? 'Begin practice'
                                                        : 'Take a pause',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .labelLarge
                                                        ?.copyWith(
                                                            color: colors
                                                                .primary)),
                                              ),
                                            ]),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      );
    }

    return Center(
        child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 680),
      child: ListView(
        padding: const EdgeInsets.only(top: 20, bottom: 32),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: LayoutBuilder(builder: (context, constraints) {
              final compact = constraints.maxWidth < 360;
              final greetingStyle = (compact
                      ? Theme.of(context).textTheme.headlineMedium
                      : Theme.of(context).textTheme.headlineLarge)
                  ?.copyWith(fontWeight: FontWeight.w600, height: 1.2);
              final greeting = Semantics(
                label: 'Hi, $firstName!',
                excludeSemantics: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hi,', style: greetingStyle),
                    Text('$firstName!',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: greetingStyle),
                  ],
                ),
              );
              final actions = Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton.filledTonal(
                    tooltip: 'Search Library',
                    style: IconButton.styleFrom(
                        foregroundColor: colors.onSurface,
                        backgroundColor: colors.surfaceContainerHighest),
                    onPressed: onSearch,
                    icon: const Icon(Icons.search_rounded)),
                SizedBox(width: compact ? 4 : 8),
                IconButton.filledTonal(
                    tooltip: 'Notifications',
                    style: IconButton.styleFrom(
                        foregroundColor: colors.onSurface,
                        backgroundColor: colors.surfaceContainerHighest),
                    onPressed: onNotifications,
                    icon: const Icon(Icons.notifications_none_rounded)),
                SizedBox(width: compact ? 4 : 8),
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
              return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: greeting),
                    const SizedBox(width: 12),
                    actions,
                  ]);
            }),
          ),
          const SizedBox(height: 24),
          Semantics(
            container: true,
            child: Container(
              key: const ValueKey('daily-ritual'),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your Practice Today',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text('Begin with what feels true for you.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant, height: 1.5)),
                  const SizedBox(height: 20),
                  if (anchors.isNotEmpty) practiceCard(anchors, anchor: true),
                  if (anchors.isNotEmpty && pauses.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Divider(height: 1, color: colors.outlineVariant),
                    ),
                  if (pauses.isNotEmpty) practiceCard(pauses, anchor: false),
                  if (anchors.isEmpty && pauses.isEmpty)
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                            'Today’s practices haven’t been posted yet.',
                            style: TextStyle(color: colors.onSurfaceVariant))),
                ],
              ),
            ),
          ),
          if (recentItems.isNotEmpty) ...[
            const SizedBox(height: 32),
            heading('Continue Listening', onRecent),
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
                    subtitle: 'Last played ${recent.videoTimestamp}',
                    onTap: () => onResume(recent),
                    subtitleMaxLines: 2,
                  );
                },
              ),
            ),
            const SizedBox(height: 28),
          ],
        ].asMap().entries.map((entry) {
          final child = entry.value;
          if (child is SizedBox && child.child == null) return child;
          return HomeSectionEntrance(
            key: ValueKey('home-section-${entry.key}'),
            order: entry.key ~/ 2,
            child: child,
          );
        }).toList(),
      ),
    ));
  }
}

class _PracticeScroll extends StatefulWidget {
  const _PracticeScroll({
    required this.showIndicator,
    required this.category,
    required this.itemCount,
    required this.pageExtent,
    required this.child,
  });

  final bool showIndicator;
  final String category;
  final int itemCount;
  final double pageExtent;
  final Widget child;

  @override
  State<_PracticeScroll> createState() => _PracticeScrollState();
}

class _PracticeScrollState extends State<_PracticeScroll> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scrollView = SingleChildScrollView(
      controller: _controller,
      scrollDirection: Axis.horizontal,
      physics: widget.showIndicator
          ? _PracticePagePhysics(pageExtent: widget.pageExtent)
          : null,
      child: widget.child,
    );
    if (!widget.showIndicator) return scrollView;

    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        scrollView,
        const SizedBox(height: 12),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final extent = _controller.hasClients &&
                    _controller.position.hasContentDimensions
                ? _controller.position.maxScrollExtent
                : 0.0;
            final active = extent > 0
                ? ((_controller.offset / extent) * (widget.itemCount - 1))
                    .round()
                    .clamp(0, widget.itemCount - 1)
                : 0;
            return Semantics(
              key: ValueKey(
                  '${widget.category.toLowerCase().replaceAll(' ', '-')}-scroll-indicator'),
              label: '${widget.category} ${active + 1} of ${widget.itemCount}',
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (var index = 0; index < widget.itemCount; index++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == active
                            ? colors.primary
                            : colors.outlineVariant,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Snap full-width practice cards while preserving their natural content height.
class _PracticePagePhysics extends ScrollPhysics {
  const _PracticePagePhysics({required this.pageExtent, super.parent});

  final double pageExtent;

  @override
  _PracticePagePhysics applyTo(ScrollPhysics? ancestor) =>
      _PracticePagePhysics(
          pageExtent: pageExtent, parent: buildParent(ancestor));

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    if ((velocity <= 0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    final tolerance = toleranceFor(position);
    var page = position.pixels / pageExtent;
    if (velocity < -tolerance.velocity) {
      page -= 0.5;
    } else if (velocity > tolerance.velocity) {
      page += 0.5;
    }
    final target = (page.round() * pageExtent)
        .clamp(position.minScrollExtent, position.maxScrollExtent)
        .toDouble();
    if (target == position.pixels) return null;
    return ScrollSpringSimulation(spring, position.pixels, target, velocity,
        tolerance: tolerance);
  }

  @override
  bool get allowImplicitScrolling => false;
}
