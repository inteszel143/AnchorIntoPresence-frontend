import '../../../common/auth/social_login_exception.dart';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindfully_evolve_app/utils/api_service.dart';

import '../../../common/local_storage.dart';
import '../../../utils/global.dart' as globals;
import '../../../utils/fcm_service.dart';
import 'signin_event.dart';
import 'signin_state.dart';

class SigninBloc extends Bloc<SigninEvent, SigninState> {
  SigninBloc() : super(SigninInitial()) {
    on<SigninSubmitted>(_onSigninSubmitted);
    on<SocialSigninSubmitted>(_onSocialSigninSubmitted);
  }

  Future<void> _onSigninSubmitted(
      SigninSubmitted event, Emitter<SigninState> emit) async {
    emit(SigninLoading());

    try {
      final fcmToken = await getFCMTokenForSignin();
      final data = await ApiService.login(
        email: event.email,
        password: event.password,
        fcmToken: fcmToken,
      );
      await LocalStorage.saveToken(data.token);
      if (data.data?.email != null) {
        final userProfileFuture = ApiService.fetchProfileData(data.token);
        final results = await Future.wait([userProfileFuture]);
        final profileData = results[0];
        globals.alreadyPurchasedProductId = profileData.productId ?? '';
        globals.isSubscribed = profileData.subscriptionStatus == 'active';
        await LocalStorage.clearPurchase();
        await LocalStorage.deleteBool();
        emit(SigninSuccess(
          data.token,
          data.data?.name,
          data.data?.image,
          data.isFirst,
        ));
      } else {
        emit(SigninFailure(
            data.message.isNotEmpty ? data.message : 'Login failed'));
      }
    } on SocketException {
      emit(SigninFailure('Please check your internet connection'));
    } catch (e) {
      emit(SigninFailure('Please check your internet connection'));
    }
  }

  Future<void> _onSocialSigninSubmitted(
      SocialSigninSubmitted event, Emitter<SigninState> emit) async {
    emit(SigninLoading());
    var stage = 'pushToken';
    try {
      final fcmToken = await getFCMTokenForSignin();
      stage = 'backend.socialLogin';
      final data = await ApiService.socialLogin(
        email: event.email,
        socialId: event.socialId,
        loginMedium: event.loginMedium,
        fcmToken: fcmToken,
      );

      if (data.data?.email?.isNotEmpty == true && data.token.isNotEmpty) {
        stage = 'profile.load';
        final userProfileFuture = ApiService.fetchProfileData(data.token);
        final results = await Future.wait([userProfileFuture]);
        final profileData = results[0];
        stage = 'session.save';
        await LocalStorage.saveToken(data.token);
        globals.alreadyPurchasedProductId = profileData.productId ?? '';
        globals.isSubscribed = profileData.subscriptionStatus == 'active';
        emit(SocialSigninSuccess(
          data.token,
          data.data?.name,
          data.data?.image,
        ));
      } else {
        emit(SigninFailure(data.message.isNotEmpty
            ? data.message
            : 'Google sign-in could not complete. Please try again.'));
      }
    } on SocialLoginException catch (error) {
      emit(SigninFailure(error.message));
    } catch (error) {
      emit(SigninFailure(switch (stage) {
        'profile.load' =>
          'Signed in with Google, but your profile could not load. Please try again.',
        'session.save' =>
          'Unable to save your sign-in on this device. Please try again.',
        _ => 'Sign-in could not complete. Please try again.',
      }));
    }
  }
}
