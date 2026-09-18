import 'package:mindfully_evolve_app/common/widgets/app_scaffold.dart';
import '../../common/widgets/auth_entrance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/widgets/auth_text_field.dart';
import '../../common/widgets/auth_theme.dart';
import '../../common/widgets/button_widget.dart';
import '../../common/widgets/custom_appbar.dart';
import '../../common/widgets/loading_overlay.dart';
import '../../utils/color_constants.dart';
import '../../utils/fonts.dart';
import '../../utils/string_constants.dart';
import '../otp_verification/otp_verification.dart';
import 'forgotpassword_bloc/forgot_password_bloc.dart';
import 'forgotpassword_bloc/forgot_password_event.dart';
import 'forgotpassword_bloc/forgot_password_state.dart';

class ForgotPassword extends StatelessWidget {
  ForgotPassword({super.key});

  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = MediaQuery.of(context).size.width * 0.06;
    return AuthTheme(
      child: BlocProvider(
        create: (_) => ForgotPasswordBloc(),
        child: BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
        listener: (context, state) {
          if (state is ForgotPasswordSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: ColorCodes.buttoncolor,
              ),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => OtpVerificationScreen(
                  email: _emailController.text.trim(),
                  flow: 'forgotpassword',
                ),
              ),
            );
            // Navigate to OTP screen if needed
          } else if (state is ForgotPasswordFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: ColorCodes.buttoncolor,
              ),
            );
          }
        },
        builder: (context, state) {
          return AppScaffold(
            body: LoadingOverlay(
              isLoading: state is ForgotPasswordLoading,
              child: SafeArea(
                child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  12,
                  horizontalPadding,
                  32,
                ),
                child: AuthEntrance(child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Form(
                      key: _formKey,
                      child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomAppbar(headingTxt: ''),
                    const SizedBox(height: 28),
                    Center(
                      child: Image.asset(
                        'assets/icons/tina-logo.png',
                        width: 110,
                        height: 92,
                        fit: BoxFit.contain,
                        semanticLabel: 'Tina Moore',
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        'RESET YOUR PASSWORD',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          letterSpacing: 2,
                          fontFamily: Fonts.body,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: Text(
                        Strings.forgotPassword,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                          fontSize: 32,
                          height: 1.15,
                          letterSpacing: Fonts.headingLetterSpacing,
                          fontFamily: Fonts.heading,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      Strings.forgotPasswordHeader,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                        height: 1.55,
                        fontFamily: Fonts.body,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      Strings.emailAddress,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        fontFamily: Fonts.body,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: AuthTextField(
                        label: Strings.enterYourEmailAddress,
                        controller: _emailController,
                        widthFactor: 1,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email address';
                          }
                          if (value.trim().isEmpty) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: AnimatedBuilder(
                        animation: _emailController,
                        builder: (context, child) {
                          final canSubmit =
                              _emailController.text.trim().isNotEmpty;
                          return ButtonWidget(
                            btnTxt: Strings.sendCode,
                            widthFactor: 1,
                            height: 60,
                            isActive: canSubmit,
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              final email = _emailController.text.trim();
                              if (_formKey.currentState!.validate()) {
                                context.read<ForgotPasswordBloc>().add(
                                      SubmitForgotPassword(email),
                                    );
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                      ),
                    ),
                  ),
                )),
              ),
            ),
          ),
          );
        },
      ),
      ),
    );
  }
}
