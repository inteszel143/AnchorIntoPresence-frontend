import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';

import '../../common/widgets/background_image.dart';
import '../../common/widgets/button_widget.dart';
import '../../common/widgets/custom_appbar.dart';
import '../../utils/color_constants.dart';
import '../../utils/fonts.dart';
import '../../utils/string_constants.dart';
import '../reset_password/reset_password.dart';
import '../signin/signin_screen.dart';
import 'otp_bloc/otp_bloc.dart';
import 'otp_bloc/otp_event.dart';
import 'otp_bloc/otp_state.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final String flow;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    required this.flow,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController otpController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 54,
      height: 54,
      textStyle: const TextStyle(
        fontSize: 14,
        color: ColorCodes.blackcolor,
        fontWeight: FontWeight.w500,
        fontFamily: Fonts.body,
      ),
      decoration: BoxDecoration(
        color: ColorCodes.whitecolor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColorCodes.searchboxcolor),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: ColorCodes.searchboxcolor),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: ColorCodes.searchboxcolor),
      ),
    );

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: BlocProvider(
        create: (_) => OtpVerificationBloc()..add(StartResendOtpTimer()),
        child: BlocConsumer<OtpVerificationBloc, OtpVerificationState>(
          listener: (context, state) {
            if (state is OtpVerificationSuccess) {
              otpController.clear();
              if (widget.flow == 'signup') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(Strings.successfullyRegistered),
                    backgroundColor: ColorCodes.buttoncolor,
                  ),
                );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => SigninScreen()),
                );
              } else if (widget.flow == 'forgotpassword') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(Strings.otpVerifiedSuccessfully),
                    backgroundColor: ColorCodes.buttoncolor,
                  ),
                );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ResetPassword(email: widget.email)),
                );
              }
            } else if (state is OtpVerificationFailure) {
              otpController.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: ColorCodes.buttoncolor,
                ),
              );
            } else if (state is OtpResendSuccess) {
              otpController.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: ColorCodes.buttoncolor,
                ),
              );
            }
          },
          builder: (context, state) {
            final bool isLoading = state is OtpVerificationLoading;
            final bool isResendLoading = state is OtpResendSuccess;
            final bool isTimerRunning = state is OtpResendTimerRunning;
            final int remainingSeconds =
                isTimerRunning ? state.remainingSeconds : 0;

            return BackgroundScaffold(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomAppbar(headingTxt: ''),
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        Strings.otpVerification,
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
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        Strings.enterVerificationCode,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ColorCodes.headerdescriptioncolor,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          fontFamily: Fonts.body,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Center(
                        child: Pinput(
                          controller: otpController,
                          length: 6,
                          defaultPinTheme: defaultPinTheme,
                          focusedPinTheme: focusedPinTheme,
                          submittedPinTheme: submittedPinTheme,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onChanged: (value) {
                            if (value.length > 6) {
                              otpController.clear();
                            } else if (value.isEmpty &&
                                otpController.text.isNotEmpty) {
                              otpController.clear();
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap: isLoading || isResendLoading
                            ? null
                            : () {
                                FocusScope.of(context).unfocus();
                                final otp = otpController.text.trim();
                                otpController.clear();
                                if (otp.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(Strings.pleaseEnterOTP),
                                      backgroundColor: ColorCodes.buttoncolor,
                                    ),
                                  );
                                  return;
                                }

                                context.read<OtpVerificationBloc>().add(
                                      VerifyOtpSubmitted(
                                        email: widget.email,
                                        otp: otp,
                                      ),
                                    );
                              },
                        child: ButtonWidget(
                          isActive: !isLoading && !isResendLoading,
                          btnTxt:
                              isLoading ? Strings.verifyOTP : Strings.verifyOTP,
                          widthFactor: 0.9,
                          height: 50,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          Strings.dontGetCode,
                          style: TextStyle(
                            color: ColorCodes.dontgetcodetextcolor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            fontFamily: Fonts.body,
                          ),
                        ),
                        TextButton(
                          onPressed: remainingSeconds > 0
                              ? null
                              : () {
                                  otpController.clear();
                                  context
                                      .read<OtpVerificationBloc>()
                                      .add(ResendOtp(email: widget.email));
                                },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(
                            remainingSeconds > 0
                                ? '${Strings.resendOtp} ($remainingSeconds s)'
                                : Strings.resendOtp,
                            style: TextStyle(
                              color: remainingSeconds > 0
                                  ? Colors.grey
                                  : ColorCodes.resendotptextcolor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              fontFamily: Fonts.body,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (isLoading)
                      Center(
                        child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
