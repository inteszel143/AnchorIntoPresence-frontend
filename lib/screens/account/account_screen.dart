import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindfully_evolve_app/utils/color_constants.dart';

import '../../utils/fonts.dart';
import '../../utils/global.dart' as globals;
import '../signin/signin_screen.dart';
import '../signup/signup_bloc/signup_bloc.dart';
import '../signup/signup_screen.dart';
import '../subscriptionmanagement/subscription_management.dart';

// Screen that presents the benefits of creating an account and available user actions.
class AccountOnboardingScreen extends StatelessWidget {
  const AccountOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorCodes.backgroundcolor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Create Your Free Account",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: ColorCodes.blackcolor,
                        letterSpacing: Fonts.headingLetterSpacing,
                        fontFamily: Fonts.heading,
                        fontSize: 26,
                        fontWeight: FontWeight.w400,
                      ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Create an account to:",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ColorCodes.blackcolor,
                  fontFamily: Fonts.body,
                ),
              ),
              const SizedBox(height: 16),
              _buildBenefitRow(context, "Track your progress"),
              _buildBenefitRow(context, "Save favorites"),
              _buildBenefitRow(context, "Access across devices"),
              _buildBenefitRow(context, "Restore purchases anytime"),
              const Spacer(),
              Column(
                children: [
                  // Opens the signup flow for users who want to create a new account.
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider(
                              create: (_) => SignupBloc(),
                              child: SignupScreen(),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorCodes.buttoncolor,
                        foregroundColor: ColorCodes.blackcolor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Create Account",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: ColorCodes.lightContainerColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: TextButton(
                      onPressed: () {
                        // Users with an existing purchase can proceed to signup; otherwise, they are directed to subscription management.
                        if (globals.alreadyPurchasedProductId.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SignupScreen(),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SubscriptionManagementScreen(),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        "Continue",
                        style: TextStyle(
                            fontSize: 16, color: ColorCodes.buttoncolor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // LOGIN OPTION
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SigninScreen(),
                          ),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.black45),
                          children: const [
                            TextSpan(
                              text: "Already have an account? ",
                            ),
                            TextSpan(
                              text: "Log In",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

// Reusable widget for displaying each benefit of creating an account.
  Widget _buildBenefitRow(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: ColorCodes.buttoncolor,
            size: 22,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 14,
                    fontFamily: Fonts.body,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
