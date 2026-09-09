import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindfully_evolve_app/utils/string_constants.dart';

import '../../common/widgets/custom_appbar.dart';
import '../../utils/color_constants.dart';
import '../../utils/fonts.dart';
import 'notification_bloc/notification_bloc.dart';
import 'notification_bloc/notification_event.dart';
import 'notification_bloc/notification_state.dart';

class NotificatonScreen extends StatelessWidget {
  const NotificatonScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorCodes.backgroundcolor,
      body: SafeArea(
        child: BlocProvider(
          create: (_) => NotificationBloc()..add(FetchNotifications()),
          child: BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is NotificationLoading) {
                return Center(child: CircularProgressIndicator());
              } else if (state is NotificationError) {
                return Center(child: Text(state.errorMessage));
              } else if (state is NotificationLoaded) {
                final notifications = state.notifications;

                // Check if notifications list is empty
                if (notifications.isEmpty) {
                  return Column(
                    children: [
                      CustomAppbar(headingTxt: Strings.notifications),
                      Expanded(
                        child: Center(
                          child: Text(
                            'No notifications',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontFamily: Fonts.body,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomAppbar(headingTxt: Strings.notifications),
                      SizedBox(height: 20),
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: state.notifications.length,
                        itemBuilder: (context, index) {
                          final item = state.notifications[index];
                          return NotificationItemTile(
                            user: item.title,
                            time: timeAgo(item.createdAt),
                            description: item.description,
                          );
                        },
                      ),
                    ],
                  ),
                );
              } else {
                return Center(child: Text('Unknown State'));
              }
            },
          ),
        ),
      ),
    );
  }

  String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays >= 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays >= 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}

class NotificationItemTile extends StatelessWidget {
  final String user;
  final String time;
  final String description;

  const NotificationItemTile({
    required this.user,
    required this.time,
    required this.description,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: ColorCodes.whiteNewReplacement,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ColorCodes.searchboxcolor),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  user,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    letterSpacing: Fonts.headingLetterSpacing,
                    fontFamily: Fonts.heading,
                    color: ColorCodes.mainheadingcolor,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: Fonts.body,
                    color: ColorCodes.textcolor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              description,
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
    );
  }
}
