import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindfully_evolve_app/screens/reset_password/resetpassword_bloc/reset_password_bloc.dart';
import 'package:mindfully_evolve_app/screens/reset_password/resetpassword_bloc/reset_password_event.dart';
import 'package:mindfully_evolve_app/screens/reset_password/resetpassword_bloc/reset_password_state.dart';

import '../../common/widgets/background_image.dart';
import '../../common/widgets/button_widget.dart';
import '../../common/widgets/custom_appbar.dart';
import '../../common/widgets/textfield_widget.dart';
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
  ResetPassword({required this.email, Key? key}) : super(key: key);

  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = MediaQuery.of(context).size.width * 0.06;
    return BlocProvider(
      create: (_) => ResetPasswordBloc(),
      child: Scaffold(
        body: BackgroundScaffold(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomAppbar(headingTxt: ''),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      Strings.resetPassword,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: ColorCodes.bellefairheadingtextcolor,
                          fontWeight: FontWeight.w400,
                          fontSize: 26,
                          letterSpacing: Fonts.headingLetterSpacing,
                          fontFamily: Fonts.heading),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: Text(
                      Strings.newUniquePassword,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: ColorCodes.headerdescriptioncolor,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        fontFamily: Fonts.body,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: const Text(
                      Strings.newPassword,
                      style: TextStyle(
                        color: ColorCodes.bellefairheadingtextcolor,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        fontFamily: Fonts.body,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFieldWidget(
                    controller: _passwordController,
                    label: Strings.enterNewPassword,
                    widthFactor: 0.9,
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
                  const SizedBox(height: 10),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: const Text(
                      Strings.confirmPassword,
                      style: TextStyle(
                        color: ColorCodes.bellefairheadingtextcolor,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        fontFamily: Fonts.body,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFieldWidget(
                    controller: _confirmPasswordController,
                    label: Strings.enterConfirmPassword,
                    widthFactor: 0.9,
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
                  const SizedBox(height: 20),
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

                        return GestureDetector(
                          onTap: isLoading
                              ? null
                              : () {
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
                          child: ButtonWidget(
                            isActive: !isLoading,
                            btnTxt:
                                isLoading ? 'Submitting...' : Strings.submit,
                            widthFactor: 0.9,
                            height: 50,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
