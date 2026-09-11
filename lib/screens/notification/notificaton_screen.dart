import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../common/widgets/collection_page.dart';
import 'notification_bloc/notification_bloc.dart';
import 'notification_bloc/notification_event.dart';
import 'notification_bloc/notification_state.dart';

class NotificatonScreen extends StatelessWidget {
  const NotificatonScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => NotificationBloc()..add(FetchNotifications()),
        child: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) => NotificationView(
            state: state,
            onRefresh: () =>
                context.read<NotificationBloc>().add(FetchNotifications()),
          ),
        ),
      );

  String timeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    String elapsed(int count, String unit) =>
        '$count $unit${count == 1 ? '' : 's'} ago';
    if (difference.inDays >= 365) {
      return elapsed(difference.inDays ~/ 365, 'year');
    }
    if (difference.inDays >= 30) {
      return elapsed(difference.inDays ~/ 30, 'month');
    }
    if (difference.inDays >= 1) {
      return elapsed(difference.inDays, 'day');
    }
    if (difference.inHours >= 1) {
      return elapsed(difference.inHours, 'hour');
    }
    if (difference.inMinutes >= 1) {
      return elapsed(difference.inMinutes, 'minute');
    }
    return 'Just now';
  }
}

class NotificationView extends StatelessWidget {
  const NotificationView(
      {super.key, required this.state, required this.onRefresh});
  final NotificationState state;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final current = state;
    return CollectionPage(
      title: 'Notifications',
      description: 'Updates and gentle reminders for your journey.',
      onRefresh: current is NotificationLoading ? null : onRefresh,
      slivers: [
        if (current is NotificationError)
          SliverToBoxAdapter(
              child: CollectionMessage(
            icon: Icons.wifi_off_rounded,
            title: 'Your updates couldn’t load',
            description: 'Please try again in a moment.',
            action: OutlinedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try again')),
          ))
        else if (current is NotificationLoaded)
          if (current.notifications.isEmpty)
            const SliverToBoxAdapter(
                child: CollectionMessage(
              icon: Icons.notifications_none_rounded,
              title: 'You’re all caught up',
              description:
                  'Take a breath. When there’s something new, you’ll find it here.',
            ))
          else
            SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
              final item = current.notifications[index];
              return NotificationItemTile(
                key: ValueKey(item.id),
                user: item.title,
                time: const NotificatonScreen().timeAgo(item.createdAt),
                description: item.description,
              );
            }, childCount: current.notifications.length))
        else
          const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                  child: CircularProgressIndicator(
                      semanticsLabel: 'Loading notifications'))),
      ],
    );
  }
}

class NotificationItemTile extends StatelessWidget {
  final String user, time, description;
  const NotificationItemTile(
      {required this.user,
      required this.time,
      required this.description,
      super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CircleAvatar(
            radius: 20,
            backgroundColor: colors.surface,
            child: Icon(Icons.notifications_outlined,
                size: 20, color: colors.primary)),
        const SizedBox(width: 14),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(user, style: theme.textTheme.titleMedium?.copyWith(height: 1.4)),
          const SizedBox(height: 6),
          Text(time,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: colors.onSurfaceVariant)),
          const SizedBox(height: 12),
          Text(description,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(height: 1.6, color: colors.onSurfaceVariant)),
        ])),
      ]),
    );
  }
}
