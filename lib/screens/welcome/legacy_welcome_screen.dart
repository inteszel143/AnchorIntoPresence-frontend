import 'package:flutter/material.dart';
import 'package:mindfully_evolve_app/common/widgets/button_widget.dart';
import 'package:mindfully_evolve_app/utils/fonts.dart';
import 'package:mindfully_evolve_app/utils/image_constants.dart';
import 'package:mindfully_evolve_app/utils/string_constants.dart';

import '../../common/local_storage.dart';
import '../../common/main_screen.dart';
import '../../utils/color_constants.dart';
import '../account/account_screen.dart';

class LegacyWelcomeScreen extends StatelessWidget {
  const LegacyWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              ImageConstants.seaBackgroundImage,
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 27.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // SizedBox(height: 50,),
                        const Text(
                          Strings.welcomeHeader,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w400,
                            color: ColorCodes.welcomepageheadingcolor,
                            letterSpacing: Fonts.headingLetterSpacing,
                            fontFamily: Fonts.heading,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 12),
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: Strings.welcomeNote1,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: ColorCodes.welcomepagedescriptioncolor,
                                  fontFamily: Fonts.body,
                                ),
                              ),
                              const TextSpan(
                                text: Strings.welcomeNote3,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: ColorCodes.welcomepagedescriptioncolor,
                                  fontFamily: Fonts.body,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 23,
            right: 23,
            bottom: 30,
            child: ButtonWidget(
              btnTxt: Strings.begin,
              widthFactor: 0.9,
              height: 52,
              onTap: () async {
                final token = await LocalStorage.getToken();

                if (token != null && token.isNotEmpty) {
                  // Already logged in → go to MainScreen
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => MainScreen(initialIndex: 0)),
                    (route) => false,
                  );
                } else {
                  // Not logged in → go to onboarding/signup
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => AccountOnboardingScreen()),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
