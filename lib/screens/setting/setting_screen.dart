import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindfully_evolve_app/common/main_screen.dart';
import 'package:mindfully_evolve_app/screens/privacy_policy/privacy_screen.dart';
import 'package:mindfully_evolve_app/screens/reminder/reminder_screen.dart';
import 'package:mindfully_evolve_app/screens/subscriptionmanagement/subscription_management.dart';
import 'package:mindfully_evolve_app/screens/term&conditions/terms_screen.dart';
import 'package:mindfully_evolve_app/utils/image_constants.dart';
import 'package:mindfully_evolve_app/utils/string_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/deleteconfirmation_dialog.dart';
import '../../common/logoutconfirmation_dialog.dart';
import '../../common/widgets/buy_subscription_dialog.dart';
import '../../common/widgets/custom_appbar.dart';
import '../../helping_widgets/setting_itemtile.dart';
import '../../utils/color_constants.dart';
import '../../utils/global.dart' as globals;
import '../activity_listing/favourite_activities.dart';
import '../activity_listing/getactivity_bloc/getrecent_activities_bloc.dart';
import '../activity_listing/getactivity_bloc/getrecent_activities_event.dart';
import '../contact_support/contact_supportscreen.dart';
import '../dashboard/dashboard_bloc/home_bloc.dart';
import '../dashboard/dashboard_bloc/home_event.dart';
import '../faq/faq.dart';
import '../privacy_policy/privacy_bloc/privacy_bloc.dart';
import '../privacy_policy/privacy_bloc/privacy_event.dart';
import '../reminder/get_reminders_screen.dart';
import '../reminder/reminder_bloc/reminder_bloc.dart';
import '../signin/deleteaccount_bloc/delete_account_bloc.dart';
import 'notification_toggle/notification_toggle_bloc.dart';
import 'notification_toggle/notification_toggle_event.dart';
import 'notification_toggle/notification_toggle_state.dart';

class SettingScreen extends StatelessWidget {
  final ValueNotifier<bool> notificationToggle =
      ValueNotifier<bool>(true); // Default state

  SettingScreen({Key? key}) : super(key: key);

  // Load notification toggle state from SharedPreferences
  static Future<void> _loadNotificationState(
      ValueNotifier<bool> notifier) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isNotificationOn = prefs.getBool('notificationState') ??
        true; // Default to true if no value exists
    notifier.value = isNotificationOn;
  }

  // Save notification toggle state to SharedPreferences
  static Future<void> _saveNotificationState(bool state) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('notificationState', state); // Save the state
  }

  void _handleSettingTap(BuildContext context, String option) {
    switch (option) {
      case Strings.notificationAlert:
        break;
      case Strings.favouriteActivities:
        if (globals.isSubscribed == true) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider<ActivityBloc>(
                create: (_) => ActivityBloc()..add(FetchActivities()),
                child: const FavouriteActivity(),
              ),
            ),
          );
        } else {
          showSubscriptionDialog(context);
        }
        break;
      case Strings.setReminderTime:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider<ReminderBloc>(
              create: (_) => ReminderBloc(),
              child: ReminderScreen(),
            ),
          ),
        );
        break;
      case Strings.getReminderTime:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider<ReminderBloc>(
              create: (_) => ReminderBloc(),
              child: GetRemindersScreen(),
            ),
          ),
        );
        break;
      case Strings.subscriptionAndBilling:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SubscriptionManagementScreen()),
        ).then((onValue) {
          context
              .read<HomePageBloc>()
              .add(FetchHomePageDataEvent(context: context));
        });
        break;
      case Strings.termsAndConditions:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TermsScreen()),
        );
        break;
      case Strings.privacyPolicy:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) {
              return BlocProvider(
                create: (context) =>
                    PrivacyBloc()..add(FetchPrivacyPolicyEvent()),
                child: PrivacyScreen(),
              );
            },
          ),
        );
        break;
      case Strings.contactSupport:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ContactSupportscreen()),
        );
        break;
      case Strings.faqs:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FrequentlyAskedQuestionsScreen()),
        );
        break;
      case Strings.deleteAccount:
        showDeleteConfirmationDialog(context);
        break;
      case Strings.logout:
        showLogoutConfirmationDialog(context);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Load the notification state initially
    _loadNotificationState(notificationToggle);

    final settings = [
      {
        "icon": ImageConstants.notificationIcon,
        "option": Strings.notificationAlert
      },
      {
        "icon": ImageConstants.recentActivityIcon,
        "option": Strings.favouriteActivities
      },
      {"icon": ImageConstants.reminderIcon, "option": Strings.setReminderTime},
      {"icon": ImageConstants.reminderIcon, "option": Strings.getReminderTime},
      {
        "icon": ImageConstants.notificationIcon,
        "option": Strings.subscriptionAndBilling
      },
      {"icon": ImageConstants.termIcon, "option": Strings.termsAndConditions},
      {"icon": ImageConstants.privacyIcon, "option": Strings.privacyPolicy},
      {
        "icon": ImageConstants.contactSupportIcon,
        "option": Strings.contactSupport
      },
      {"icon": ImageConstants.faqIcon, "option": Strings.faqs},
      {"icon": ImageConstants.deleteIcon, "option": Strings.deleteAccount},
      {"icon": ImageConstants.logoutIcon, "option": Strings.logout},
    ];

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => NotificationToggleBloc()),
        BlocProvider(create: (context) => AccountDeletionBloc()),
        BlocProvider(create: (context) => ActivityBloc()),
        BlocProvider(create: (context) => ReminderBloc()),
        BlocProvider(create: (context) => PrivacyBloc()),
        BlocProvider(create: (context) => HomePageBloc()),
      ],
      child: BlocConsumer<NotificationToggleBloc, NotificationToggleState>(
        listener: (context, state) {
          if (state is NotificationToggleSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: ColorCodes.buttoncolor,
              ),
            );
          } else if (state is NotificationToggleError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: ColorCodes.buttoncolor,
              ),
            );
          }
        },
        builder: (context, state) {
          return WillPopScope(
            onWillPop: () async {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => MainScreen(
                          initialIndex: 0,
                        )),
                (route) => false,
              );
              return false;
            },
            child: Scaffold(
              backgroundColor: ColorCodes.backgroundcolor,
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomAppbar(
                        headingTxt: Strings.settings,
                        onTap: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MainScreen(
                                        initialIndex: 0,
                                      )));
                        },
                      ),
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: settings.length,
                        itemBuilder: (context, index) {
                          final item = settings[index];
                          final isNotificationToggle =
                              item['option'] == Strings.notificationAlert;

                          if (isNotificationToggle) {
                            return ValueListenableBuilder<bool>(
                              valueListenable: notificationToggle,
                              builder: (context, value, child) {
                                return SettingItemTile(
                                  key: ValueKey(item['option']),
                                  iconPath: item['icon']!,
                                  option: item['option']!,
                                  showToggle: true,
                                  toggleValue: value,
                                  onToggle: (val) {
                                    notificationToggle.value = val;
                                    _saveNotificationState(
                                        val); // Save state when toggled
                                    BlocProvider.of<NotificationToggleBloc>(
                                            context)
                                        .add(ToggleNotificationEvent(val));
                                  },
                                  onTap: () => _handleSettingTap(
                                      context, item['option']!),
                                );
                              },
                            );
                          } else {
                            return SettingItemTile(
                              key: ValueKey(item['option']),
                              iconPath: item['icon']!,
                              option: item['option']!,
                              onTap: () =>
                                  _handleSettingTap(context, item['option']!),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
