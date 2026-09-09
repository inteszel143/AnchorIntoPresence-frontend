import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindfully_evolve_app/utils/color_constants.dart';

import '../../utils/fonts.dart';
import '../../utils/global.dart' as globals;
import '../../common/widgets/auth_theme.dart';
import '../signin/signin_screen.dart';
import '../signup/signup_bloc/signup_bloc.dart';
import '../signup/signup_screen.dart';
import '../subscriptionmanagement/subscription_management.dart';

// Screen that presents the benefits of creating an account and available user actions.
class AccountOnboardingScreen extends StatelessWidget {
  const AccountOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthTheme(
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth > 520 ? 40.0 : 24.0;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                28,
                horizontalPadding,
                24,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/icons/tina-logo.png',
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Theme.of(context).colorScheme.onSurface
                              : null,
                          width: 120,
                          height: 100,
                          fit: BoxFit.contain,
                          semanticLabel: 'Tina Moore',
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "YOUR SPACE TO SLOW DOWN",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.2,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontFamily: Fonts.body,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        "Create Your Free Account",
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              letterSpacing: Fonts.headingLetterSpacing,
                              fontFamily: Fonts.heading,
                              fontSize: 32,
                              height: 1.15,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Make a little space for yourself and keep your journey close.",
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.55,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontFamily: Fonts.body,
                        ),
                      ),
                      const SizedBox(height: 36),
                      Text(
                        "Create an account to:",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                          fontFamily: Fonts.body,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildBenefitRow(context, "Track your progress"),
                            _buildBenefitRow(context, "Save favorites"),
                            _buildBenefitRow(context, "Access across devices"),
                            _buildBenefitRow(
                                context, "Restore purchases anytime"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 44),
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
                            backgroundColor: ColorCodes.buttonActive,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Create Account",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              fontFamily: Fonts.body,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: TextButton.icon(
                          onPressed: () {
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
                          icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                          label: const Text("Continue"),
                          style: TextButton.styleFrom(
                            foregroundColor: ColorCodes.buttonActive,
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              fontFamily: Fonts.body,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
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
                              style: TextStyle(
                                color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                                fontFamily: Fonts.body,
                                fontSize: 14,
                              ),
                              children: [
                                const TextSpan(text: "Already have an account? "),
                                TextSpan(
                                  text: "Log In",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitRow(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: ColorCodes.buttonActive,
              size: 19,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontFamily: Fonts.body,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
