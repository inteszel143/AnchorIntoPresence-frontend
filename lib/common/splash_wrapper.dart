import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mindfully_evolve_app/common/widgets/main_page.dart';
import 'package:mindfully_evolve_app/screens/community/post_detail_screen.dart';
import 'package:mindfully_evolve_app/screens/dashboard/home_model.dart';
import 'package:mindfully_evolve_app/screens/signin/signin_screen.dart';
import 'package:mindfully_evolve_app/screens/signup/signup_screen.dart';
import 'package:mindfully_evolve_app/screens/welcome/welcome_screen.dart';

import '../utils/api_service.dart';
import '../utils/global.dart' as globals;
import 'local_storage.dart';

class SplashWrapper extends StatefulWidget {
  const SplashWrapper({Key? key}) : super(key: key);

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  static const MethodChannel _channel =
      MethodChannel('com.mediation.mindfullyevolve.deepLink');

  @override
  void initState() {
    super.initState();

    _channel.setMethodCallHandler(_handleMethod);

    _navigateAfterDelay();
  }

  Future<void> _handleMethod(MethodCall call) async {
    if (call.method == "onDeepLinkReceived") {
      final String shareId = call.arguments;
      // Navigate directly to PostDetailScreen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PostDetailScreen(shareId: shareId),
          ),
        );
      }
    }
  }

  Future<void> _navigateAfterDelay() async {
    // Wait 3 seconds splash
    await Future.delayed(const Duration(seconds: 3));
    try {
      final token = await LocalStorage.getToken();

      if (token != null && token.isNotEmpty) {
        // OPTIONAL: You can still call API if needed
        final userProfileFuture = ApiService.fetchProfileData(token);
        final results = await Future.wait([userProfileFuture]);

        if (results.isNotEmpty && results[0] is ProfileDataModel) {
          final profileData = results[0] as ProfileDataModel;

          globals.alreadyPurchasedProductId = profileData.productId ?? '';
          globals.isSubscribed = profileData.subscriptionStatus == 'active';
        }

        // ALWAYS GO TO MAIN SCREEN IF TOKEN EXISTS
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              // builder: (_) => MainScreen(initialIndex: 0),
              builder: (_) => WelcomeScreen(),
            ),
          );
        }
        return; // VERY IMPORTANT
      }

      // Only if NO token
      if (mounted) {
        final purchase = await LocalStorage.getPurchase();
        if (purchase != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => SignupScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => WelcomeScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => SigninScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const MainPage(); // Your splash screen UI
  }
}
