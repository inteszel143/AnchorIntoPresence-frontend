import 'package:mindfully_evolve_app/common/widgets/button_widget.dart';
import 'package:mindfully_evolve_app/utils/fonts.dart';
import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindfully_evolve_app/screens/activity_listing/activity_detail.dart';
import 'package:mindfully_evolve_app/screens/activity_listing/getactivity_bloc/getrecent_activities_bloc.dart';
import 'package:mindfully_evolve_app/screens/add_post/add_post_bloc/add_post_bloc.dart';
import 'package:mindfully_evolve_app/screens/comment/comment_bloc/comment_bloc.dart';
import 'package:mindfully_evolve_app/screens/community/community_bloc/community_bloc.dart';
import 'package:mindfully_evolve_app/screens/community/post_detail_screen.dart';
import 'package:mindfully_evolve_app/screens/dashboard/dashboard_bloc/home_bloc.dart';
import 'package:mindfully_evolve_app/screens/dashboard/dashboard_bloc/home_event.dart';
import 'package:mindfully_evolve_app/screens/feeling_category/feelingcategory_bloc/feeling_categories_bloc.dart';
import 'package:mindfully_evolve_app/screens/notification/notification_bloc/notification_bloc.dart';
import 'package:mindfully_evolve_app/screens/privacy_policy/privacy_bloc/privacy_bloc.dart';
import 'package:mindfully_evolve_app/screens/privacy_policy/privacy_bloc/privacy_event.dart';
import 'package:mindfully_evolve_app/screens/reminder/reminder_bloc/reminder_bloc.dart';
import 'package:mindfully_evolve_app/screens/setting/notification_toggle/notification_toggle_bloc.dart';
import 'package:mindfully_evolve_app/screens/signin/deleteaccount_bloc/delete_account_bloc.dart';
import 'package:mindfully_evolve_app/screens/signin/deleteaccount_bloc/delete_account_event.dart';
import 'package:mindfully_evolve_app/screens/signin/signin_bloc/signin_bloc.dart';
import 'package:mindfully_evolve_app/screens/signin/signin_screen.dart';
import 'package:mindfully_evolve_app/screens/subscriptionmanagement/subscription_management_bloc/subscriprion_management_bloc.dart';
import 'package:mindfully_evolve_app/screens/track/track_bloc/track_bloc.dart';
import 'package:mindfully_evolve_app/utils/connectivity_handler.dart';
import 'package:mindfully_evolve_app/utils/fcm_service.dart';
import 'package:provider/provider.dart';

import 'common/local_storage.dart';
import 'common/splash_wrapper.dart';
import 'firebase_options.dart';
import 'helping_widgets/user_provider/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') rethrow;
  }

  await initializeFCM();

  runApp(ChangeNotifierProvider(
      create: (_) => UserProvider(), child: const MyApp()));
}

class MyApp extends StatefulWidget with WidgetsBindingObserver {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  StreamSubscription<Uri>? _linkSubscription;
  bool _initialLinkHandled = false;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> initDeepLinks() async {
    final appLinks = AppLinks();

    try {
      final initialUri = await appLinks.getInitialLink();
      if (initialUri != null && !_initialLinkHandled) {
        _initialLinkHandled = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          openAppLink(initialUri);
        });
      }
    } catch (e) {}

    _linkSubscription?.cancel();
    _linkSubscription = appLinks.uriLinkStream.listen((uri) {
      openAppLink(uri);
    });
  }

  Future<void> openAppLink(Uri uri) async {
    if (uri.pathSegments.length >= 4 &&
        uri.pathSegments[0] == 'app' &&
        uri.pathSegments[1] == 'post' &&
        uri.pathSegments[2] == 'share') {
      String shareId = uri.pathSegments.last;
      final token = await LocalStorage.getToken() ?? '';
      if (shareId.isNotEmpty && token != '') {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(shareId: shareId),
          ),
        );
      } else {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (context) => SigninScreen()),
        );
      }
    } else if (uri.pathSegments.length >= 4 &&
        uri.pathSegments[0] == 'app' &&
        uri.pathSegments[1] == 'anchorOfLove' &&
        uri.pathSegments[2] == 'share') {
      // Extract IDs
      final String activityId = uri.pathSegments[3];
      final token = await LocalStorage.getToken() ?? '';
      if (activityId.isNotEmpty && token.isNotEmpty) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => ActivityDetail(
              activityId: activityId,
            ),
          ),
        );
      } else {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (context) => SigninScreen()),
        );
      }
    } else {
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (context) => SigninScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SigninBloc()),
        BlocProvider(
            create: (_) =>
                HomePageBloc()..add(FetchHomePageDataEvent(context: context))),
        BlocProvider<ActivityBloc>(create: (_) => ActivityBloc()),
        BlocProvider<TrackBloc>(create: (_) => TrackBloc()),
        BlocProvider<SubscriptionBloc>(create: (_) => SubscriptionBloc()),
        BlocProvider<NotificationBloc>(create: (_) => NotificationBloc()),
        BlocProvider<ReminderBloc>(create: (_) => ReminderBloc()),
        BlocProvider<CategoryBloc>(create: (_) => CategoryBloc()),
        BlocProvider<PostBloc>(create: (_) => PostBloc()),
        BlocProvider<CommentBloc>(create: (_) => CommentBloc()),
        BlocProvider<AccountDeletionBloc>(
            create: (_) =>
                AccountDeletionBloc()..add(AccountDeletionRequest())),
        BlocProvider<NotificationToggleBloc>(
            create: (_) => NotificationToggleBloc()),
        BlocProvider(
            create: (_) => PrivacyBloc()..add(FetchPrivacyPolicyEvent())),
        BlocProvider<CommunityBloc>(create: (_) => CommunityBloc()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Anchor Into Presence',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          fontFamily: Fonts.body,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonWidget.primaryStyle,
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: ButtonWidget.primaryStyle,
          ),
          textTheme: Fonts.textTheme(
            ThemeData(useMaterial3: true, fontFamily: Fonts.body).textTheme,
          ),
        ),
        builder: (context, child) {
          return ConnectivityHandler(child: child ?? Container());
        },
        home: const SplashWrapper(),
      ),
    );
  }
}
