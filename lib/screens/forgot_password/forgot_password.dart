import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/widgets/background_image.dart';
import '../../common/widgets/button_widget.dart';
import '../../common/widgets/custom_appbar.dart';
import '../../common/widgets/textfield_widget.dart';
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
    return BlocProvider(
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
          if (state is ForgotPasswordLoading) {
            return Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    color: ColorCodes.backgroundcolor,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: ColorCodes.buttoncolor,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          return BackgroundScaffold(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomAppbar(headingTxt: ''),
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        Strings.forgotPassword,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ColorCodes.bellefairheadingtextcolor,
                          fontWeight: FontWeight.w400,
                          fontSize: 26,
                          letterSpacing: Fonts.headingLetterSpacing,
                          fontFamily: Fonts.heading,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 50),
                      child: Text(
                        Strings.forgotPasswordHeader,
                        textAlign: TextAlign.center,
                        style: TextStyle(
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
                        Strings.emailAddress,
                        style: TextStyle(
                          color: ColorCodes.bellefairheadingtextcolor,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          fontFamily: Fonts.body,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Center(
                      child: TextFieldWidget(
                        label: Strings.enterYourEmailAddress,
                        controller: _emailController,
                        widthFactor: 0.9,
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
                    const SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          final email = _emailController.text.trim();
                          if (_formKey.currentState!.validate()) {
                            context.read<ForgotPasswordBloc>().add(
                                  SubmitForgotPassword(email),
                                );
                          }
                        },
                        child: ButtonWidget(
                          btnTxt: Strings.sendCode,
                          widthFactor: 0.9,
                          height: 50,
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
    );
  }
}
