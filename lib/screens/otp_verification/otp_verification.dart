import 'package:mindfully_evolve_app/common/widgets/app_scaffold.dart';
import '../../common/widgets/auth_entrance.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';

import '../../common/widgets/auth_theme.dart';
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
  bool _isBusy = false;
  bool _isResending = false;
  int _remainingSeconds = 120;
  String? _error;

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthTheme(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: BlocProvider(
          create: (_) => OtpVerificationBloc()..add(StartResendOtpTimer()),
          child: BlocConsumer<OtpVerificationBloc, OtpVerificationState>(
            listener: (context, state) {
              if (state is OtpResendTimerRunning) {
                _remainingSeconds = state.remainingSeconds;
              } else {
                _isBusy = state is OtpVerificationLoading;
              }
              if (state is OtpVerificationFailure) {
                _error = state.error;
              } else if (state is OtpResendSuccess) {
                _error = null;
              }
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
              final colors = Theme.of(context).colorScheme;
              return AppScaffold(
                body: SafeArea(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                    child: AuthEntrance(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const CustomAppbar(headingTxt: '', topPadding: 0),
                              const SizedBox(height: 24),
                              Center(
                                child: Image.asset(
                                  'assets/icons/tina-logo.png',
                                  width: 100,
                                  height: 80,
                                  fit: BoxFit.contain,
                                  semanticLabel: 'Tina Moore',
                                ),
                              ),
                              const SizedBox(height: 28),
                              Text(
                                'ONE MORE STEP',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2.4,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                Strings.otpVerification,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: colors.onSurface,
                                  fontFamily: Fonts.heading,
                                  fontSize: 34,
                                  height: 1.15,
                                  letterSpacing: Fonts.headingLetterSpacing,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Enter the 6-digit code sent to',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: colors.onSurfaceVariant,
                                    fontSize: 15,
                                    height: 1.5),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                widget.email,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: colors.onSurface,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    height: 1.5),
                              ),
                              const SizedBox(height: 36),
                              Text(
                                'Verification code',
                                style: TextStyle(
                                    color: colors.onSurface,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 12),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final gap =
                                      constraints.maxWidth < 320 ? 6.0 : 10.0;
                                  final pinTheme = PinTheme(
                                    width: (constraints.maxWidth - gap * 5) / 6,
                                    height: 64,
                                    textStyle: TextStyle(
                                      fontFamily: Fonts.body,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w600,
                                      color: colors.onSurface,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.surfaceContainerLow,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                          color: colors.outline
                                              .withValues(alpha: 0.55)),
                                    ),
                                  );
                                  return Pinput(
                                    controller: otpController,
                                    length: 6,
                                    enabled: !_isBusy,
                                    autofillHints: const [
                                      AutofillHints.oneTimeCode
                                    ],
                                    separatorBuilder: (_) =>
                                        SizedBox(width: gap),
                                    defaultPinTheme: pinTheme,
                                    focusedPinTheme: pinTheme.copyWith(
                                      decoration: pinTheme.decoration!.copyWith(
                                        color: colors.primary
                                            .withValues(alpha: 0.05),
                                        border: Border.all(
                                            color: colors.primary, width: 2),
                                        boxShadow: [
                                          BoxShadow(
                                              color: colors.primary
                                                  .withValues(alpha: 0.08),
                                              blurRadius: 0,
                                              spreadRadius: 3)
                                        ],
                                      ),
                                    ),
                                    submittedPinTheme: pinTheme.copyWith(
                                      decoration: pinTheme.decoration!.copyWith(
                                        color: colors.primary
                                            .withValues(alpha: 0.08),
                                        border: Border.all(
                                            color: colors.primary
                                                .withValues(alpha: 0.5)),
                                      ),
                                    ),
                                    errorPinTheme: pinTheme.copyWith(
                                      decoration: pinTheme.decoration!.copyWith(
                                          border:
                                              Border.all(color: colors.error)),
                                    ),
                                    forceErrorState: _error != null,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    onChanged: (_) =>
                                        setState(() => _error = null),
                                  );
                                },
                              ),
                              if (_error != null) ...[
                                const SizedBox(height: 12),
                                Semantics(
                                  liveRegion: true,
                                  child: Text(_error!,
                                      style: TextStyle(
                                          color: colors.error,
                                          fontSize: 13,
                                          height: 1.4)),
                                ),
                              ],
                              const SizedBox(height: 28),
                              FilledButton(
                                onPressed: _isBusy
                                    ? null
                                    : () {
                                        final otp = otpController.text.trim();
                                        if (otp.length != 6) {
                                          setState(() => _error =
                                              'Please enter all 6 digits.');
                                          return;
                                        }
                                        FocusScope.of(context).unfocus();
                                        setState(() {
                                          _error = null;
                                          _isResending = false;
                                          _isBusy = true;
                                        });
                                        context.read<OtpVerificationBloc>().add(
                                            VerifyOtpSubmitted(
                                                email: widget.email, otp: otp));
                                      },
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size.fromHeight(54),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  child: _isBusy
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const SizedBox(
                                                width: 18,
                                                height: 18,
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color:
                                                            ColorCodes.cream)),
                                            const SizedBox(width: 12),
                                            Flexible(
                                                child: Text(_isResending
                                                    ? 'Sending code…'
                                                    : 'Verifying…')),
                                          ],
                                        )
                                      : const Text(Strings.verifyOTP),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Didn’t receive a code?',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: colors.onSurfaceVariant,
                                    fontSize: 14),
                              ),
                              Center(
                                child: TextButton(
                                  onPressed: _isBusy || _remainingSeconds > 0
                                      ? null
                                      : () {
                                          setState(() {
                                            _isBusy = true;
                                            _isResending = true;
                                            _error = null;
                                          });
                                          context
                                              .read<OtpVerificationBloc>()
                                              .add(ResendOtp(
                                                  email: widget.email));
                                        },
                                  child: Text(
                                    _remainingSeconds > 0
                                        ? 'Resend code in ${_remainingSeconds ~/ 60}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}'
                                        : 'Resend code',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Check your spam or junk folder, too.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: colors.onSurfaceVariant,
                                    fontSize: 12,
                                    height: 1.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
