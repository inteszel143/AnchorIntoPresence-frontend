import 'package:mindfully_evolve_app/common/widgets/app_scaffold.dart';
import '../../common/widgets/auth_entrance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindfully_evolve_app/screens/reset_password/resetpassword_bloc/reset_password_bloc.dart';
import 'package:mindfully_evolve_app/screens/reset_password/resetpassword_bloc/reset_password_event.dart';
import 'package:mindfully_evolve_app/screens/reset_password/resetpassword_bloc/reset_password_state.dart';

import '../../common/widgets/auth_text_field.dart';
import '../../common/widgets/auth_theme.dart';
import '../../common/widgets/button_widget.dart';
import '../../common/widgets/custom_appbar.dart';
import '../../utils/color_constants.dart';
import '../../utils/fonts.dart';
import '../../utils/string_constants.dart';
import '../signin/signin_screen.dart';

class ResetPassword extends StatelessWidget {
  final String email;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final RegExp _alphanumericRegex =
      RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]+$');
  final RegExp _letterRegex = RegExp(r'[A-Za-z]');
  final RegExp _numberRegex = RegExp(r'\d');
  ResetPassword({required this.email, super.key});

  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = MediaQuery.of(context).size.width * 0.06;
    return AuthTheme(
      child: Builder(
        builder: (context) => BlocProvider(
          create: (_) => ResetPasswordBloc(),
          child: AppScaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                12,
                horizontalPadding,
                32,
              ),
              child: AuthEntrance(child: Form(
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
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).colorScheme.onSurface
                          : null,
                      semanticLabel: 'Tina Moore',
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'A FRESH START',
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
                      Strings.resetPassword,
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
                      Strings.newUniquePassword,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        height: 1.55,
                        fontFamily: Fonts.body,
                      ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                      Strings.newPassword,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        fontFamily: Fonts.body,
                      ),
                  ),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: _passwordController,
                    label: Strings.enterNewPassword,
                    widthFactor: 1,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Password is required';
                      } else if (value.trim().length < 6) {
                        return 'Password must be at least 6 characters long';
                      } else if (!_letterRegex.hasMatch(value.trim()) ||
                          !_numberRegex.hasMatch(value.trim())) {
                        return 'Password must contain at least one letter and one number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                      Strings.confirmPassword,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        fontFamily: Fonts.body,
                      ),
                  ),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: _confirmPasswordController,
                    label: Strings.enterConfirmPassword,
                    widthFactor: 1,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Confirm Password is required';
                      } else if (value.trim().length < 6) {
                        return 'Password must be at least 6 characters long';
                      } else if (!_letterRegex.hasMatch(value.trim()) ||
                          !_numberRegex.hasMatch(value.trim())) {
                        return 'Password must contain at least one letter and one number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: BlocConsumer<ResetPasswordBloc, ResetPasswordState>(
                      listener: (context, state) {
                        if (state is ResetPasswordSuccess) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.message),
                              backgroundColor: ColorCodes.buttoncolor,
                            ),
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SigninScreen()),
                          );
                        } else if (state is ResetPasswordFailure) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.error),
                              backgroundColor: ColorCodes.buttoncolor,
                            ),
                          );
                          _passwordController.clear();
                          _confirmPasswordController.clear();
                        }
                      },
                      builder: (context, state) {
                        bool isLoading = state is ResetPasswordLoading;

                        return AnimatedBuilder(
                          animation: Listenable.merge([
                            _passwordController,
                            _confirmPasswordController,
                          ]),
                          builder: (context, child) {
                            final canSubmit =
                                _passwordController.text.trim().isNotEmpty &&
                                    _confirmPasswordController.text
                                        .trim()
                                        .isNotEmpty;

                            return ButtonWidget(
                              isActive: !isLoading && canSubmit,
                              btnTxt: isLoading ? 'Submitting...' : Strings.submit,
                              widthFactor: 1,
                              height: 60,
                              onTap: () {
                                  FocusScope.of(context).unfocus();
                                  if (_formKey.currentState!.validate()) {
                                    context.read<ResetPasswordBloc>().add(
                                          ResetPasswordSubmitted(
                                            email: email,
                                            password:
                                                _passwordController.text.trim(),
                                            confirmPassword:
                                                _confirmPasswordController.text
                                                    .trim(),
                                          ),
                                        );
                                  }
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            )),
          ),
        ),
          ),
        ),
      ),
    );
  }
}
