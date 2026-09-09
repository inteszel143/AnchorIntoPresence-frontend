import '../../common/widgets/button_widget.dart';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mindfully_evolve_app/common/main_screen.dart';
import 'package:mindfully_evolve_app/screens/feeling_category/feelingcategory_screen.dart';
import 'package:mindfully_evolve_app/screens/signin/signin_bloc/signin_state.dart';
import 'package:mindfully_evolve_app/screens/signup/signup_screen.dart';
import 'package:mindfully_evolve_app/utils/image_constants.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../common/local_storage.dart';

import '../../helping_widgets/sociallogin-button.dart';
import '../../common/widgets/auth_theme.dart';
import '../../common/widgets/auth_text_field.dart';
import '../../common/widgets/loading_overlay.dart';
import '../../utils/fonts.dart';
import '../../utils/string_constants.dart';
import '../forgot_password/forgot_password.dart';
import '../signup/signup_bloc/signup_bloc.dart';
import 'signin_bloc/signin_bloc.dart';
import 'signin_bloc/signin_event.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double horizontalPadding = 0;
    return AuthTheme(
        child: BlocProvider(
      create: (context) => SigninBloc(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: LoadingOverlay(
              isLoading: context.watch<SigninBloc>().state is SigninLoading,
              child: BlocListener<SigninBloc, SigninState>(
                  listener: (context, state) {
                    if (state is SigninSuccess) {
                      final isFirst = state.isFirst;
                      WidgetsBinding.instance.addPostFrameCallback((_) async {
                        final categorySelected =
                            await LocalStorage.getCategorySelected();
                        if (!context.mounted) {
                          return;
                        }
                        if ((isFirst ?? false) || !categorySelected) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => CategoryScreen()),
                            (route) => false,
                          );
                        } else {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => MainScreen(initialIndex: 0)),
                            (route) => false,
                          );
                        }
                      });
                    } else if (state is SocialSigninSuccess) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => MainScreen(
                                    initialIndex: 0,
                                  )),
                          (route) => false,
                        );
                      });
                    } else if (state is SigninFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.errorMessage.toString()),
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                      );
                    }
                  },
                  child: SafeArea(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                      child: Center(
                          child: ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 480),
                              child: LayoutBuilder(
                                  builder: (context, constraints) => MediaQuery(
                                      data: MediaQuery.of(context).copyWith(
                                          size: Size(
                                              constraints.maxWidth,
                                              MediaQuery.of(context)
                                                  .size
                                                  .height)),
                                      child: Form(
                                        key: _formKey,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Center(
                                              child: Image.asset(
                                                  'assets/icons/tina-logo.png',
                                                  color: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.dark
                                                      ? Theme.of(context)
                                                          .colorScheme
                                                          .onSurface
                                                      : null,
                                                  width: 180,
                                                  height: 160,
                                                  fit: BoxFit.contain,
                                                  semanticLabel: 'Tina Moore'),
                                            ),
                                            SizedBox(height: 44),
                                            Text('YOUR SPACE TO SLOW DOWN',
                                                style: TextStyle(
                                                    fontFamily: Fonts.body,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                    fontSize: 12,
                                                    letterSpacing: 2.2,
                                                    fontWeight:
                                                        FontWeight.w700)),
                                            SizedBox(height: 18),
                                            Text('Welcome back.',
                                                style: TextStyle(
                                                    fontFamily: Fonts.heading,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface,
                                                    fontSize: 38,
                                                    letterSpacing: -1.5,
                                                    height: 1.2,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                            SizedBox(height: 22),
                                            Text(
                                                'A moment to reconnect with yourself.\nSign in to continue your journey.',
                                                style: TextStyle(
                                                    fontFamily: Fonts.body,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                    fontSize: 16,
                                                    height: 1.65)),
                                            SizedBox(height: 32),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal:
                                                      horizontalPadding),
                                              child: Text(
                                                Strings.emailAddress,
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                  fontFamily: Fonts.body,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Center(
                                              child: AuthTextField(
                                                label: Strings
                                                    .enterYourEmailAddress,
                                                controller: _emailController,
                                                widthFactor: 1,
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.trim().isEmpty) {
                                                    return 'Email is required';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                            SizedBox(height: 20),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal:
                                                      horizontalPadding),
                                              child: Text(
                                                Strings.password,
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                  fontFamily: Fonts.body,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Center(
                                              child: AuthTextField(
                                                label:
                                                    Strings.enterYourPassword,
                                                controller: _passwordController,
                                                widthFactor: 1,
                                                obscureText: true,
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.trim().isEmpty) {
                                                    return 'Password is required';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: TextButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ForgotPassword()),
                                                  );
                                                },
                                                child: Text(
                                                  Strings
                                                      .forgotPasswordquestion,
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily: Fonts.body,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Center(
                                              child: AnimatedBuilder(
                                                animation: Listenable.merge([
                                                  _emailController,
                                                  _passwordController,
                                                ]),
                                                builder: (context, child) {
                                                  final bothFieldsFilled =
                                                      _emailController.text
                                                              .trim()
                                                              .isNotEmpty &&
                                                          _passwordController
                                                              .text
                                                              .trim()
                                                              .isNotEmpty;
                                                  return ButtonWidget(
                                                    btnTxt: 'Sign in',
                                                    widthFactor: 1,
                                                    height: 60,
                                                    isActive: bothFieldsFilled,
                                                    onTap: () {
                                                      FocusScope.of(context)
                                                          .unfocus();
                                                      if (_formKey.currentState!
                                                          .validate()) {
                                                        context
                                                            .read<SigninBloc>()
                                                            .add(
                                                                SigninSubmitted(
                                                              email:
                                                                  _emailController
                                                                      .text
                                                                      .trim(),
                                                              password:
                                                                  _passwordController
                                                                      .text
                                                                      .trim(),
                                                            ));
                                                      }
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                            SizedBox(height: 24),
                                            Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Icon(
                                                      Icons
                                                          .lock_outline_rounded,
                                                      size: 20,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurfaceVariant),
                                                  SizedBox(width: 12),
                                                  Expanded(
                                                      child: Text(
                                                          'Your personal space for presence.\nPick up where you left off.',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  Fonts.body,
                                                              fontSize: 13,
                                                              height: 1.7,
                                                              color: Color(
                                                                  0xFF80796F)))),
                                                ]),
                                            SizedBox(height: 28),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Divider(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                    thickness: 1,
                                                    indent: 20,
                                                    endIndent: 10,
                                                  ),
                                                ),
                                                Text(
                                                  Strings.orSignInWith,
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily: Fonts.body,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Divider(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                    thickness: 1,
                                                    endIndent: 20,
                                                    indent: 10,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 20),
                                            Center(
                                              child: SocialLoginButton(
                                                'Continue with Google',
                                                Image.asset(
                                                    ImageConstants.googleIcon),
                                                onPressed: () async {
                                                  final userCredential =
                                                      await signInWithGoogle(); // Await the sign-in

                                                  // Check if the userCredential is not null and the user is valid
                                                  if (userCredential != null &&
                                                      userCredential.user !=
                                                          null) {
                                                    final email = userCredential
                                                            .user?.email ??
                                                        ''; // Safe null check
                                                    final uid = userCredential
                                                            .user?.uid ??
                                                        ''; // Safe null check
                                                    final fcmToken =
                                                        await LocalStorage
                                                                .getFCMToken() ??
                                                            '';

                                                    if (!context.mounted) {
                                                      return;
                                                    }
                                                    context
                                                        .read<SigninBloc>()
                                                        .add(
                                                          SocialSigninSubmitted(
                                                            loginMedium:
                                                                "google",
                                                            email: email,
                                                            socialId: uid,
                                                            fcmToken: fcmToken,
                                                          ),
                                                        );
                                                  }
                                                },
                                              ),
                                            ),
                                            SizedBox(height: 20),
                                            if (Platform.isIOS)
                                              Center(
                                                child: SocialLoginButton(
                                                  'Continue with Apple',
                                                  Image.asset(
                                                      ImageConstants.appleIcon,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurface),
                                                  onPressed: () async {
                                                    final userCredential =
                                                        await signUpWithApple();

                                                    if (userCredential ==
                                                            null ||
                                                        userCredential.user ==
                                                            null) {
                                                      return;
                                                    }

                                                    final user =
                                                        userCredential.user!;
                                                    final fcmToken =
                                                        await LocalStorage
                                                            .getFCMToken();

                                                    if (!context.mounted) {
                                                      return;
                                                    }
                                                    context
                                                        .read<SigninBloc>()
                                                        .add(
                                                          SocialSigninSubmitted(
                                                            loginMedium:
                                                                "google",
                                                            email: user.email ??
                                                                '',
                                                            socialId: user.uid,
                                                            fcmToken:
                                                                fcmToken ?? '',
                                                          ),
                                                        );
                                                  },
                                                ),
                                              ),
                                            SizedBox(height: 20),
                                            Center(
                                                child: Wrap(
                                              alignment: WrapAlignment.center,
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.center,
                                              children: [
                                                Text('New here?',
                                                    style: TextStyle(
                                                        fontFamily: Fonts.body,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurfaceVariant)),
                                                TextButton(
                                                  onPressed: () => Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (_) => BlocProvider(
                                                              create: (_) =>
                                                                  SignupBloc(),
                                                              child:
                                                                  SignupScreen()))),
                                                  child: Text(
                                                      'Create an account',
                                                      style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                          fontWeight:
                                                              FontWeight.w700)),
                                                ),
                                              ],
                                            )),
                                          ],
                                        ),
                                      ))))),
                    ),
                  ),
                ),
            ),
          );
        },
      ),
    ));
  }
}

Future<UserCredential?> signInWithGoogle() async {
  try {
    // Create an instance of GoogleSignIn
    final GoogleSignIn googleSignIn = GoogleSignIn();

    // Start the Google sign-in process
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      // The user canceled the sign-in, return null
      return null;
    }

    // Obtain authentication details from the sign-in
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a credential for Firebase Authentication
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase with the credential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  } catch (e) {
    // Handle errors (e.g., network errors, invalid credentials)
    return null;
  }
}

Future<UserCredential?> signInWithApple() async {
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
    return null; // Handle error gracefully
  }
}
