import 'package:mindfully_evolve_app/common/widgets/app_scaffold.dart';
import '../../common/widgets/auth_entrance.dart';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../common/widgets/auth_text_field.dart';
import 'package:mindfully_evolve_app/utils/image_constants.dart';
import 'package:mindfully_evolve_app/utils/string_constants.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../common/widgets/auth_theme.dart';
import '../../common/widgets/button_widget.dart';
import '../../common/widgets/custom_appbar.dart';
import '../../common/widgets/loading_overlay.dart';
import '../../helping_widgets/sociallogin-button.dart';
import '../../utils/fonts.dart';
import '../otp_verification/otp_verification.dart';
import '../signin/signin_screen.dart';
import 'signup_bloc/signup_bloc.dart';
import 'signup_bloc/signup_event.dart';
import 'signup_bloc/signup_state.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final RegExp _letterRegex = RegExp(r'[A-Za-z]');
  final RegExp _numberRegex = RegExp(r'\d');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthTheme(
        child: Builder(
            builder: (context) => BlocProvider(
                  create: (_) => SignupBloc(),
                  child: AppScaffold(
                    body: BlocListener<SignupBloc, SignupState>(
                      listener: (context, state) {
                        if (state is SignupSuccess) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('OTP sent to your email'),
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                          );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OtpVerificationScreen(
                                email: _emailController.text.trim(),
                                flow: 'signup',
                              ),
                            ),
                          );
                        } else if (state is SignupFailure) {
                          if (state.errorMessage == 'Invalid credentials') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Invalid email or password'),
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                              ),
                            );
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.errorMessage.toString()),
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                          );
                        }
                      },
                      child: BlocBuilder<SignupBloc, SignupState>(
                        builder: (context, state) {
                          double horizontalPadding = 0;
                          return LoadingOverlay(
                            isLoading: state is SignupLoading,
                            child: Stack(
                              children: [
                              SafeArea(
                                child: SingleChildScrollView(
                                  keyboardDismissBehavior:
                                      ScrollViewKeyboardDismissBehavior.onDrag,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 24),
                                  child: AuthEntrance(child: Center(
                                      child: ConstrainedBox(
                                          constraints:
                                              BoxConstraints(maxWidth: 480),
                                          child: LayoutBuilder(
                                              builder: (context, constraints) =>
                                                  MediaQuery(
                                                      data: MediaQuery.of(
                                                              context)
                                                          .copyWith(
                                                              size: Size(
                                                                  constraints
                                                                      .maxWidth,
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height)),
                                                      child: AutofillGroup(
                                                          child: Form(
                                                        key: _formKey,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            CustomAppbar(
                                                              headingTxt: ''),
                                                            Center(
                                                                child: Image.asset(
                                                                    'assets/icons/tina-logo.png',
                                                                    width: 180,
                                                                    height: 160,
                                                                    fit: BoxFit
                                                                        .contain,
                                                                    color: Theme.of(context).brightness ==
                                                                            Brightness
                                                                                .dark
                                                                        ? Theme.of(context)
                                                                            .colorScheme
                                                                            .onSurface
                                                                        : null,
                                                                    semanticLabel:
                                                                        'Tina Moore')),
                                                            SizedBox(
                                                                height: 44),
                                                            Text(
                                                                'YOUR SPACE TO SLOW DOWN',
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        Fonts
                                                                            .body,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .onSurfaceVariant,
                                                                    fontSize:
                                                                        12,
                                                                    letterSpacing:
                                                                        2.2,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700)),
                                                            SizedBox(
                                                                height: 18),
                                                            Text(
                                                                'Create Your Free Account',
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        Fonts
                                                                            .heading,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .onSurface,
                                                                    fontSize:
                                                                        38,
                                                                    letterSpacing:
                                                                        -1.5,
                                                                    height: 1.2,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600)),
                                                            SizedBox(
                                                                height: 22),
                                                            Text(
                                                                'Make a little space for yourself.\nBegin your journey into presence.',
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        Fonts
                                                                            .body,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .onSurfaceVariant,
                                                                    fontSize:
                                                                        16,
                                                                    height:
                                                                        1.65)),
                                                            SizedBox(
                                                                height: 32),
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          horizontalPadding),
                                                              child: Text(
                                                                'Name (optional)',
                                                                style:
                                                                    TextStyle(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .onSurface,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 14,
                                                                  fontFamily:
                                                                      Fonts
                                                                          .body,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(height: 5),
                                                            Center(
                                                              child:
                                                                  AuthTextField(
                                                                label: Strings
                                                                    .enterYourName,
                                                                controller:
                                                                    _nameController,
                                                                keyboardType:
                                                                    TextInputType
                                                                        .name,
                                                                widthFactor: 1,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                height: 15),
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          horizontalPadding),
                                                              child: Text(
                                                                Strings
                                                                    .emailAddress,
                                                                style:
                                                                    TextStyle(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .onSurface,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 14,
                                                                  fontFamily:
                                                                      Fonts
                                                                          .body,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(height: 5),
                                                            Center(
                                                              child:
                                                                  AuthTextField(
                                                                label: Strings
                                                                    .enterYourEmailAddress,
                                                                controller:
                                                                    _emailController,
                                                                widthFactor: 1,
                                                                validator:
                                                                    (value) {
                                                                  if (value ==
                                                                          null ||
                                                                      value
                                                                          .trim()
                                                                          .isEmpty) {
                                                                    return 'Email is required';
                                                                  }
                                                                  String
                                                                      pattern =
                                                                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                                                                  RegExp regex =
                                                                      RegExp(
                                                                          pattern);

                                                                  if (!regex
                                                                      .hasMatch(
                                                                          value
                                                                              .trim())) {
                                                                    return 'Please enter a valid email address';
                                                                  }
                                                                  return null;
                                                                },
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                height: 15),
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          horizontalPadding),
                                                              child: Text(
                                                                Strings
                                                                    .password,
                                                                style:
                                                                    TextStyle(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .onSurface,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 14,
                                                                  fontFamily:
                                                                      Fonts
                                                                          .body,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(height: 5),
                                                            Center(
                                                              child:
                                                                  AuthTextField(
                                                                label: Strings
                                                                    .enterYourPassword,
                                                                obscureText:
                                                                    true,
                                                                widthFactor: 1,
                                                                controller:
                                                                    _passwordController,
                                                                validator:
                                                                    (value) {
                                                                  if (value ==
                                                                          null ||
                                                                      value
                                                                          .trim()
                                                                          .isEmpty) {
                                                                    return 'Password is required';
                                                                  } else if (value
                                                                          .trim()
                                                                          .length <
                                                                      6) {
                                                                    return 'Password must be at least 6 characters long';
                                                                  } else if (!_letterRegex
                                                                          .hasMatch(value
                                                                              .trim()) ||
                                                                      !_numberRegex
                                                                          .hasMatch(
                                                                              value.trim())) {
                                                                    return 'Password must contain at least one letter and one number';
                                                                  }
                                                                  return null;
                                                                },
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                height: 20),
                                                            Center(
                                                              child:
                                                                  AnimatedBuilder(
                                                                animation:
                                                                    Listenable.merge([
                                                                  _emailController,
                                                                  _passwordController,
                                                                ]),
                                                                builder: (context,
                                                                    child) {
                                                                  final canSubmit =
                                                                      _emailController
                                                                              .text
                                                                              .trim()
                                                                              .isNotEmpty &&
                                                                          _passwordController
                                                                              .text
                                                                              .trim()
                                                                              .isNotEmpty;

                                                                  return ButtonWidget(
                                                                    btnTxt:
                                                                        'Create free account',
                                                                    widthFactor:
                                                                        1,
                                                                    height: 60,
                                                                    isActive:
                                                                        canSubmit,
                                                                    onTap: () {
                                                                      FocusScope.of(
                                                                              context)
                                                                          .unfocus();

                                                                      if (_formKey
                                                                          .currentState!
                                                                          .validate()) {
                                                                        final signupData =
                                                                            {
                                                                          if (_nameController
                                                                              .text
                                                                              .trim()
                                                                              .isNotEmpty)
                                                                            'name': _nameController.text.trim(),
                                                                          'email': _emailController
                                                                              .text
                                                                              .trim(),
                                                                          'password':
                                                                              _passwordController.text,
                                                                        };

                                                                        context
                                                                            .read<SignupBloc>()
                                                                            .add(
                                                                              SignupSubmitted(
                                                                                name: signupData['name'],
                                                                                email: signupData['email']!,
                                                                                password: signupData['password']!,
                                                                              ),
                                                                            );
                                                                      }
                                                                    },
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                height: 20),
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child:
                                                                      Divider(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .onSurfaceVariant,
                                                                    thickness:
                                                                        1,
                                                                    indent: 20,
                                                                    endIndent:
                                                                        10,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  Strings
                                                                      .orSignUpWith,
                                                                  style:
                                                                      TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .onSurfaceVariant,
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontFamily:
                                                                        Fonts
                                                                            .body,
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child:
                                                                      Divider(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .onSurfaceVariant,
                                                                    thickness:
                                                                        1,
                                                                    endIndent:
                                                                        20,
                                                                    indent: 10,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                                height: 20),
                                                            Center(
                                                              child:
                                                                  SocialLoginButton(
                                                                'Continue with Google',
                                                                Image.asset(
                                                                    ImageConstants
                                                                        .googleIcon),
                                                                onPressed:
                                                                    () async {
                                                                  final userCredential =
                                                                      await signUpWithGoogle();

                                                                  if (userCredential ==
                                                                          null ||
                                                                      userCredential
                                                                              .user ==
                                                                          null) {
                                                                    return;
                                                                  }
                                                                  if (!context
                                                                      .mounted) {
                                                                    return;
                                                                  }

                                                                  final user =
                                                                      userCredential
                                                                          .user!;
                                                                  final isNewUser =
                                                                      userCredential
                                                                              .additionalUserInfo
                                                                              ?.isNewUser ??
                                                                          false;

                                                                  if (!isNewUser) {
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .showSnackBar(
                                                                      SnackBar(
                                                                        content:
                                                                            Text("Account already exists. Please sign in."),
                                                                        backgroundColor: Theme.of(context)
                                                                            .colorScheme
                                                                            .primary,
                                                                      ),
                                                                    );
                                                                    return;
                                                                  }

                                                                  context
                                                                      .read<
                                                                          SignupBloc>()
                                                                      .add(
                                                                        SocialSignupSubmitted(
                                                                          name: user.displayName ??
                                                                              '',
                                                                          email:
                                                                              user.email ?? '',
                                                                          socialId:
                                                                              user.uid,
                                                                          loginMedium:
                                                                              "google",
                                                                        ),
                                                                      );
                                                                },
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                height: 20),
                                                            if (Platform.isIOS)
                                                              Center(
                                                                child:
                                                                    SocialLoginButton(
                                                                  'Continue with Apple',
                                                                  Image.asset(
                                                                      ImageConstants
                                                                          .appleIcon,
                                                                      color: Theme.of(
                                                                              context)
                                                                          .colorScheme
                                                                          .onSurface),
                                                                  onPressed:
                                                                      () async {
                                                                    final userCredential =
                                                                        await signUpWithApple();

                                                                    if (userCredential ==
                                                                            null ||
                                                                        userCredential.user ==
                                                                            null) {
                                                                      return;
                                                                    }
                                                                    if (!context
                                                                        .mounted) {
                                                                      return;
                                                                    }

                                                                    final user =
                                                                        userCredential
                                                                            .user!;
                                                                    final isNewUser = userCredential
                                                                            .additionalUserInfo
                                                                            ?.isNewUser ??
                                                                        false;

                                                                    if (!isNewUser) {
                                                                      ScaffoldMessenger.of(
                                                                              context)
                                                                          .showSnackBar(
                                                                        SnackBar(
                                                                          content:
                                                                              Text("Account already exists. Please sign in."),
                                                                          backgroundColor: Theme.of(context)
                                                                              .colorScheme
                                                                              .primary,
                                                                        ),
                                                                      );
                                                                      return;
                                                                    }

                                                                    context
                                                                        .read<
                                                                            SignupBloc>()
                                                                        .add(
                                                                          SocialSignupSubmitted(
                                                                            name:
                                                                                user.displayName ?? '',
                                                                            email:
                                                                                user.email ?? '',
                                                                            socialId:
                                                                                user.uid,
                                                                            loginMedium:
                                                                                "apple",
                                                                          ),
                                                                        );
                                                                  },
                                                                ),
                                                              ),
                                                            SizedBox(
                                                                height: 20),
                                                            Center(
                                                                child: Wrap(
                                                              alignment:
                                                                  WrapAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  WrapCrossAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                    'Already have an account?',
                                                                    style: TextStyle(
                                                                        color: Theme.of(context)
                                                                            .colorScheme
                                                                            .onSurfaceVariant)),
                                                                TextButton(
                                                                  onPressed: () => Navigator.pushReplacement(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (_) =>
                                                                              SigninScreen())),
                                                                  child: Text(
                                                                      'Sign in'),
                                                                ),
                                                              ],
                                                            )),
                                                          ],
                                                        ),
                                                      ))))))),
                                ),
                              ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                )));
  }
}

Future<UserCredential?> signUpWithGoogle() async {
  try {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  } catch (e) {
    return null;
  }
}

Future<UserCredential?> signUpWithApple() async {
  try {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  } catch (e) {
    return null;
  }
}
